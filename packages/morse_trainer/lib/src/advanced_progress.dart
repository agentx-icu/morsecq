part of 'trainer_progress.dart';

/// Optional additions to old profiles, serialized in the same atomic write
/// as course progress. Separating these keeps the main progress model small.
final class _AdvancedProgress {
  _AdvancedProgress(
    MistakeNotebook? mistakes,
    this.goal,
    Iterable<ListeningAttempt> attempts,
  ) : mistakes = mistakes ?? MistakeNotebook(),
      attempts = List.unmodifiable(attempts);

  final MistakeNotebook mistakes;
  final LearningGoal goal;
  final List<ListeningAttempt> attempts;

  Map<String, Object?> toJson() => {
    'mistakeNotebook': mistakes.toJson(),
    'learningGoal': goal.name,
    'listeningAttempts': attempts.map((a) => a.toJson()).toList(),
  };

  factory _AdvancedProgress.fromJson(Map<String, Object?> json) =>
      _AdvancedProgress(
        json['mistakeNotebook'] == null
            ? null
            : MistakeNotebook.fromJson(
                json['mistakeNotebook'] as Map<String, Object?>,
              ),
        LearningGoal.parse(json['learningGoal'] as String?),
        [
          for (final raw in json['listeningAttempts'] as List? ?? [])
            ListeningAttempt.fromJson(raw as Map<String, Object?>),
        ],
      );
}

extension ListeningProgress on TrainerProgress {
  /// Information scores are activity and route evidence, never character
  /// accuracy, Koch unlocks or receive SRS. IDs remain remembered on trimming.
  TrainerProgress recordListening(ListeningAttempt attempt) {
    if (hasCommitted(attempt.id)) return this;
    final all = [...listeningAttempts, attempt];
    if (all.length > maxHistory) all.removeRange(0, all.length - maxHistory);
    final plan = dailyPlan;
    final stepId = attempt.planStepId;
    final ownStep = stepId == null ? null : plan?.stepById(stepId);
    final nextPlan =
        plan != null &&
            plan.isFor(attempt.at) &&
            ownStep?.kind == PlanStepKind.comprehension &&
            ownStep?.state == PlanStepState.active
        ? plan.complete(
            stepId!,
            exerciseId: attempt.id,
            accuracy: attempt.accuracy,
          )
        : plan;
    return copyWith(
      listeningAttempts: all,
      committedIds: _withId(attempt.id),
      lifetimeSessions: lifetimeSessions + 1,
      streakDays: streakAfterPracticeOn(attempt.at),
      lastPracticeDay: latestPracticeDay(attempt.at),
      dailyPlan: nextPlan,
    );
  }
}
