import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_plan.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/learn/plan/speed_advice_card.dart';

import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

final String _newest = KochCourse().newCharForLesson(10);

/// Three comparable receive sessions at 20/[eff] WPM, [correct] of 60 right.
TrainerProgress _evidence({required int correct, double eff = 8}) =>
    TrainerProgress(
      currentLesson: 10,
      history: <SessionSummary>[
        for (var i = 2; i >= 0; i--)
          SessionSummary(
            at: kTestNow.subtract(Duration(hours: i + 1)),
            totalChars: 60,
            correctChars: correct,
            drillKind: 'review',
            lesson: 10,
            id: 'ex$i',
            source: ExerciseSource.review,
            characterWpm: 20,
            effectiveWpm: eff,
            insertions: 0,
            assistance: const {},
            perChar: {_newest: const CharStats(attempts: 20, correct: 20)},
          ),
      ],
      charStats: {_newest: const CharStats(attempts: 20, correct: 20)},
    );

Future<void> _pump(WidgetTester tester, TrainingController c) async {
  await tester.pumpWidget(
    l10nApp(
      home: Scaffold(
        body: AnimatedBuilder(
          animation: c,
          builder: (_, _) => SpeedAdviceCard(controller: c),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final Finder _card = find.byKey(const ValueKey('speed-advice-card'));

final class _FailingSettingsStore implements TrainingSettingsStore {
  @override
  Future<TrainingSettings?> load() async => null;
  @override
  Future<void> save(TrainingSettings settings) async =>
      throw StateError('disk full');
  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets('nothing shows without a pending recommendation', (tester) async {
    final t = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 10),
    );
    await _pump(tester, t.controller);
    expect(_card, findsNothing);
  });

  testWidgets('raise: Apply changes the spacing and hides the batch', (
    tester,
  ) async {
    final t = await TestTraining.create(progress: _evidence(correct: 60));
    final c = t.controller;
    final advice = c.pendingSpeedAdvice!;
    await _pump(tester, c);
    expect(_card, findsOneWidget);
    expect(
      find.text(en.learnSpeedAdviceRaise(advice.effectiveWpm.round())),
      findsOneWidget,
    );
    expect(find.text(en.learnSpeedAdviceBody(3, 100)), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
    expect(c.trainerSettings.farnsworthWpm, 8, reason: 'never automatic');

    await tester.tap(find.byKey(const ValueKey('speed-advice-apply')));
    await tester.pumpAndSettle();
    expect(c.trainerSettings.farnsworthWpm, advice.effectiveWpm);
    expect(_card, findsNothing);
  });

  testWidgets('lower: Not now keeps the speeds and hides the batch', (
    tester,
  ) async {
    final t = await TestTraining.create(progress: _evidence(correct: 40));
    final c = t.controller;
    final before = c.settings;
    final advice = c.pendingSpeedAdvice!;
    expect(advice.kind, SpeedAdviceKind.decrease);
    await _pump(tester, c);
    expect(
      find.text(en.learnSpeedAdviceLower(advice.effectiveWpm.round())),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.trending_down), findsOneWidget);
    expect(find.text(en.learnSpeedAdviceBody(3, 67)), findsOneWidget);
    await tester.tap(find.text(en.learnSpeedAdviceDismiss));
    await tester.pumpAndSettle();
    expect(_card, findsNothing);
    expect(c.settings, before);
  });

  testWidgets('raise both speeds names the new character speed', (
    tester,
  ) async {
    final t = await TestTraining.create(
      progress: _evidence(correct: 60, eff: 20),
      settings: const TrainingSettings(
        trainer: TrainerSettings(characterWpm: 20, farnsworthWpm: null),
      ),
    );
    final advice = t.controller.pendingSpeedAdvice!;
    expect(advice.kind, SpeedAdviceKind.increaseBoth);
    await _pump(tester, t.controller);
    expect(
      find.text(en.learnSpeedAdviceRaiseBoth(advice.characterWpm.round())),
      findsOneWidget,
    );
  });

  testWidgets('a failed save reverts quietly and keeps the advice', (
    tester,
  ) async {
    final c = TrainingController(
      progressStore: InMemoryTrainerStore(_evidence(correct: 60)),
      settingsStore: _FailingSettingsStore(),
      now: () => kTestNow,
      random: Random(1),
    );
    await c.load();
    addTearDown(c.dispose);
    await _pump(tester, c);
    final before = c.settings;
    await tester.tap(find.byKey(const ValueKey('speed-advice-apply')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(c.settings, before, reason: 'the controller reverts the speeds');
    expect(_card, findsOneWidget, reason: 'the batch was not used up');
  });
}
