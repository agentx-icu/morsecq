import 'dart:convert';

import 'package:morse_trainer/src/exercise.dart';
import 'package:morse_trainer/src/listening_comprehension.dart';
import 'package:morse_trainer/src/radio_conditions.dart';
import 'package:morse_trainer/src/mistake_notebook.dart';
import 'package:test/test.dart';

final day = DateTime(2026, 10, 9, 14);

MistakeAttempt attempt({
  String target = 'NAME JOHN',
  String answer = 'NAME JON',
  DateTime? at,
  ExerciseSource source = ExerciseSource.focus,
  String drillKind = 'qso',
  double characterWpm = 25,
  double effectiveWpm = 15,
  String? sourceRef,
  RadioScenario? conditions,
}) => MistakeAttempt(
  target: target,
  answer: answer,
  source: source,
  drillKind: drillKind,
  at: at ?? day,
  characterWpm: characterWpm,
  effectiveWpm: effectiveWpm,
  sourceRef: sourceRef,
  conditions: conditions,
);

MistakeNotebook failed() => MistakeNotebook().recordExercise(
  exerciseId: 'first',
  attempts: [attempt()],
);

void main() {
  test(
    'retains actual failed text and blank answers without storing correct rounds',
    () {
      final book = MistakeNotebook().recordExercise(
        exerciseId: 'session-1',
        attempts: [
          attempt(target: 'NAME JOHN', answer: 'NAME JON'),
          attempt(target: 'QTH YORK', answer: ''),
          attempt(target: 'CQ', answer: 'cq'),
        ],
      );
      expect(book.pending, hasLength(2));
      final name = book.entries.first;
      expect(name.target, 'NAME JOHN');
      expect(name.originalAnswer, 'NAME JON');
      expect(name.answer, 'NAME JON');
      expect(name.drillKind, 'qso');
      expect(name.source, ExerciseSource.focus);
      expect(name.characterWpm, 25);
      expect(name.effectiveWpm, 15);
      expect(name.firstFailedAt, day);
      expect(book.entries.last.answer, isEmpty);
      expect(() => book.entries.clear(), throwsUnsupportedError);
    },
  );

  test(
    'groups normalized text only within the same origin, timing and channel',
    () {
      final light = RadioScenario.preset(
        RadioPreset.light,
        seed: 9,
        characterWpm: 25,
        effectiveWpm: 15,
        toneHz: 600,
      );
      final book = MistakeNotebook().recordExercise(
        exerciseId: 'one',
        attempts: [
          attempt(target: ' name  john ', conditions: light),
          attempt(conditions: light.forRound(1)),
          attempt(source: ExerciseSource.material),
          attempt(effectiveWpm: 18),
          attempt(sourceRef: 'lesson:2'),
          attempt(
            conditions: RadioScenario.preset(
              RadioPreset.radio,
              seed: 9,
              characterWpm: 25,
              effectiveWpm: 15,
              toneHz: 600,
            ),
          ),
        ],
      );
      expect(book.entries, hasLength(5));
      expect(book.entries.first.failureCount, 2);
      expect(book.entries.first.conditions, light);
      expect(book.entries.first.target, ' name  john ');
    },
  );

  test('saving the same exercise twice never duplicates failures', () {
    final book = failed();
    final replay = book.recordExercise(
      exerciseId: 'first',
      attempts: [attempt()],
    );
    expect(identical(book, replay), isTrue);
    expect(replay.entries.single.failureCount, 1);
  });

  test(
    'only exact independent retries on two different days recover an entry',
    () {
      var book = failed();
      final id = book.entries.single.id;
      MistakeNotebook retry(
        String exercise,
        DateTime at, {
        bool assisted = false,
        String? answer,
      }) => book.recordExercise(
        exerciseId: exercise,
        retryEntryId: id,
        assisted: assisted,
        attempts: [
          attempt(
            at: at,
            answer: answer ?? 'name  john',
            source: ExerciseSource.review,
          ),
        ],
      );
      book = retry('a', day, assisted: true);
      expect(book.entries.single.independentCorrectDays, isEmpty);
      book = retry('b', day);
      book = retry('c', day.add(const Duration(hours: 1)));
      expect(book.pending, hasLength(1));
      expect(book.entries.single.independentCorrectDays, hasLength(1));
      book = retry('d', day.add(const Duration(days: 1)));
      expect(book.pending, isEmpty);
      expect(book.recovered, hasLength(1));
      expect(book.entries.single.recoveredAt, day.add(const Duration(days: 1)));
    },
  );

  test(
    'wrong word boundaries fail even when symbol scoring would be perfect',
    () {
      var book = failed();
      final id = book.entries.single.id;
      book = book.recordExercise(
        exerciseId: 'joined',
        retryEntryId: id,
        attempts: [attempt(answer: 'NAMEJOHN')],
      );
      expect(book.entries.single.independentCorrectDays, isEmpty);
      expect(book.entries.single.failureCount, 2);
    },
  );

  test('ordinary successes and different speeds cannot clear an error', () {
    var book = failed();
    final id = book.entries.single.id;
    book = book.recordExercise(
      exerciseId: 'normal',
      attempts: [attempt(answer: 'NAME JOHN')],
    );
    book = book.recordExercise(
      exerciseId: 'slow',
      retryEntryId: id,
      attempts: [attempt(answer: 'NAME JOHN', effectiveWpm: 10)],
    );
    expect(book.entries.single.independentCorrectDays, isEmpty);
  });

  test(
    'a renewed failure reopens recovered work and resets correct-day evidence',
    () {
      var book = failed();
      final id = book.entries.single.id;
      for (var i = 0; i < 2; i++) {
        book = book.recordExercise(
          exerciseId: 'pass-$i',
          retryEntryId: id,
          attempts: [
            attempt(
              answer: 'NAME JOHN',
              at: day.add(Duration(days: i + 1)),
            ),
          ],
        );
      }
      expect(book.recovered, hasLength(1));
      book = book.recordExercise(
        exerciseId: 'wrong-again',
        retryEntryId: id,
        attempts: [attempt(answer: '', at: day.add(const Duration(days: 3)))],
      );
      expect(book.pending, hasLength(1));
      expect(book.entries.single.independentCorrectDays, isEmpty);
      expect(book.entries.single.originalAnswer, 'NAME JON');
      expect(book.entries.single.answer, isEmpty);
      expect(
        book.entries.single.lastFailedAt,
        day.add(const Duration(days: 3)),
      );
    },
  );

  test(
    'JSON roundtrip preserves recovery, context, original channel seed and deduplication',
    () {
      final light = RadioScenario.preset(
        RadioPreset.light,
        seed: 87,
        characterWpm: 25,
        effectiveWpm: 15,
        toneHz: 600,
      );
      final book = MistakeNotebook().recordExercise(
        exerciseId: 'seeded',
        attempts: [attempt(sourceRef: 'material:7', conditions: light)],
      );
      final restored = MistakeNotebook.fromJson(
        jsonDecode(jsonEncode(book.toJson())),
      );
      expect(restored.toJson(), book.toJson());
      expect(restored.entries.single.conditions, light);
      expect(
        identical(
          restored,
          restored.recordExercise(exerciseId: 'seeded', attempts: [attempt()]),
        ),
        isTrue,
      );
      expect(
        MistakeNotebook.fromJson({
          'entries': [
            null,
            {'target': 4},
          ],
        }).entries,
        isEmpty,
      );
      expect(MistakeNotebook.fromJson(null).entries, isEmpty);
    },
  );

  test('bounded notebooks evict old recovered entries before pending work', () {
    var book = MistakeNotebook(maxEntries: 2).recordExercise(
      exerciseId: 'initial',
      attempts: [
        attempt(target: 'A', answer: 'B'),
        attempt(target: 'C', answer: 'D'),
      ],
    );
    final id = book.entries.last.id;
    for (var i = 0; i < 2; i++) {
      book = book.recordExercise(
        exerciseId: 'pass-$i',
        retryEntryId: id,
        attempts: [
          attempt(
            target: 'C',
            answer: 'C',
            at: day.add(Duration(days: i + 1)),
          ),
        ],
      );
    }
    book = book.recordExercise(
      exerciseId: 'next',
      attempts: [attempt(target: 'E', answer: 'F')],
    );
    expect(book.entries.map((e) => e.target), ['A', 'E']);
    expect(book.entries, hasLength(2));
  });
  test(
    'semantic mistakes keep full audio and fields and recover from accepted information answers',
    () {
      final exercise = ListeningExercise(
        mode: ListeningMode.story,
        spokenText: 'ANNA WALKS TO THE PARK AT NOON',
        questions: [
          ListeningQuestion(field: ListeningField.person, answer: 'ANNA'),
          ListeningQuestion(
            field: ListeningField.time,
            answer: 'NOON',
            alternatives: ['12'],
          ),
        ],
      );
      MistakeAttempt semantic(
        Map<ListeningField, String> answers,
        DateTime at,
      ) => MistakeAttempt.listening(
        exercise: exercise,
        answers: answers,
        at: at,
        characterWpm: 25,
        effectiveWpm: 15,
      );
      var book = MistakeNotebook().recordExercise(
        exerciseId: 'story-failure',
        attempts: [
          semantic({
            ListeningField.person: 'ANA',
            ListeningField.time: '',
          }, day),
        ],
      );
      final id = book.entries.single.id;
      expect(book.entries.single.target, exercise.spokenText);
      expect(
        book.entries.single.listeningContext!.exercise.mode,
        ListeningMode.story,
      );
      expect(
        book.entries.single.listeningContext!.answers[ListeningField.time],
        '',
      );
      for (var i = 0; i < 2; i++) {
        book = book.recordExercise(
          exerciseId: 'story-pass-$i',
          retryEntryId: id,
          attempts: [
            semantic({
              ListeningField.person: 'anna',
              ListeningField.time: '12',
            }, day.add(Duration(days: i + 1))),
          ],
        );
      }
      expect(book.recovered, hasLength(1));
      final entry = book.entries.single;
      expect(
        entry.originalListeningContext!.answers[ListeningField.person],
        'ANA',
      );
      expect(entry.listeningContext!.answers[ListeningField.person], 'anna');
      final restored = MistakeNotebook.fromJson(
        jsonDecode(jsonEncode(book.toJson())),
      );
      expect(restored.toJson(), book.toJson());
      expect(
        restored
            .recovered
            .single
            .listeningContext!
            .exercise
            .questions
            .last
            .alternatives,
        ['12'],
      );
    },
  );

  test('different semantic question sets never group or clear each other', () {
    ListeningExercise exercise(String answer) => ListeningExercise(
      mode: ListeningMode.qso,
      spokenText: 'DE K1ABC NAME JOHN K',
      questions: [
        ListeningQuestion(field: ListeningField.callsign, answer: answer),
      ],
    );
    MistakeAttempt semantic(String expected, String answer) =>
        MistakeAttempt.listening(
          exercise: exercise(expected),
          answers: {ListeningField.callsign: answer},
          at: day,
          characterWpm: 25,
          effectiveWpm: 15,
        );
    var book = MistakeNotebook().recordExercise(
      exerciseId: 'callsign-error',
      attempts: [semantic('K1ABC', 'K1AB')],
    );
    final id = book.entries.single.id;
    book = book.recordExercise(
      exerciseId: 'changed-question',
      retryEntryId: id,
      attempts: [semantic('K2ABC', 'K2ABC')],
    );
    expect(book.entries.single.correctDayCount, 0);
    book = book.recordExercise(
      exerciseId: 'second-context-error',
      attempts: [semantic('K2ABC', '')],
    );
    expect(book.pending, hasLength(2));
  });
  test(
    'preview-based semantic retries never supply independent recovery evidence',
    () {
      final preview = ListeningExercise(
        mode: ListeningMode.words,
        spokenText: 'ANNA',
        questions: [
          ListeningQuestion(field: ListeningField.answer, answer: 'ANNA'),
        ],
        missingSymbols: ['N'],
      );
      MistakeAttempt semantic(
        ListeningExercise exercise,
        String answer,
        DateTime at,
      ) => MistakeAttempt.listening(
        exercise: exercise,
        answers: {ListeningField.answer: answer},
        at: at,
        characterWpm: 25,
        effectiveWpm: 15,
      );
      var book = MistakeNotebook().recordExercise(
        exerciseId: 'preview-failure',
        attempts: [semantic(preview, '', day)],
      );
      final id = book.entries.single.id;
      for (var i = 0; i < 2; i++) {
        book = book.recordExercise(
          exerciseId: 'preview-pass-$i',
          retryEntryId: id,
          attempts: [semantic(preview, 'ANNA', day.add(Duration(days: i + 1)))],
        );
      }
      expect(book.pending.single.correctDayCount, 0);
      final learned = preview.forAlphabet(['A', 'N']);
      for (var i = 0; i < 2; i++) {
        book = book.recordExercise(
          exerciseId: 'learned-pass-$i',
          retryEntryId: id,
          attempts: [semantic(learned, 'ANNA', day.add(Duration(days: i + 3)))],
        );
      }
      expect(book.recovered.single.id, id);
    },
  );
}
