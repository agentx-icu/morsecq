import 'dart:typed_data';

import 'models.dart';

/// Identity lifecycle. Training also requires an identity (product decision
/// 2026-09-30), so the startup gate calls [inspect] before showing anything.
///
/// Sequence on first run: `inspect() == none` → `create(...)` → identity is
/// [IdentityState.ready] → `connect()`.
/// Sequence on later runs: `inspect()` → `ready` (plain profile) or `locked`
/// → `unlock(password)` → `connect()`.
abstract interface class IdentityService {
  /// Current identity once created/unlocked, else null.
  Identity? get current;

  Stream<Identity?> get identityChanges;

  /// Live Tox connection state; only meaningful after [connect].
  Stream<ConnectionStatus> get connectionChanges;
  ConnectionStatus get connectionStatus;

  /// Look at disk; never prompts. Cheap enough to call on every launch.
  Future<IdentityState> inspect();

  /// Create a brand-new Tox identity. Optionally encrypt the profile.
  Future<Identity> create({required String displayName, String? password});

  /// Decrypt and load an existing encrypted profile.
  /// Throws [ChatException] `wrong_password`.
  Future<Identity> unlock(String password);

  /// Load an existing plain profile (state was [IdentityState.ready]).
  Future<Identity> open();

  /// Add, change (`null` old → set) or remove (`null` new) the profile password.
  Future<void> changePassword({String? oldPassword, String? newPassword});

  Future<Identity> updateProfile({String? displayName, String? statusMessage});

  /// Encrypted (if a password is set) `.tox` profile bytes plus the training
  /// progress bundle, for the first-run backup wizard. Format is owned by the
  /// implementation but must round-trip through [importBackup].
  Future<Uint8List> exportBackup();

  /// Restore from [exportBackup] output. Replaces any current identity.
  Future<Identity> importBackup(Uint8List bytes, {String? password});

  /// Start the Tox node: bootstrap DHT, begin polling. Idempotent.
  Future<void> connect();

  /// Stop networking but keep the profile on disk.
  Future<void> disconnect();

  /// Irreversibly delete the profile and all local data (history, progress).
  Future<void> deleteIdentity();

  /// Directory (per identity) where other modules persist their data, e.g.
  /// morse_trainer progress. Available once the identity is ready.
  Future<String> dataDirectory();
}
