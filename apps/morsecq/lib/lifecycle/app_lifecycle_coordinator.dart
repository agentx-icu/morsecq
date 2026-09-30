import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../notifications/notification_platform.dart';
import 'lifecycle_hint.dart';

/// Tracks foreground / background and drives the mobile background policy.
///
/// - [isForeground] feeds `NotificationCenter` (post only when the user
///   cannot see the conversation).
/// - On background, on mobile, a countdown of the platform's expected
///   background budget (`NotificationPlatform.backgroundBudget`: iOS ~30 s,
///   Android ~60 s / OEM-dependent) flips [mayBeDisconnected] and emits
///   [LifecycleHint.mayBeDisconnected]. Desktop never suspends, so no
///   countdown runs there.
/// - On resume after any background period, `IdentityService.connect()` is
///   called (the contract guarantees idempotency) so a suspended node
///   re-bootstraps without the user tapping the connection chip.
/// - The contract has no `persist` hook (nothing to flush: Tim2Tox saves the
///   Tox state itself), so [onBackground] is an optional app-level hook the
///   orchestrator may use for drafts or settings.
///
/// `inactive` is ignored on purpose: it fires for transient overlays
/// (control centre, an incoming call banner, a permission dialog) and for a
/// desktop window merely losing focus, none of which hide the conversation.
/// `hidden` (window minimised / app switcher) and `paused` count as
/// background on every platform.
class AppLifecycleCoordinator with WidgetsBindingObserver {
  AppLifecycleCoordinator({
    required IdentityService identity,
    Clock? clock,
    NotificationPlatform? platform,
    Duration? backgroundBudget,
    Future<void> Function()? onBackground,
  }) : _identity = identity,
       _clock = clock ?? SystemClock.shared,
       _platform = platform ?? NotificationPlatform.detect(),
       _budgetOverride = backgroundBudget,
       _onBackground = onBackground;

  final IdentityService _identity;
  final Clock _clock;
  final NotificationPlatform _platform;
  final Duration? _budgetOverride;
  final Future<void> Function()? _onBackground;

  final ValueNotifier<bool> _foreground = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _mayBeDisconnected = ValueNotifier<bool>(false);
  final StreamController<LifecycleHint> _hints =
      StreamController<LifecycleHint>.broadcast();

  Timer? _budgetTimer;
  bool _attached = false;
  bool _inBackground = false;
  bool _disposed = false;

  ValueListenable<bool> get isForeground => _foreground;

  /// True from the end of the background budget until the next resume.
  ValueListenable<bool> get mayBeDisconnected => _mayBeDisconnected;

  Stream<LifecycleHint> get hints => _hints.stream;

  /// The countdown used on background; null when this platform is never
  /// suspended (desktop) and no override was given.
  Duration? get backgroundBudget => _budgetOverride ?? _platform.backgroundBudget;

  /// Registers with [WidgetsBinding] and seeds the state from the binding's
  /// current lifecycle. Idempotent.
  void attach() {
    if (_attached || _disposed) return;
    _attached = true;
    final WidgetsBinding binding = WidgetsBinding.instance;
    binding.addObserver(this);
    final AppLifecycleState? state = binding.lifecycleState;
    if (state != null) didChangeAppLifecycleState(state);
  }

  void detach() {
    if (!_attached) return;
    _attached = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _enterForeground();
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _enterBackground();
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    detach();
    _budgetTimer?.cancel();
    _budgetTimer = null;
    await _hints.close();
    _foreground.dispose();
    _mayBeDisconnected.dispose();
  }

  void _enterBackground() {
    if (_inBackground) return;
    _inBackground = true;
    _foreground.value = false;
    _emit(LifecycleHint.background);
    final Future<void> Function()? hook = _onBackground;
    if (hook != null) {
      unawaited(
        hook().catchError(
          (Object error, StackTrace stack) =>
              _report('onBackground', error, stack),
        ),
      );
    }
    final Duration? budget = backgroundBudget;
    if (budget == null) return;
    _budgetTimer?.cancel();
    _budgetTimer = _clock.schedule(budget, _onBudgetExpired);
  }

  void _onBudgetExpired() {
    _budgetTimer = null;
    if (_disposed || !_inBackground) return;
    _mayBeDisconnected.value = true;
    _emit(LifecycleHint.mayBeDisconnected);
  }

  void _enterForeground() {
    _budgetTimer?.cancel();
    _budgetTimer = null;
    if (!_inBackground) {
      // Initial resume (or a spurious repeat): nothing to recover from; the
      // startup controller owns the first connect().
      _foreground.value = true;
      return;
    }
    _inBackground = false;
    _foreground.value = true;
    _mayBeDisconnected.value = false;
    _emit(LifecycleHint.foreground);
    unawaited(_reconnect());
  }

  Future<void> _reconnect() async {
    if (_identity.current == null) return;
    _emit(LifecycleHint.reconnectRequested);
    try {
      await _identity.connect();
    } catch (error, stack) {
      _report('connect', error, stack);
      _emit(LifecycleHint.reconnectFailed);
    }
  }

  void _emit(LifecycleHint hint) {
    if (!_hints.isClosed) _hints.add(hint);
  }

  static void _report(String what, Object error, StackTrace stack) {
    debugPrint('[AppLifecycleCoordinator] $what failed: $error\n$stack');
  }
}
