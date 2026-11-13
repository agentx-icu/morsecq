import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'desktop/desktop_platform.dart';
import 'desktop/desktop_instance.dart';
import 'diagnostics/local_diagnostics.dart';
import 'desktop/linux_tray_host.dart';
import 'desktop/desktop_shell_controller.dart';
import 'desktop/init_desktop_shell.dart';
import 'di/app_scope.dart';
import 'di/app_settings.dart';
import 'di/desktop_store_adapter.dart';
import 'di/privacy_consent.dart';
import 'i18n/current_strings.dart';
import 'i18n/key_value_store.dart';
import 'i18n/l10n_extension.dart';
import 'i18n/locale_controller.dart';
import 'lifecycle/background_task_api.dart';
import 'ui/settings/settings_routes.dart';
import 'ui/learn/settings/training_settings_entry.dart';
import 'ui/legal/privacy_consent_gate.dart';
import 'ui/shell/app_shell.dart';
import 'ui/theme.dart';
import 'training/local_learning_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalDiagnostics.installErrorHandlers();

  // Own every persistent store before opening settings or learning data.
  DesktopInstance? instance;
  if (isDesktopTarget(defaultTargetPlatform)) {
    instance = await DesktopInstance.acquire(
      await getApplicationSupportDirectory(),
    );
    if (instance == null) exit(0);
  }

  await LocalDiagnostics.initialize();

  if (requiresPrivacyConsent()) {
    runApp(
      AndroidPrivacyStartup(
        openSettingsStore: _openPersistentSettingsStore,
        openConsentStore: _openAndroidConsentStore,
      ),
    );
    return;
  }

  // One settings file for app-wide choices (language, theme, playback,
  // and window bounds). Learning data stays in the local profile.
  final KeyValueStore settingsStore = await _openSettingsStore();

  // Desktop only: window bounds, close-to-tray, tray menu. No-op elsewhere.
  DesktopShellController? desktopShell;
  if (isDesktopTarget(defaultTargetPlatform)) {
    desktopShell = await initDesktopShell(
      DesktopShellConfig(
        store: DesktopStoreAdapter(settingsStore),
        // Product name, never translated; resolved through S so the desktop
        // shell has no English literal of its own.
        appName: currentS().appName,
        trayHostAvailable: Platform.isLinux ? linuxTrayHostAvailable : null,
        log: kDebugMode ? debugPrint : null,
      ),
    );
  }

  instance?.onActivate = desktopShell?.showWindow;
  runApp(
    MorsecqApp(
      localeStore: settingsStore,
      desktopShell: desktopShell,
      backgroundTasks: BackgroundTaskApi.forPlatform(),
    ),
  );
}

/// `<application support>/settings.json`; falls back to memory if the
/// directory cannot be created (the app still runs, preferences just do not
/// survive a restart).
Future<KeyValueStore> _openSettingsStore() async {
  try {
    return await _openPersistentSettingsStore();
  } on Object catch (error) {
    LocalDiagnostics.report(DiagnosticContext.settingsOpen, error);
    return InMemoryKeyValueStore();
  }
}

Future<KeyValueStore> _openPersistentSettingsStore() async {
  final dir = await getApplicationSupportDirectory();
  return JsonFileKeyValueStore.open(File(p.join(dir.path, 'settings.json')));
}

Future<KeyValueStore> _openAndroidConsentStore() async {
  const channel = MethodChannel('morsecq/privacy_consent');
  final path = await channel.invokeMethod<String>('getNoBackupDirectory');
  if (path == null || path.isEmpty) {
    throw const FileSystemException('Privacy consent storage unavailable');
  }
  return JsonFileKeyValueStore.open(File(p.join(path, 'privacy.json')));
}

/// Opens both Android stores before offering privacy consent.
class AndroidPrivacyStartup extends StatefulWidget {
  const AndroidPrivacyStartup({
    super.key,
    required this.openSettingsStore,
    required this.openConsentStore,
    this.learningStore,
  });

  final Future<KeyValueStore> Function() openSettingsStore;
  final Future<KeyValueStore> Function() openConsentStore;
  final LocalLearningStore? learningStore;

  @override
  State<AndroidPrivacyStartup> createState() => _AndroidPrivacyStartupState();
}

class _AndroidPrivacyStartupState extends State<AndroidPrivacyStartup> {
  KeyValueStore? _settings;
  KeyValueStore? _consent;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _open().ignore();
  }

  Future<void> _open() async {
    try {
      _settings = await widget.openSettingsStore();
      if (!mounted) return;
      final consent = await widget.openConsentStore();
      if (mounted) setState(() => _consent = consent);
    } on Object catch (error, stack) {
      LocalDiagnostics.capture(DiagnosticContext.settingsOpen, error, stack);
      if (mounted) setState(() => _failed = true);
    }
  }

  void _retry() {
    if (!_failed) return;
    setState(() => _failed = false);
    _open().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final consent = _consent;
    if (consent != null) {
      return MorsecqApp(
        localeStore: _settings,
        consentStore: consent,
        learningStore: widget.learningStore,
        privacyConsentRequired: true,
      );
    }
    return MaterialApp(
      key: const ValueKey('android-privacy-startup'),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      locale: LocaleController.parseLocaleName(
        _settings?.getString(LocaleController.storageKey),
      ),
      localeListResolutionCallback: LocaleController.resolve,
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: Navigator.defaultRouteName),
          builder: _buildStatus,
        ),
      ],
      routes: {Navigator.defaultRouteName: _buildStatus},
      builder: (context, child) =>
          Provider<bool>.value(value: _failed, child: child),
    );
  }

  Widget _buildStatus(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: context.watch<bool>()
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.s.privacyConsentStorageFailed),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retry,
                      child: Text(context.s.actionRetry),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    ),
  );
}

/// Root widget: local services from [AppScope], Material 3 appearance,
/// and the responsive [AppShell] opening learning directly.
class MorsecqApp extends StatelessWidget {
  const MorsecqApp({
    super.key,
    this.learningStore,
    this.localeStore,
    this.consentStore,
    this.desktopShell,
    this.backgroundTasks,
    this.privacyConsentRequired,
  });

  final LocalLearningStore? learningStore;

  /// Persistence for app preferences; memory when null.
  final KeyValueStore? localeStore;
  final KeyValueStore? consentStore;

  /// Initialised desktop shell (window + tray); null on mobile and in tests.
  final DesktopShellController? desktopShell;

  /// OS background-task bridge (iOS); null in tests.
  final BackgroundTaskApi? backgroundTasks;

  @visibleForTesting
  final bool? privacyConsentRequired;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      learningStore: learningStore,
      localeStore: localeStore,
      consentStore: consentStore,
      desktopShell: desktopShell,
      backgroundTasks: backgroundTasks,
      child: Builder(
        builder: (context) {
          final appearance = context.watch<AppSettings>();
          final locale = context.watch<LocaleController>().locale;
          final consent = context.watch<PrivacyConsent>();
          final enforceConsent =
              privacyConsentRequired ?? requiresPrivacyConsent();
          final needsConsent = enforceConsent && !consent.accepted;
          Widget buildHome(BuildContext context) =>
              enforceConsent && !context.watch<PrivacyConsent>().accepted
              ? const PrivacyConsentGate()
              : const AppShell();
          return MaterialApp(
            // onGenerateTitle supersedes `title`; the window/task title is
            // the (untranslated) product name from the ARB.
            onGenerateTitle: (context) => S.of(context).appName,
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            locale: locale,
            // Same rules as LocaleController.effectiveLocale and currentS():
            // the whole preferred list in order, script/region aware
            // (zh-TW/HK/MO -> Traditional when shipped), unknown -> English.
            localeListResolutionCallback: LocaleController.resolve,
            debugShowCheckedModeBanner: false,
            theme: MorsecqTheme.light(style: appearance.style),
            darkTheme: MorsecqTheme.dark(style: appearance.style),
            themeMode: appearance.themeMode,
            themeAnimationDuration: Duration.zero,
            // The platform can supply an initial route independently of home.
            onGenerateInitialRoutes: needsConsent
                ? (_) => [
                    MaterialPageRoute<void>(
                      settings: const RouteSettings(
                        name: Navigator.defaultRouteName,
                      ),
                      builder: buildHome,
                    ),
                  ]
                : null,
            routes: {
              Navigator.defaultRouteName: buildHome,
              if (!needsConsent)
                kTrainingSettingsRoute: (_) => const TrainingSettingsEntry(),
            },
          );
        },
      ),
    );
  }
}
