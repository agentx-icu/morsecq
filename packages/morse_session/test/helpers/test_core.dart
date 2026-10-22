import 'dart:math';

import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';

/// A fixed "now" for tests: 2026-09-30 10:00 local.
final DateTime kTestNow = DateTime(2026, 9, 30, 10);

/// Mutable clock so a test can move to the next day.
final class TestClock {
  TestClock([DateTime? start]) : now = start ?? kTestNow;

  DateTime now;

  void advance(Duration by) => now = now.add(by);
}

/// [TrainingCore] with a plain listener list, standing in for the app's
/// `ChangeNotifier` mixin.
final class TestTrainingCore extends TrainingCore {
  TestTrainingCore({
    required super.progressStore,
    required super.settingsStore,
    super.course,
    super.now,
    super.random,
    super.profileKey,
    super.docs,
  });

  final List<void Function()> _listeners = <void Function()>[];

  void addListener(void Function() listener) => _listeners.add(listener);

  void removeListener(void Function() listener) =>
      _listeners.remove(listener);

  @override
  void notifyListeners() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }
}

/// In-memory stores + seeded random + injected clock, already loaded.
final class TestTraining {
  TestTraining._(
    this.progressStore,
    this.settingsStore,
    this.clock,
    this.controller,
  );

  static Future<TestTraining> create({
    TrainerProgress? progress,
    TrainingSettings? settings,
    int seed = 1,
    TestClock? clock,
  }) async {
    final c = clock ?? TestClock();
    final progressStore = InMemoryTrainerStore(progress);
    final settingsStore = InMemoryTrainingSettingsStore(settings);
    final controller = TestTrainingCore(
      progressStore: progressStore,
      settingsStore: settingsStore,
      now: () => c.now,
      random: Random(seed),
    );
    await controller.load();
    return TestTraining._(progressStore, settingsStore, c, controller);
  }

  final InMemoryTrainerStore progressStore;
  final InMemoryTrainingSettingsStore settingsStore;
  final TestClock clock;
  final TestTrainingCore controller;
}

/// Short sessions keep tests to one or two rounds.
const TrainingSettings kShortSettings = TrainingSettings(
  trainer: TrainerSettings(sessionLengthChars: 5, groupSize: 5),
);
