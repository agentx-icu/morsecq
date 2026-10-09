import 'dart:convert';

import 'exercise.dart';
import 'morse_text.dart';
import 'listening_comprehension.dart';
import 'mistake_listening_context.dart';

export 'mistake_listening_context.dart';
import 'radio_conditions.dart';

/// One actual answer, retaining the exercise rather than only its confusions.
final class MistakeAttempt {
  const MistakeAttempt({
    required this.target,
    required this.answer,
    required this.source,
    required this.drillKind,
    required this.at,
    required this.characterWpm,
    required this.effectiveWpm,
    this.sourceRef,
    this.conditions,
    this.listeningContext,
  });

  factory MistakeAttempt.listening({
    required ListeningExercise exercise,
    required Map<ListeningField, String> answers,
    required DateTime at,
    required double characterWpm,
    required double effectiveWpm,
    String? sourceRef,
  }) {
    final context = MistakeListeningContext(
      exercise: exercise,
      answers: answers,
    );
    return MistakeAttempt(
      target: exercise.spokenText,
      answer: context.answerSummary,
      source: ExerciseSource.focus,
      drillKind: 'listening/${exercise.mode.name}',
      sourceRef: sourceRef ?? 'listening:${exercise.mode.name}',
      at: at,
      characterWpm: characterWpm,
      effectiveWpm: effectiveWpm,
      listeningContext: context,
    );
  }

  final String target;
  final String answer;
  final ExerciseSource source;
  final String drillKind;
  final DateTime at;
  final double characterWpm;
  final double effectiveWpm;
  final String? sourceRef;
  final RadioScenario? conditions;
  final MistakeListeningContext? listeningContext;

  /// Exact words and boundaries, with case/whitespace normalised. Alignment
  /// accuracy alone would incorrectly accept `NAMEJOHN` for `NAME JOHN`.
  bool get isCorrect =>
      listeningContext?.isCorrect ?? (_normal(target) == _normal(answer));
  bool get isUsable =>
      MorseText.symbols(target).isNotEmpty &&
      characterWpm.isFinite &&
      characterWpm > 0 &&
      effectiveWpm.isFinite &&
      effectiveWpm > 0 &&
      effectiveWpm <= characterWpm;

  String get groupingKey => jsonEncode([
    _normal(target),
    source.name,
    drillKind,
    sourceRef,
    characterWpm,
    effectiveWpm,
    _channel(conditions),
    if (listeningContext != null) listeningContext!.comparableKey,
  ]);
}

/// A failed exercise and the evidence from later, explicitly chosen retries.
final class MistakeEntry {
  MistakeEntry._({
    required this.id,
    required this.target,
    required this.originalAnswer,
    required this.answer,
    required this.source,
    required this.drillKind,
    required this.characterWpm,
    required this.effectiveWpm,
    required this.firstFailedAt,
    required this.lastFailedAt,
    required this.lastPracticedAt,
    required this.failureCount,
    required List<DateTime> independentCorrectDays,
    this.sourceRef,
    this.conditions,
    this.listeningContext,
    this.originalListeningContext,
    this.recoveredAt,
  }) : independentCorrectDays = List.unmodifiable(independentCorrectDays);

  factory MistakeEntry._first(MistakeAttempt attempt) => MistakeEntry._(
    id: base64Url.encode(utf8.encode(attempt.groupingKey)),
    target: attempt.target,
    originalAnswer: attempt.answer,
    answer: attempt.answer,
    source: attempt.source,
    drillKind: attempt.drillKind,
    sourceRef: attempt.sourceRef,
    conditions: attempt.conditions,
    listeningContext: attempt.listeningContext,
    originalListeningContext: attempt.listeningContext,
    characterWpm: attempt.characterWpm,
    effectiveWpm: attempt.effectiveWpm,
    firstFailedAt: attempt.at,
    lastFailedAt: attempt.at,
    lastPracticedAt: attempt.at,
    failureCount: 1,
    independentCorrectDays: const [],
  );

  final String id;
  final String target;
  final String originalAnswer;
  final String answer;
  final ExerciseSource source;
  final String drillKind;
  final String? sourceRef;
  final RadioScenario? conditions;
  final MistakeListeningContext? listeningContext;
  final MistakeListeningContext? originalListeningContext;
  final double characterWpm;
  final double effectiveWpm;
  final DateTime firstFailedAt;
  final DateTime lastFailedAt;
  final DateTime lastPracticedAt;
  final int failureCount;
  final List<DateTime> independentCorrectDays;
  final DateTime? recoveredAt;

  bool get isRecovered => recoveredAt != null;
  int get correctDayCount => independentCorrectDays.length;

  String get groupingKey => MistakeAttempt(
    target: target,
    answer: answer,
    source: source,
    drillKind: drillKind,
    sourceRef: sourceRef,
    conditions: conditions,
    listeningContext: listeningContext,
    at: lastPracticedAt,
    characterWpm: characterWpm,
    effectiveWpm: effectiveWpm,
  ).groupingKey;

  bool _matchesRetry(MistakeAttempt attempt) =>
      _normal(target) == _normal(attempt.target) &&
      characterWpm == attempt.characterWpm &&
      effectiveWpm == attempt.effectiveWpm &&
      conditions == attempt.conditions &&
      listeningContext?.comparableKey ==
          attempt.listeningContext?.comparableKey;

  MistakeEntry _record(MistakeAttempt attempt, {required bool assisted}) {
    final correct = attempt.isCorrect;
    final days = correct ? [...independentCorrectDays] : <DateTime>[];
    final day = _day(attempt.at);
    if (correct &&
        !assisted &&
        !(attempt.listeningContext?.exercise.previewRequired ?? false) &&
        !attempt.at.isBefore(lastFailedAt) &&
        !days.contains(day)) {
      days.add(day);
      days.sort();
    }
    return MistakeEntry._(
      id: id,
      target: target,
      originalAnswer: originalAnswer,
      answer: attempt.answer,
      source: source,
      drillKind: drillKind,
      sourceRef: sourceRef,
      conditions: conditions,
      listeningContext: attempt.listeningContext == null
          ? listeningContext
          : listeningContext?.withAnswers(attempt.listeningContext!.answers),
      originalListeningContext: originalListeningContext,
      characterWpm: characterWpm,
      effectiveWpm: effectiveWpm,
      firstFailedAt: firstFailedAt,
      lastFailedAt: correct ? lastFailedAt : attempt.at,
      lastPracticedAt: attempt.at,
      failureCount: failureCount + (correct ? 0 : 1),
      independentCorrectDays: days.take(2).toList(),
      recoveredAt: correct && days.length >= 2
          ? recoveredAt ?? attempt.at
          : null,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'target': target,
    'originalAnswer': originalAnswer,
    'answer': answer,
    'source': source.name,
    'drillKind': drillKind,
    'sourceRef': sourceRef,
    'conditions': conditions?.toJson(),
    if (listeningContext != null)
      'listeningContext': listeningContext!.toJson(),
    if (originalListeningContext != null)
      'originalListeningContext': originalListeningContext!.toJson(),
    'characterWpm': characterWpm,
    'effectiveWpm': effectiveWpm,
    'firstFailedAt': firstFailedAt.toIso8601String(),
    'lastFailedAt': lastFailedAt.toIso8601String(),
    'lastPracticedAt': lastPracticedAt.toIso8601String(),
    'failureCount': failureCount,
    'independentCorrectDays': [
      for (final day in independentCorrectDays) day.toIso8601String(),
    ],
    'recoveredAt': recoveredAt?.toIso8601String(),
  };

  static MistakeEntry? _fromJson(Object? raw) {
    if (raw is! Map) return null;
    final target = raw['target'];
    final answer = raw['answer'];
    final original = raw['originalAnswer'];
    final kind = raw['drillKind'];
    final source = ExerciseSource.parse(
      raw['source'] is String ? raw['source'] as String : null,
    );
    final cw = raw['characterWpm'];
    final ew = raw['effectiveWpm'];
    final first = _date(raw['firstFailedAt']);
    final last = _date(raw['lastFailedAt']);
    final practiced = _date(raw['lastPracticedAt']);
    final failures = raw['failureCount'];
    if (target is! String ||
        answer is! String ||
        original is! String ||
        kind is! String ||
        source == null ||
        cw is! num ||
        ew is! num ||
        first == null ||
        last == null ||
        practiced == null ||
        failures is! int ||
        failures < 1) {
      return null;
    }
    final scenario = RadioScenario.fromJson(raw['conditions']);
    final listening = MistakeListeningContext.fromJson(raw['listeningContext']);
    final originalListening = MistakeListeningContext.fromJson(
      raw['originalListeningContext'],
    );
    if ((raw['listeningContext'] != null && listening == null) ||
        (raw['originalListeningContext'] != null &&
            originalListening == null)) {
      return null;
    }
    if (raw['conditions'] != null && scenario == null) return null;
    final attempt = MistakeAttempt(
      target: target,
      answer: answer,
      source: source,
      drillKind: kind,
      at: practiced,
      characterWpm: cw.toDouble(),
      effectiveWpm: ew.toDouble(),
      sourceRef: raw['sourceRef'] is String ? raw['sourceRef'] as String : null,
      conditions: scenario,
      listeningContext: listening,
    );
    if (!attempt.isUsable) return null;
    final days = <DateTime>{};
    final rawDays = raw['independentCorrectDays'];
    if (rawDays is List) {
      for (final value in rawDays) {
        final day = _date(value);
        if (day != null && !day.isBefore(_day(last))) days.add(_day(day));
      }
    }
    final sorted = days.toList()..sort();
    return MistakeEntry._(
      id: base64Url.encode(utf8.encode(attempt.groupingKey)),
      target: target,
      originalAnswer: original,
      answer: answer,
      source: source,
      drillKind: kind,
      sourceRef: attempt.sourceRef,
      conditions: scenario,
      listeningContext: listening,
      originalListeningContext: originalListening ?? listening,
      characterWpm: cw.toDouble(),
      effectiveWpm: ew.toDouble(),
      firstFailedAt: first,
      lastFailedAt: last,
      lastPracticedAt: practiced,
      failureCount: failures,
      independentCorrectDays: sorted.take(2).toList(),
      recoveredAt: sorted.length >= 2 ? _date(raw['recoveredAt']) : null,
    );
  }
}

/// Bounded immutable cross-session notebook, persisted with trainer progress.
/// Ordinary correct rounds do not clear errors. Recovery needs two distinct
/// local calendar days of exact independent retries at the original pace and
/// channel; repeating or revealing an answer never supplies that evidence.
final class MistakeNotebook {
  MistakeNotebook({
    List<MistakeEntry> entries = const [],
    List<String> committedIds = const [],
    this.maxEntries = 200,
  }) : assert(maxEntries > 0),
       entries = List.unmodifiable(_bounded(entries, maxEntries)),
       committedIds = List.unmodifiable(
         committedIds.length > maxCommittedIds
             ? committedIds.sublist(committedIds.length - maxCommittedIds)
             : committedIds,
       );

  static const maxCommittedIds = 10000;
  final int maxEntries;
  final List<MistakeEntry> entries;
  final List<String> committedIds;

  List<MistakeEntry> get pending =>
      List.unmodifiable(entries.reversed.where((e) => !e.isRecovered));
  List<MistakeEntry> get recovered =>
      List.unmodifiable(entries.reversed.where((e) => e.isRecovered));

  MistakeEntry? entryById(String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  MistakeNotebook recordExercise({
    required String exerciseId,
    required Iterable<MistakeAttempt> attempts,
    bool assisted = false,
    String? retryEntryId,
  }) {
    if (committedIds.contains(exerciseId)) return this;
    final next = [...entries];
    for (final attempt in attempts) {
      if (!attempt.isUsable) continue;
      final retry = retryEntryId == null
          ? -1
          : next.indexWhere((e) => e.id == retryEntryId);
      if (retry >= 0 && next[retry]._matchesRetry(attempt)) {
        next[retry] = next[retry]._record(attempt, assisted: assisted);
        continue;
      }
      if (attempt.isCorrect) continue;
      final existing = next.indexWhere(
        (e) => e.groupingKey == attempt.groupingKey,
      );
      if (existing >= 0) {
        next[existing] = next[existing]._record(attempt, assisted: assisted);
      } else {
        next.add(MistakeEntry._first(attempt));
      }
    }
    return MistakeNotebook(
      entries: next,
      committedIds: [...committedIds, exerciseId],
      maxEntries: maxEntries,
    );
  }

  Map<String, Object?> toJson() => {
    'v': 1,
    'maxEntries': maxEntries,
    'entries': [for (final entry in entries) entry.toJson()],
    'committedIds': committedIds,
  };

  factory MistakeNotebook.fromJson(Object? raw) {
    if (raw is! Map) return MistakeNotebook();
    final rawEntries = raw['entries'];
    final rawIds = raw['committedIds'];
    final cap = raw['maxEntries'];
    final entries = <MistakeEntry>[];
    if (rawEntries is List) {
      for (final value in rawEntries) {
        final entry = MistakeEntry._fromJson(value);
        if (entry != null && !entries.any((e) => e.id == entry.id)) {
          entries.add(entry);
        }
      }
    }
    return MistakeNotebook(
      entries: entries,
      committedIds: rawIds is List ? rawIds.whereType<String>().toList() : [],
      maxEntries: cap is int && cap > 0 && cap <= 1000 ? cap : 200,
    );
  }

  static List<MistakeEntry> _bounded(List<MistakeEntry> entries, int max) {
    final next = [...entries];
    while (next.length > max) {
      final recovered = next.indexWhere((e) => e.isRecovered);
      next.removeAt(recovered < 0 ? 0 : recovered);
    }
    return next;
  }
}

String _normal(String text) => MorseText.tokenize(text).join();
DateTime _day(DateTime at) => DateTime(at.year, at.month, at.day);
DateTime? _date(Object? raw) => raw is String ? DateTime.tryParse(raw) : null;
String? _channel(RadioScenario? scenario) {
  if (scenario == null) return null;
  return jsonEncode(scenario.toJson()..remove('seed'));
}
