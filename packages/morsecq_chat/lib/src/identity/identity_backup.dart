part of 'tim2tox_identity_service.dart';

extension _IdentityBackup on Tim2ToxIdentityService {
  Future<Uint8List> _exportBackup({bool includeMedia = false}) async {
    final record = _requireRecord();
    await _persist();
    var profile = await File(_paths.profileFile).readAsBytes();
    final password = _sessionPassword;
    var encrypted = _crypto.isEncrypted(profile);
    if (!encrypted && password != null && password.isNotEmpty) {
      profile = _crypto.encrypt(profile, password);
      encrypted = true;
    }
    final entries = <String, Uint8List>{
      BackupContainer.identityEntry: record.encode(),
      BackupContainer.profileEntry: profile,
    };
    final training = Directory(_paths.trainingDirectory);
    if (await training.exists()) {
      final files =
          training
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
      for (final file in files) {
        final rel = p.url.joinAll(
          p.split(p.relative(file.path, from: training.path)),
        );
        entries['${BackupContainer.trainingPrefix}$rel'] = await file
            .readAsBytes();
      }
    }
    if (includeMedia) {
      // Opt-in only: saved recordings beside (not inside) the training tree.
      final media = Directory(p.join(_paths.root, 'media', 'recordings'));
      if (await media.exists()) {
        final files =
            media.listSync(followLinks: false).whereType<File>().toList()
              ..sort((a, b) => a.path.compareTo(b.path));
        for (final file in files) {
          entries['${BackupContainer.mediaPrefix}${p.basename(file.path)}'] =
              await file.readAsBytes();
        }
      }
    }
    return BackupContainer(
      entries: entries,
      profileEncrypted: encrypted,
    ).encode();
  }

  Future<Identity> _importBackup(Uint8List bytes, String? password) async {
    final backup = BackupContainer.decode(bytes);
    final profile = backup.profile;
    if (profile == null || profile.isEmpty) {
      throw const ChatException('invalid_backup', 'Backup has no Tox profile');
    }
    final encrypted = _crypto.isEncrypted(profile);
    if (encrypted && (password == null || password.isEmpty)) {
      throw const ChatException(
        'wrong_password',
        'This backup is password protected',
      );
    }
    final plain = encrypted ? _crypto.decrypt(profile, password!) : profile;
    final key = _crypto.extractPublicKey(plain);
    final stored = backup.identity == null
        ? null
        : IdentityRecord.decode(backup.identity!);
    if (stored != null && !stored.toxId.toUpperCase().startsWith(key)) {
      throw const ChatException(
        'invalid_backup',
        'Identity does not match the Tox profile',
      );
    }
    final record =
        (stored ?? IdentityRecord(toxId: key, displayName: 'morsecq')).copyWith(
          hasPassword: encrypted,
        );
    final root = Directory(_paths.root);
    // Also creates root.parent; the staged tree below must not land in a
    // directory iOS would back up.
    await _paths.excludeFromBackup();
    final stage = await root.parent.createTemp('.morsecq-import-');
    final previous = Directory(p.join(stage.path, 'previous'));
    final staged = IdentityPaths(p.join(stage.path, 'identity'));
    var replaced = false;
    final old = _record ?? await IdentityRecord.read(_paths.identityFile);
    final oldPassword = _sessionPassword;
    try {
      // Finish every archive write before touching the existing account.
      await staged.ensureDirectories();
      await File(staged.profileFile).writeAsBytes(profile, flush: true);
      await record.write(staged.identityFile);
      for (final entry in backup.trainingFiles) {
        final rel = entry.key.substring(BackupContainer.trainingPrefix.length);
        final target = File(
          p.join(staged.trainingDirectory, p.joinAll(rel.split('/'))),
        );
        await target.parent.create(recursive: true);
        await target.writeAsBytes(entry.value, flush: true);
      }
      for (final entry in backup.mediaFiles) {
        final name = entry.key.substring(BackupContainer.mediaPrefix.length);
        final target = File(p.join(staged.root, 'media', 'recordings', name));
        await target.parent.create(recursive: true);
        await target.writeAsBytes(entry.value, flush: true);
      }
      await _prepareForReplacement();
      await _disconnectImpl();
      await _verifier.replacePassword(
        record.toxId,
        encrypted ? password : null,
        () async {
          if (await root.exists()) await root.rename(previous.path);
          try {
            await Directory(staged.root).rename(root.path);
            replaced = true;
          } catch (_) {
            if (await previous.exists()) await previous.rename(root.path);
            rethrow;
          }
        },
      );
      _forgetIdentity();
      _sessionPassword = encrypted ? password : null;
      _publish(record);
      if (old != null) {
        if (old.toxId != record.toxId) {
          await _verifier.removePassword(old.toxId);
        }
        await _clearPreferences(old.toxId);
      }
      await _clearPreferences(record.toxId);
    } catch (_) {
      if (!replaced && old != null) {
        _sessionPassword = oldPassword;
        _publish(old);
      }
      rethrow;
    } finally {
      // If both the replacement rename and rollback fail, retain the old
      // tree in `previous` for recovery instead of deleting the only copy.
      if (replaced || !await previous.exists()) {
        await stage.delete(recursive: true);
      }
    }
    return record.toIdentity();
  }
}
