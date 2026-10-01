part of 'tim2tox_identity_service.dart';

extension _IdentityProfile on Tim2ToxIdentityService {
  Future<Identity> _create(String displayName, String? password) async {
    if (_paths.profileExists) {
      throw const ChatException(
        'identity_exists',
        'An identity already exists',
      );
    }
    final name = displayName.trim();
    if (name.isEmpty) {
      throw const ChatException('invalid_name', 'Display name is empty');
    }
    String? createdId;
    try {
      await _paths.ensureDirectories();
      final toxId = await _engine.createProfile(
        paths: _paths,
        displayName: name,
        statusMessage: '',
      );
      createdId = toxId;
      final protected = password != null && password.isNotEmpty;
      final record = IdentityRecord(
        toxId: toxId,
        displayName: name,
        hasPassword: protected,
      );
      if (protected) {
        final file = File(_paths.profileFile);
        final encrypted = _crypto.encrypt(await file.readAsBytes(), password);
        await _verifier.replacePassword(toxId, password, () async {
          await writeBytesAtomic(file, encrypted);
          await record.write(_paths.identityFile);
        });
      } else {
        await record.write(_paths.identityFile);
      }
      _sessionPassword = protected ? password : null;
      _publish(record);
      _logger.info('[Identity] created ${toxId.substring(0, 8)}…');
      return record.toIdentity();
    } catch (_) {
      try {
        if (createdId != null) await _verifier.removePassword(createdId);
      } finally {
        await _paths.deleteAll();
      }
      rethrow;
    }
  }

  Future<void> _changePassword(String? oldPassword, String? newPassword) async {
    final record = _requireRecord();
    if (await _verifier.hasPassword(record.toxId) &&
        (oldPassword == null ||
            !await _verifier.verify(record.toxId, oldPassword))) {
      throw const ChatException('wrong_password', 'Incorrect password');
    }
    final setting = newPassword != null && newPassword.isNotEmpty;
    final updated = record.copyWith(hasPassword: setting);
    final file = File(_paths.profileFile);
    final before = await file.readAsBytes();
    Uint8List? replacement;
    if (!_started) {
      final plain = _crypto.isEncrypted(before)
          ? _crypto.decrypt(before, oldPassword ?? _sessionPassword ?? '')
          : before;
      // Derive before touching either durable store. An encryption error
      // leaves the previous ciphertext and verifier untouched.
      replacement = setting ? _crypto.encrypt(plain, newPassword) : plain;
    }
    Future<void> commitFiles() async {
      try {
        if (replacement != null) await writeBytesAtomic(file, replacement);
        await updated.write(_paths.identityFile);
      } catch (_) {
        if (replacement != null) await writeBytesAtomic(file, before);
        rethrow;
      }
    }

    if (setting) {
      await _verifier.replacePassword(record.toxId, newPassword, commitFiles);
    } else {
      // Leave the old verifier in place until BOTH files describe the
      // unprotected profile. A process exit during removal can still unlock
      // with the old password; it never leaves hasPassword without a verifier.
      try {
        await commitFiles();
        await _verifier.replacePassword(record.toxId, null, () async {});
      } catch (_) {
        if (replacement != null) await writeBytesAtomic(file, before);
        await record.write(_paths.identityFile);
        rethrow;
      }
    }
    _sessionPassword = setting ? newPassword : null;
    _publish(updated);
  }

  Future<Identity> _updateProfile(String? name, String? status) async {
    final record = _requireRecord();
    final updated = record.copyWith(
      displayName: name?.trim().isEmpty ?? true ? null : name!.trim(),
      statusMessage: status,
    );
    await updated.write(_paths.identityFile);
    // The durable mirror is authoritative on the next connect, even when a
    // live native update fails after the file commit.
    _publish(updated);
    await _engine.updateSelfProfile(updated.displayName, updated.statusMessage);
    return updated.toIdentity();
  }
}
