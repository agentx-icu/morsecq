import 'package:flutter/widgets.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../desktop/desktop_shell_controller.dart';
import '../i18n/key_value_store.dart';
import '../i18n/locale_controller.dart';
import '../lifecycle/app_lifecycle_coordinator.dart';
import '../notifications/connection_banner_policy.dart';
import '../notifications/notification_center.dart';
import '../notifications/notification_prefs.dart';
import '../startup/startup_controller.dart';
import '../training/training_controller_host.dart';
import '../ui/account/backup_file_gateway.dart';
import '../ui/chat/morse_playback_settings.dart';
import 'app_services.dart';
import 'app_settings.dart';
import 'backend_factory.dart';

/// Builds the backend services once from a [BackendFactory] and exposes them
/// to the whole widget tree — including routes pushed on the root navigator,
/// which is why this sits ABOVE `MaterialApp` rather than inside the shell.
///
/// Provided: [IdentityService], [ChatService], [BackupFileGateway],
/// [AppSettings], [StartupController], [LocaleController],
/// [MorsePlaybackSettings], [AppLifecycleCoordinator],
/// [ConnectionBannerPolicy], [NotificationPrefs], and — when `main()` supplies
/// them — [NotificationCenter] and [DesktopShellController] (nullable).
class AppScope extends StatefulWidget {
  const AppScope({
    super.key,
    required this.factory,
    required this.child,
    this.backupFiles,
    this.localeStore,
    this.notificationApis,
    this.desktopShell,
  });

  final BackendFactory factory;
  final Widget child;

  /// Override for the file save/pick gateway; tests pass a fake.
  final BackupFileGateway? backupFiles;

  /// Where the language choice persists; defaults to memory (tests, fake
  /// backend). `main()` passes a file-backed store.
  final KeyValueStore? localeStore;

  /// Real notification plugins from `main()`; null disables OS notifications
  /// (tests, or platforms without support).
  final NotificationApis? notificationApis;

  /// Initialised desktop shell from `main()`; null on mobile and in tests.
  final DesktopShellController? desktopShell;

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
  late final AppServices _services = AppServices(
    identity: _identity,
    chat: _chat,
    locale: _locale,
    notificationApis: widget.notificationApis,
    desktopShell: widget.desktopShell,
  );

  late final TrainingControllerHost _training = TrainingControllerHost(
    _identity,
  );

  @override
  void initState() {
    super.initState();
    // Context-free code (notifications, tray) reads strings through
    // currentS() / the services' StringsResolver, both following this
    // controller. Set before start(): the resolver is built from _locale, and
    // start() pushes the persisted language into the desktop shell.
    LocaleController.active = _locale;
    _services.start();
  }

  @override
  void dispose() {
    if (LocaleController.active == _locale) LocaleController.active = null;
    _training.dispose().ignore();
    _services.dispose().ignore();
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
        Provider<AppLifecycleCoordinator>.value(value: _services.lifecycle),
        Provider<ConnectionBannerPolicy>.value(value: _services.banner),
        ChangeNotifierProvider<NotificationPrefs>.value(
          value: _services.notificationPrefs,
        ),
        Provider<NotificationCenter?>.value(value: _services.notifications),
        // A ChangeNotifier must go through a listenable provider: a plain
        // Provider fails provider's debug type check, which crashed every
        // debug launch on desktop (caught by integration_test/app_launch_test).
        ChangeNotifierProvider<DesktopShellController?>.value(
          value: widget.desktopShell,
        ),
        Provider<TrainingControllerHost?>.value(value: _training),
      ],
      child: widget.child,
    );
  }
}
