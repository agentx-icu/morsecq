import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/mistake_practice.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_controller.dart';

import 'helpers/test_controller.dart';

void main() {
  test(
    'retry uses original exact text, pace and one round even after settings change',
    () async {
      final notebook = MistakeNotebook().recordExercise(
        exerciseId: 'first',
        attempts: [
          MistakeAttempt(
            target: 'NAME JOHN',
            answer: 'NAME JON',
            source: ExerciseSource.material,
            sourceRef: 'material:7',
            drillKind: 'words',
            at: kTestNow,
            characterWpm: 25,
            effectiveWpm: 15,
          ),
        ],
      );
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 10, mistakeNotebook: notebook),
        settings: const TrainingSettings(
          trainer: TrainerSettings(characterWpm: 20, farnsworthWpm: 8),
        ),
      );
      addTearDown(t.controller.dispose);
      final entry = notebook.entries.single;
      final session = t.controller.startMistakeSession(entry);
      expect(session.currentDrill.text, 'NAME JOHN');
      expect(session.timing.wpm, 25);
      expect(session.timing.farnsworthWpm, 15);
      expect(session.source, ExerciseSource.review);
      expect(session.sourceRef, 'mistake:${entry.id}');
      expect(session.countsTowardLesson, isFalse);
      expect(session.chars, containsAll(['J', 'O', 'H', 'N', 'K', 'M']));
      session.submit('NAME JOHN');
      expect(session.isComplete, isTrue);
      expect(session.rounds, hasLength(1));
    },
  );

  test(
    'radio retry preserves full original per-round scenario and receives conditions credit',
    () async {
      final channel = RadioScenario.preset(
        RadioPreset.radio,
        seed: 43,
        characterWpm: 25,
        effectiveWpm: 15,
        toneHz: 700,
      ).forRound(3);
      final notebook = MistakeNotebook().recordExercise(
        exerciseId: 'radio',
        attempts: [
          MistakeAttempt(
            target: 'CQ K1ABC',
            answer: '',
            source: ExerciseSource.conditions,
            drillKind: 'qso',
            at: kTestNow,
            characterWpm: 25,
            effectiveWpm: 15,
            conditions: channel,
          ),
        ],
      );
      final t = await TestTraining.create(
        progress: TrainerProgress(mistakeNotebook: notebook),
      );
      addTearDown(t.controller.dispose);
      final session = t.controller.startMistakeSession(notebook.entries.single);
      expect(session.currentConditions, channel);
      expect(session.source, ExerciseSource.conditions);
      expect(session.learnedChars, t.controller.learnedChars.toSet());
    },
  );
  test(
    'a blank round persists as a notebook error in the same progress write',
    () async {
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      final session = ReceiveSession(
        id: 'blank-error',
        kind: ReceiveDrillKind.words,
        generator: const _SavedText('CQ TEST'),
        chars: const ['C', 'Q', 'T', 'E', 'S'],
        timing: const MorseTiming(wpm: 25, farnsworthWpm: 15),
        charBudget: 6,
        source: ExerciseSource.material,
        sourceRef: 'material:7',
        random: t.controller.random,
        now: t.controller.now,
      );
      session.submit('');
      expect(session.hasAnswers, isFalse);
      final outcome = await t.controller.recordReceiveSession(session);
      expect(outcome.saved, isTrue);
      expect(outcome.credit.activity, isFalse);
      expect(t.progressStore.saveCount, 1);
      final disk = (await t.progressStore.load())!;
      expect(disk.mistakeNotebook.pending.single.target, 'CQ TEST');
      expect(disk.mistakeNotebook.pending.single.answer, isEmpty);
      expect(disk.mistakeNotebook.pending.single.sourceRef, 'material:7');
      await t.controller.load();
      await t.controller.recordReceiveSession(session);
      expect(
        t.controller.progress.mistakeNotebook.entries.single.failureCount,
        1,
      );
      expect(t.progressStore.saveCount, 1);
    },
  );

  test(
    'recorded retries retain same-day and assisted limits across restart',
    () async {
      final notebook = MistakeNotebook().recordExercise(
        exerciseId: 'first',
        attempts: [
          MistakeAttempt(
            target: 'NAME JOHN',
            answer: 'NAME JON',
            source: ExerciseSource.focus,
            drillKind: 'qso',
            at: kTestNow,
            characterWpm: 25,
            effectiveWpm: 15,
          ),
        ],
      );
      final t = await TestTraining.create(
        progress: TrainerProgress(mistakeNotebook: notebook),
      );
      addTearDown(t.controller.dispose);
      final id = notebook.entries.single.id;
      Future<void> retry({bool assisted = false}) async {
        final entry = t.controller.progress.mistakeNotebook.entryById(id)!;
        final session = t.controller.startMistakeSession(entry);
        if (assisted) session.markReplay();
        session.submit(entry.target);
        await t.controller.recordReceiveSession(session);
      }

      await retry(assisted: true);
      expect(
        t.controller.progress.mistakeNotebook.entries.single.correctDayCount,
        0,
      );
      await retry();
      await retry();
      await t.controller.load();
      expect(
        t.controller.progress.mistakeNotebook.pending.single.correctDayCount,
        1,
      );
      t.clock.advance(const Duration(days: 1));
      await retry(assisted: true);
      expect(t.controller.progress.mistakeNotebook.pending, hasLength(1));
      await retry();
      await t.controller.load();
      expect(t.controller.progress.mistakeNotebook.pending, isEmpty);
      expect(t.controller.progress.mistakeNotebook.recovered.single.id, id);
    },
  );
  test(
    'semantic mistakes cannot be retried through transcript copying',
    () async {
      final exercise = ListeningExercise.generate(
        mode: ListeningMode.story,
        seed: 2,
      );
      final book = MistakeNotebook().recordExercise(
        exerciseId: 'semantic',
        attempts: [
          MistakeAttempt.listening(
            exercise: exercise,
            answers: {},
            at: kTestNow,
            characterWpm: 25,
            effectiveWpm: 15,
          ),
        ],
      );
      final t = await TestTraining.create(
        progress: TrainerProgress(mistakeNotebook: book),
      );
      addTearDown(t.controller.dispose);
      expect(
        () => t.controller.startMistakeSession(book.entries.single),
        throwsArgumentError,
      );
    },
  );
  test(
    'semantic answers and original audio persist and recover atomically across sessions',
    () async {
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
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      ListeningAttempt attempt(
        String id,
        Map<ListeningField, String> answers, {
        String? retryId,
        bool replayed = false,
      }) => exercise
          .score(answers)
          .attempt(
            id: id,
            at: t.clock.now,
            characterWpm: 25,
            effectiveWpm: 15,
            exercise: exercise,
            answers: answers,
            retryEntryId: retryId,
            replayed: replayed,
          );
      final failure = attempt('info-error', {ListeningField.person: 'ANA'});
      await t.controller.recordListeningAttempt(failure);
      expect(t.progressStore.saveCount, 1);
      final entry = t.controller.progress.mistakeNotebook.pending.single;
      expect(entry.listeningContext!.exercise.spokenText, exercise.spokenText);
      expect(entry.listeningContext!.answers[ListeningField.person], 'ANA');
      expect(t.controller.progress.charStats, isEmpty);
      await t.controller.load();
      await t.controller.recordListeningAttempt(failure);
      expect(
        t.controller.progress.mistakeNotebook.entries.single.failureCount,
        1,
      );
      final correct = {
        ListeningField.person: 'ANNA',
        ListeningField.time: '12',
      };
      await t.controller.recordListeningAttempt(
        attempt('info-assisted', correct, retryId: entry.id, replayed: true),
      );
      expect(
        t.controller.progress.mistakeNotebook.pending.single.correctDayCount,
        0,
      );
      await t.controller.recordListeningAttempt(
        attempt('info-pass-1', correct, retryId: entry.id),
      );
      await t.controller.load();
      t.clock.advance(const Duration(days: 1));
      await t.controller.recordListeningAttempt(
        attempt('info-pass-2', correct, retryId: entry.id),
      );
      await t.controller.load();
      expect(t.controller.progress.mistakeNotebook.pending, isEmpty);
      expect(
        t.controller.progress.mistakeNotebook.recovered.single.id,
        entry.id,
      );
      expect(t.controller.progress.charStats, isEmpty);
    },
  );
}

final class _SavedText implements DrillGenerator {
  const _SavedText(this.text);
  final String text;
  @override
  String get kind => 'words';
  @override
  Drill generate(Random random) => Drill.fromText(text, kind: kind);
}
