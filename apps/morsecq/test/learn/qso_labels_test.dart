import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/i18n/locale_resolution.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/learn/qso/qso_labels.dart';

import 'helpers/l10n.dart';

const _local = QsoStation(
  callsign: 'BI1ABC',
  name: 'TOM',
  qth: 'PARIS',
  serialNumber: '001',
  parkReference: 'K-1234',
);

/// Plays [scenario] to the end with level-2 hints; returns the task label
/// shown at every stage, in order.
List<(QsoStage, String)> _walk(QsoScenario scenario) {
  final session = QsoSession.start(
    scenario: scenario,
    seed: 1,
    local: _local,
    characterWpm: 20,
    effectiveWpm: 20,
  );
  final seen = <(QsoStage, String)>[
    (session.stage, QsoLabels.task(en, session)),
  ];
  var id = 0;
  for (var i = 0; i < 40 && !session.isDone; i++) {
    while (session.consecutiveErrors < QsoSession.hintAfterErrors) {
      session.submit('e${id++}', 'ZZZ');
    }
    if (session.submit('a${id++}', session.hint().example).advanced) {
      seen.add((session.stage, QsoLabels.task(en, session)));
    }
  }
  expect(session.isDone, isTrue, reason: '$scenario finished');
  return seen;
}

void main() {
  for (final locale in S.supportedLocales) {
    final s = lookupS(locale);
    final tag = localeTag(locale);

    test('$tag: every QSO stage and issue has its own label', () {
      final stages = [for (final x in QsoStage.values) QsoLabels.stage(s, x)];
      expect(
        stages,
        everyElement(predicate<String>((v) => v.trim().isNotEmpty)),
      );
      expect(stages.toSet(), hasLength(stages.length), reason: 'stages');
      final issues = [for (final x in QsoIssue.values) QsoLabels.issue(s, x)];
      expect(
        issues,
        everyElement(predicate<String>((v) => v.trim().isNotEmpty)),
      );
      expect(issues.toSet(), hasLength(issues.length), reason: 'issues');
    });
  }

  test('basic QSOs name each stage; a short exchange asks for a report', () {
    for (final scenario in [
      QsoScenario.shortExchange,
      QsoScenario.respondToCq,
      QsoScenario.callCq,
    ]) {
      for (final (stage, task) in _walk(scenario)) {
        final expected =
            scenario == QsoScenario.shortExchange && stage == QsoStage.exchange
            ? en.learnQsoSignalReport
            : QsoLabels.stage(en, stage);
        expect(task, expected, reason: '$scenario at $stage');
      }
    }
  });

  test('advanced QSOs explain the exchange and the correction', () {
    for (final scenario in [
      QsoScenario.contestExchange,
      QsoScenario.potaActivation,
    ]) {
      final tasks = {for (final (stage, task) in _walk(scenario)) stage: task};
      expect(
        tasks[QsoStage.exchange],
        scenario == QsoScenario.contestExchange
            ? en.qsoAdvancedContestStage
            : en.qsoAdvancedPotaStage,
      );
      expect(tasks[QsoStage.confirmInfo], en.qsoAdvancedCorrectionStage);
      expect(tasks[QsoStage.closing], en.learnQsoStageClosing);
      expect(tasks[QsoStage.done], en.learnQsoStageDone);
    }
  });

  test('labels follow the UI language', () {
    final zh = lookupS(const Locale('zh'));
    expect(
      QsoLabels.stage(zh, QsoStage.exchange),
      isNot(QsoLabels.stage(en, QsoStage.exchange)),
    );
  });
}
