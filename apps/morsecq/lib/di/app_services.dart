import 'dart:async';
import 'package:flutter/widgets.dart';
import '../desktop/desktop_shell_controller.dart';
import '../i18n/locale_controller.dart';
import '../i18n/strings_resolver.dart';
import '../lifecycle/background_task_api.dart';

/// Saves local preferences and learning data when backgrounding or quitting.
final class AppServices with WidgetsBindingObserver {
  AppServices({
    required LocaleController locale,
    required this.flush,
    this.desktopShell,
    BackgroundTaskApi? backgroundTasks,
  }) : strings = StringsResolver(locale),
       _background = backgroundTasks ?? const NoopBackgroundTaskApi();
  final Future<void> Function() flush;
  final DesktopShellController? desktopShell;
  final StringsResolver strings;
  final BackgroundTaskApi _background;
  bool _started = false;
  Future<void>? _flushing;
  bool _flushAgain = false;
  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    strings.addListener(_onStringsChanged);
    desktopShell?.addBeforeQuitListener(flush);
    _onStringsChanged();
  }

  void _onStringsChanged() => desktopShell?.updateStrings(strings.s);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      unawaited(_flushInBackground());
    }
  }

  // A request arriving during a save may follow newer writes that the running
  // barrier does not cover, so it schedules one more barrier.
  Future<void> _flushInBackground() {
    if (_flushing != null) {
      _flushAgain = true;
      return _flushing!;
    }
    return _flushing = _save().whenComplete(() => _flushing = null);
  }

  Future<void> _save() async {
    final token = await _background.begin();
    try {
      do {
        _flushAgain = false;
        try {
          await flush();
        } on Object catch (error) {
          debugPrint('Learning persistence failed: $error');
        }
      } while (_flushAgain);
    } finally {
      if (token != null) await _background.end(token);
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    desktopShell?.removeBeforeQuitListener(flush);
    strings.removeListener(_onStringsChanged);
    strings.dispose();
  }
}
