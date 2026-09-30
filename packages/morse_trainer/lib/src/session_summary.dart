import 'session_score.dart';

/// Compact record of one finished session, kept in progress history.
final class SessionSummary {
  const SessionSummary({
    required this.at,
    required this.totalChars,
    required this.correctChars,
    this.lesson,
    this.drillKind,
    this.elapsed,
  }) : assert(totalChars >= 0, 'totalChars must be >= 0'),
       assert(
         correctChars >= 0 && correctChars <= totalChars,
         'correctChars must be within 0..totalChars',
       );

  factory SessionSummary.fromScore(
    SessionScore score, {
    DateTime? at,
    int? lesson,
  }) => SessionSummary(
    at: at ?? score.at ?? DateTime.now(),
    totalChars: score.totalChars,
    correctChars: score.correctChars,
    lesson: lesson ?? score.lesson,
    drillKind: score.drillKind,
    elapsed: score.elapsed,
  );

  final DateTime at;
  final int totalChars;
  final int correctChars;
  final int? lesson;
  final String? drillKind;
  final Duration? elapsed;

  double get accuracy => totalChars == 0 ? 0 : correctChars / totalChars;

  Map<String, Object?> toJson() => <String, Object?>{
    'at': at.toIso8601String(),
    'totalChars': totalChars,
    'correctChars': correctChars,
    'lesson': lesson,
    'drillKind': drillKind,
    'elapsedMs': elapsed?.inMilliseconds,
  };

  factory SessionSummary.fromJson(Map<String, Object?> json) {
    final elapsedMs = (json['elapsedMs'] as num?)?.toInt();
    return SessionSummary(
      at: DateTime.parse(json['at'] as String),
      totalChars: (json['totalChars'] as num).toInt(),
      correctChars: (json['correctChars'] as num).toInt(),
      lesson: (json['lesson'] as num?)?.toInt(),
      drillKind: json['drillKind'] as String?,
      elapsed: elapsedMs == null ? null : Duration(milliseconds: elapsedMs),
    );
  }

  @override
  String toString() =>
      'SessionSummary($at, L$lesson ${drillKind ?? ''} '
      '$correctChars/$totalChars)';

  @override
  bool operator ==(Object other) =>
      other is SessionSummary &&
      other.at == at &&
      other.totalChars == totalChars &&
      other.correctChars == correctChars &&
      other.lesson == lesson &&
      other.drillKind == drillKind &&
      other.elapsed == elapsed;

  @override
  int get hashCode =>
      Object.hash(at, totalChars, correctChars, lesson, drillKind, elapsed);
}
