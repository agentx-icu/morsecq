import 'package:morse_core/morse_core.dart';
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
    this.challenge = false,
    this.attemptedLesson,
    this.lessonVerdict,
    this.courseCompleted = false,
  });

  final SessionScore score;

  /// What the exercise was credited with (spec §3.3).
  final ExerciseCredit credit;

  /// The exercise id was already committed; nothing was credited again.
  final bool duplicate;
  final String? exerciseId;

  ReceiveOutcome withSaved(bool saved) => ReceiveOutcome(
    score: score,
    passed: passed,
    advanced: advanced,
    lesson: lesson,
    saved: saved,
    credit: credit,
    duplicate: duplicate,
    exerciseId: exerciseId,
    challenge: challenge,
    attemptedLesson: attemptedLesson,
    lessonVerdict: lessonVerdict,
    courseCompleted: courseCompleted,
  );

  /// Whether the attempt was assisted (no SRS, unlock or speed evidence).
  bool get assisted => credit.activity && !credit.receiveStats;

  /// False when writing progress failed. The session still counts in memory
  /// and is written by [TrainingController.retryProgressSave] or the next
  /// successful save.
  final bool saved;

  /// The attempt was an eligible course challenge **and** met the lesson
  /// rule ([KochCourse.evaluate]). Free practice, assisted attempts and
  /// attempts at another lesson are never "passed", whatever their score.
  final bool passed;

  /// Whether the current lesson moved forward.
  final bool advanced;

  /// Lesson after recording.
  final int lesson;

  /// The attempt was committed as a course challenge: unlock credit, the
  /// session counted toward the lesson, and it was an attempt at the
  /// lesson the learner is on. Exactly the condition under which the Koch
  /// rule was applied.
  final bool challenge;

  /// The lesson the attempt was made at (before any advance).
  final int? attemptedLesson;

  /// How the lesson rule judged the score at [attemptedLesson]; null when
  /// the lesson is unknown or invalid.
  final LessonVerdict? lessonVerdict;

  /// Whether the course is completed after recording.
  final bool courseCompleted;
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
  SessionScore score, {
  required DateTime now,
  required String profileKey,
  double? accuracy,
}) {
  final plan = next.dailyPlan;
  final step = stepId == null ? null : plan?.stepById(stepId);
  if (plan == null ||
      step == null ||
      step.isDone ||
      ((step.kind == PlanStepKind.qso ||
              step.kind == PlanStepKind.comprehension) &&
          step.state != PlanStepState.active) ||
      !plan.isFor(now) ||
      plan.profileKey != profileKey) {
    return next;
  }
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
      accuracy: accuracy ?? score.strictAccuracy,
    ),
  );
}

/// The pure part of `TrainingController.recordExercise`: builds the
/// exercise record, applies [CreditPolicy], the Koch rule (course sessions
/// with unlock credit for the current lesson only) and the plan step, and
/// returns the progress to commit in one write.
(TrainerProgress, ReceiveOutcome) applyExercise(
  TrainerProgress progress, {
  required KochCourse course,
  required DateTime now,
  required SessionScore score,
  required String id,
  required ExerciseSource source,
  required Set<Assistance> assistance,
  required bool answered,
  required bool completed,
  required MorseTiming timing,
  required double toneHz,
  required Set<String> learned,
  required bool countsTowardLesson,
  int? lesson,
  Duration? active,
  String? planStepId,
  double? planAccuracy,
  required String profileKey,
  String? sourceRef,
  String? detailRef,
  RadioScenario? conditions,
}) {
  if (progress.hasCommitted(id)) {
    return (
      progress,
      ReceiveOutcome(
        score: score,
        passed: false,
        advanced: false,
        lesson: progress.currentLesson,
        duplicate: true,
        exerciseId: id,
        courseCompleted: progress.courseCompleted,
      ),
    );
  }
  final credit = CreditPolicy.decide(
    source: source,
    completed: completed,
    answered: answered,
    assistance: assistance,
  );
  final summary = SessionSummary.exercise(
    score,
    id: id,
    source: source,
    at: score.at ?? now,
    assistance: assistance,
    lesson: lesson ?? score.lesson ?? progress.currentLesson,
    characterWpm: timing.wpm,
    effectiveWpm: timing.isFarnsworth ? timing.farnsworthWpm : timing.wpm,
    toneHz: toneHz,
    completed: completed,
    active: active,
    planStepId: planStepId,
    sourceRef: sourceRef,
    detailRef: detailRef,
    conditions: conditions,
  );
  var next = progress.recordExercise(
    score,
    summary,
    credit: credit,
    now: summary.at,
    learned: learned,
  );
  final before = next.currentLesson;
  final attempted = lesson ?? before;
  // The one place that decides whether an attempt is a course challenge.
  final challenge = credit.unlock && countsTowardLesson && attempted == before;
  final verdict = course.isValidLesson(attempted)
      ? course.evaluate(score, attempted)
      : null;
  if (challenge) next = next.advanceIfPassed(course, score);
  // A plan step only completes with credited activity (no blank runs).
  if (credit.activity) {
    next = completePlanStep(
      next,
      planStepId,
      id,
      score,
      now: now,
      profileKey: profileKey,
      accuracy: planAccuracy,
    );
  }
  if (next.currentLesson != before && next.dailyPlan != null) {
    next = next.copyWith(dailyPlan: next.dailyPlan!.markPendingStale());
  }
  return (
    next,
    ReceiveOutcome(
      score: score,
      passed: challenge && verdict == LessonVerdict.passed,
      advanced: next.currentLesson != before,
      lesson: next.currentLesson,
      credit: credit,
      exerciseId: id,
      challenge: challenge,
      attemptedLesson: attempted,
      lessonVerdict: verdict,
      courseCompleted: next.courseCompleted,
    ),
  );
}
