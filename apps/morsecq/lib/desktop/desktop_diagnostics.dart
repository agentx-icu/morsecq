import 'package:flutter/foundation.dart';

import '../diagnostics/local_diagnostics.dart';
import 'desktop_platform.dart';

extension DesktopDiagnostics on DesktopShellConfig {
  /// The event is fixed in release; optional operation text is debug-only.
  void diagnose(DiagnosticContext context, Object error, {String? operation}) {
    LocalDiagnostics.capture(context, error);
    if (!kDebugMode) return;
    final label = switch (context) {
      DiagnosticContext.desktopTray =>
        'tray unavailable, continuing without it',
      DiagnosticContext.desktopTrayHost => 'tray host unavailable',
      DiagnosticContext.desktopDisplay => 'display lookup failed',
      DiagnosticContext.desktopWindowSave => 'could not persist window state',
      DiagnosticContext.desktopCloseSave => 'could not persist closeToTray',
      DiagnosticContext.desktopSoundSave => 'could not persist sound',
      DiagnosticContext.desktopSoundChange => 'onToggleSound failed',
      DiagnosticContext.desktopBeforeQuit => 'onBeforeQuit failed',
      DiagnosticContext.desktopRead => 'could not read setting',
      DiagnosticContext.desktopOperation => '$operation failed',
      _ => context.name,
    };
    logger('[DesktopShell] $label: $error');
  }
}
