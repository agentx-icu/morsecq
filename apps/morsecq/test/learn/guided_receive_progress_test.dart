import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_plan.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/theme.dart';

import 'helpers/test_controller.dart';
import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';

Future<void> finish(
  TrainingController c, {
  bool assist = false,
  bool wrong = false,
}) async {
  final session = c.startGuidedSession();
  if (assist) session.markReplay();
  while (!session.isComplete) {
    session.submit(wrong ? '' : session.currentDrill.text);
  }
  await c.recordReceiveSession(session);
}

void main() {
  test(
    'failed, assisted, stale, different-speed and other-lesson runs cannot advance',
    () async {
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      await finish(t.controller, wrong: true);
      expect(t.controller.recommendedGuidedLevel, GuidedLevel.single);
      await finish(t.controller, assist: true);
      expect(t.controller.recommendedGuidedLevel, GuidedLevel.single);
      await finish(t.controller);
      expect(t.controller.recommendedGuidedLevel, GuidedLevel.short);
      t.clock.advance(const Duration(days: 15));
      expect(t.controller.recommendedGuidedLevel, GuidedLevel.single);
      await finish(t.controller);
      await t.controller.updateSettings(
        t.controller.settings.copyWith(
          trainer: t.controller.trainerSettings.copyWith(farnsworthWpm: 6),
        ),
      );
      expect(t.controller.recommendedGuidedLevel, GuidedLevel.single);
      await finish(t.controller);
      await t.controller.setLesson(2);
      expect(t.controller.recommendedGuidedLevel, GuidedLevel.single);
    },
  );
  test(
    'a perfect old-symbol-only run cannot skip new-symbol recognition',
    () async {
      final score = SessionScore.evaluate('KKKKKKKKKK', 'KKKKKKKKKK');
      final row = SessionSummary.exercise(
        score,
        id: 'old-only',
        source: ExerciseSource.focus,
        at: kTestNow,
        lesson: 2,
        sourceRef: 'guided/2/single',
        characterWpm: 20,
        effectiveWpm: 8,
        assistance: const {},
      );
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 2, history: [row]),
      );
      addTearDown(t.controller.dispose);
      expect(t.controller.recommendedGuidedLevel, GuidedLevel.single);
      for (final level in GuidedLevel.values) {
        final session = t.controller.startGuidedSession(level: level);
        while (!session.isComplete) {
          session.submit(session.currentDrill.text);
        }
        expect(
          session.finish().charStats['R']!.attempts,
          greaterThanOrEqualTo(5),
        );
      }
    },
  );
  test(
    'QSO recognition gives each of four taught symbols ten actual attempts',
    () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 42),
      );
      addTearDown(t.controller.dispose);
      final session = t.controller.startQsoSymbolSession([
        'C',
        'D',
        '?',
        '<SK>',
        'X',
      ])!;
      expect(session.chars, ['C', 'D', '?', '<SK>']);
      while (!session.isComplete) {
        session.submit(session.currentDrill.text);
      }
      final outcome = await t.controller.recordReceiveSession(session);
      expect(outcome.credit.unlock, isFalse);
      for (final c in session.chars) {
        expect(outcome.score.charStats[c]!.attempts, 10);
        expect(t.controller.masteryOf(c), CharMastery.mastered);
      }
    },
  );
  testWidgets('all three levels can be selected from the home', (tester) async {
    final t = await TestTraining.create(
      progress: TrainerProgress(firstLessonDoneAt: kTestNow),
    );
    addTearDown(t.controller.dispose);
    await tester.pumpWidget(
      l10nApp(
        home: LearnHome(
          controller: t.controller,
          playback: FakeLearnPlaybackFactory(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('guided-practice')));
    await tester.tap(find.byKey(const ValueKey('guided-practice')));
    await tester.pumpAndSettle();
    for (final level in GuidedLevel.values) {
      expect(
        find.byKey(ValueKey('guided-level-${level.name}')),
        findsOneWidget,
      );
    }
    await tester.tap(find.byKey(const ValueKey('guided-level-groups')));
    await tester.pumpAndSettle();
    final screen = tester.widget<ReceiveDrillScreen>(
      find.byType(ReceiveDrillScreen),
    );
    expect(screen.session.currentDrill.charCount, 5);
    expect(screen.session.charBudget, 20);
  });
  test(
    'the last QSO symbol includes a contrast rather than one answer option',
    () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 42),
      );
      addTearDown(t.controller.dispose);
      final session = t.controller.startQsoSymbolSession(['X'])!;
      expect(session.chars, hasLength(2));
      expect(session.chars, contains('X'));
      while (!session.isComplete) {
        session.submit(session.currentDrill.text);
      }
      final score = session.finish();
      expect(score.charStats['X']!.attempts, greaterThanOrEqualTo(10));
      expect(score.charStats.length, 2);
    },
  );
  test(
    'daily recognition guarantees evidence for the newest late-course symbol',
    () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 42),
      );
      addTearDown(t.controller.dispose);
      final plan = await t.controller.ensureTodayPlan();
      final step = plan.steps.firstWhere(
        (s) => s.kind == PlanStepKind.recognition,
      );
      final session = await t.controller.startPlanReceiveStep(step);
      while (!session.isComplete) {
        session.submit(session.currentDrill.text);
      }
      final result = await t.controller.recordReceiveSession(session);
      expect(
        result.score.charStats['<AR>']?.attempts ?? 0,
        greaterThanOrEqualTo(10),
      );
      expect(result.credit.unlock, isFalse);
      expect(t.controller.masteryOf('<AR>'), CharMastery.mastered);
    },
  );
  for (final style in UiStyle.values) {
    testWidgets(
      '$style intro fits 320px with large Chinese text on the first frame',
      (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final t = await TestTraining.create();
        addTearDown(t.controller.dispose);
        await tester.pumpWidget(
          l10nApp(
            locale: const Locale('zh'),
            theme: MorsecqTheme.light(style: style),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 740),
                textScaler: TextScaler.linear(1.8),
              ),
              child: LearnHome(
                controller: t.controller,
                playback: FakeLearnPlaybackFactory(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('start-here')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
