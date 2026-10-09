import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/file_trainer_store.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_plan.dart';
import 'package:morsecq/training/training_settings_store.dart';

void main() {
  late Directory directory;
  late DateTime at;
  TrainingController controller() => TrainingController(
    progressStore: FileTrainerStore.inDataDirectory(directory.path),
    settingsStore: InMemoryTrainingSettingsStore(),
    now: () => at,
  );
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('morsecq_advanced_');
    at = DateTime(2026, 10, 9);
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'exact receive mistake and selected goal survive real file reopen',
    () async {
      final first = controller();
      await first.load();
      final session = ReceiveSession(
        kind: ReceiveDrillKind.groups,
        generator: RandomGroupsDrill(chars: ['K'], groupCount: 1, groupSize: 1),
        chars: ['K'],
        timing: const MorseTiming(wpm: 20, farnsworthWpm: 13),
        charBudget: 1,
        random: Random(1),
        now: () => at,
      );
      session.submit('M');
      await first.recordReceiveSession(session);
      await first.recordReceiveSession(session);
      await first.setLearningGoal(LearningGoal.contest);
      await first.flush();
      final reopened = controller();
      await reopened.load();
      expect(reopened.progress.learningGoal, LearningGoal.contest);
      expect(reopened.progress.mistakeNotebook.entries.single.target, 'K');
      expect(reopened.progress.mistakeNotebook.entries.single.failureCount, 1);
      first.dispose();
      reopened.dispose();
    },
  );

  test(
    'blank copying still becomes a mistake without crediting activity',
    () async {
      final c = controller();
      await c.load();
      final session = ReceiveSession(
        kind: ReceiveDrillKind.groups,
        generator: RandomGroupsDrill(chars: ['K'], groupCount: 1, groupSize: 1),
        chars: ['K'],
        timing: const MorseTiming(wpm: 20),
        charBudget: 1,
        random: Random(1),
        now: () => at,
      );
      session.submit('');
      await c.recordReceiveSession(session);
      expect(c.progress.mistakeNotebook.pending.length, 1);
      expect(c.progress.lifetimeSessions, 0);
      c.dispose();
    },
  );

  test(
    'semantic listening errors save exact questions in the notebook once',
    () async {
      final c = controller();
      await c.load();
      final exercise = ListeningExercise.generate(
        mode: ListeningMode.qso,
        seed: 4,
      );
      final attempt = ListeningAttempt(
        id: 'listen_wrong',
        at: at,
        mode: ListeningMode.qso,
        correct: 0,
        total: exercise.questions.length,
        characterWpm: 20,
        effectiveWpm: 13,
        exercise: exercise,
        answers: const {},
      );
      await c.recordListeningAttempt(attempt);
      await c.recordListeningAttempt(attempt);
      expect(c.progress.mistakeNotebook.pending.length, 1);
      final restored = controller();
      await restored.load();
      expect(
        restored
            .progress
            .mistakeNotebook
            .pending
            .single
            .listeningContext!
            .exercise
            .spokenText,
        exercise.spokenText,
      );
      expect(restored.progress.listeningAttempts.length, 1);
      expect(restored.progress.charStats, isEmpty);
      c.dispose();
      restored.dispose();
    },
  );

  test(
    'listening completes only its active plan step and reloads independently',
    () async {
      final c = controller();
      await c.load();
      await c.commitProgress(
        (p) => p.copyWith(currentLesson: 42, courseCompleted: true),
      );
      final plan = await c.ensureTodayPlan();
      final listening = plan.steps.firstWhere(
        (s) => s.kind == PlanStepKind.comprehension,
      );
      await c.startGoalPlanStep(listening);
      final attempt = ListeningAttempt(
        id: 'listen_save',
        at: at,
        mode: ListeningMode.qso,
        correct: 3,
        total: 3,
        characterWpm: 20,
        effectiveWpm: 13,
        planStepId: listening.id,
      );
      await c.recordListeningAttempt(attempt);
      await c.recordListeningAttempt(attempt);
      expect(c.todayPlan!.stepById(listening.id)!.isDone, isTrue);
      expect(c.progress.listeningAttempts.length, 1);
      expect(c.progress.charStats, isEmpty);
      final restored = controller();
      await restored.load();
      expect(restored.progress.listeningAttempts.single.accuracy, 1);
      expect(restored.progress.mistakeNotebook.entries, isEmpty);
      c.dispose();
      restored.dispose();
    },
  );

  test(
    'goal changes replace pending work while retaining finished work',
    () async {
      final c = controller();
      await c.load();
      await c.commitProgress(
        (p) => p.copyWith(currentLesson: 42, courseCompleted: true),
      );
      final plan = await c.ensureTodayPlan();
      final send = plan.steps.firstWhere((s) => s.kind == PlanStepKind.send);
      await c.commitProgress(
        (p) => p.withDailyPlan(
          plan.start(send.id).complete(send.id, exerciseId: 'send_done'),
        ),
      );
      await c.setLearningGoal(LearningGoal.contest);
      expect(c.todayPlan!.stepById(send.id)!.resultRef, 'send_done');
      expect(
        c.todayPlan!.steps.firstWhere((s) => s.kind == PlanStepKind.qso).pool,
        ['contestExchange'],
      );
      c.dispose();
    },
  );

  QsoSession completedQso(String stepId) {
    final session = QsoSession.start(
      scenario: QsoScenario.shortExchange,
      seed: 81,
      local: const QsoStation(callsign: 'K1ABC', name: 'AL', qth: 'CA'),
      characterWpm: 20,
      effectiveWpm: 13,
      planStepId: stepId,
    );
    session.submit('wrong', 'NOPE');
    session.submit('call', '${session.remote.callsign} DE K1ABC K');
    session.submit('exchange', 'UR RST 599 K');
    session.submit('closing', 'TU 73 <SK>');
    expect(session.isDone, isTrue);
    return session;
  }

  test(
    'QSO plan retains the semantic score after correcting an error',
    () async {
      final c = controller();
      await c.load();
      await c.commitProgress((p) => p.copyWith(courseCompleted: true));
      final plan = await c.ensureTodayPlan();
      final step = plan.steps.firstWhere((s) => s.kind == PlanStepKind.qso);
      await c.startGoalPlanStep(step);
      final session = completedQso(step.id);
      await c.recordQso(session, Duration.zero);
      expect(c.todayPlan!.stepById(step.id)!.isDone, isTrue);
      expect(c.todayPlan!.stepById(step.id)!.accuracy, closeTo(2 / 3, .001));
      c.dispose();
    },
  );

  test(
    'late QSO result cannot finish an earlier inspection-only plan',
    () async {
      final c = controller();
      await c.load();
      await c.commitProgress((p) => p.copyWith(courseCompleted: true));
      final plan = await c.ensureTodayPlan();
      final step = plan.steps.firstWhere((s) => s.kind == PlanStepKind.qso);
      await c.startGoalPlanStep(step);
      final session = completedQso(step.id);
      at = at.add(const Duration(days: 1));
      await c.recordQso(session, Duration.zero);
      expect(c.progress.history.length, 1);
      expect(c.progress.dailyPlan!.stepById(step.id)!.isDone, isFalse);
      c.dispose();
    },
  );
}
