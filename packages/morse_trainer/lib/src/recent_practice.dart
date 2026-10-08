import 'char_stats.dart';
import 'exercise.dart';
import 'session_summary.dart';

/// Current recognition evidence, distinct from lifetime training totals.
final class RecentSymbolEvidence {
  const RecentSymbolEvidence({
    this.stats = CharStats.empty,
    this.insertions = 0,
  });

  final CharStats stats;
  final int insertions;

  /// Inserting candidate answers never makes recognition look mastered.
  double get strictAccuracy => stats.attempts + insertions == 0
      ? 0
      : stats.correct / (stats.attempts + insertions);
}

/// Comparable copying within a rolling period. Whole sessions are retained:
/// per-symbol counters cannot reconstruct the order of answers inside one.
abstract final class RecentPractice {
  static const Duration ageLimit = Duration(days: 14);
  static const int sessionsPerSymbol = 5;

  static bool isCurrent(
    SessionSummary row, {
    required DateTime now,
    double? characterWpm,
    double? effectiveWpm,
  }) =>
      !row.at.isAfter(now) &&
      now.difference(row.at) <= ageLimit &&
      row.completed &&
      row.isKnownUnassisted &&
      row.characterWpm != null &&
      row.effectiveWpm != null &&
      (characterWpm == null || row.characterWpm == characterWpm) &&
      (effectiveWpm == null || row.effectiveWpm == effectiveWpm);

  static bool _copying(SessionSummary row) =>
      row.source != null &&
      row.perChar != null &&
      row.conditions == null &&
      CreditPolicy.decide(
        source: row.source!,
        completed: row.completed,
        answered: row.totalChars > 0,
        assistance: row.assistance ?? <Assistance>{Assistance.hint},
      ).receiveStats;

  static RecentSymbolEvidence forSymbol(
    Iterable<SessionSummary> history,
    String symbol, {
    required DateTime now,
    double? characterWpm,
    double? effectiveWpm,
  }) {
    var stats = CharStats.empty;
    var insertions = 0;
    var sessions = 0;
    // History is append ordered. Reverse first and use the original index
    // as a tie breaker: several answers can share one clock tick.
    final rows =
        history.toList().asMap().entries.where((entry) {
          final row = entry.value;
          return _copying(row) &&
              isCurrent(
                row,
                now: now,
                characterWpm: characterWpm,
                effectiveWpm: effectiveWpm,
              ) &&
              (row.perChar?[symbol]?.attempts ?? 0) > 0;
        }).toList()..sort((a, b) {
          final byTime = b.value.at.compareTo(a.value.at);
          return byTime == 0 ? b.key.compareTo(a.key) : byTime;
        });
    for (final entry in rows) {
      final row = entry.value;
      stats += row.perChar![symbol]!;
      insertions += row.insertions ?? 0;
      if (++sessions == sessionsPerSymbol) break;
    }
    return RecentSymbolEvidence(stats: stats, insertions: insertions);
  }
}
