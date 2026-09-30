import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

/// Where the app is in its identity lifecycle. The [StartupGate] renders one
/// screen per phase; everything behind [ready] is the normal shell.
enum StartupPhase {
  /// `inspect()` is running (also the very first frame).
  inspecting,

  /// No identity on disk: welcome → create / restore.
  onboarding,

  /// Encrypted profile on disk: unlock screen.
  locked,

  /// Plain profile found; `open()` is running.
  opening,

  /// Identity was just created; the mandatory backup wizard is showing.
  backupRequired,

  /// Identity loaded. Connection runs in the background.
  ready,

  /// `inspect()` / `open()` threw; retry screen.
  failed,
}

/// Drives the startup sequence (`inspect → onboarding | unlock | open`) and
/// the identity-level actions that change which screen the gate shows.
///
/// Mirrors toxee's `StartupSessionUseCase` policy without its account
/// registry: one identity per device, no auto-login of an encrypted profile
/// (the password is never cached across launches), connection never blocks
/// the UI.
///
/// Holds no user-facing text: failures are kept as the thrown object (a
/// `ChatException` with a stable code, or anything else) and the widgets
/// translate them with `describeChatError(s, error)`.
class StartupController extends ChangeNotifier {
  StartupController(this._identity) {
    _identitySub = _identity.identityChanges.listen(_onIdentityChanged);
  }

  final IdentityService _identity;
  late final StreamSubscription<Identity?> _identitySub;

  /// Sentinel for [_set]: "leave the error as it is".
  static const Object _keepError = Object();

  StartupPhase _phase = StartupPhase.inspecting;
  Object? _error;
  Object? _connectionError;
  bool _started = false;
  bool _disposed = false;

  StartupPhase get phase => _phase;

  /// What `inspect()` / `open()` threw for [StartupPhase.failed]; null in
  /// every other phase.
  Object? get error => _error;

  /// Last `connect()` failure, if any. Cleared by a successful [reconnect].
  Object? get connectionError => _connectionError;

  IdentityService get identity => _identity;

  /// Runs `inspect()` once per controller. Safe to call from `initState`: the
  /// first notification happens after an await, never synchronously.
  Future<void> ensureStarted() {
    if (_started) return Future.value();
    _started = true;
    return _inspect();
  }

  /// Re-runs the inspection after [StartupPhase.failed].
  Future<void> retry() => _inspect();

  Future<void> _inspect() async {
    _set(StartupPhase.inspecting, error: null);
    try {
      final state = await _identity.inspect();
      switch (state) {
        case IdentityState.none:
          _set(StartupPhase.onboarding);
        case IdentityState.locked:
          _set(StartupPhase.locked);
        case IdentityState.ready:
          _set(StartupPhase.opening);
          await _identity.open();
          _becomeReady();
      }
    } on Object catch (e) {
      _set(StartupPhase.failed, error: e);
    }
  }

  /// Decrypts the profile. Throws (typically `ChatException('wrong_password')`)
  /// so the unlock screen can render the error inline.
  Future<void> unlock(String password) async {
    await _identity.unlock(password);
    _becomeReady();
  }

  /// Creates the identity and moves to the mandatory backup wizard.
  Future<Identity> createIdentity({
    required String displayName,
    String? password,
  }) async {
    final identity = await _identity.create(
      displayName: displayName,
      password: password,
    );
    _set(StartupPhase.backupRequired);
    return identity;
  }

  /// The wizard's "I understand" step was completed.
  void completeBackupWizard() {
    if (_phase != StartupPhase.backupRequired) return;
    _becomeReady();
  }

  /// Restores an identity from backup bytes. The user evidently has a backup,
  /// so the wizard is skipped. Throws `wrong_password` / `invalid_backup`.
  Future<Identity> restoreFromBackup(
    Uint8List bytes, {
    String? password,
  }) async {
    final identity = await _identity.importBackup(bytes, password: password);
    _becomeReady();
    return identity;
  }

  /// Retries the background connection, e.g. from the connection chip.
  Future<void> reconnect() => _connectInBackground();

  /// Irreversibly deletes the identity; the gate falls back to onboarding via
  /// the identity stream.
  Future<void> deleteIdentity() async {
    await _identity.deleteIdentity();
    if (_phase != StartupPhase.onboarding) _set(StartupPhase.onboarding);
  }

  void _becomeReady() {
    _set(StartupPhase.ready);
    unawaited(_connectInBackground());
  }

  Future<void> _connectInBackground() async {
    try {
      await _identity.connect();
      if (_connectionError != null) {
        _connectionError = null;
        _notify();
      }
    } on Object catch (e) {
      _connectionError = e;
      _notify();
    }
  }

  void _onIdentityChanged(Identity? identity) {
    if (identity != null) return;
    if (_phase == StartupPhase.ready || _phase == StartupPhase.backupRequired) {
      _set(StartupPhase.onboarding);
    }
  }

  void _set(StartupPhase phase, {Object? error = _keepError}) {
    // `_keepError` means "leave as is"; null clears; anything else sets.
    final nextError = identical(error, _keepError) ? _error : error;
    if (phase == _phase && identical(nextError, _error)) return;
    _phase = phase;
    _error = nextError;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _identitySub.cancel().ignore();
    super.dispose();
  }
}
