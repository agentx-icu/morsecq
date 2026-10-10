import 'package:morse_trainer/morse_trainer.dart';
import 'package:test/test.dart';

const QsoStation _local = QsoStation(
  callsign: 'BI1ABC',
  name: 'TOM',
  qth: 'PARIS',
  serialNumber: '007',
  parkReference: 'K-1234',
);

QsoSession _start(QsoScenario scenario, {QsoStation local = _local}) =>
    QsoSession.start(
      scenario: scenario,
      seed: 11,
      local: local,
      characterWpm: 20,
      effectiveWpm: 15,
    );

void main() {
  group('hints', () {
    for (final QsoScenario scenario in QsoScenario.values) {
      test('$scenario: level-2 hints are accepted answers to the end', () {
        final QsoSession s = _start(scenario);
        int id = 0;
        final List<QsoStage> stages = <QsoStage>[];
        while (!s.isDone && id < 100) {
          final QsoHint first = s.hint();
          expect(first.level, 1, reason: 'no errors yet at ${s.stage}');
          expect(first.stage, s.stage);
          // A level-1 hint with placeholders shows the shape, not the
          // answer: sending it as written is not accepted.
          if (RegExp(r'<(?!SK>)[A-Z ]+>').hasMatch(first.example)) {
            expect(s.submit('p${id++}', first.example).advanced, isFalse);
          }
          while (s.consecutiveErrors < QsoSession.hintAfterErrors) {
            s.submit('e${id++}', 'ZZZ');
          }
          final QsoHint second = s.hint();
          expect(second.level, 2);
          stages.add(s.stage);
          final QsoReply reply = s.submit('a${id++}', second.example);
          expect(
            reply.advanced,
            isTrue,
            reason: '${s.stage}: ${second.example}',
          );
          expect(s.consecutiveErrors, 0);
        }
        expect(s.isDone, isTrue);
        expect(stages, hasLength(s.answerStages));
        expect(s.hints, greaterThanOrEqualTo(2 * s.answerStages));
        expect(s.hint().example, isEmpty, reason: 'nothing left to send');
      });
    }

    test('level-2 examples name the station details', () {
      final QsoSession contest = _start(QsoScenario.contestExchange);
      final QsoSession pota = _start(QsoScenario.potaActivation);
      final QsoSession call = _start(QsoScenario.callCq);
      for (final QsoSession s in <QsoSession>[contest, pota, call]) {
        int id = 0;
        while (s.stage != QsoStage.exchange) {
          while (s.consecutiveErrors < QsoSession.hintAfterErrors) {
            s.submit('e${id++}', 'ZZZ');
          }
          s.submit('a${id++}', s.hint().example);
        }
        while (s.consecutiveErrors < QsoSession.hintAfterErrors) {
          s.submit('e${id++}', 'ZZZ');
        }
      }
      expect(contest.hint().example, contains('NR 007'));
      expect(pota.hint().example, contains('PARK'));
      expect(
        call.hint().example,
        allOf(contains('NAME TOM'), contains('QTH PARIS')),
      );
      expect(
        call.hint().example,
        startsWith('${call.remote.callsign} DE BI1ABC'),
      );
    });
  });

  test('advanced scenarios refuse a station without their exchange', () {
    expect(
      () => _start(
        QsoScenario.contestExchange,
        local: const QsoStation(
          callsign: 'BI1ABC',
          name: 'TOM',
          qth: 'PARIS',
          serialNumber: 'ABC',
          parkReference: 'K-1234',
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => _start(
        QsoScenario.potaActivation,
        local: const QsoStation(
          callsign: 'BI1ABC',
          name: 'TOM',
          qth: 'PARIS',
          serialNumber: '007',
          parkReference: '!!',
        ),
      ),
      throwsArgumentError,
    );
  });

  test('repeat fields follow what the remote actually sent', () {
    final QsoSession s = _start(QsoScenario.respondToCq);
    expect(s.learnerTurns, 0);
    expect(s.availableRepeatFields, contains(QsoRepeatField.call));
    expect(s.availableRepeatFields, isNot(contains(QsoRepeatField.name)));
    int id = 0;
    while (s.stage != QsoStage.confirmInfo) {
      while (s.consecutiveErrors < QsoSession.hintAfterErrors) {
        s.submit('e${id++}', 'ZZZ');
      }
      s.submit('a${id++}', s.hint().example);
    }
    expect(s.learnerTurns, greaterThan(0));
    expect(
      s.availableRepeatFields,
      containsAll(<QsoRepeatField>[
        QsoRepeatField.call,
        QsoRepeatField.rst,
        QsoRepeatField.name,
        QsoRepeatField.qth,
      ]),
    );
    expect(s.availableRepeatFields, isNot(contains(QsoRepeatField.serial)));
  });

  test('turns keep known issues through JSON and drop unknown ones', () {
    const QsoTurn turn = QsoTurn(
      fromRemote: false,
      text: 'UR RST 599',
      stage: QsoStage.exchange,
      accepted: false,
      issues: <QsoIssue>[QsoIssue.missingName, QsoIssue.missingQth],
    );
    final Map<String, Object?> json = turn.toJson();
    final QsoTurn back = QsoTurn.fromJson(json);
    expect(back.issues, turn.issues);
    expect(back.accepted, isFalse);
    expect(back.assistance, isFalse);
    final QsoTurn future = QsoTurn.fromJson(<String, Object?>{
      ...json,
      'issues': <Object?>['missingName', 'fromAFutureVersion'],
    });
    expect(future.issues, <QsoIssue>[QsoIssue.missingName]);
  });
}
