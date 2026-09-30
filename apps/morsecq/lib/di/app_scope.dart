import 'package:flutter/widgets.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../startup/startup_controller.dart';
import '../ui/account/backup_file_gateway.dart';
import 'app_settings.dart';
import 'backend_factory.dart';

/// Builds the backend services once from a [BackendFactory] and exposes them
/// to the whole widget tree — including routes pushed on the root navigator,
/// which is why this sits ABOVE `MaterialApp` rather than inside the shell.
///
/// Provided: [IdentityService], [ChatService], [BackupFileGateway],
/// [AppSettings], [StartupController].
class AppScope extends StatefulWidget {
  const AppScope({
    super.key,
    required this.factory,
    required this.child,
    this.backupFiles,
  });

  final BackendFactory factory;
  final Widget child;

  /// Override for the file save/pick gateway; tests pass a fake.
  final BackupFileGateway? backupFiles;

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final IdentityService _identity = widget.factory.createIdentityService();
  late final ChatService _chat = widget.factory.createChatService(_identity);
  late final AppSettings _settings = AppSettings(
    backendLabel: widget.factory.label,
  );
  late final StartupController _startup = StartupController(_identity);
  late final BackupFileGateway _backupFiles =
      widget.backupFiles ?? const PlatformBackupFileGateway();

  @override
  void dispose() {
    _startup.dispose();
    _settings.dispose();
    // Fire-and-forget: the scope is going away and there is nobody left to
    // report to; the fake and the real backend both log internally.
    widget.factory.disposeServices(identity: _identity, chat: _chat).ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<IdentityService>.value(value: _identity),
        Provider<ChatService>.value(value: _chat),
        Provider<BackupFileGateway>.value(value: _backupFiles),
        ChangeNotifierProvider<AppSettings>.value(value: _settings),
        ChangeNotifierProvider<StartupController>.value(value: _startup),
      ],
      child: widget.child,
    );
  }
}
