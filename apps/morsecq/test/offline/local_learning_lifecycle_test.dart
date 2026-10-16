import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/di/app_services.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/lifecycle/background_task_api.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/training/training_settings_store.dart';

void main() {
  test(
    'clearing flushes, retires the shared controller and reloads empty learning',
    () async {
      final progress = InMemoryTrainerStore();
      var loads = 0;
      var goalBeforeClear = 0;
      final store = _ClearingStore(() async {
        goalBeforeClear = (await progress.load())!.dailyGoalChars;
        await progress.clear();
      });
      final host = TrainingControllerHost(
        store,
        factory: () async {
          loads++;
          final controller = TrainingController(
            progressStore: progress,
            settingsStore: InMemoryTrainingSettingsStore(),
          );
          await controller.load();
          return controller;
        },
      );
      addTearDown(host.dispose);
      final first = await host.controller();
      expect(await host.controller(), same(first));
      await first.setDailyGoal(77);
      await host.clear();
      expect(first.isDisposed, isTrue);
      expect(goalBeforeClear, 77);
      final next = await host.controller();
      expect(next, isNot(same(first)));
      expect(next.progress.dailyGoalChars, TrainerProgress().dailyGoalChars);
      expect(loads, 2);
    },
  );
  test('an earlier failed save does not block confirmed clearing', () async {
    final progress = _FailingSaveStore();
    var cleared = 0;
    final host = TrainingControllerHost(
      _ClearingStore(() async {
        cleared++;
        await progress.clear();
      }),
      factory: () async {
        final controller = TrainingController(
          progressStore: progress,
          settingsStore: InMemoryTrainingSettingsStore(),
        );
        await controller.load();
        return controller;
      },
    );
    addTearDown(host.dispose);
    final first = await host.controller();
    progress.failing = true;
    await expectLater(first.setDailyGoal(55), throwsA(isA<StateError>()));
    progress.failing = false;
    await host.clear();
    expect(cleared, 1);
    expect(first.isDisposed, isTrue);
    final next = await host.controller();
    expect(next.progress.dailyGoalChars, TrainerProgress().dailyGoalChars);
  });
  test('a failed open can be retried without a restart', () async {
    var failed = true;
    final host = TrainingControllerHost(
      LocalLearningStore(),
      factory: () async {
        if (failed) throw StateError('temporarily unavailable');
        final c = TrainingController(
          progressStore: InMemoryTrainerStore(),
          settingsStore: InMemoryTrainingSettingsStore(),
        );
        await c.load();
        return c;
      },
    );
    addTearDown(host.dispose);
    await expectLater(host.controller(), throwsStateError);
    failed = false;
    expect((await host.controller()).isLoaded, isTrue);
  });
  testWidgets(
    'backgrounding awaits local flush within the native grace period',
    (tester) async {
      final background = _RecordingBackgroundTask();
      final locale = LocaleController(InMemoryKeyValueStore());
      final saved = Completer<void>();
      var calls = 0;
      final services = AppServices(
        locale: locale,
        backgroundTasks: background,
        flush: () {
          calls++;
          return saved.future;
        },
      );
      services.start();
      addTearDown(services.dispose);
      addTearDown(locale.dispose);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(calls, 1);
      expect(background.started, 1);
      expect(background.ended, 0);
      saved.complete();
      await tester.pump();
      expect(background.ended, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    },
  );
  testWidgets(
    'backgrounding again during a slow save also saves the newer writes',
    (tester) async {
      final background = _RecordingBackgroundTask();
      final locale = LocaleController(InMemoryKeyValueStore());
      final saves = <Completer<void>>[];
      final services = AppServices(
        locale: locale,
        backgroundTasks: background,
        flush: () {
          saves.add(Completer<void>());
          return saves.last.future;
        },
      );
      services.start();
      addTearDown(services.dispose);
      addTearDown(locale.dispose);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(saves, hasLength(1));
      // Back in the foreground the learner saves more progress, then leaves
      // again before the first barrier has finished.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      saves.first.complete();
      await tester.pump();
      expect(saves, hasLength(2), reason: 'a fresh barrier covers new writes');
      expect(background.ended, 0, reason: 'the task covers the second save');
      saves.last.complete();
      await tester.pump();
      expect(background.ended, background.started);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    },
  );
}

final class _RecordingBackgroundTask implements BackgroundTaskApi {
  var started = 0;
  var ended = 0;
  @override
  Future<int?> begin() async => ++started;
  @override
  Future<void> end(int token) async {
    ended++;
  }
}

final class _ClearingStore extends LocalLearningStore {
  _ClearingStore(this.onClear);
  final Future<void> Function() onClear;
  @override
  Future<void> clear() => onClear();
}

final class _FailingSaveStore implements TrainerStore {
  final InMemoryTrainerStore _inner = InMemoryTrainerStore();
  var failing = false;
  @override
  Future<TrainerProgress?> load() => _inner.load();
  @override
  Future<void> save(TrainerProgress progress) async {
    if (failing) throw StateError('disk full');
    await _inner.save(progress);
  }

  @override
  Future<void> clear() => _inner.clear();
}
