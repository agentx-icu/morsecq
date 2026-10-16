import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_plan.dart';
import 'package:morsecq/ui/learn/plan/today_plan_card.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

PlanStep _step(
  String id,
  PlanStepKind kind, {
  PlanStepState state = PlanStepState.pending,
  double? accuracy,
  int charBudget = 3,
}) => PlanStep(
  id: id,
  kind: kind,
  pool: const ['K', 'M', 'R', 'S'],
  minutes: 3,
  charBudget: charBudget,
  lesson: 3,
  reason: PlanReason.values.first,
  state: state,
  accuracy: accuracy,
  resultRef: state == PlanStepState.done ? 'ex-$id' : null,
  seed: 7,
);

DailyPlan _plan(List<PlanStep> steps, {DateTime? day}) => DailyPlan(
  id: 'plan-${steps.length}',
  date: DailyPlan.dateKey(day ?? kTestNow),
  profileKey: '',
  seed: 2,
  budgetMinutes: 10,
  settings: const PlanSettings(
    characterWpm: 20,
    effectiveWpm: 10,
    toneHz: 700,
    groupSize: 5,
  ),
  steps: steps,
);

SessionSummary _attempt(String stepId, Map<String, CharStats> perChar) =>
    SessionSummary(
      at: kTestNow.subtract(const Duration(minutes: 10)),
      totalChars: perChar.values.fold(0, (n, s) => n + s.attempts),
      correctChars: perChar.values.fold(0, (n, s) => n + s.correct),
      drillKind: 'groups',
      lesson: 3,
      id: 'ex-$stepId',
      source: ExerciseSource.focus,
      planStepId: stepId,
      perChar: perChar,
    );

Future<TestTraining> _pump(
  WidgetTester tester,
  TrainerProgress progress, {
  TestClock? clock,
}) async {
  tester.view.physicalSize = const Size(430, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final t = await TestTraining.create(progress: progress, clock: clock);
  addTearDown(t.controller.dispose);
  await tester.pumpWidget(
    l10nApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: t.controller,
            builder: (_, _) => TodayPlanCard(
              controller: t.controller,
              playback: FakeLearnPlaybackFactory(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return t;
}

void main() {
  testWidgets('a finished plan names the symbols that need work', (
    tester,
  ) async {
    await _pump(
      tester,
      TrainerProgress(
        currentLesson: 3,
        dailyPlan: _plan([
          _step(
            'a',
            PlanStepKind.focus,
            state: PlanStepState.done,
            accuracy: 0.7,
          ),
          _step('b', PlanStepKind.review, state: PlanStepState.done),
        ]),
        history: [
          _attempt('a', const {
            'K': CharStats(attempts: 10, correct: 5),
            'M': CharStats(attempts: 10, correct: 10),
          }),
        ],
      ),
    );
    expect(find.text(en.learnPlanComplete), findsOneWidget);
    expect(find.text(en.learnPlanNeedsWork('K')), findsOneWidget);
    expect(find.text(en.learnPlanTomorrow), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-start')), findsNothing);
    // Step results: a percentage when known, otherwise just done.
    expect(find.text(en.learnPlanStepDonePercent(70)), findsOneWidget);
    expect(find.text(en.learnPlanStepDone), findsOneWidget);
    // A finished plan's length can no longer change.
    final budget = tester.widget<SegmentedButton<int>>(
      find.byType(SegmentedButton<int>),
    );
    expect(budget.onSelectionChanged, isNull);
  });

  testWidgets('a clean finished plan says all is well', (tester) async {
    await _pump(
      tester,
      TrainerProgress(
        currentLesson: 3,
        dailyPlan: _plan([
          _step(
            'a',
            PlanStepKind.focus,
            state: PlanStepState.done,
            accuracy: 1,
          ),
        ]),
      ),
    );
    expect(find.text(en.learnPlanAllGood), findsOneWidget);
  });

  testWidgets('send steps count keyed targets', (tester) async {
    await _pump(
      tester,
      TrainerProgress(
        currentLesson: 3,
        dailyPlan: _plan([_step('s', PlanStepKind.send, charBudget: 4)]),
      ),
    );
    expect(find.text(en.learnPlanSendProgress(0, 4)), findsOneWidget);
  });

  testWidgets('stale steps can be updated from the card', (tester) async {
    final t = await _pump(tester, TrainerProgress(currentLesson: 10));
    final c = t.controller;
    expect(c.todayPlan, isNotNull, reason: 'made after the first frame');
    await c.setLesson(12);
    await tester.pumpAndSettle();
    expect(c.todayPlan!.hasStaleSteps, isTrue);
    expect(find.text(en.learnPlanStale), findsOneWidget);
    await tester.tap(find.text(en.learnPlanUpdate));
    await tester.pumpAndSettle();
    expect(c.todayPlan!.hasStaleSteps, isFalse);
    expect(find.text(en.learnPlanStale), findsNothing);
  });

  testWidgets('the budget selector changes the plan length', (tester) async {
    final t = await _pump(tester, TrainerProgress(currentLesson: 10));
    final target = DailyPlanBuilder.budgets.firstWhere(
      (m) => m != t.controller.todayPlan!.budgetMinutes,
    );
    await tester.tap(find.text(en.learnPlanBudgetMinutes(target)).first);
    await tester.pumpAndSettle();
    expect(t.controller.todayPlan!.budgetMinutes, target);
    expect(t.controller.settings.planMinutes, target);
  });

  testWidgets('a step tapped on a card left over from yesterday makes '
      'today\'s plan instead of running it', (tester) async {
    final clock = TestClock();
    final t = await _pump(
      tester,
      TrainerProgress(
        currentLesson: 3,
        dailyPlan: _plan([_step('a', PlanStepKind.focus)]),
      ),
      clock: clock,
    );
    clock.advance(const Duration(days: 1));
    await tester.tap(find.byKey(const ValueKey('plan-start')));
    await tester.pumpAndSettle();
    expect(find.byType(ReceiveDrillScreen), findsNothing);
    final today = t.controller.todayPlan!;
    expect(today.isFor(clock.now), isTrue);
    expect(t.controller.unfinishedEarlierPlan!.id, 'plan-1');
    expect(
      find.text(en.learnPlanEarlier(0, 1)),
      findsOneWidget,
      reason: 'yesterday stays visible for inspection',
    );
  });

  testWidgets('the card rolls over at local midnight', (tester) async {
    final clock = TestClock(DateTime(2026, 9, 30, 23, 59, 30));
    final t = await _pump(
      tester,
      TrainerProgress(currentLesson: 10),
      clock: clock,
    );
    final first = t.controller.todayPlan!;
    clock.advance(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();
    final next = t.controller.todayPlan!;
    expect(next.id, isNot(first.id));
    expect(next.isFor(clock.now), isTrue);
  });

  testWidgets('returning from the background on a new day refreshes', (
    tester,
  ) async {
    final clock = TestClock();
    final t = await _pump(
      tester,
      TrainerProgress(currentLesson: 10),
      clock: clock,
    );
    final first = t.controller.todayPlan!;
    clock.advance(const Duration(hours: 20));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(t.controller.todayPlan!.id, isNot(first.id));
  });
}
