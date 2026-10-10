// The offline storage contract (doc/architecture/OFFLINE_LEARNING.md) through
// the real app: AppScope, the lifecycle observer, the desktop quit hook and
// the Me page's confirmed clear, on the device file system. A relaunch is a
// second MorsecqApp over the same directory after the first is unmounted.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/desktop/desktop.dart' hide KeyValueStore;
import 'package:morsecq/desktop/testing/testing.dart' as fakes;
import 'package:morsecq/di/app_preferences.dart';
import 'package:morsecq/di/app_settings.dart';
import 'package:morsecq/di/desktop_store_adapter.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/lifecycle/background_task_api.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'support/scene_walk.dart';
import 'support/shot_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory scratch;
  late String learningDir;
  setUp(() async {
    scratch = await Directory.systemTemp.createTemp('morsecq_app_storage_');
    learningDir = p.join(scratch.path, 'morsecq', 'guest');
  });
  tearDown(() => scratch.delete(recursive: true));

  File settingsFile() => File(p.join(scratch.path, 'settings.json'));
  File progressFile() => File(p.join(learningDir, 'training', 'progress.json'));

  Future<TrainingController> launch(
    WidgetTester tester, {
    required String key,
    BackgroundTaskApi? background,
    DesktopShellController? desktop,
    KeyValueStore? settings,
  }) async {
    await tester.pumpWidget(
      MorsecqApp(
        key: ValueKey(key),
        learningStore: LocalLearningStore(root: () async => learningDir),
        localeStore:
            settings ?? await JsonFileKeyValueStore.open(settingsFile()),
        backgroundTasks: background,
        desktopShell: desktop,
      ),
    );
    await settle(tester, extra: const Duration(milliseconds: 500));
    expect(find.byType(AppShell), findsOneWidget);
    return tester.widget<LearnHome>(find.byType(LearnHome)).controller;
  }

  Future<void> quitProcess(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets('progress written mid-session survives backgrounding', (
    tester,
  ) async {
    Object? onDiskAtRelease;
    final background = _ObservedBackgroundTask(
      BackgroundTaskApi.forPlatform(),
      // What a suspended (or killed) process would leave behind.
      onRelease: () =>
          onDiskAtRelease = jsonDecode(progressFile().readAsStringSync()),
    );
    final c = await launch(tester, key: 'first', background: background);
    final element = tester.element(find.byType(AppShell));
    // Nothing below is awaited: only the lifecycle barrier may persist it.
    // The queued documents keep the progress save behind real disk work.
    for (var i = 0; i < 200; i++) {
      c.writeDoc('queued-$i', {'index': i}).ignore();
    }
    c.setDailyGoal(64).ignore();
    c.markFirstLessonDone().ignore();
    c.writeDoc('lifecycle-note', {'value': 'kept'}).ignore();
    element.read<AppPreferences>().reference.wpm = 24;
    element.read<LocaleController>().setLocale(const Locale('de')).ignore();
    _leaveForeground(tester);
    // The OS may suspend the process once the background task ends.
    await tester.runAsync(background.released);
    expect(background.begun, greaterThan(0));
    expect(onDiskAtRelease, containsPair('dailyGoalChars', 64));
    debugPrint('[storage] background task released');
    // A paused binding schedules no frames: resume before unmounting.
    _returnToForeground(tester);
    await quitProcess(tester);

    final again = await launch(tester, key: 'second');
    expect(again.progress.dailyGoalChars, 64);
    expect(again.progress.firstLessonDone, isTrue);
    expect(await tester.runAsync(() => again.readDoc('lifecycle-note')), {
      'value': 'kept',
    });
    final next = tester.element(find.byType(AppShell));
    expect(next.read<AppPreferences>().reference.wpm, 24);
    expect(next.read<LocaleController>().locale, const Locale('de'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop quit awaits pending learning and preference writes', (
    tester,
  ) async {
    final window = fakes.FakeWindowApi();
    final tray = fakes.FakeTrayApi();
    // As in main(): window state shares the app's settings file.
    final settings = await JsonFileKeyValueStore.open(settingsFile());
    final desktop = DesktopShellController(
      config: DesktopShellConfig(
        store: DesktopStoreAdapter(settings),
        platform: TargetPlatform.linux,
        persistDebounce: Duration.zero,
      ),
      window: window,
      tray: tray,
      screen: fakes.FakeScreenApi(),
    );
    await tester.runAsync(desktop.initialize);
    addTearDown(desktop.dispose);
    final c = await launch(
      tester,
      key: 'desktop',
      desktop: desktop,
      settings: settings,
    );
    final element = tester.element(find.byType(AppShell));
    for (var i = 0; i < 200; i++) {
      c.writeDoc('queued-$i', {'index': i}).ignore();
    }
    c.setDailyGoal(73).ignore();
    c.writeDoc('quit-note', {'value': 'kept'}).ignore();
    element.read<AppPreferences>().reference.wpm = 26;
    Object? onDiskAtQuit;
    await tester.runAsync(() async {
      await desktop.quit().timeout(const Duration(seconds: 30));
      // Read before any further I/O completes: the runner exits here.
      onDiskAtQuit = jsonDecode(progressFile().readAsStringSync());
    });
    debugPrint('[storage] desktop quit finished');
    expect(window.destroyed, isTrue);
    expect(onDiskAtQuit, containsPair('dailyGoalChars', 73));
    await quitProcess(tester);

    final again = await launch(tester, key: 'after-quit');
    expect(again.progress.dailyGoalChars, 73);
    expect(await tester.runAsync(() => again.readDoc('quit-note')), {
      'value': 'kept',
    });
    final next = tester.element(find.byType(AppShell));
    expect(next.read<AppPreferences>().reference.wpm, 26);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmed clearing keeps preferences and learning restarts', (
    tester,
  ) async {
    final background = _ObservedBackgroundTask(BackgroundTaskApi.forPlatform());
    final c = await launch(tester, key: 'before-clear', background: background);
    final element = tester.element(find.byType(AppShell));
    final s = S.of(element);
    await tester.runAsync(() async {
      await c.setDailyGoal(91);
      await c.markFirstLessonDone();
      await c.writeDoc('clear-note', {'value': 'gone'});
      await element.read<AppSettings>().applyAppearance(
        style: UiStyle.paper,
        themeMode: ThemeMode.dark,
      );
      await element.read<LocaleController>().setLocale(const Locale('en'));
      element.read<AppPreferences>().reference.wpm = 27;
      await element.read<AppPreferences>().flush();
      final recordings = Directory(p.join(learningDir, 'media', 'recordings'));
      await recordings.create(recursive: true);
      await File(p.join(recordings.path, 'clip.wav')).writeAsBytes([1, 2, 3]);
    });
    final settingsBefore = settingsFile().readAsStringSync();
    // Unawaited learning writes still pending when the learner confirms.
    c.setDailyGoal(92).ignore();
    c.writeDoc('late-note', {'value': 'gone'}).ignore();

    await selectTab(tester, ShellTab.me);
    await tapHittable(
      tester,
      find.byKey(const ValueKey('offline-clear')),
      'clear learning data',
    );
    await tapText(tester, s.guestClearConfirm);
    debugPrint('[storage] clear confirmed');
    await settle(tester, extra: const Duration(milliseconds: 500));
    expect(find.text(s.offlineCleared), findsOneWidget);
    expect(c.isDisposed, isTrue, reason: 'the old controller is retired');
    expect(Directory(p.join(learningDir, 'media')).existsSync(), isFalse);
    expect(settingsFile().readAsStringSync(), settingsBefore);

    await selectTab(tester, ShellTab.learn);
    await settle(tester, extra: const Duration(milliseconds: 500));
    final fresh = tester.widget<LearnHome>(find.byType(LearnHome)).controller;
    expect(identical(fresh, c), isFalse);
    expect(fresh.progress.dailyGoalChars, TrainerProgress().dailyGoalChars);
    expect(fresh.progress.firstLessonDone, isFalse);
    expect(await tester.runAsync(() => fresh.readDoc('clear-note')), isNull);
    expect(await tester.runAsync(() => fresh.readDoc('late-note')), isNull);
    // Backgrounding after the clear flushes only the new controller.
    fresh.setDailyGoal(33).ignore();
    _leaveForeground(tester);
    await tester.runAsync(background.released);
    _returnToForeground(tester);
    debugPrint('[storage] background save after clearing released');
    await quitProcess(tester);

    final again = await launch(tester, key: 'after-clear');
    expect(again.progress.dailyGoalChars, 33);
    expect(again.progress.firstLessonDone, isFalse);
    expect(await tester.runAsync(() => again.readDoc('late-note')), isNull);
    final next = tester.element(find.byType(AppShell));
    final appearance = next.read<AppSettings>();
    expect(appearance.style, UiStyle.paper);
    expect(appearance.themeMode, ThemeMode.dark);
    expect(next.read<LocaleController>().locale, const Locale('en'));
    expect(next.read<AppPreferences>().reference.wpm, 27);
    expect(progressFile().existsSync(), isTrue);
    expect(tester.takeException(), isNull);
  });
}

// AppLifecycleListener asserts that states change one step at a time.
void _leaveForeground(WidgetTester tester) {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

void _returnToForeground(WidgetTester tester) {
  for (final state in [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

/// Delegates to the platform's real background-task bridge (native on iOS)
/// and reports when the app gives the task back to the OS.
final class _ObservedBackgroundTask implements BackgroundTaskApi {
  _ObservedBackgroundTask(this._inner, {this.onRelease});
  final BackgroundTaskApi _inner;
  final void Function()? onRelease;
  Completer<void> _released = Completer<void>();
  var begun = 0;

  /// Completes when the latest background task is given back, or fails the
  /// test instead of hanging when the save never finishes.
  Future<void> released() =>
      _released.future.timeout(const Duration(seconds: 30));
  static const int _noNativeTask = -1;

  @override
  Future<int?> begin() async {
    begun++;
    if (_released.isCompleted) _released = Completer<void>();
    return await _inner.begin() ?? _noNativeTask;
  }

  @override
  Future<void> end(int token) async {
    onRelease?.call();
    if (token != _noNativeTask) await _inner.end(token);
    if (!_released.isCompleted) _released.complete();
  }
}
