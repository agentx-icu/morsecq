import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../desktop/desktop_shell_controller.dart';
import '../i18n/key_value_store.dart';
import '../i18n/locale_controller.dart';
import '../keying/key_profiles.dart';
import '../lifecycle/background_task_api.dart';
import '../training/local_learning_store.dart';
import '../training/training_controller_host.dart';
import '../ui/listen/listen_preferences.dart';
import '../ui/reference/reference_playback_settings.dart';
import 'app_preferences.dart';
import 'app_services.dart';
import 'app_settings.dart';

class AppScope extends StatefulWidget {
  const AppScope({
    super.key,
    required this.child,
    this.learningStore,
    this.localeStore,
    this.desktopShell,
    this.backgroundTasks,
  });
  final Widget child;
  final LocalLearningStore? learningStore;
  final KeyValueStore? localeStore;
  final DesktopShellController? desktopShell;
  final BackgroundTaskApi? backgroundTasks;
  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final _store = widget.localeStore ?? InMemoryKeyValueStore();
  late final _preferences = AppPreferences(_store);
  late final _locale = LocaleController(_store);
  late final _keys = KeyProfiles(_store);
  late final _learning = widget.learningStore ?? LocalLearningStore();
  late final _training = TrainingControllerHost(_learning);
  late final _services = AppServices(
    locale: _locale,
    flush: _flush,
    desktopShell: widget.desktopShell,
    backgroundTasks: widget.backgroundTasks,
  );
  Future<void> _flush() async => Future.wait<void>([
    _preferences.flush(),
    _locale.flush(),
    _keys.flush(),
    _training.flush(),
  ]);
  @override
  void initState() {
    super.initState();
    LocaleController.active = _locale;
    _services.start();
  }

  @override
  void dispose() {
    if (LocaleController.active == _locale) LocaleController.active = null;
    _services.dispose();
    _training.dispose();
    _preferences.dispose();
    _locale.dispose();
    _keys.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<AppPreferences>.value(value: _preferences),
      ChangeNotifierProvider<AppSettings>.value(value: _preferences.settings),
      ChangeNotifierProvider<LocaleController>.value(value: _locale),
      ChangeNotifierProvider<KeyProfiles?>.value(value: _keys),
      ChangeNotifierProvider<ReferencePlaybackSettings>.value(
        value: _preferences.reference,
      ),
      ChangeNotifierProvider<ListenPreferences>.value(
        value: _preferences.listen,
      ),
      ChangeNotifierProvider<DesktopShellController?>.value(
        value: widget.desktopShell,
      ),
      Provider<TrainingControllerHost>.value(value: _training),
      Provider<TrainingControllerHost?>.value(value: _training),
      Provider<LocalLearningStore>.value(value: _learning),
    ],
    child: widget.child,
  );
}
