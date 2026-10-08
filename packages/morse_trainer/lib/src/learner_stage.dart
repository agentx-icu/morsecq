import 'char_stats.dart';
import 'koch_course.dart';
import 'recent_practice.dart';
import 'trainer_progress.dart';

/// How well one symbol is known from current independent copying.
enum CharMastery {
  /// Unlocked but never answered.
  introduced,

  /// Some attempts, not yet at the mastery bar.
  practicing,

  /// At least [LearnerStages.masteryAttempts] attempts at
  /// [LearnerStages.masteryAccuracy] or better.
  mastered,
}

/// Where a learner is on the path the pedagogy review laid out. Decided
/// from evidence in [TrainerProgress], never from calendar time; the daily
/// plan, the home card's goal line and the speed advice adapt to it.
enum LearnerStage {
  /// Lesson 1, no copying evidence and the guided first lesson not done:
  /// the learner has not heard the difference between K and M yet.
  firstUse,

  /// A symbol the current lesson introduces is not mastered yet.
  recognition,

  /// The current lesson's new symbols are mastered; the challenge is next.
  copying,

  /// The last lesson's challenge was passed. This names the character
  /// course only: practical operating readiness is `QsoReadiness`.
  coursePassed,
}

/// Stage and mastery rules. Thresholds are product defaults to calibrate.
abstract final class LearnerStages {
  static const int masteryAttempts = 10;
  static const double masteryAccuracy = 0.9;

  static CharMastery masteryOf(CharStats? stats, {int insertions = 0}) {
    if (stats == null || stats.attempts == 0) return CharMastery.introduced;
    if (stats.attempts >= masteryAttempts &&
        stats.accuracy >= masteryAccuracy &&
        stats.correct / (stats.attempts + insertions) >= masteryAccuracy) {
      return CharMastery.mastered;
    }
    return CharMastery.practicing;
  }

  /// Whether any symbol was ever copied with statistics credit (assisted
  /// and activity-only exercises leave none).
  static bool hasCopyingEvidence(TrainerProgress progress) =>
      progress.charStats.values.any((s) => s.attempts > 0);

  static LearnerStage of(
    TrainerProgress progress,
    KochCourse course, {
    DateTime? now,
    double? characterWpm,
    double? effectiveWpm,
  }) {
    if (progress.courseCompleted) return LearnerStage.coursePassed;
    if (course.lessonCount == 0) return LearnerStage.copying;
    final lesson = course.clampLesson(progress.currentLesson);
    // A learner placed at a later lesson is never "first use", even though
    // placement itself leaves no copying evidence.
    if (lesson == course.firstLesson &&
        !progress.firstLessonDone &&
        !hasCopyingEvidence(progress)) {
      return LearnerStage.firstUse;
    }
    final at = now ?? DateTime.now();
    final unmastered = course.newCharsForLesson(lesson).any((c) {
      final evidence = RecentPractice.forSymbol(
        progress.history,
        c,
        now: at,
        characterWpm: characterWpm,
        effectiveWpm: effectiveWpm,
      );
      return masteryOf(evidence.stats, insertions: evidence.insertions) !=
          CharMastery.mastered;
    });
    return unmastered ? LearnerStage.recognition : LearnerStage.copying;
  }
}
