import 'package:flutter/widgets.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../i18n/key_value_store.dart';
import '../i18n/locale_controller.dart';
import '../startup/startup_controller.dart';
import '../ui/account/backup_file_gateway.dart';
import '../ui/chat/morse_playback_settings.dart';
import 'app_settings.dart';
import 'backend_factory.dart';

/// Builds the backend services once from a [BackendFactory] and exposes them
/// to the whole widget tree — including routes pushed on the root navigator,
/// which is why this sits ABOVE `MaterialApp` rather than inside the shell.
///
/// Provided: [IdentityService], [ChatService], [BackupFileGateway],
/// [AppSettings], [StartupController], [LocaleController],
/// [MorsePlaybackSettings].
class AppScope extends StatefulWidget {
  const AppScope({
    super.key,
    required this.factory,
    required this.child,
    this.backupFiles,
    this.localeStore,
  });

  final BackendFactory factory;
  final Widget child;

  /// Override for the file save/pick gateway; tests pass a fake.
  final BackupFileGateway? backupFiles;

  /// Where the language choice persists; defaults to memory (tests, fake
  /// backend). `main()` passes a file-backed store.
  final KeyValueStore? localeStore;

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
  late final LocaleController _locale = LocaleController(
    widget.localeStore ?? InMemoryKeyValueStore(),
  );
  final MorsePlaybackSettings _playback = MorsePlaybackSettings();

  @override
  void dispose() {
    _playback.dispose();
    _locale.dispose();
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
        ChangeNotifierProvider<LocaleController>.value(value: _locale),
        ChangeNotifierProvider<MorsePlaybackSettings>.value(value: _playback),
      ],
      child: widget.child,
    );
  }
}
