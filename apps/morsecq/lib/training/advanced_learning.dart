import 'package:morse_trainer/morse_trainer.dart';

import 'training_controller.dart';
import 'training_plan.dart';

extension AdvancedLearning on TrainingController {
  Future<void> recordListeningAttempt(ListeningAttempt attempt) =>
      commitProgress((p) {
        if (p.hasCommitted(attempt.id)) return p;
        final exercise = attempt.exercise;
        final notebook = exercise == null
            ? p.mistakeNotebook
            : p.mistakeNotebook.recordExercise(
                exerciseId: attempt.id,
                assisted: attempt.assisted,
                retryEntryId: attempt.retryEntryId,
                attempts: [
                  MistakeAttempt.listening(
                    exercise: exercise,
                    answers: attempt.answers,
                    at: attempt.at,
                    characterWpm: attempt.characterWpm,
                    effectiveWpm: attempt.effectiveWpm,
                  ),
                ],
              );
        return p.recordListening(attempt).copyWith(mistakeNotebook: notebook);
      });

  Future<void> setLearningGoal(LearningGoal goal) async {
    // A failed write keeps the selected goal in memory. Selecting it again
    // must retry persistence and finish refreshing the remaining plan.
    await commitProgress((p) => p.copyWith(learningGoal: goal));
    await refreshPlan();
  }

  LearningRoute get learningRoute => LearningRoute.evaluate(
    progress.learningGoal,
    _goalEvidence(),
    now: now(),
  );

  Iterable<GoalEvidence> _goalEvidence() sync* {
    for (final session in progress.history) {
      final speed = session.effectiveWpm;
      if (speed == null || !session.completed || !session.isKnownUnassisted) {
        continue;
      }
      final skill = switch (session.source) {
        ExerciseSource.send => RouteSkill.sending,
        ExerciseSource.course ||
        ExerciseSource.review ||
        ExerciseSource.focus ||
        ExerciseSource.material => RouteSkill.copying,
        ExerciseSource.qso when session.drillKind == 'qso-sim' =>
          session.sourceRef?.startsWith('qso:contestExchange:') ?? false
              ? RouteSkill.contest
              : RouteSkill.qso,
        _ => null,
      };
      if (skill == null) continue;
      var accuracy = session.strictAccuracy;
      var samples = session.totalChars;
      if (skill == RouteSkill.qso || skill == RouteSkill.contest) {
        final parts = session.sourceRef?.split(':').last.split('/');
        final correct = parts?.length == 2 ? int.tryParse(parts!.first) : null;
        final total = parts?.length == 2 ? int.tryParse(parts!.last) : null;
        if (correct == null || total == null || total <= 0) continue;
        samples = total;
        accuracy = correct / total;
      }
      yield GoalEvidence(
        skill: skill,
        at: session.at,
        effectiveWpm: speed,
        accuracy: accuracy,
        assisted: false,
        samples: samples,
      );
    }
    for (final attempt in progress.listeningAttempts) {
      yield GoalEvidence(
        skill: switch (attempt.mode) {
          ListeningMode.words => RouteSkill.words,
          ListeningMode.phrases => RouteSkill.phrases,
          ListeningMode.qso || ListeningMode.pota => RouteSkill.information,
          ListeningMode.story => RouteSkill.story,
        },
        at: attempt.at,
        effectiveWpm: attempt.effectiveWpm,
        accuracy: attempt.accuracy,
        assisted: attempt.assisted,
        samples: attempt.total,
      );
    }
  }

  /// Frozen plan state for a comprehension or simulator activity.
  Future<PlanStep> startGoalPlanStep(PlanStep step) async {
    final plan = todayPlan;
    if (plan?.stepById(step.id) == null ||
        (step.kind != PlanStepKind.comprehension &&
            step.kind != PlanStepKind.qso)) {
      throw StateError('not an advanced step of this profile');
    }
    final started = plan!.start(step.id);
    await commitProgress((p) => p.withDailyPlan(started));
    return started.stepById(step.id)!;
  }
}
