import 'package:morse_trainer/morse_trainer.dart';
import 'package:test/test.dart';

void main() {
  const local = QsoStation(callsign: 'K1ABC', name: 'BOB', qth: 'BOSTON');
  QsoSession short() => QsoSession.start(
    scenario: QsoScenario.parse('shortExchange'),
    seed: 17,
    local: local,
    characterWpm: 20,
    effectiveWpm: 8,
  );
  test('short exchange has calls, report and closing without name/QTH', () {
    final s = short();
    expect(s.answerStages, 3);
    expect(
      s.submit('calls', '${s.remote.callsign} DE K1ABC K').advanced,
      isTrue,
    );
    expect(s.lastRemoteText, isNot(contains('NAME')));
    expect(s.submit('report', 'UR RST 599 K').advanced, isTrue);
    expect(s.stage, QsoStage.closing);
    expect(s.submit('closing', 'TU 73 <SK>').advanced, isTrue);
    expect(s.isDone, isTrue);
    expect(s.firstTryStages, 3);
  });
  test('QRS is assistance and survives draft restore', () {
    final s = short();
    s.submit('slow', 'QRS');
    expect(s.repeats, greaterThan(0));
    final restored = QsoSession.fromJson(s.toJson());
    expect(restored.repeats, greaterThan(0));
  });
  test(
    'plain copying records cannot substitute for understanding and interaction',
    () {
      final now = DateTime.now();
      SessionSummary row(String kind) => SessionSummary(
        at: now,
        totalChars: 20,
        correctChars: 20,
        completed: true,
        source: ExerciseSource.focus,
        assistance: {},
        drillKind: kind,
        characterWpm: 20,
        effectiveWpm: 8,
        perChar: {
          for (final c in QsoReadiness.requiredChars)
            c: const CharStats(attempts: 10, correct: 10),
        },
      );
      final r = QsoReadiness.of(
        learned: KochCourse().charsForLesson(42),
        history: [row('abbreviations'), row('qso')],
      );
      expect(r.isReady, isFalse);
    },
  );

  group('independent protocol understanding', () {
    test('all four concepts need one correct first answer', () {
      final quiz = QsoProtocolAttempt(id: 'quiz', at: DateTime(2026, 10, 8));
      for (final concept in QsoProtocolConcept.values) {
        expect(quiz.current, concept);
        expect(quiz.answer(concept), isTrue);
      }
      expect(quiz.completed, isTrue);
      expect(quiz.passed, isTrue);
      expect(quiz.sourceRef, QsoProtocolAttempt.passedSourceRef);
    });
    test('an error cannot be replaced by a second answer', () {
      final quiz = QsoProtocolAttempt(id: 'quiz', at: DateTime(2026, 10, 8));
      expect(quiz.answer(QsoProtocolConcept.bestRegards), isFalse);
      for (final concept in QsoProtocolConcept.values.skip(1)) {
        quiz.answer(concept);
      }
      expect(quiz.correct, 3);
      expect(quiz.passed, isFalse);
      expect(quiz.answer(QsoProtocolConcept.generalCall), isFalse);
      expect(quiz.correct, 3);
    });
  });

  group('recent readiness evidence', () {
    final now = DateTime(2026, 10, 8, 12);
    final all = KochCourse().charsForLesson(42);
    SessionSummary row({
      String kind = 'groups',
      ExerciseSource source = ExerciseSource.focus,
      String? ref,
      DateTime? at,
      double effective = 8,
      bool completed = true,
      Set<Assistance> assistance = const {},
      int attempts = 10,
      int correct = 10,
    }) => SessionSummary(
      at: at ?? now,
      totalChars: 20,
      correctChars: 20,
      drillKind: kind,
      source: source,
      sourceRef: ref,
      characterWpm: 20,
      effectiveWpm: effective,
      assistance: assistance,
      completed: completed,
      perChar: {
        for (final c in QsoReadiness.requiredChars)
          c: CharStats(attempts: attempts, correct: correct),
      },
    );
    QsoReadiness readiness(List<SessionSummary> history) => QsoReadiness.of(
      learned: all,
      history: history,
      now: now,
      characterWpm: 20,
      effectiveWpm: 8,
    );
    List<SessionSummary> readyRows() => [
      row(),
      row(kind: 'abbreviations'),
      row(
        kind: QsoProtocolAttempt.drillKind,
        source: ExerciseSource.qso,
        ref: QsoProtocolAttempt.passedSourceRef,
      ),
      row(
        kind: 'qso-sim',
        source: ExerciseSource.qso,
        ref: 'qso:shortExchange:3/3',
      ),
    ];

    test('introduced symbols differ from current mastery', () {
      final r = readiness([]);
      expect(r.missing, isEmpty);
      expect(r.unmastered, hasLength(QsoReadiness.requiredChars.length));
      expect(r.symbolsIntroduced, isTrue);
      expect(r.symbolsReady, isFalse);
      expect(r.level, QsoReadinessLevel.consolidate);
    });
    test(
      'current recognition, shorthand, understanding and exchange qualify',
      () {
        expect(readiness(readyRows()).isReady, isTrue);
      },
    );
    test('errors, help, expiration and other speeds never prove exchange', () {
      final baseline = readyRows()..removeLast();
      for (final exchange in [
        row(
          kind: 'qso-sim',
          source: ExerciseSource.qso,
          ref: 'qso:shortExchange:2/3',
        ),
        row(
          kind: 'qso-sim',
          source: ExerciseSource.qso,
          ref: 'qso:shortExchange:3/3',
          assistance: {Assistance.replay},
        ),
        row(
          kind: 'qso-sim',
          source: ExerciseSource.qso,
          ref: 'qso:shortExchange:3/3',
          effective: 6,
        ),
        row(
          kind: 'qso-sim',
          source: ExerciseSource.qso,
          ref: 'qso:shortExchange:3/3',
          at: now.subtract(const Duration(days: 15)),
        ),
        row(
          kind: 'qso-sim',
          source: ExerciseSource.qso,
          ref: 'qso:shortExchange:3/3',
          completed: false,
        ),
        row(
          kind: 'qso-sim',
          source: ExerciseSource.qso,
          ref: 'qso:respondToCq:4/4',
        ),
      ]) {
        expect(
          readiness([...baseline, exchange]).level,
          QsoReadinessLevel.exchange,
        );
      }
    });
    test('recent recognition needs ten real attempts and 90 percent', () {
      for (final copying in [
        row(attempts: 9, correct: 9),
        row(attempts: 10, correct: 8),
      ]) {
        expect(readiness([copying]).level, QsoReadinessLevel.consolidate);
      }
    });
    test('expired and assisted protocol results do not qualify', () {
      final baseline = readyRows()..removeAt(2);
      for (final protocol in [
        row(
          kind: QsoProtocolAttempt.drillKind,
          source: ExerciseSource.qso,
          ref: 'protocol:3/4:firstTry=false',
        ),
        row(
          kind: QsoProtocolAttempt.drillKind,
          source: ExerciseSource.qso,
          ref: QsoProtocolAttempt.passedSourceRef,
          assistance: {Assistance.hint},
        ),
        row(
          kind: QsoProtocolAttempt.drillKind,
          source: ExerciseSource.qso,
          ref: QsoProtocolAttempt.passedSourceRef,
          at: now.subtract(const Duration(days: 15)),
        ),
      ]) {
        expect(
          readiness([...baseline, protocol]).level,
          QsoReadinessLevel.protocol,
        );
      }
    });
  });
}
