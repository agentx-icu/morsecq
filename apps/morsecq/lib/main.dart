import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'di/app_scope.dart';
import 'di/app_settings.dart';
import 'di/backend_factory.dart';
import 'startup/startup_gate.dart';
import 'ui/account/account_strings.dart';
import 'ui/account/backup_file_gateway.dart';
import 'ui/pages/placeholder_page.dart';
import 'ui/shell/app_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final backend = await resolveBackendFactory();
  runApp(MorsecqApp(backend: backend));
}

/// Root widget: services from [backend] via [AppScope], then Material 3 with
/// light/dark following the system setting, and the [StartupGate] guarding
/// the responsive [AppShell].
class MorsecqApp extends StatelessWidget {
  const MorsecqApp({super.key, required this.backend, this.backupFiles});

  final BackendFactory backend;

  /// Test hook: replaces the native save/pick dialogs.
  final BackupFileGateway? backupFiles;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      factory: backend,
      backupFiles: backupFiles,
      child: Builder(
        builder: (context) {
          final themeMode = context.select<AppSettings, ThemeMode>(
            (s) => s.themeMode,
          );
          return MaterialApp(
            title: AccountStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: MorsecqTheme.light(),
            darkTheme: MorsecqTheme.dark(),
            themeMode: themeMode,
            home: const StartupGate(child: AppShell()),
            routes: {
              // TODO(learn-ui): replace with the real training-defaults page.
              AccountStrings.trainingSettingsRoute: (_) =>
                  const PlaceholderPage(
                    title: AccountStrings.trainingDefaults,
                    description: AccountStrings.trainingDefaultsPlaceholder,
                    icon: Icons.tune,
                  ),
            },
          );
        },
      ),
    );
  }
}
