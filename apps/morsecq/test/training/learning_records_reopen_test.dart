import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/audio_material_store.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/material_practice.dart';
import 'package:morsecq/training/material_store.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/send_detail_store.dart';
import 'package:morsecq/training/telegraph_sessions.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/training/training_plan.dart';

void main() {
  test(
    'every practice mode and document survives file reopen and learning clear',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'morsecq_all_learning_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = LocalLearningStore(root: () async => directory.path);
      final host = TrainingControllerHost(store);
      addTearDown(host.dispose);
      final c = await host.controller();
      await c.setLesson(c.lessonCount);
      await c.markFirstLessonDone();
      await c.updateSettings(
        c.settings.copyWith(
          trainer: c.trainerSettings.copyWith(
            characterWpm: 20,
            farnsworthWpm: 13,
          ),
        ),
      );

      Future<void> copy(ReceiveSession session, {bool wrong = false}) async {
        var first = true;
        while (!session.isComplete) {
          session.submit(wrong && first ? 'NOPE' : session.currentDrill.text);
          first = false;
        }
        final recorded = await c.recordReceiveSession(session);
        expect(recorded.saved, isTrue);
        expect((await c.recordReceiveSession(session)).duplicate, isTrue);
      }

      for (final kind in ReceiveDrillKind.values) {
        await copy(
          c.startReceiveSession(kind),
          wrong: kind == ReceiveDrillKind.groups,
        );
      }
      for (final preset in RadioPreset.values.where(
        (p) => p != RadioPreset.clear,
      )) {
        await copy(
          c.startReceiveSession(ReceiveDrillKind.groups, preset: preset),
        );
      }
      for (final level in GuidedLevel.values) {
        await copy(c.startGuidedSession(level: level));
      }
      await copy(c.startLessonSession());
      final material = MaterialImport.create(
        id: 'audit_words',
        title: 'Saved words',
        kind: MaterialKind.wordList,
        text: 'CQ\nDE\nTU',
        analysis: MaterialImport.analyze('CQ\nDE\nTU', MaterialKind.wordList),
        now: c.now(),
      );
      await c.upsertMaterial(material);
      await copy(c.startMaterialSession(material, learnedOnly: true)!);
      for (final book in TelegraphCodebook.values) {
        await copy(c.startTelegraphDigitsSession(book));
        await c.recordTelegraphRecall(book, [
          (TelegraphCurriculum.introductoryFor(book).first, true, false),
        ]);
      }
      await c.recordExercise(
        score: SessionScore.evaluate('KM', 'KM', at: c.now()),
        id: 'audit_placement',
        source: ExerciseSource.placement,
        assistance: const {},
      );

      final send = c.startGuidedSendSession();
      addTearDown(send.dispose);
      var elapsed = Duration.zero;
      for (final element in MorseEncoder.encode(
        send.target,
        send.nominalTiming,
      )) {
        if (element.on) {
          send.keyDown(elapsed);
          send.keyUp(elapsed + element.duration);
        }
        elapsed += element.duration;
      }
      final detail = await c.saveSendDetail(send, send.finish());
      await c.setSendDetailFavorite(detail, true);
      await c.recordSendSession(send, detailRef: detail);

      const station = QsoStation(callsign: 'K1ABC', name: 'AL', qth: 'CA');
      await c.saveQsoStation(station);
      final qso = QsoSession.start(
        scenario: QsoScenario.shortExchange,
        seed: 703,
        local: station,
        characterWpm: 20,
        effectiveWpm: 13,
      );
      await c.saveQsoDraft(qso, pendingText: 'K1ABC', pendingId: 'draft-reply');
      await c.commitProgress((p) => p.copyWith(courseCompleted: true));
      await c.setLearningGoal(LearningGoal.contest);
      final plan = await c.ensureTodayPlan();
      final step = plan.steps.firstWhere(
        (s) => s.kind == PlanStepKind.comprehension,
      );
      await c.startGoalPlanStep(step);
      for (final mode in ListeningMode.values) {
        final exercise = ListeningExercise.generate(
          mode: mode,
          seed: mode.index + 800,
        );
        await c.recordListeningAttempt(
          ListeningAttempt(
            id: 'audit_listening_${mode.name}',
            at: c.now(),
            mode: mode,
            correct: 0,
            total: exercise.questions.length,
            characterWpm: 20,
            effectiveWpm: 13,
            exercise: exercise,
            answers: const {},
            planStepId: mode == ListeningMode.words ? step.id : null,
          ),
        );
      }
      final media = File('${directory.path}/media/recordings/audit.wav');
      await media.parent.create(recursive: true);
      await media.writeAsBytes([82, 73, 70, 70]);
      await c.upsertAudioMaterial(
        AudioMaterial(
          id: 'audit_audio',
          title: 'Saved selection',
          file: 'media/recordings/audit.wav',
          originalName: 'input.wav',
          start: Duration.zero,
          end: const Duration(seconds: 1),
          sampleRate: 8000,
          channels: 1,
          createdAt: c.now(),
          note: 'CQ',
        ),
      );
      await c.flush();
      final expectedProgress = c.progress.toJson();
      final expectedSettings = c.settings;

      final reopened = await store.openController();
      expect(reopened.loadError, isNull);
      expect(reopened.progress.toJson(), expectedProgress);
      expect(reopened.settings, expectedSettings);
      expect(
        (await reopened.loadMaterials()).single.toJson(),
        material.toJson(),
      );
      expect((await reopened.loadAudioMaterials()).single.note, 'CQ');
      expect((await reopened.loadQsoStation())!.callsign, station.callsign);
      expect((await reopened.loadQsoDraft())!.pendingText, 'K1ABC');
      expect((await reopened.loadSendDetail(detail))!.marks, send.marks);
      expect(await reopened.isSendDetailFavorite(detail), isTrue);
      for (final book in TelegraphCodebook.values) {
        expect((await reopened.readTelegraphRecall()).answered(book), 1);
      }
      expect(
        reopened.progress.listeningAttempts.length,
        ListeningMode.values.length,
      );
      expect(reopened.progress.mistakeNotebook.pending, isNotEmpty);
      expect(reopened.todayPlan!.stepById(step.id)!.isDone, isTrue);
      reopened.dispose();

      await host.clear();
      final cleared = await host.controller();
      expect(c.isDisposed, isTrue);
      expect(cleared.progress.history, isEmpty);
      expect(cleared.progress.listeningAttempts, isEmpty);
      expect(cleared.progress.mistakeNotebook.entries, isEmpty);
      expect(cleared.progress.dailyPlan, isNull);
      expect(cleared.progress.learningGoal, LearningGoal.firstQso);
      expect(await cleared.docNames(), isEmpty);
      expect(await media.exists(), isFalse);
    },
  );
}
