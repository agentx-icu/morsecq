import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:test/test.dart';

import 'helpers/test_core.dart';

void main() {
  for (final futureStore in ['progress', 'settings']) {
    test('future $futureStore prevents loading writable defaults', () async {
      final error = UnsupportedDataVersion(futureStore, 2);
      final core = TestTrainingCore(
        progressStore: futureStore == 'progress'
            ? FailingProgressStore(error)
            : InMemoryTrainerStore(),
        settingsStore: futureStore == 'settings'
            ? FailingSettingsStore(error)
            : InMemoryTrainingSettingsStore(),
      );
      var notifications = 0;
      core.addListener(() => notifications++);
      await expectLater(core.load(), throwsA(same(error)));
      expect(core.isLoaded, isFalse);
      expect(notifications, 0);
      core.dispose();
    });
  }

  test(
    'ordinary load failures retain the readable settings and retry',
    () async {
      final error = StateError('storage temporarily unavailable');
      const settings = TrainingSettings(trainer: TrainerSettings(toneHz: 600));
      final core = TestTrainingCore(
        progressStore: FailingProgressStore(error),
        settingsStore: InMemoryTrainingSettingsStore(settings),
      );
      await core.load();
      expect(core.isLoaded, isTrue);
      expect(core.loadError, same(error));
      expect(core.settings, settings);
      core.dispose();
    },
  );

  test('close disposes the core and a later dispose is a no-op', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    var notified = 0;
    c.addListener(() => notified++);
    await c.setDailyGoal(10);
    expect(notified, 1);

    await c.close();
    expect(c.isDisposed, isTrue);
    c.dispose();
    expect(c.isDisposed, isTrue);
    expect(c.setDailyGoal(20), throwsStateError);
    expect(notified, 1);
  });

  test('dispose before close refuses further writes', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    c.dispose();
    c.dispose();
    expect(c.isDisposed, isTrue);
    expect(c.markFirstLessonDone(), throwsStateError);
  });
}

final class FailingProgressStore implements TrainerStore {
  FailingProgressStore(this.error);
  final Object error;

  @override
  Future<TrainerProgress?> load() async => throw error;
  @override
  Future<void> save(TrainerProgress progress) async {}
  @override
  Future<void> clear() async {}
}

final class FailingSettingsStore implements TrainingSettingsStore {
  FailingSettingsStore(this.error);
  final Object error;

  @override
  Future<TrainingSettings?> load() async => throw error;
  @override
  Future<void> save(TrainingSettings settings) async {}
  @override
  Future<void> clear() async {}
}
