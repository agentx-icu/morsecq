import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:path/path.dart' as p;

import '../engine/chat_engine.dart';
import '../logging/chat_logger.dart';
import '../util/value_stream.dart';
import 'backup_container.dart';
import 'identity_paths.dart';
import 'identity_record.dart';
import 'password_verifier.dart';
import 'profile_crypto.dart';

/// [IdentityService] over Tim2Tox. States: `none` (no `tox_profile.tox`),
/// `locked` (the verifier holds a password or the file is encrypted, and this
/// process has not unlocked it), `ready` (plain, or unlocked this run).
///
/// Encryption at rest mirrors toxee's `AccountService` teardown: with a
/// password set the profile is encrypted whenever the engine is STOPPED and
/// plaintext while it RUNS (Tox rewrites it as it runs). [connect] decrypts
/// right before `init`, [disconnect] re-encrypts right after `uninit`; the
/// session password lives in memory only. The PBKDF2 verifier in the secure
/// store is the authority on "has a password"; the Tox-level decrypt is the
/// second check and the fallback for an imported, verifier-less profile.
class Tim2ToxIdentityService implements IdentityService {
  Tim2ToxIdentityService({
    required IdentityPaths paths,
    required ChatEngine engine,
    required ProfileCrypto crypto,
    required PasswordVerifier verifier,
    ChatLogger logger = const SilentChatLogger(),
  })  : _paths = paths,
        _engine = engine,
        _crypto = crypto,
        _verifier = verifier,
        _logger = logger {
    _connSub = _engine.connectionChanges.listen(_onEngineConnection);
  }

  final IdentityPaths _paths;
  final ChatEngine _engine;
  final ProfileCrypto _crypto;
  final PasswordVerifier _verifier;
  final ChatLogger _logger;

  final ValueStream<Identity?> _identity = ValueStream(null);
  final ValueStream<ConnectionStatus> _status =
      ValueStream(ConnectionStatus.offline);
  StreamSubscription<bool>? _connSub;

  IdentityRecord? _record;
  String? _sessionPassword;
  bool _connecting = false;
  // Started by [connect], not yet stopped. Tracked here, not inferred from
  // `engine.service`, so encrypt-at-rest never depends on the engine's shape.
  bool _started = false;
  Future<void>? _connectFuture;

  /// Exposed for the backend / diagnostics.
  IdentityPaths get paths => _paths;

  @override
  Identity? get current => _identity.value;

  @override
  Stream<Identity?> get identityChanges => _identity.stream;

  @override
  ConnectionStatus get connectionStatus => _status.value;

  @override
  Stream<ConnectionStatus> get connectionChanges => _status.stream;

  void _onEngineConnection(bool online) {
    if (online) {
      _status.add(ConnectionStatus.online);
    } else if (_started || _connecting) {
      _status.add(ConnectionStatus.connecting);
    } else {
      _status.add(ConnectionStatus.offline);
    }
  }

  void _publish(IdentityRecord record) {
    _record = record;
    _identity.force(record.toIdentity());
  }

  // ---- inspect / open / unlock / create ------------------------------------

  @override
  Future<IdentityState> inspect() async {
    if (!_paths.profileExists) return IdentityState.none;
    if (_record != null) return IdentityState.ready;
    final record = await IdentityRecord.read(_paths.identityFile);
    final encrypted = await _profileIsEncrypted();
    if (record == null) {
      // Profile without identity.json (foreign / half-imported file).
      return encrypted ? IdentityState.locked : IdentityState.ready;
    }
    final hasPassword =
        record.hasPassword || await _verifier.hasPassword(record.toxId);
    return hasPassword || encrypted ? IdentityState.locked : IdentityState.ready;
  }

  @override
  Future<Identity> open() async {
    if (_record != null) return _record!.toIdentity();
    if (!_paths.profileExists) {
      throw const ChatException('no_identity', 'No identity on disk');
    }
    if (await inspect() == IdentityState.locked) {
      throw const ChatException('locked', 'Identity requires a password');
    }
    final record = await _loadOrRecoverRecord(password: null);
    _publish(record);
    return record.toIdentity();
  }

  @override
  Future<Identity> unlock(String password) async {
    if (_record != null) return _record!.toIdentity();
    if (!_paths.profileExists) {
      throw const ChatException('no_identity', 'No identity on disk');
    }
    if (password.isEmpty) {
      throw const ChatException('wrong_password', 'Password required');
    }
    final stored = await IdentityRecord.read(_paths.identityFile);
    final bytes = await File(_paths.profileFile).readAsBytes();
    final encrypted = _crypto.isEncrypted(bytes);
    if (stored != null && await _verifier.hasPassword(stored.toxId)) {
      if (!await _verifier.verify(stored.toxId, password)) {
        throw const ChatException('wrong_password', 'Incorrect password');
      }
      if (encrypted) _crypto.decrypt(bytes, password); // second factor
    } else if (encrypted) {
      _crypto.decrypt(bytes, password); // throws wrong_password
    } else {
      throw const ChatException('not_locked', 'Identity has no password');
    }
    _sessionPassword = password;
    var record = stored ?? await _loadOrRecoverRecord(password: password);
    if (!await _verifier.hasPassword(record.toxId)) {
      // Encrypted profile that arrived without a verifier (import / restore).
      await _verifier.setPassword(record.toxId, password);
    }
    if (!record.hasPassword) {
      record = record.copyWith(hasPassword: true);
      await record.write(_paths.identityFile);
    }
    _publish(record);
    return record.toIdentity();
  }

  @override
  Future<Identity> create({
    required String displayName,
    String? password,
  }) async {
    if (_paths.profileExists) {
      throw const ChatException(
        'identity_exists',
        'An identity already exists; delete it before creating another',
      );
    }
    final name = displayName.trim();
    if (name.isEmpty) {
      throw const ChatException('invalid_name', 'Display name is empty');
    }
    await _paths.ensureDirectories();
    final toxId = await _engine.createProfile(
      paths: _paths,
      displayName: name,
      statusMessage: '',
    );
    final hasPassword = password != null && password.isNotEmpty;
    final record = IdentityRecord(
      toxId: toxId,
      displayName: name,
      hasPassword: hasPassword,
    );
    await record.write(_paths.identityFile);
    if (hasPassword) {
      await _verifier.setPassword(toxId, password);
      _sessionPassword = password;
      await _encryptProfileAtRest();
    }
    _publish(record);
    _logger.info('[Identity] created ${toxId.substring(0, 8)}…');
    return record.toIdentity();
  }

  /// identity.json, or one rebuilt from the profile's public key when the
  /// JSON is missing (an import that copied only the `.tox`).
  Future<IdentityRecord> _loadOrRecoverRecord({String? password}) async {
    final stored = await IdentityRecord.read(_paths.identityFile);
    if (stored != null) return stored;
    var bytes = await File(_paths.profileFile).readAsBytes();
    if (_crypto.isEncrypted(bytes)) {
      if (password == null) {
        throw const ChatException('locked', 'Identity requires a password');
      }
      bytes = _crypto.decrypt(bytes, password);
    }
    final record = IdentityRecord(
      toxId: _crypto.extractPublicKey(bytes),
      displayName: 'morsecq',
      hasPassword: password != null,
    );
    await record.write(_paths.identityFile);
    return record;
  }

  // ---- password / profile ---------------------------------------------------

  @override
  Future<void> changePassword({
    String? oldPassword,
    String? newPassword,
  }) async {
    final record = _requireRecord();
    final hasOld = await _verifier.hasPassword(record.toxId);
    if (hasOld) {
      if (oldPassword == null ||
          !await _verifier.verify(record.toxId, oldPassword)) {
        throw const ChatException('wrong_password', 'Incorrect password');
      }
    }
    final setting = newPassword != null && newPassword.isNotEmpty;
    // Order: never leave the profile encrypted under a password the verifier
    // does not hold.
    if (setting) {
      await _verifier.setPassword(record.toxId, newPassword);
      _sessionPassword = newPassword;
    } else {
      await _decryptProfileAtRest(oldPassword);
      await _verifier.removePassword(record.toxId);
      _sessionPassword = null;
    }
    if (setting && !_started) {
      await _decryptProfileAtRest(oldPassword);
      await _encryptProfileAtRest();
    }
    final updated = record.copyWith(hasPassword: setting);
    await updated.write(_paths.identityFile);
    _publish(updated);
  }

  @override
  Future<Identity> updateProfile({
    String? displayName,
    String? statusMessage,
  }) async {
    final record = _requireRecord();
    final updated = record.copyWith(
      displayName: displayName?.trim().isEmpty ?? true
          ? null
          : displayName!.trim(),
      statusMessage: statusMessage,
    );
    await updated.write(_paths.identityFile);
    await _engine.updateSelfProfile(
      updated.displayName,
      updated.statusMessage,
    );
    _publish(updated);
    return updated.toIdentity();
  }

  // ---- backup ---------------------------------------------------------------

  @override
  Future<Uint8List> exportBackup() async {
    final record = _requireRecord();
    _engine.saveProfileNow();
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
      final files = training
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      for (final f in files) {
        final rel = p.url.joinAll(p.split(p.relative(f.path, from: training.path)));
        entries['${BackupContainer.trainingPrefix}$rel'] = await f.readAsBytes();
      }
    }
    return BackupContainer(entries: entries, profileEncrypted: encrypted)
        .encode();
  }

  @override
  Future<Identity> importBackup(Uint8List bytes, {String? password}) async {
    final backup = BackupContainer.decode(bytes);
    final profile = backup.profile;
    if (profile == null || profile.isEmpty) {
      throw const ChatException('invalid_backup', 'Backup has no Tox profile');
    }
    final encrypted = _crypto.isEncrypted(profile);
    Uint8List plain = profile;
    if (encrypted) {
      if (password == null || password.isEmpty) {
        throw const ChatException(
          'wrong_password',
          'This backup is password protected',
        );
      }
      plain = _crypto.decrypt(profile, password); // throws wrong_password
    }
    final publicKey = _crypto.extractPublicKey(plain);
    final stored =
        backup.identity == null ? null : IdentityRecord.decode(backup.identity!);
    if (stored != null && !stored.toxId.toUpperCase().startsWith(publicKey)) {
      throw const ChatException(
        'invalid_backup',
        'identity.json does not match the Tox profile in the backup',
      );
    }
    final hasPassword = encrypted;
    final record = (stored ??
            IdentityRecord(toxId: publicKey, displayName: 'morsecq'))
        .copyWith(hasPassword: hasPassword);

    // Stop networking first so Tox cannot rewrite the old savedata over the
    // restored one.
    await disconnect();
    final old = _record;
    if (old != null) await _verifier.removePassword(old.toxId);
    await _paths.deleteAll();
    await _paths.ensureDirectories();
    await File(_paths.profileFile).writeAsBytes(profile, flush: true);
    await record.write(_paths.identityFile);
    for (final entry in backup.trainingFiles) {
      final rel = entry.key.substring(BackupContainer.trainingPrefix.length);
      final target = File(p.join(_paths.trainingDirectory, p.joinAll(rel.split('/'))));
      await target.parent.create(recursive: true);
      await target.writeAsBytes(entry.value, flush: true);
    }
    if (hasPassword) {
      await _verifier.setPassword(record.toxId, password!);
      _sessionPassword = password;
    } else {
      _sessionPassword = null;
    }
    _publish(record);
    return record.toIdentity();
  }

  // ---- connect / disconnect / delete ----------------------------------------

  @override
  Future<void> connect() {
    final inFlight = _connectFuture;
    if (inFlight != null) return inFlight;
    if (_started) return Future<void>.value();
    return _connectFuture = _connectImpl().whenComplete(() {
      _connectFuture = null;
    });
  }

  Future<void> _connectImpl() async {
    final record = _requireRecord();
    _connecting = true;
    _status.add(ConnectionStatus.connecting);
    try {
      await _decryptProfileAtRest(_sessionPassword);
      await _engine.start(
        EngineSessionConfig(
          paths: _paths,
          toxId: record.toxId,
          displayName: record.displayName,
          statusMessage: record.statusMessage,
        ),
      );
    } catch (e) {
      _connecting = false;
      _status.add(ConnectionStatus.offline);
      // Never leave a plaintext profile behind after a failed start.
      await _encryptProfileAtRest();
      if (e is ChatException) rethrow;
      throw ChatException('connect_failed', 'Could not start Tox: $e');
    }
    _connecting = false;
    _started = true;
    _onEngineConnection(_engine.isConnected);
  }

  @override
  Future<void> disconnect() async {
    await _connectFuture;
    if (!_started) return;
    _started = false;
    await _engine.stop();
    _status.add(ConnectionStatus.offline);
    await _encryptProfileAtRest();
  }

  @override
  Future<void> deleteIdentity() async {
    await disconnect();
    final record = _record ?? await IdentityRecord.read(_paths.identityFile);
    if (record != null) await _verifier.removePassword(record.toxId);
    await _paths.deleteAll();
    _record = null;
    _sessionPassword = null;
    _identity.force(null);
    _status.add(ConnectionStatus.offline);
  }

  @override
  Future<String> dataDirectory() async {
    _requireRecord();
    await Directory(_paths.trainingDirectory).create(recursive: true);
    return _paths.trainingDirectory;
  }

  Future<void> dispose() async {
    final cancelled = _connSub?.cancel();
    _connSub = null;
    await Future.wait([?cancelled, _identity.close(), _status.close()]);
  }

  // ---- helpers ----------------------------------------------------------------

  IdentityRecord _requireRecord() {
    final r = _record;
    if (r == null) {
      throw const ChatException(
        'no_identity',
        'No identity is open (create, open or unlock first)',
      );
    }
    return r;
  }

  Future<bool> _profileIsEncrypted() async {
    final file = File(_paths.profileFile);
    if (!await file.exists()) return false;
    try {
      return _crypto.isEncrypted(await file.readAsBytes());
    } catch (e, st) {
      _logger.error('[Identity] could not probe profile encryption', e, st);
      return false;
    }
  }

  /// Encrypts `tox_profile.tox` in place when a session password is held and
  /// the file is plaintext. No-op otherwise. Atomic rename.
  Future<void> _encryptProfileAtRest() async {
    final password = _sessionPassword;
    if (password == null || password.isEmpty) return;
    final file = File(_paths.profileFile);
    if (!await file.exists()) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || _crypto.isEncrypted(bytes)) return;
    await _writeAtomic(file, _crypto.encrypt(bytes, password));
  }

  /// Decrypts `tox_profile.tox` in place when it is encrypted. Throws
  /// `wrong_password` when no usable password is available.
  Future<void> _decryptProfileAtRest(String? password) async {
    final file = File(_paths.profileFile);
    if (!await file.exists()) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || !_crypto.isEncrypted(bytes)) return;
    if (password == null || password.isEmpty) {
      throw const ChatException(
        'wrong_password',
        'Profile is encrypted and no password is available',
      );
    }
    await _writeAtomic(file, _crypto.decrypt(bytes, password));
  }

  static Future<void> _writeAtomic(File target, Uint8List bytes) async {
    final stage = File('${target.path}.new');
    try {
      await stage.writeAsBytes(bytes, flush: true);
      await stage.rename(target.path);
    } catch (_) {
      if (await stage.exists()) await stage.delete();
      rethrow;
    }
  }
}
