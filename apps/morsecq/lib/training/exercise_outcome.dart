import 'package:morse_trainer/morse_trainer.dart';

/// What recording a receive session did to the learner's state.
final class ReceiveOutcome {
  const ReceiveOutcome({
    required this.score,
    required this.passed,
    required this.advanced,
    required this.lesson,
    this.saved = true,
    this.credit = ExerciseCredit.none,
    this.duplicate = false,
    this.exerciseId,
  });

  final SessionScore score;

  /// What the exercise was credited with (spec §3.3).
  final ExerciseCredit credit;

  /// The exercise id was already committed; nothing was credited again.
  final bool duplicate;
  final String? exerciseId;

  /// Whether the attempt was assisted (no SRS, unlock or speed evidence).
  bool get assisted => credit.activity && !credit.receiveStats;

  /// False when writing progress failed. The session still counts in memory
  /// and is written by [TrainingController.retryProgressSave] or the next
  /// successful save.
  final bool saved;

  /// Whether the Koch unlock rule was met (regardless of [advanced]).
  final bool passed;

  /// Whether the current lesson moved forward.
  final bool advanced;

  /// Lesson after recording.
  final int lesson;
}

/// What recording a send session did.
final class SendOutcome {
  const SendOutcome({required this.score, this.saved = true});

  final SessionScore score;

  /// See [ReceiveOutcome.saved].
  final bool saved;
}

/// Marks the plan step [stepId] done with [exerciseId], inside the same
/// progress value the exercise is committed with (one write).
TrainerProgress completePlanStep(
  TrainerProgress next,
  String? stepId,
  String exerciseId,
  SessionScore score,
) {
  final plan = next.dailyPlan;
  final step = stepId == null ? null : plan?.stepById(stepId);
  if (plan == null || step == null || step.isDone) return next;
  if (step.kind == PlanStepKind.send) {
    // A send step completes after its number of keyed targets.
    final attempts = next.history.where((s) => s.planStepId == stepId).length;
    if (attempts < step.charBudget) return next;
    return next.copyWith(
      dailyPlan: plan.complete(stepId!, exerciseId: exerciseId),
    );
  }
  return next.copyWith(
    dailyPlan: plan.complete(
      stepId!,
      exerciseId: exerciseId,
      accuracy: score.strictAccuracy,
    ),
  );
}
