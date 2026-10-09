import 'daily_plan.dart';
import 'daily_plan_builder.dart';
import 'learner_stage.dart';
import 'learning_goal.dart';

/// Reuses review and readable sending while replacing completed coursework
/// with the selected route's listening and interactive exchange.
abstract final class GoalPlanBuilder {
  static List<PlanStep> enrich(List<PlanStep> steps, PlanInputs inputs) {
    if (inputs.goal == null || inputs.stage != LearnerStage.coursePassed) {
      return steps;
    }
    final course = steps.firstWhere((s) => s.kind == PlanStepKind.course);
    final goal = inputs.goal!;
    final mode = switch (goal) {
      LearningGoal.firstQso => 'qso',
      LearningGoal.conversation =>
        inputs.settings.effectiveWpm >= 18 ? 'story' : 'phrases',
      LearningGoal.contest => 'pota',
    };
    final scenario = switch (goal) {
      LearningGoal.firstQso => 'shortExchange',
      LearningGoal.conversation => 'respondToCq',
      LearningGoal.contest => 'contestExchange',
    };
    return [
      for (final step in steps)
        if (step.kind != PlanStepKind.course)
          step
        else ...[
          _step(
            course,
            PlanStepKind.comprehension,
            mode,
            PlanReason.goalListening,
            1,
          ),
          _step(course, PlanStepKind.qso, scenario, PlanReason.goalExchange, 1),
        ],
    ];
  }

  static PlanStep _step(
    PlanStep from,
    PlanStepKind kind,
    String content,
    PlanReason reason,
    int attempts,
  ) => PlanStep(
    id: '${from.id}_${kind.name}',
    kind: kind,
    pool: [content],
    minutes: from.minutes / 2,
    charBudget: attempts,
    lesson: from.lesson,
    reason: reason,
    seed: from.seed,
    settings: from.settings,
  );
}
