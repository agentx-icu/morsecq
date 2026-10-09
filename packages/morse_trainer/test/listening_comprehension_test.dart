import 'package:morse_trainer/src/listening_comprehension.dart';
import 'package:test/test.dart';

void main() {
  for (final mode in ListeningMode.values) {
    test('${mode.name} content and questions repeat for a saved seed', () {
      final first = ListeningExercise.generate(mode: mode, seed: 17);
      final reopened = ListeningExercise.generate(mode: mode, seed: 17);
      expect(first.spokenText, reopened.spokenText);
      expect(
        first.questions.map((q) => q.field),
        reopened.questions.map((q) => q.field),
      );
      expect(
        first.questions.map((q) => q.answer),
        reopened.questions.map((q) => q.answer),
      );
      expect(first.spokenText, isNotEmpty);
      expect(first.previewRequired, isFalse);
      expect(
        first.score({
          for (final q in first.questions) q.field: q.answer,
        }).correct,
        first.questions.length,
      );
    });
  }

  test('QSO grade counts each requested information field independently', () {
    final exercise = ListeningExercise.generate(
      mode: ListeningMode.qso,
      seed: 4,
    );
    final answers = {
      for (final q in exercise.questions)
        q.field: '  ${q.answer.toLowerCase()}  ',
    };
    answers[ListeningField.rst] = '5 9 9';
    // Any generated report must be copied; whitespace cannot change its value.
    answers[ListeningField.rst] = exercise.questions
        .singleWhere((q) => q.field == ListeningField.rst)
        .answer
        .split('')
        .join(' ');
    final score = exercise.score(answers);
    expect(score.correct, 4);
    expect(score.total, 4);
    answers[ListeningField.name] = 'WRONG';
    expect(exercise.score(answers).correct, 3);
    expect(exercise.score({}).correct, 0);
  });

  test(
    'callsigns and park designators accept harmless separators but not wrong digits',
    () {
      final exercise = ListeningExercise(
        mode: ListeningMode.pota,
        spokenText: 'K1ABC W2DEF PARK US 1234',
        questions: [
          ListeningQuestion(field: ListeningField.callsign, answer: 'K1ABC'),
          ListeningQuestion(
            field: ListeningField.otherCallsign,
            answer: 'W2DEF/P',
          ),
          ListeningQuestion(field: ListeningField.park, answer: 'US-1234'),
        ],
      );
      expect(
        exercise.score({
          ListeningField.callsign: ' k1abc ',
          ListeningField.otherCallsign: 'w2def / p',
          ListeningField.park: 'us 1234',
        }).correct,
        3,
      );
      expect(exercise.score({ListeningField.park: 'US-1235'}).correct, 0);
    },
  );

  test('whole phrases preserve word boundaries and normalize punctuation', () {
    final exercise = ListeningExercise(
      mode: ListeningMode.phrases,
      spokenText: 'READ A BOOK',
      questions: [
        ListeningQuestion(field: ListeningField.answer, answer: 'READ A BOOK'),
      ],
    );
    expect(
      exercise.score({ListeningField.answer: '  read  a book. '}).correct,
      1,
    );
    expect(exercise.score({ListeningField.answer: 'readabook'}).correct, 0);
  });

  test('unknown symbols create an explicit assisted preview', () {
    final exercise = ListeningExercise.generate(
      mode: ListeningMode.story,
      seed: 8,
      allowedChars: ['K', 'M'],
    );
    expect(exercise.previewRequired, isTrue);
    expect(exercise.missingSymbols, isNotEmpty);
    final score = exercise.score({
      for (final q in exercise.questions) q.field: q.answer,
    });
    expect(
      score
          .attempt(
            id: 'preview',
            at: DateTime(2026),
            characterWpm: 20,
            effectiveWpm: 10,
          )
          .assisted,
      isTrue,
    );
  });

  test(
    'word generator restricts material when a learned word is available',
    () {
      final exercise = ListeningExercise.generate(
        mode: ListeningMode.words,
        seed: 21,
        allowedChars: ['M', 'E'],
      );
      expect(exercise.spokenText, 'ME');
      expect(exercise.previewRequired, isFalse);
      expect(exercise.missingSymbols, isEmpty);
    },
  );

  test('replay and reveal never count as independent listening evidence', () {
    final exercise = ListeningExercise.generate(
      mode: ListeningMode.words,
      seed: 11,
    );
    final score = exercise.score({
      for (final q in exercise.questions) q.field: q.answer,
    });
    ListeningAttempt attempt({bool replayed = false, bool revealed = false}) =>
        score.attempt(
          id: 'one',
          at: DateTime(2026),
          characterWpm: 20,
          effectiveWpm: 13,
          replayed: replayed,
          revealed: revealed,
          planStepId: 'plan/2',
        );
    expect(attempt().independent, isTrue);
    expect(attempt(replayed: true).independent, isFalse);
    expect(attempt(revealed: true).independent, isFalse);
    final restored = ListeningAttempt.fromJson(
      attempt(replayed: true).toJson(),
    );
    expect(restored.assisted, isTrue);
    expect(restored.planStepId, 'plan/2');
    expect(restored.mode, ListeningMode.words);
    expect(restored.correct, 1);
    expect(restored.effectiveWpm, 13);
  });

  test('empty or duplicate question fields are rejected', () {
    expect(
      () => ListeningQuestion(field: ListeningField.answer, answer: ' '),
      throwsArgumentError,
    );
    final q = ListeningQuestion(field: ListeningField.answer, answer: 'ME');
    expect(
      () => ListeningExercise(
        mode: ListeningMode.words,
        spokenText: 'ME',
        questions: [q, q],
      ),
      throwsArgumentError,
    );
  });

  test('invalid persisted evidence does not become a successful attempt', () {
    expect(
      () => ListeningAttempt.fromJson({
        'id': 'bad',
        'at': DateTime(2026).toIso8601String(),
        'mode': 'words',
        'correct': 3,
        'total': 1,
        'characterWpm': 20,
        'effectiveWpm': 13,
      }),
      throwsFormatException,
    );
    expect(
      () => ListeningAttempt.fromJson({
        'id': 'bad',
        'at': DateTime(2026).toIso8601String(),
        'mode': 'unsupported',
        'correct': 1,
        'total': 1,
        'characterWpm': 20,
        'effectiveWpm': 13,
      }),
      throwsFormatException,
    );
  });
  test(
    'saved listening context preserves exact questions and submitted fields',
    () {
      final exercise = ListeningExercise.generate(
        mode: ListeningMode.story,
        seed: 25,
      );
      final answers = {for (final q in exercise.questions) q.field: q.answer};
      final attempt = exercise
          .score(answers)
          .attempt(
            id: 'snapshot',
            at: DateTime(2026),
            characterWpm: 20,
            effectiveWpm: 13,
            exercise: exercise,
            answers: answers,
            retryEntryId: 'mistake/1',
          );
      final restored = ListeningAttempt.fromJson(attempt.toJson());
      expect(restored.retryEntryId, 'mistake/1');
      expect(restored.exercise!.toJson(), exercise.toJson());
      expect(restored.answers, answers);
      expect(
        restored.exercise!.score(restored.answers).correct,
        restored.correct,
      );
    },
  );

  test('exact retry recomputes preview status using the current alphabet', () {
    final preview = ListeningExercise.generate(
      mode: ListeningMode.qso,
      seed: 4,
      allowedChars: ['K', 'M'],
    );
    final restored = ListeningExercise.fromJson(preview.toJson());
    expect(restored.previewRequired, isTrue);
    final retry = restored.forAlphabet(restored.spokenText.split(''));
    expect(retry.previewRequired, isFalse);
    expect(retry.spokenText, restored.spokenText);
    expect(
      retry.questions.map((q) => q.answer),
      restored.questions.map((q) => q.answer),
    );
  });

  test(
    'malformed contexts and inconsistent scores are rejected at runtime',
    () {
      final exercise = ListeningExercise.generate(
        mode: ListeningMode.words,
        seed: 2,
      );
      final answers = {ListeningField.answer: exercise.questions.single.answer};
      final valid = exercise
          .score(answers)
          .attempt(
            id: 'valid',
            at: DateTime(2026),
            characterWpm: 20,
            effectiveWpm: 10,
            exercise: exercise,
            answers: answers,
          )
          .toJson();
      for (final changes in [
        {'assisted': 'false'},
        {'assisted': null},
        {'effectiveWpm': double.nan},
        {'correct': 0},
        {'retryEntryId': ''},
        {
          'answers': {'unsupported': 'X'},
        },
      ]) {
        expect(
          () => ListeningAttempt.fromJson({...valid, ...changes}),
          throwsFormatException,
        );
      }
      final raw = exercise.toJson();
      expect(
        () => ListeningExercise.fromJson({...raw, 'spokenText': '你好'}),
        throwsFormatException,
      );
      expect(
        () => ListeningExercise.fromJson({...raw, 'questions': []}),
        throwsFormatException,
      );
    },
  );
}
