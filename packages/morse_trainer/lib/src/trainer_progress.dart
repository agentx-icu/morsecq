import 'char_stats.dart';
import 'confusion_matrix.dart';
import 'koch_course.dart';
import 'session_score.dart';
import 'session_summary.dart';
import 'srs_scheduler.dart';

/// Everything the trainer remembers about a learner.
///
/// Immutable; [recordSession] returns the updated progress. Persist it with a
/// `TrainerStore` (the app supplies the file-backed implementation).
final class TrainerProgress {
  TrainerProgress({
    this.currentLesson = 1,
    Map<String, CharStats> charStats = const <String, CharStats>{},
    this.streakDays = 0,
    DateTime? lastPracticeDay,
    this.dailyGoalChars = 100,
    List<SessionSummary> history = const <SessionSummary>[],
    SrsScheduler? srs,
    ConfusionMatrix? confusion,
    this.maxHistory = 500,
  }) : assert(currentLesson >= 1, 'currentLesson must be >= 1'),
       assert(streakDays >= 0, 'streakDays must be >= 0'),
       assert(dailyGoalChars >= 0, 'dailyGoalChars must be >= 0'),
       assert(maxHistory > 0, 'maxHistory must be positive'),
       charStats = Map<String, CharStats>.unmodifiable(charStats),
       lastPracticeDay = lastPracticeDay == null
           ? null
           : dayOf(lastPracticeDay),
       history = List<SessionSummary>.unmodifiable(history),
       srs = srs ?? SrsScheduler(),
       confusion = confusion ?? ConfusionMatrix();

  /// 1-based Koch lesson the learner is working on.
  final int currentLesson;

  /// Lifetime per-symbol counters.
  final Map<String, CharStats> charStats;

  /// Consecutive days with at least one session, as of [lastPracticeDay].
  final int streakDays;

  /// Local calendar day (midnight) of the most recent session, or null.
  final DateTime? lastPracticeDay;

  /// Symbols per day the learner aims for.
  final int dailyGoalChars;

  /// Newest last; trimmed to [maxHistory].
  final List<SessionSummary> history;

  final SrsScheduler srs;

  /// Lifetime confusion counts.
  final ConfusionMatrix confusion;

  final int maxHistory;

  /// Local midnight of [when].
  static DateTime dayOf(DateTime when) =>
      DateTime(when.year, when.month, when.day);

  int get totalCharsPracticed =>
      history.fold<int>(0, (sum, s) => sum + s.totalChars);

  int get sessionCount => history.length;

  /// Lifetime correct / attempted over every symbol; 0 with no data.
  double get overallAccuracy {
    var attempts = 0;
    var correct = 0;
    for (final s in charStats.values) {
      attempts += s.attempts;
      correct += s.correct;
    }
    return attempts == 0 ? 0 : correct / attempts;
  }

  /// Symbols practised on the calendar day of [when].
  int charsOn(DateTime when) {
    final day = dayOf(when);
    return history
        .where((s) => dayOf(s.at) == day)
        .fold<int>(0, (sum, s) => sum + s.totalChars);
  }

  bool dailyGoalMet(DateTime now) => charsOn(now) >= dailyGoalChars;

  /// The streak as seen from [now]: 0 once a full day has been skipped.
  int streakAsOf(DateTime now) {
    final last = lastPracticeDay;
    if (last == null) {
      return 0;
    }
    final gap = dayOf(now).difference(last).inDays;
    return gap > 1 ? 0 : streakDays;
  }

  /// Folds a finished session into the progress.
  ///
  /// [lesson] defaults to the score's lesson, then to [currentLesson].
  /// [now] must be supplied so callers (and tests) control the clock.
  TrainerProgress recordSession(
    SessionScore score, {
    required DateTime now,
    int? lesson,
    bool updateSrs = true,
    double srsPassAccuracy = 0.9,
  }) {
    final today = dayOf(now);
    final last = lastPracticeDay;
    final int streak;
    if (last == null) {
      streak = 1;
    } else {
      final gap = today.difference(last).inDays;
      streak = gap == 0 ? streakDays : (gap == 1 ? streakDays + 1 : 1);
    }

    final summary = SessionSummary.fromScore(
      score,
      at: score.at ?? now,
      lesson: lesson ?? score.lesson ?? currentLesson,
    );
    final nextHistory = <SessionSummary>[...history, summary];
    if (nextHistory.length > maxHistory) {
      nextHistory.removeRange(0, nextHistory.length - maxHistory);
    }

    final mergedConfusion = confusion.copy()..merge(score.confusion);

    return copyWith(
      charStats: CharStats.merge(charStats, score.charStats),
      streakDays: streak,
      lastPracticeDay: today,
      history: nextHistory,
      srs: updateSrs
          ? srs.applyScore(score, now: now, passAccuracy: srsPassAccuracy)
          : srs,
      confusion: mergedConfusion,
    );
  }

  /// Moves to [course]'s next lesson when [score] passes, otherwise unchanged.
  TrainerProgress advanceIfPassed(KochCourse course, SessionScore score) {
    if (!course.isValidLesson(currentLesson)) {
      return this;
    }
    final next = course.nextLesson(currentLesson, score);
    return next == currentLesson ? this : copyWith(currentLesson: next);
  }

  TrainerProgress withLesson(int lesson) => copyWith(currentLesson: lesson);

  TrainerProgress copyWith({
    int? currentLesson,
    Map<String, CharStats>? charStats,
    int? streakDays,
    DateTime? lastPracticeDay,
    int? dailyGoalChars,
    List<SessionSummary>? history,
    SrsScheduler? srs,
    ConfusionMatrix? confusion,
    int? maxHistory,
  }) => TrainerProgress(
    currentLesson: currentLesson ?? this.currentLesson,
    charStats: charStats ?? this.charStats,
    streakDays: streakDays ?? this.streakDays,
    lastPracticeDay: lastPracticeDay ?? this.lastPracticeDay,
    dailyGoalChars: dailyGoalChars ?? this.dailyGoalChars,
    history: history ?? this.history,
    srs: srs ?? this.srs,
    confusion: confusion ?? this.confusion,
    maxHistory: maxHistory ?? this.maxHistory,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'version': 1,
    'currentLesson': currentLesson,
    'charStats': CharStats.mapToJson(charStats),
    'streakDays': streakDays,
    'lastPracticeDay': lastPracticeDay?.toIso8601String().substring(0, 10),
    'dailyGoalChars': dailyGoalChars,
    'history': history.map((s) => s.toJson()).toList(),
    'srs': srs.toJson(),
    'confusion': confusion.toJson(),
    'maxHistory': maxHistory,
  };

  factory TrainerProgress.fromJson(Map<String, Object?> json) {
    final lastDay = json['lastPracticeDay'] as String?;
    final rawHistory = json['history'] as List<Object?>? ?? const <Object?>[];
    final rawSrs = json['srs'] as Map<String, Object?>?;
    return TrainerProgress(
      currentLesson: (json['currentLesson'] as num?)?.toInt() ?? 1,
      charStats: CharStats.mapFromJson(
        json['charStats'] as Map<String, Object?>?,
      ),
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      lastPracticeDay: lastDay == null ? null : DateTime.parse(lastDay),
      dailyGoalChars: (json['dailyGoalChars'] as num?)?.toInt() ?? 100,
      history: rawHistory
          .map((e) => SessionSummary.fromJson(e! as Map<String, Object?>))
          .toList(),
      srs: rawSrs == null ? null : SrsScheduler.fromJson(rawSrs),
      confusion: ConfusionMatrix.fromJson(
        json['confusion'] as Map<String, Object?>?,
      ),
      maxHistory: (json['maxHistory'] as num?)?.toInt() ?? 500,
    );
  }

  @override
  String toString() =>
      'TrainerProgress(lesson $currentLesson, ${history.length} sessions, '
      'streak $streakDays, ${(overallAccuracy * 100).toStringAsFixed(1)}%)';
}
