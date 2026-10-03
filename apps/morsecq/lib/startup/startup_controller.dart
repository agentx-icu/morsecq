import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../training/guest_profile.dart';

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

  /// Learning without an identity (functional spec §8): the shell runs on
  /// the guest learning profile; chat asks for an identity. No Tox identity
  /// is created, opened, unlocked or connected in this phase.
  guest,
}

/// Guest-data hooks the controller needs; null disables guest learning.
final class GuestHooks {
  const GuestHooks({required this.store, required this.releaseGuestController});

  final GuestStore store;

  /// Flushes and closes the guest training controller (before migration).
  final Future<void> Function() releaseGuestController;
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
  StartupController(
    this._identity, {
    GuestHooks? guest,
    DateTime Function()? now,
  }) : _guest = guest,
       _now = now ?? DateTime.now {
    _identitySub = _identity.identityChanges.listen(_onIdentityChanged);
  }

  final IdentityService _identity;
  final GuestHooks? _guest;
  final DateTime Function() _now;

  /// True while the guest learning profile is in use; the training host
  /// listens to it.
  final ValueNotifier<bool> guestMode = ValueNotifier<bool>(false);

  /// Phase to return to when leaving guest mode (onboarding or locked).
  StartupPhase _beforeGuest = StartupPhase.onboarding;

  Object? _migrationError;

  /// Moving guest progress to a just-created identity failed; the identity
  /// exists, the guest data is intact, [retryMigration] tries again.
  Object? get migrationError => _migrationError;

  bool _guestChoicePending = false;

  /// A backup was restored while guest progress exists: the restored
  /// progress is used; the learner may switch to the guest progress.
  bool get guestChoicePending => _guestChoicePending;

  bool get guestAvailable => _guest != null;
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
      final resumeGuest = await _guestWasActive();
      switch (state) {
        case IdentityState.none:
          _beforeGuest = StartupPhase.onboarding;
          _set(resumeGuest ? StartupPhase.guest : StartupPhase.onboarding);
        case IdentityState.locked:
          _beforeGuest = StartupPhase.locked;
          _set(resumeGuest ? StartupPhase.guest : StartupPhase.locked);
        case IdentityState.ready:
          _set(StartupPhase.opening);
          await _identity.open();
          _becomeReady();
      }
    } on Object catch (e) {
      _set(StartupPhase.failed, error: e);
    }
  }

  Future<bool> _guestWasActive() async {
    final guest = _guest;
    if (guest == null) return false;
    try {
      final active = await guest.store.isActive();
      guestMode.value = active;
      return active;
    } on Object {
      return false;
    }
  }

  /// "Try learning first": learn on the guest profile. Never touches an
  /// identity on disk (an encrypted one stays locked).
  Future<void> enterGuest() async {
    final guest = _guest;
    if (guest == null) return;
    if (_phase == StartupPhase.onboarding || _phase == StartupPhase.locked) {
      _beforeGuest = _phase;
    }
    try {
      await guest.store.setActive(true);
    } on Object {
      // Guest mode still works this session; it just won't be remembered.
    }
    guestMode.value = true;
    _set(StartupPhase.guest);
  }

  /// Back to creating / restoring / unlocking an identity.
  Future<void> leaveGuest() async {
    guestMode.value = false;
    try {
      await _guest?.store.setActive(false);
    } on Object {
      // Not remembered; the next launch may start in guest mode again.
    }
    _set(_beforeGuest);
  }

  /// Deletes the guest's learning data (the learner asked for it).
  Future<void> clearGuestData() async {
    final guest = _guest;
    if (guest == null) return;
    await guest.releaseGuestController();
    await guest.store.clear();
  }

  /// Moves guest progress to the open identity (after creating it).
  Future<void> _migrateGuest() async {
    final guest = _guest;
    final identity = _identity.current;
    if (guest == null || identity == null) return;
    guestMode.value = false;
    try {
      if (!await guest.store.hasProgress()) {
        await guest.store.setActive(false);
        _migrationError = null;
        return;
      }
      await guest.releaseGuestController();
      await GuestMigration(
        guestDirectory: await guest.store.directory(),
        identityDirectory: await _identity.dataDirectory(),
      ).run(identityKey: identity.publicKey, now: _now());
      await guest.store.setActive(false);
      _migrationError = null;
    } on Object catch (e) {
      _migrationError = e;
    }
    _notify();
  }

  /// Retries a failed guest migration; idempotent.
  Future<void> retryMigration() => _migrateGuest();

  /// After a restore: replace the restored learning data with the guest's
  /// (the restored data is moved aside, never merged or deleted).
  Future<void> useGuestProgress() async {
    _guestChoicePending = false;
    await _migrateGuest();
  }

  /// After a restore: keep the restored progress; guest data stays apart.
  Future<void> keepRestoredProgress() async {
    _guestChoicePending = false;
    try {
      await _guest?.store.setActive(false);
    } on Object {
      // Harmless: only the guest-mode resume flag.
    }
    _notify();
  }

  /// Decrypts the profile. Throws (typically `ChatException('wrong_password')`)
  /// so the unlock screen can render the error inline.
  Future<void> unlock(String password) async {
    await _identity.unlock(password);
    final fromGuest = guestMode.value;
    guestMode.value = false;
    // Unlocking from guest mode keeps the identity's own progress; the
    // learner may switch to the guest progress explicitly.
    _guestChoicePending = fromGuest && await _guestHasProgress();
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
    // Guest progress moves with the learner to the new identity by default.
    await _migrateGuest();
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
    final fromGuest = guestMode.value;
    guestMode.value = false;
    // Restored progress is used; guest scores are never silently merged.
    _guestChoicePending = fromGuest && await _guestHasProgress();
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

  Future<bool> _guestHasProgress() async {
    try {
      return await _guest?.store.hasProgress() ?? false;
    } on Object {
      return false;
    }
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
    guestMode.dispose();
    super.dispose();
  }
}
