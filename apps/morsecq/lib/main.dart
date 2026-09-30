import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'desktop/desktop_platform.dart';
import 'desktop/desktop_shell_controller.dart';
import 'desktop/init_desktop_shell.dart';
import 'di/app_scope.dart';
import 'di/app_services.dart';
import 'di/app_settings.dart';
import 'di/backend_factory.dart';
import 'di/desktop_store_adapter.dart';
import 'i18n/key_value_store.dart';
import 'i18n/l10n_extension.dart';
import 'i18n/locale_controller.dart';
import 'notifications/app_badge_plus_api.dart';
import 'notifications/flutter_local_notifications_api.dart';
import 'startup/startup_gate.dart';
import 'ui/account/account_strings.dart';
import 'ui/account/backup_file_gateway.dart';
import 'ui/learn/settings/training_settings_entry.dart';
import 'ui/shell/app_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // One small settings file for app-wide, pre-identity preferences (language,
  // window bounds). Per-identity data lives under IdentityService.dataDirectory.
  final KeyValueStore settingsStore = await _openSettingsStore();

  // Desktop only: window bounds, close-to-tray, tray menu. No-op elsewhere.
  DesktopShellController? desktopShell;
  if (isDesktopTarget(defaultTargetPlatform)) {
    desktopShell = await initDesktopShell(
      DesktopShellConfig(
        store: DesktopStoreAdapter(settingsStore),
        appName: AccountStrings.appName,
        log: kDebugMode ? debugPrint : null,
      ),
    );
  }

  final backend = await resolveBackendFactory();

  runApp(
    MorsecqApp(
      backend: backend,
      localeStore: settingsStore,
      desktopShell: desktopShell,
      notifications: NotificationApis(
        notifications: FlutterLocalNotificationsApi(),
        badge: AppBadgePlusApi(),
      ),
    ),
  );
}

/// `<application support>/settings.json`; falls back to memory if the
/// directory cannot be created (the app still runs, preferences just do not
/// survive a restart).
Future<KeyValueStore> _openSettingsStore() async {
  try {
    final dir = await getApplicationSupportDirectory();
    return await JsonFileKeyValueStore.open(
      File(p.join(dir.path, 'settings.json')),
    );
  } on Object catch (error) {
    debugPrint('settings store unavailable, using memory: $error');
    return InMemoryKeyValueStore();
  }
}

/// Root widget: services from [backend] via [AppScope], then Material 3 with
/// light/dark following the system setting, and the [StartupGate] guarding
/// the responsive [AppShell].
class MorsecqApp extends StatelessWidget {
  const MorsecqApp({
    super.key,
    required this.backend,
    this.backupFiles,
    this.localeStore,
    this.desktopShell,
    this.notifications,
  });

  final BackendFactory backend;

  /// Test hook: replaces the native save/pick dialogs.
  final BackupFileGateway? backupFiles;

  /// Persistence for the language choice; memory when null.
  final KeyValueStore? localeStore;

  /// Initialised desktop shell (window + tray); null on mobile and in tests.
  final DesktopShellController? desktopShell;

  /// Real notification plugins; null disables OS notifications (tests).
  final NotificationApis? notifications;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      factory: backend,
      backupFiles: backupFiles,
      localeStore: localeStore,
      desktopShell: desktopShell,
      notificationApis: notifications,
      child: Builder(
        builder: (context) {
          final themeMode = context.select<AppSettings, ThemeMode>(
            (s) => s.themeMode,
          );
          final locale = context.watch<LocaleController>().locale;
          return MaterialApp(
            title: AccountStrings.appName,
            onGenerateTitle: (context) => S.of(context).appName,
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            locale: locale,
            debugShowCheckedModeBanner: false,
            theme: MorsecqTheme.light(),
            darkTheme: MorsecqTheme.dark(),
            themeMode: themeMode,
            home: const StartupGate(child: AppShell()),
            routes: {
              AccountStrings.trainingSettingsRoute: (_) =>
                  const TrainingSettingsEntry(),
            },
          );
        },
      ),
    );
  }
}
