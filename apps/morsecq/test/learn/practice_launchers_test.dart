import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_plan.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/comprehension/listening_comprehension_screen.dart';
import 'package:morsecq/ui/learn/goals/goal_practice_launcher.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';
import 'package:morsecq/ui/learn/plan/plan_launcher.dart';
import 'package:morsecq/ui/learn/qso/qso_setup_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

/// Pumps a button that runs [open] with a live context, taps it and settles.
Future<void> _launch(
  WidgetTester tester,
  Future<void> Function(BuildContext context) open,
) async {
  tester.view.physicalSize = const Size(430, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    l10nApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => open(context),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
}

T _screen<T extends Widget>(WidgetTester tester) =>
    tester.widget<T>(find.byType(T));

/// 20 WPM characters with 8 WPM spacing unless a test says otherwise.
const TrainingSettings _settings = TrainingSettings(
  trainer: TrainerSettings(characterWpm: 20, farnsworthWpm: 8),
);

PlanStep _step(String id, PlanStepKind kind, List<String> pool) => PlanStep(
  id: id,
  kind: kind,
  pool: pool,
  minutes: 3,
  charBudget: 3,
  lesson: 10,
  reason: PlanReason.values.first,
  seed: 5,
);

DailyPlan _plan(List<PlanStep> steps) => DailyPlan(
  id: 'plan',
  date: DailyPlan.dateKey(kTestNow),
  profileKey: '',
  seed: 3,
  budgetMinutes: 15,
  settings: const PlanSettings(
    characterWpm: 24,
    effectiveWpm: 14,
    toneHz: 700,
    groupSize: 5,
  ),
  steps: steps,
);

void main() {
  group('openGoalPractice', () {
    Future<TrainingController> launch(
      WidgetTester tester,
      RouteSkill skill, {
      int wpm = 13,
      int lesson = 10,
    }) async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: lesson),
        settings: _settings,
      );
      await _launch(
        tester,
        (context) => openGoalPractice(
          context,
          t.controller,
          FakeLearnPlaybackFactory(),
          RouteMilestone(skill: skill, wpm: wpm, attempts: 0),
        ),
      );
      return t.controller;
    }

    testWidgets('copying runs a focus drill at the milestone spacing', (
      tester,
    ) async {
      final c = await launch(tester, RouteSkill.copying);
      final session = _screen<ReceiveDrillScreen>(tester).session;
      expect(session.timing.wpm, 20, reason: 'never below the learner speed');
      expect(session.timing.farnsworthWpm, 13);
      expect(session.charBudget, 50);
      expect(session.source, ExerciseSource.focus);
      expect(session.countsTowardLesson, isFalse, reason: 'goals never unlock');
      expect(
        session.currentDrill.text.replaceAll(' ', '').split(''),
        everyElement(isIn(c.learnedChars)),
      );
    });

    testWidgets('a faster milestone raises the character speed', (
      tester,
    ) async {
      await launch(tester, RouteSkill.copying, wpm: 25);
      final session = _screen<ReceiveDrillScreen>(tester).session;
      expect(session.timing.wpm, 25);
      expect(session.timing.farnsworthWpm, isNull);
    });

    testWidgets('copying before the first lesson starts the first lesson', (
      tester,
    ) async {
      await launch(tester, RouteSkill.copying, lesson: 1);
      expect(find.byType(FirstLessonScreen), findsOneWidget);
    });

    testWidgets('sending keys learned symbols with two attempts', (
      tester,
    ) async {
      final c = await launch(tester, RouteSkill.sending);
      final screen = _screen<SendPracticeScreen>(tester);
      expect(screen.maxAttempts, 2);
      final session = screen.session!;
      expect(session.nominalTiming.wpm, 20);
      expect(session.nominalTiming.farnsworthWpm, 13);
      final symbols = session.target.replaceAll(' ', '');
      expect(symbols, hasLength(5));
      expect(symbols.split(''), everyElement(isIn(c.learnedChars)));
      final next = await screen.nextSession!();
      expect(next.nominalTiming.wpm, 20);
    });

    for (final (skill, scenario) in [
      (RouteSkill.qso, QsoScenario.respondToCq),
      (RouteSkill.contest, QsoScenario.contestExchange),
    ]) {
      testWidgets('$skill opens the QSO setup on $scenario', (tester) async {
        await launch(tester, skill, wpm: 15);
        final setup = _screen<QsoSetupScreen>(tester);
        expect(setup.initialScenario, scenario);
        expect(setup.practiceTiming!.wpm, 20);
        expect(setup.practiceTiming!.farnsworthWpm, 15);
      });
    }

    for (final (skill, mode) in [
      (RouteSkill.words, ListeningMode.words),
      (RouteSkill.phrases, ListeningMode.phrases),
      (RouteSkill.story, ListeningMode.story),
      (RouteSkill.information, ListeningMode.qso),
    ]) {
      testWidgets('$skill opens listening comprehension in $mode', (
        tester,
      ) async {
        await launch(tester, skill);
        final screen = _screen<ListeningComprehensionScreen>(tester);
        expect(screen.initialMode, mode);
        expect(screen.practiceTiming!.farnsworthWpm, 13);
      });
    }
  });

  group('openPlanStep', () {
    Future<TrainingController> launch(
      WidgetTester tester,
      PlanStep step, {
      int lesson = 10,
    }) async {
      final t = await TestTraining.create(
        progress: TrainerProgress(
          currentLesson: lesson,
          dailyPlan: _plan([step]),
        ),
        settings: _settings,
      );
      final c = t.controller;
      await _launch(
        tester,
        (context) => openPlanStep(
          context,
          controller: c,
          playback: FakeLearnPlaybackFactory(),
          step: c.todayPlan!.stepById(step.id)!,
        ),
      );
      return c;
    }

    testWidgets('a comprehension step opens its frozen mode and speeds', (
      tester,
    ) async {
      final c = await launch(
        tester,
        _step('lc', PlanStepKind.comprehension, const ['story']),
      );
      final screen = _screen<ListeningComprehensionScreen>(tester);
      expect(screen.initialMode, ListeningMode.story);
      expect(screen.planStepId, 'lc');
      expect(screen.practiceTiming!.wpm, 24);
      expect(screen.practiceTiming!.farnsworthWpm, 14);
      expect(c.todayPlan!.stepById('lc')!.state, PlanStepState.active);
    });

    testWidgets('an unknown comprehension mode falls back to words', (
      tester,
    ) async {
      await launch(
        tester,
        _step('lc', PlanStepKind.comprehension, const ['bogus']),
      );
      expect(
        _screen<ListeningComprehensionScreen>(tester).initialMode,
        ListeningMode.words,
      );
    });

    testWidgets('a QSO step opens the setup bound to the step', (tester) async {
      await launch(tester, _step('q', PlanStepKind.qso, const ['callCq']));
      final setup = _screen<QsoSetupScreen>(tester);
      expect(setup.initialScenario, QsoScenario.callCq);
      expect(setup.planStepId, 'q');
      expect(setup.practiceTiming!.wpm, 24);
    });

    testWidgets('the intro step runs the first lesson trials', (tester) async {
      final c = await launch(
        tester,
        _step('intro', PlanStepKind.intro, const ['K', 'M']),
        lesson: 1,
      );
      final screen = _screen<FirstLessonScreen>(tester);
      expect(screen.trialSession!.planStepId, 'intro');
      expect(c.todayPlan!.stepById('intro')!.state, PlanStepState.active);
    });

    testWidgets('a send step opens sending bound to the step', (tester) async {
      final c = await launch(
        tester,
        _step('send', PlanStepKind.send, const ['K', 'M', 'R', 'S']),
      );
      final screen = _screen<SendPracticeScreen>(tester);
      expect(screen.session!.planStepId, 'send');
      expect((await screen.nextSession!()).planStepId, 'send');
      expect(c.todayPlan!.stepById('send')!.state, PlanStepState.active);
    });

    testWidgets('a review step opens a receive drill bound to the step', (
      tester,
    ) async {
      await launch(
        tester,
        _step('rev', PlanStepKind.review, const ['K', 'M', 'R', 'S']),
      );
      final session = _screen<ReceiveDrillScreen>(tester).session;
      expect(session.planStepId, 'rev');
      expect(session.kind, ReceiveDrillKind.review);
      expect(session.timing.wpm, 24);
    });
  });
}
