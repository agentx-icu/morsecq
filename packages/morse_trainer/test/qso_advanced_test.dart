import 'package:morse_trainer/src/qso/qso_scenario.dart';
import 'package:morse_trainer/src/qso/qso_session.dart';
import 'package:test/test.dart';

void main() {
  const local = QsoStation(callsign: 'K1ABC', name: 'BOB', qth: 'BOSTON');
  QsoSession start(String scenario) => QsoSession.start(
    scenario: QsoScenario.parse(scenario),
    seed: 41,
    local: local,
    characterWpm: 20,
    effectiveWpm: 10,
  );

  test('advanced scenario names restore without falling back to ragchew', () {
    expect(QsoScenario.parse('contestExchange').name, 'contestExchange');
    expect(QsoScenario.parse('potaActivation').name, 'potaActivation');
  });

  test('CALL? repeats only the available callsign without advancing', () {
    final s = start('respondToCq');
    final reply = s.submit('call-repeat', 'PSE CALL?');
    expect(reply.remoteText, 'CALL ${s.remote.callsign} K');
    expect(reply.advanced, isFalse);
    expect(s.repeats, 1);
    expect(s.consecutiveErrors, 0);
  });

  test('NAME? before a name is sent cannot reveal future information', () {
    final s = start('respondToCq');
    final reply = s.submit('early-name', 'NAME?');
    expect(reply.remoteText, 'NIL NAME K');
    expect(reply.advanced, isFalse);
    expect(reply.evaluation.accepted, isFalse);
    expect(s.consecutiveErrors, 0);
    expect(s.repeats, 1);
  });

  test('targeted RST, NAME and QTH repeat only heard fields', () {
    final s = start('respondToCq');
    s.submit('answer-call', '${s.remote.callsign} DE K1ABC K');
    final heard = s.lastRemoteText;
    for (final request in ['RST', 'NAME', 'QTH']) {
      final value = switch (request) {
        'RST' => s.report,
        'NAME' => s.remote.name,
        _ => s.remote.qth,
      };
      expect(
        s.submit('repeat-$request', '$request?').remoteText,
        '$request $value K',
      );
      expect(s.stage, QsoStage.exchange);
    }
    expect(
      s.submit('again', 'PSE AGN').remoteText,
      heard,
      reason: 'AGN still repeats the full stage transmission',
    );
  });

  test(
    'targeted repeat survives drafts and double submissions are ignored',
    () {
      final s = start('respondToCq');
      s.submit('help', 'CALL?');
      final restored = QsoSession.fromJson(s.toJson());
      expect(restored.submit('help', 'CALL?').duplicate, isTrue);
      expect(restored.repeats, 1);
      expect(
        restored.submit('again', 'AGN').remoteText,
        'CQ CQ CQ DE ${s.remote.callsign} ${s.remote.callsign} K',
      );
    },
  );

  test('station details roundtrip new vocabulary and load legacy defaults', () {
    final configured = QsoStation.fromJson({
      ...local.toJson(),
      'serialNumber': '017',
      'parkReference': 'US-1234',
    }).normalized();
    expect(configured.toJson()['serialNumber'], '017');
    expect(configured.toJson()['parkReference'], 'US-1234');
    final legacy = QsoStation.fromJson(local.toJson());
    expect(legacy.toJson()['serialNumber'], '001');
    expect(legacy.toJson()['parkReference'], 'US-1234');
  });

  test('contest exchanges confirm corrected serial rather than a name', () {
    final s = start('contestExchange');
    expect(s.lastRemoteText, contains('TEST'));
    expect(
      s.submit('calls', '${s.remote.callsign} DE K1ABC K').advanced,
      isTrue,
    );
    final announced = RegExp(r'NR (\w+)').firstMatch(s.lastRemoteText!)![1];
    expect(s.submit('repeat', 'NR?').remoteText, 'NR $announced K');
    expect(
      s
          .submit('exchange', '${s.remote.callsign} DE K1ABC UR RST 5NN NR 1 K')
          .advanced,
      isTrue,
    );
    expect(s.lastRemoteText, contains('CORR NR'));
    final corrected = s.remote.toJson()['serialNumber'];
    expect(corrected, isNot(announced));
    expect(
      s.submit('stale', 'R R RST ${s.report} NR $announced K').advanced,
      isFalse,
    );
    expect(
      s.submit('correct', 'QSL TNX RST ${s.report} NR $corrected KN').advanced,
      isTrue,
    );
    expect(s.submit('closing', 'TU 73').advanced, isTrue);
    expect(s.isDone, isTrue);
    expect(s.firstTryStages, 3);
  });

  test(
    'POTA accepts own park exchange then confirms corrected remote park',
    () {
      final s = start('potaActivation');
      expect(s.lastRemoteText, contains('POTA'));
      s.submit('calls', '${s.remote.callsign} DE K1ABC K');
      expect(s.lastRemoteText, contains('PARK'));
      expect(
        s.submit('exchange', 'UR RST 579 PARK US/1234 K').advanced,
        isTrue,
      );
      expect(s.lastRemoteText, contains('CORR PARK'));
      final park = s.remote.toJson()['parkReference'];
      final repeat = s.submit('repeat', 'PARK?');
      expect(
        repeat.remoteText,
        'PARK ${park.toString().replaceAll('-', '')} K',
      );
      final wrong = s.submit('wrong', 'R R RST ${s.report} PARK US0000 K');
      expect(wrong.advanced, isFalse);
      expect(
        s.submit('confirm', 'R R RST ${s.report} PARK $park K').advanced,
        isTrue,
      );
      expect(s.submit('closing', 'TNX TU 73 <SK>').advanced, isTrue);
      expect(s.isDone, isTrue);
    },
  );

  test('advanced exchanges reject malformed or incorrect serial and park', () {
    for (final name in ['contestExchange', 'potaActivation']) {
      final s = start(name);
      s.submit('calls', '${s.remote.callsign} DE K1ABC K');
      for (final text
          in name == 'contestExchange'
              ? [
                  'UR RST 599 NR 000 K',
                  'UR RST 599 NR ABC K',
                  'UR RST 599 NR 02 K',
                ]
              : ['UR RST 599 PARK US-12 K', 'UR RST 599 PARK US9999 K']) {
        final reply = s.submit(text, text);
        expect(reply.advanced, isFalse, reason: '$name: $text');
        expect(reply.evaluation.issues, isNotEmpty);
      }
    }
  });

  test('new scenarios preserve corrected information and stage in drafts', () {
    final s = start('contestExchange');
    s.submit('calls', '${s.remote.callsign} DE K1ABC K');
    s.submit('exchange', 'UR RST 599 NR 001 K');
    final restored = QsoSession.fromJson(s.toJson());
    expect(restored.scenario.name, 'contestExchange');
    expect(restored.stage, QsoStage.confirmInfo);
    expect(restored.remote.toJson(), s.remote.toJson());
    expect(restored.submit('exchange', 'x').duplicate, isTrue);
    expect(
      restored.submit('repeat', 'PSE NR?').remoteText,
      'NR ${s.remote.toJson()['serialNumber']} K',
    );
  });
  test(
    'plan attribution survives a draft while legacy sessions stay unbound',
    () {
      final s = start('contestExchange');
      final attributed = QsoSession.fromJson({
        ...s.toJson(),
        'planStepId': 'goal-contest-17',
      });
      expect(attributed.toJson()['planStepId'], 'goal-contest-17');
      expect(s.toJson()['planStepId'], isNull);
    },
  );
  test(
    'typed assistance survives restores and duplicate submissions count once',
    () {
      final s = start('contestExchange');
      final call = '${s.remote.callsign} DE K1ABC K';
      final first = s.submit('typed-call', call, typed: true);
      expect(first.advanced, isTrue);
      expect(s.typedReplies, 1);
      expect(s.firstTryStages, 1);
      expect(s.submit('typed-call', call, typed: true).duplicate, isTrue);
      expect(s.typedReplies, 1);
      final restored = QsoSession.fromJson(s.toJson());
      expect(restored.typedReplies, 1);
      expect(
        restored.submit('typed-call', call, typed: true).duplicate,
        isTrue,
      );
      expect(restored.typedReplies, 1);
      restored.submit('wrong-typed', 'UR RST 599 NR 9999 K', typed: true);
      expect(restored.typedReplies, 2);
      restored.submit('keyed-exchange', 'UR RST 599 NR 001 K');
      expect(restored.typedReplies, 2);
    },
  );

  test('legacy session JSON defaults to zero typed responses', () {
    final legacy = start('shortExchange').toJson()..remove('typedReplies');
    expect(QsoSession.fromJson(legacy).typedReplies, 0);
  });
}
