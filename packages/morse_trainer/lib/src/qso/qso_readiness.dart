import 'package:morse_core/morse_core.dart';

import '../exercise.dart';
import '../morse_text.dart';
import '../qso_protocol.dart';
import '../recent_practice.dart';
import '../session_summary.dart';

/// Evidence still needed before starting the full interactive simulator.
enum QsoReadinessLevel {
  symbols,
  consolidate,
  shorthand,
  protocol,
  exchange,
  ready,
}

/// Current listening evidence, shorthand copying, understanding and an
/// independent short interaction are separate abilities. Unlocking every
/// symbol, or copying a line correctly, cannot substitute for the others.
/// Readiness concerns starting a simulator, not operating a real station.
final class QsoReadiness {
  const QsoReadiness({
    required this.missing,
    required this.unmastered,
    required this.shorthandPractised,
    required this.protocolPractised,
    required this.exchangePractised,
  });

  static const double practisedAccuracy = 0.8;
  static const int practisedMinChars = 10;
  static const String shorthandDrillKind = 'abbreviations';
  static const String exchangeDrillKind = 'qso-sim';
  static const String shortExchangeSourceRef = 'qso:shortExchange:3/3';

  /// Every possible symbol in the full scripts and random station details.
  static final Set<String> requiredChars = Set<String>.unmodifiable(<String>{
    for (final c in MorseAlphabet.kochOrder)
      if (RegExp(r'^[A-Z0-9]$').hasMatch(c)) c,
    '?',
    '<SK>',
  });

  static QsoReadiness of({
    required Iterable<String> learned,
    required List<SessionSummary> history,
    DateTime? now,
    double? characterWpm,
    double? effectiveWpm,
  }) {
    final at = now ?? DateTime.now();
    final known = learned.map(MorseText.normalizeChar).toSet();
    final missing = <String>[];
    final unmastered = <String>[];
    for (final c in MorseAlphabet.kochOrder) {
      if (!requiredChars.contains(c)) continue;
      if (!known.contains(c)) {
        missing.add(c);
        continue;
      }
      final evidence = RecentPractice.forSymbol(
        history,
        c,
        now: at,
        characterWpm: characterWpm,
        effectiveWpm: effectiveWpm,
      );
      if (evidence.stats.attempts < 10 || evidence.strictAccuracy < 0.9) {
        unmastered.add(c);
      }
    }
    final current = history.where(
      (row) => RecentPractice.isCurrent(
        row,
        now: at,
        characterWpm: characterWpm,
        effectiveWpm: effectiveWpm,
      ),
    );
    return QsoReadiness(
      missing: List<String>.unmodifiable(missing),
      unmastered: List<String>.unmodifiable(unmastered),
      shorthandPractised: current.any(
        (row) =>
            row.drillKind == shorthandDrillKind &&
            row.source != null &&
            row.conditions == null &&
            CreditPolicy.decide(
              source: row.source!,
              completed: row.completed,
              answered: row.totalChars > 0,
              assistance: row.assistance!,
            ).receiveStats &&
            row.totalChars >= practisedMinChars &&
            row.strictAccuracy >= practisedAccuracy,
      ),
      protocolPractised: current.any(
        (row) =>
            row.source == ExerciseSource.qso &&
            row.drillKind == QsoProtocolAttempt.drillKind &&
            row.sourceRef == QsoProtocolAttempt.passedSourceRef,
      ),
      exchangePractised: current.any(
        (row) =>
            row.source == ExerciseSource.qso &&
            row.drillKind == exchangeDrillKind &&
            row.sourceRef == shortExchangeSourceRef,
      ),
    );
  }

  /// Required symbols not yet introduced, in Koch order.
  final List<String> missing;

  /// Introduced symbols without sufficient current recognition evidence.
  final List<String> unmastered;
  final bool shorthandPractised;
  final bool protocolPractised;
  final bool exchangePractised;

  bool get symbolsIntroduced => missing.isEmpty;
  bool get symbolsReady => symbolsIntroduced && unmastered.isEmpty;
  bool get symbolsMastered => symbolsReady;
  bool get isReady =>
      symbolsReady &&
      shorthandPractised &&
      protocolPractised &&
      exchangePractised;

  QsoReadinessLevel get level {
    if (!symbolsIntroduced) return QsoReadinessLevel.symbols;
    if (!symbolsReady) return QsoReadinessLevel.consolidate;
    if (!shorthandPractised) return QsoReadinessLevel.shorthand;
    if (!protocolPractised) return QsoReadinessLevel.protocol;
    if (!exchangePractised) return QsoReadinessLevel.exchange;
    return QsoReadinessLevel.ready;
  }

  @override
  String toString() =>
      'QsoReadiness(${level.name}, missing $missing, unmastered $unmastered)';
}
