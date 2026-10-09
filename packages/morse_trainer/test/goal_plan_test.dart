import 'package:test/test.dart';
import 'package:morse_trainer/src/daily_plan.dart';
import 'package:morse_trainer/src/daily_plan_builder.dart';
import 'package:morse_trainer/src/learning_goal.dart';
import 'package:morse_trainer/src/learner_stage.dart';
import 'package:morse_trainer/src/koch_course.dart';
import 'package:morse_trainer/src/confusion_matrix.dart';

void main() {
  PlanInputs inputs({
    LearnerStage stage = LearnerStage.coursePassed,
    LearningGoal goal = LearningGoal.firstQso,
  }) => PlanInputs(
    now: DateTime(2026, 10, 9),
    profileKey: 'guest',
    budgetMinutes: 10,
    lesson: 42,
    course: KochCourse(),
    due: [],
    charStats: {},
    confusion: ConfusionMatrix(),
    seed: 4,
    stage: stage,
    firstLessonDone: true,
    goal: goal,
    settings: const PlanSettings(
      characterWpm: 20,
      effectiveWpm: 13,
      toneHz: 600,
      groupSize: 5,
    ),
  );

  test(
    'completed course daily plan includes listening and actual QSO practice',
    () {
      final plan = DailyPlanBuilder.build(inputs());
      expect(
        plan.steps.any((s) => s.kind == PlanStepKind.comprehension),
        isTrue,
      );
      expect(plan.steps.any((s) => s.kind == PlanStepKind.qso), isTrue);
      expect(plan.steps.any((s) => s.unlockEligible), isFalse);
      expect(plan.steps.any((s) => s.kind == PlanStepKind.send), isTrue);
      expect(plan.estimatedMinutes, closeTo(10, .01));
    },
  );
  test('goal changes content but preserves the beginner course path', () {
    final beginner = DailyPlanBuilder.build(
      inputs(stage: LearnerStage.recognition),
    );
    expect(
      beginner.steps.any((s) => s.kind == PlanStepKind.comprehension),
      isFalse,
    );
    final contest = DailyPlanBuilder.build(inputs(goal: LearningGoal.contest));
    expect(contest.steps.firstWhere((s) => s.kind == PlanStepKind.qso).pool, [
      'contestExchange',
    ]);
  });
  test(
    'refreshing a changed goal retains completed and active steps and speeds',
    () {
      var plan = DailyPlanBuilder.build(inputs());
      final done = plan.steps.first;
      plan = plan.start(done.id).complete(done.id, exerciseId: 'e');
      final active = plan.steps.last;
      plan = plan.start(active.id);
      final next = DailyPlanBuilder.refreshPending(
        plan,
        inputs(goal: LearningGoal.contest),
      );
      expect(next.stepById(done.id)!.resultRef, 'e');
      expect(next.stepById(active.id)!.settings, plan.settings);
      expect(next.steps.map((s) => s.id).toSet().length, next.steps.length);
      expect(
        DailyPlan.fromJson(next.toJson()).steps.map((s) => s.kind),
        next.steps.map((s) => s.kind),
      );
    },
  );
}
