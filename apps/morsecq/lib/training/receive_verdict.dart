import 'package:morse_trainer/morse_trainer.dart';

import 'exercise_outcome.dart';
import 'receive_session.dart';

/// What the end-of-session card tells the learner. Derived from what was
/// actually committed ([ReceiveOutcome]) and from the session's own
/// assistance record, never from the score alone (pedagogy review A4).
enum ReceiveVerdict {
  /// Nothing was answered: no credit at all.
  notCredited,

  /// Replays or reveals were used: activity only, no unlock, no SRS.
  assisted,

  /// Free practice (or practice under radio conditions): statistics and
  /// reviews as applicable, never the course.
  practice,

  /// A review session was recorded.
  reviewRecorded,

  /// A challenge passed and the next lesson is unlocked.
  unlocked,

  /// The last lesson's challenge passed: the course is complete.
  courseComplete,

  /// A challenge with fewer symbols than the course minimum.
  tooShort,

  /// A challenge below the pass accuracy overall.
  belowAccuracy,

  /// A challenge in which a new symbol was not heard often enough.
  newSymbolsUncovered,

  /// A challenge that was fine overall but weak on a new symbol.
  newSymbolsBelowPass;

  /// The attempt was a challenge that did not pass.
  bool get isFailedChallenge =>
      this == tooShort ||
      this == belowAccuracy ||
      this == newSymbolsUncovered ||
      this == newSymbolsBelowPass;

  /// Shown in the "good" colour.
  bool get isPositive =>
      this == unlocked ||
      this == courseComplete ||
      this == reviewRecorded ||
      this == practice;
}

/// Maps a recorded session to its verdict.
ReceiveVerdict verdictOf(ReceiveOutcome outcome, ReceiveSession session) {
  if (!outcome.duplicate && !outcome.credit.activity) {
    return ReceiveVerdict.notCredited;
  }
  if (session.isAssisted) return ReceiveVerdict.assisted;
  if (session.kind == ReceiveDrillKind.review) {
    return ReceiveVerdict.reviewRecorded;
  }
  if (!outcome.challenge) return ReceiveVerdict.practice;
  return switch (outcome.lessonVerdict) {
    LessonVerdict.passed || null =>
      outcome.advanced ? ReceiveVerdict.unlocked : ReceiveVerdict.courseComplete,
    LessonVerdict.tooShort => ReceiveVerdict.tooShort,
    LessonVerdict.belowPassAccuracy => ReceiveVerdict.belowAccuracy,
    LessonVerdict.newSymbolsUncovered => ReceiveVerdict.newSymbolsUncovered,
    LessonVerdict.newSymbolsBelowPass => ReceiveVerdict.newSymbolsBelowPass,
  };
}
