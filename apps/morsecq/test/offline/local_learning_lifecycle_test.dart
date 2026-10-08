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
