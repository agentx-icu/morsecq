import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../i18n/current_strings.dart';
import '../diagnostics/local_diagnostics.dart';
import 'desktop_diagnostics.dart';
import '../l10n/generated/s.dart';
import 'desktop_platform.dart';
import 'screen_api.dart';
import 'tray_api.dart';
import 'tray_host_watch.dart';
import 'window_api.dart';
import 'window_bounds.dart';

/// Keys of the tray context-menu rows (see [DesktopShellController.trayMenu]).
abstract final class TrayMenuKeys {
  static const String showHide = 'show_hide';
  static const String sound = 'sound';
  static const String quit = 'quit';
}

/// Manages desktop windows, window preferences and the localized tray menu.
/// Mobile and web leave the native adapters untouched.
class DesktopShellController extends ChangeNotifier
    implements WindowEventHandler, TrayEventHandler {
  DesktopShellController({
    required this.config,
    required WindowApi window,
    required TrayApi tray,
    required ScreenApi screen,
    S? strings,
  }) : _window = window,
       _tray = tray,
       _screen = screen,
       _closeToTray = config.closeToTray,
       _soundEnabled = config.soundEnabled,
       _s = strings ?? currentS();

  static const String boundsKey = 'desktop.windowBounds';
  static const String closeToTrayKey = 'desktop.closeToTray';
  static const String soundEnabledKey = 'desktop.soundEnabled';

  final DesktopShellConfig config;
  final WindowApi _window;
  final TrayApi _tray;
  final ScreenApi _screen;

  bool _initialized = false;
  bool _active = false;
  bool _trayAvailable = false;
  bool _windowVisible = false;
  bool _closing = false;
  Rect? _normalBounds;
  bool _closeToTray;
  bool _soundEnabled;
  S _s;
  Timer? _persistTimer;
  Future<void> _trayQueue = Future<void>.value();
  bool _trayGapWarned = false;
  final Set<Future<void> Function()> _beforeQuit = {};
  late final _trayHostWatch = TrayHostWatch(
    isAvailable: () async => _trayAvailable && await _hasTrayHost(),
    onLost: () async {
      _trayAvailable = false;
      await _tolerate('show window', showWindow);
    },
  );

  void addBeforeQuitListener(Future<void> Function() listener) =>
      _beforeQuit.add(listener);

  void removeBeforeQuitListener(Future<void> Function() listener) =>
      _beforeQuit.remove(listener);

  bool get isActive => _active;

  bool get isTrayAvailable => _trayAvailable;

  bool get isWindowVisible => _windowVisible;

  bool get closeToTray => _closeToTray;

  bool get soundEnabled => _soundEnabled;

  S get strings => _s;

  String get windowTitle => config.appName;
  String get trayTooltip => config.appName;

  /// Menu rows follow visibility, sound state and language.
  List<TrayMenuEntry> get trayMenu => [
    TrayMenuEntry(
      key: TrayMenuKeys.showHide,
      label: _windowVisible
          ? _s.desktopTrayHide(config.appName)
          : _s.desktopTrayShow(config.appName),
    ),
    if (config.onToggleSound != null)
      TrayMenuEntry(
        key: TrayMenuKeys.sound,
        label: _soundEnabled ? _s.desktopTraySoundOn : _s.desktopTraySoundOff,
        checked: _soundEnabled,
      ),
    const TrayMenuEntry.separator(),
    TrayMenuEntry(
      key: TrayMenuKeys.quit,
      label: _s.desktopTrayQuit(config.appName),
    ),
  ];

  void updateStrings(S strings) {
    if (strings.localeName == _s.localeName) return;
    _s = strings;
    notifyListeners();
    if (!_active) return;
    unawaited(_tolerate('setTitle', () => _window.setTitle(windowTitle)));
    _enqueueTray(_applyTrayState);
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (!config.isDesktop) return;

    _closeToTray = await _readCloseToTray();
    final sound = await _read(soundEnabledKey);
    _soundEnabled = sound == 'false'
        ? false
        : sound == 'true'
        ? true
        : config.soundEnabled;
    await _window.ensureInitialized();
    final areas = await _workAreas();
    final primary = areas.isEmpty ? null : areas.first;
    final minSize = fitSizeToArea(config.minimumSize, primary);
    final saved = WindowBounds.decode(await _read(boundsKey));
    final target = (saved ?? WindowBounds.centered(config.defaultSize, primary))
        .fitTo(areas, minSize);

    _window.setEventHandler(this);
    // Always intercept close: even without close-to-tray we must persist the
    // bounds and run onBeforeQuit before the runner exits.
    await _window.setPreventClose(true);
    await _window.waitUntilReadyToShow(
      title: windowTitle,
      minimumSize: minSize,
      size: target.rect.size,
    );
    _normalBounds = target.rect;
    await _window.setBounds(target.rect);
    await _window.show();
    await _window.focus();
    if (target.maximized) await _window.maximize();
    _windowVisible = true;
    _active = true;
    await _initTray();
    notifyListeners();
  }

  Future<void> _initTray() async {
    final icon = TrayIconAssets.forPlatform(config.effectivePlatform);
    if (icon == null) return;
    try {
      if (!await _hasTrayHost()) return;
      _tray.setEventHandler(this);
      await _tray.setIcon(icon, isTemplate: config.isMacOS);
      _trayAvailable = true;
    } catch (e) {
      // A tray-less session (headless Linux, no SNI host) throws on the first
      // call. Disable the tray entirely: close-to-tray then falls back to a
      // real quit so the user can never lose the window.
      _trayAvailable = false;
      _tray.setEventHandler(null);
      config.diagnose(DiagnosticContext.desktopTray, e);
      return;
    }
    await _applyTrayState();
  }

  Future<bool> _hasTrayHost() async {
    try {
      return await config.trayHostAvailable?.call() ?? true;
    } on Object catch (error) {
      config.diagnose(DiagnosticContext.desktopTrayHost, error);
      return false;
    }
  }

  Future<List<Rect>> _workAreas() async {
    try {
      return await _screen.workAreas();
    } catch (e) {
      config.diagnose(DiagnosticContext.desktopDisplay, e);
      return const [];
    }
  }

  Future<void> _applyTrayState() async {
    if (!_trayAvailable) return;
    await _tolerate('setToolTip', () => _tray.setToolTip(trayTooltip));
    if (config.isMacOS) {
      await _tolerate('setTitle', () => _tray.setTitle(''));
    }
    try {
      await _tray.setMenu(trayMenu);
    } on Object catch (error) {
      // Linux AppIndicator uses the menu to reopen the window.
      if (config.isLinux) _trayAvailable = false;
      config.diagnose(
        DiagnosticContext.desktopOperation,
        error,
        operation: 'setMenu',
      );
    }
  }

  /// Tray updates are several async plugin calls; callers fire them without
  /// awaiting, so serialise them to keep an older state from landing last.
  void _enqueueTray(Future<void> Function() op) {
    _trayQueue = _trayQueue.then((_) => op());
  }

  /// Completes when every queued tray update has been applied (tests).
  Future<void> flushTrayUpdates() => _trayQueue;

  Future<void> showWindow() async {
    if (!_active) return;
    if (await _window.isMinimized()) await _window.restore();
    await _window.show();
    if (!_active) return;
    _setWindowVisible(true);
    await _window.focus();
  }

  /// Hides the window when the tray can reopen it.
  Future<void> hideToTray() async {
    await _hideToTray();
  }

  Future<bool> _hideToTray() async {
    if (!_active || _closing) return false;
    if (_trayAvailable) {
      if (!await _hasTrayHost()) return false;
    } else if (config.trayHostAvailable != null) {
      await _initTray();
    }
    if (!_trayAvailable || _closing || !_active) return false;
    await persistWindowState();
    if (_closing || !_active) return false;
    await _window.hide();
    if (!_active) return false;
    _setWindowVisible(false);
    return true;
  }

  Future<void> toggleWindow() async {
    if (!_active) return;
    final visible = await _tolerateBool('isVisible', _window.isVisible);
    if (visible ?? _windowVisible) {
      await hideToTray();
    } else {
      await showWindow();
    }
  }

  void _setWindowVisible(bool visible) {
    if (visible) _trayHostWatch.stop();
    if (!visible) _watchHiddenTray();
    if (_windowVisible == visible) return;
    _windowVisible = visible;
    notifyListeners();
    _enqueueTray(_applyTrayState);
  }

  void _watchHiddenTray() {
    if (config.trayHostAvailable != null && !_closing && _active) {
      _trayHostWatch.start();
    }
  }

  /// Reads the live bounds and maximised flag and stores them.
  Future<void> persistWindowState() async {
    if (!_active) return;
    try {
      final rect = await _window.getBounds();
      final maximized = await _window.isMaximized();
      if (!maximized &&
          !await _window.isFullScreen() &&
          !await _window.isMinimized()) {
        _normalBounds = rect;
      }
      await config.store.set(
        boundsKey,
        WindowBounds(
          rect: _normalBounds ?? rect,
          maximized: maximized,
        ).encode(),
      );
    } catch (e) {
      config.diagnose(DiagnosticContext.desktopWindowSave, e);
    }
  }

  Future<void> setCloseToTray(bool value) =>
      _trackPreference(_setCloseToTray(value));

  Future<void> _setCloseToTray(bool value) async {
    if (_closeToTray == value) return;
    final previous = _closeToTray;
    _closeToTray = value;
    notifyListeners();
    if (!config.isDesktop) return;
    try {
      await config.store.set(closeToTrayKey, value.toString());
    } catch (e) {
      if (_closeToTray == value) {
        _closeToTray = previous;
        notifyListeners();
      }
      config.diagnose(DiagnosticContext.desktopCloseSave, e);
    }
  }

  Future<bool> _readCloseToTray() async {
    final raw = await _read(closeToTrayKey);
    return switch (raw) {
      'true' => true,
      'false' => false,
      _ => config.closeToTray,
    };
  }

  /// Persists the sound choice, then informs its owner.
  Future<void> setSoundEnabled(bool enabled) =>
      _trackPreference(_setSoundEnabled(enabled));

  Future<void> _setSoundEnabled(bool enabled) async {
    if (_soundEnabled == enabled) return;
    final previous = _soundEnabled;
    _soundEnabled = enabled;
    notifyListeners();
    try {
      if (config.isDesktop) {
        await config.store.set(soundEnabledKey, enabled.toString());
      }
    } catch (e) {
      if (_soundEnabled == enabled) {
        _soundEnabled = previous;
        notifyListeners();
      }
      config.diagnose(DiagnosticContext.desktopSoundSave, e);
      return;
    }
    try {
      await config.onToggleSound?.call(enabled);
    } catch (e) {
      config.diagnose(DiagnosticContext.desktopSoundChange, e);
    }
    if (_active) _enqueueTray(_applyTrayState);
  }

  /// Persists the window state, runs [DesktopShellConfig.onBeforeQuit] and
  /// closes the window for real. Idempotent.
  Future<void> quit() async {
    if (!_active || _closing) return;
    _closing = true;
    _trayHostWatch.stop();
    _persistTimer?.cancel();
    await _pendingPreferences;
    await persistWindowState();
    try {
      for (final listener in _beforeQuit.toList()) {
        await listener();
      }
    } catch (e) {
      _closing = false;
      if (!_windowVisible) _watchHiddenTray();
      config.diagnose(DiagnosticContext.desktopBeforeQuit, e);
      return;
    }
    try {
      await config.onBeforeQuit?.call();
    } catch (e) {
      config.diagnose(DiagnosticContext.desktopBeforeQuit, e);
    }
    await _tolerate('destroy tray', _tray.destroy);
    try {
      await _window.destroy();
    } on Object catch (error) {
      config.diagnose(
        DiagnosticContext.desktopOperation,
        error,
        operation: 'destroy window',
      );
      if (_trayAvailable) {
        _trayAvailable = false;
        await _initTray();
      }
      if (!_trayAvailable && !_windowVisible) {
        await _tolerate('show window', showWindow);
      }
      _closing = false;
      if (!_windowVisible) _watchHiddenTray();
    }
  }

  @override
  void onCloseRequested() {
    unawaited(handleCloseRequested());
  }

  /// Close-to-tray hides (when the tray exists); otherwise this is the real
  /// exit path.
  Future<void> handleCloseRequested() async {
    if (!_active || _closing) return;
    if (_closeToTray && await _hideToTray()) return;
    await quit();
  }

  @override
  void onBoundsChanged() {
    if (!_active || _closing) return;
    _persistTimer?.cancel();
    _persistTimer = Timer(config.persistDebounce, () {
      _persistTimer = null;
      unawaited(persistWindowState());
    });
  }

  @override
  void onTrayIconClicked() {
    unawaited(toggleWindow());
  }

  @override
  void onTrayMenuItem(String key) {
    switch (key) {
      case TrayMenuKeys.showHide:
        unawaited(toggleWindow());
      case TrayMenuKeys.sound:
        unawaited(setSoundEnabled(!_soundEnabled));
      case TrayMenuKeys.quit:
        unawaited(quit());
    }
  }

  @override
  void dispose() {
    _persistTimer?.cancel();
    _trayHostWatch.stop();
    if (_active) {
      _active = false;
      _window.setEventHandler(null);
      _tray.setEventHandler(null);
    }
    super.dispose();
  }

  Future<void> _pendingPreferences = Future<void>.value();

  Future<void> _trackPreference(Future<void> write) {
    _pendingPreferences = Future.wait<void>([
      _pendingPreferences,
      write,
    ]).then<void>((_) {});
    return write;
  }

  Future<String?> _read(String key) async {
    try {
      return await config.store.get(key);
    } catch (e) {
      config.diagnose(DiagnosticContext.desktopRead, e);
      return null;
    }
  }

  /// Runs one optional call, warning once about a per-platform gap (Linux
  /// tray_manager has no tooltip; some hosts reject titles).
  Future<void> _tolerate(String label, Future<void> Function() op) async {
    try {
      await op();
    } catch (e) {
      if (_trayGapWarned) return;
      _trayGapWarned = true;
      config.diagnose(DiagnosticContext.desktopOperation, e, operation: label);
    }
  }

  Future<bool?> _tolerateBool(String label, Future<bool> Function() op) async {
    try {
      return await op();
    } catch (e) {
      config.diagnose(DiagnosticContext.desktopOperation, e, operation: label);
      return null;
    }
  }
}
