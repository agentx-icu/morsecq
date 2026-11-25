import 'package:morse_trainer/morse_trainer.dart';

/// Typed validation of a stored `progress.json`, shared by the app's file
/// store, the learning backup and the mini-program bridge.
abstract final class TrainerProgressCodec {
  /// Decodes and validates a progress document; throws [FormatException]
  /// when the structure is readable but the values are impossible.
  static TrainerProgress decode(Map<String, Object?> json) {
    final progress = TrainerProgress.fromJson(json);
    // Model constructors use assertions. Files must be validated in release
    // builds too, before invalid counters or SRS indexes reach the trainer.
    final invalid =
        progress.currentLesson < 1 ||
        progress.streakDays < 0 ||
        progress.dailyGoalChars < 0 ||
        progress.maxHistory <= 0 ||
        // Lifetime counters can never be below what the kept history shows.
        progress.lifetimeSessions < progress.history.length ||
        progress.lifetimeChars <
            progress.history.fold<int>(0, (sum, s) => sum + s.totalChars) ||
        progress.charStats.values.any(
          (s) => s.attempts < 0 || s.correct < 0 || s.correct > s.attempts,
        ) ||
        progress.history.any(
          (s) =>
              s.totalChars < 0 ||
              s.correctChars < 0 ||
              s.correctChars > s.totalChars ||
              (s.lesson != null && s.lesson! < 1) ||
              (s.elapsed?.isNegative ?? false),
        ) ||
        progress.srs.intervals.any((interval) => interval.isNegative) ||
        progress.srs.cards.values.any(
          (card) => card.box < 0 || card.box > progress.srs.maxBox,
        ) ||
        progress.confusion.targets.any(
          (target) => progress.confusion
              .rowFor(target)
              .values
              .any((count) => count < 0),
        );
    if (invalid) throw const FormatException('Invalid training progress');
    return progress;
  }
}
