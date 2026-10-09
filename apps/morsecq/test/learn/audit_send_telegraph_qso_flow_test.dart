import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/send_session.dart';
import 'package:morsecq/training/telegraph_sessions.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_doc_store.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_summary_view.dart';
import 'package:morsecq/ui/learn/send/send_targeted_practice.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_recall_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

final class _RecallDocs implements TrainingDocStore {
  final delegate = InMemoryTrainingDocStore();
  bool failWrites = true;

  @override
  Future<Map<String, Object?>?> read(String name) => delegate.read(name);
  @override
  Future<List<String>> names() => delegate.names();
  @override
  Future<void> delete(String name) => delegate.delete(name);
  @override
  Future<void> write(String name, Map<String, Object?> json) async {
    if (name == TelegraphSessions.recallDoc && failWrites) {
      throw StateError('temporary disk failure');
    }
    await delegate.write(name, json);
  }
}

void main() {
  for (final scenario in QsoScenario.values) {
    testWidgets(
      'audit $scenario typed protocol completes UI through persisted result',
      (tester) async {
        tester.view.physicalSize = const Size(430, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final t = await TestTraining.create();
        final playback = FakeLearnPlaybackFactory();
        final session = QsoSession.start(
          scenario: scenario,
          seed: 51,
          local: const QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS'),
          characterWpm: 20,
          effectiveWpm: 20,
        );
        await tester.pumpWidget(
          l10nApp(
            home: QsoScreen(
              controller: t.controller,
              playback: playback,
              session: session,
            ),
          ),
        );
        await tester.pumpAndSettle();
        playback.clock.advance(const Duration(minutes: 5));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
        await tester.pump();
        for (var turn = 0; !session.isDone && turn < 6; turn++) {
          playback.clock.advance(const Duration(minutes: 5));
          await tester.pump();
          final text = switch (session.stage) {
            QsoStage.callCq => 'CQ CQ DE BD1XYZ K',
            QsoStage.callConfirm => '${session.remote.callsign} DE BD1XYZ K',
            QsoStage.exchange => switch (scenario) {
              QsoScenario.shortExchange => 'UR RST 599 K',
              QsoScenario.contestExchange =>
                'UR RST 599 NR ${session.local.serialNumber} K',
              QsoScenario.potaActivation =>
                'UR RST 599 PARK ${session.local.parkOnAir} K',
              _ =>
                '${scenario == QsoScenario.callCq ? '${session.remote.callsign} DE BD1XYZ ' : ''}UR RST 599 NAME LI QTH PARIS K',
            },
            QsoStage.confirmInfo =>
              scenario.isAdvanced
                  ? 'R R RST ${session.report} ${scenario == QsoScenario.contestExchange ? 'NR ${session.remote.serialNumber}' : 'PARK ${session.remote.parkOnAir}'} K'
                  : 'R R TNX ${session.remote.name}',
            QsoStage.closing => 'TU 73 <SK>',
            QsoStage.done => '',
          };
          await tester.enterText(
            find.byKey(const ValueKey('qso-typed-reply')),
            text,
          );
          await tester.pump();
          await tester.tap(find.byKey(const ValueKey('qso-send')));
          await tester.pumpAndSettle();
        }
        expect(session.isDone, isTrue);
        expect(find.byType(QsoSummaryView), findsOneWidget);
        final row = t.controller.progress.history.single;
        expect(row.source, ExerciseSource.qso);
        expect(
          row.sourceRef,
          'qso:${scenario.name}:${session.answerStages}/${session.answerStages}',
        );
        expect(row.isKnownUnassisted, isFalse);
        expect(await t.controller.loadQsoDraft(), isNull);
        expect(t.controller.progress.overallAccuracy, 0);
        await t.controller.finishQso(session, Duration.zero);
        expect(t.controller.progress.history, hasLength(1));
      },
    );
  }

  testWidgets('audit a QSO double tap never submits a cleared typed reply', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final t = await TestTraining.create();
    addTearDown(t.controller.dispose);
    final playback = FakeLearnPlaybackFactory();
    final session = QsoSession.start(
      scenario: QsoScenario.shortExchange,
      seed: 51,
      local: const QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS'),
      characterWpm: 20,
      effectiveWpm: 20,
    );
    await tester.pumpWidget(
      l10nApp(
        home: QsoScreen(
          controller: t.controller,
          playback: playback,
          session: session,
        ),
      ),
    );
    await tester.pumpAndSettle();
    playback.clock.advance(const Duration(minutes: 2));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('qso-typed-reply')),
      '${session.remote.callsign} DE BD1XYZ K',
    );
    await tester.pump();
    final send = find.byKey(const ValueKey('qso-send'));
    await tester.tap(send);
    // Keep the original enabled callback alive: no frame between taps.
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(session.learnerTurns, 1);
    expect(session.stage, QsoStage.exchange);
    expect(
      session.turns.where(
        (turn) => !turn.fromRemote && turn.text.trim().isEmpty,
      ),
      isEmpty,
    );
    expect((await t.controller.loadQsoDraft())!.session.learnerTurns, 1);
    expect(t.controller.progress.history, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  for (final interrupt in [
    'leave',
    'background',
    'hint-then-leave',
    'keyed-to-typed',
  ]) {
    testWidgets('audit QSO $interrupt retains the final uncommitted symbol', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final t = await TestTraining.create(
        settings: const TrainingSettings(keyerMode: KeyerMode.straight),
      );
      final playback = FakeLearnPlaybackFactory();
      final session = QsoSession.start(
        scenario: QsoScenario.shortExchange,
        seed: 51,
        local: const QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS'),
        characterWpm: 20,
        effectiveWpm: 20,
      );
      await tester.pumpWidget(
        l10nApp(
          home: QsoScreen(
            controller: t.controller,
            playback: playback,
            session: session,
            resumed: QsoDraft(session: session),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final key = find.byType(StraightKeyButton);
      // E is fully released, but its decoder character boundary has not
      // elapsed. This is ordinary completed key input, not a held key.
      final gesture = await tester.startGesture(tester.getCenter(key));
      playback.clock.advance(const Duration(milliseconds: 60));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      if (interrupt == 'keyed-to-typed') {
        await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
        await tester.pump();
        expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('qso-typed-reply')))
              .controller!
              .text,
          'E',
        );
      }
      if (interrupt == 'hint-then-leave') {
        await tester.tap(find.text(en.learnQsoHint));
        await tester.pump();
        // Saving while still practising must not force a character boundary.
        playback.clock.advance(const Duration(milliseconds: 60));
        final second = await tester.startGesture(tester.getCenter(key));
        playback.clock.advance(const Duration(milliseconds: 60));
        await second.up();
        await tester.pump();
      }
      if (interrupt != 'background') {
        await tester.pumpWidget(const SizedBox.shrink());
      } else {
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      }
      await tester.pump();
      final draft = (await t.controller.loadQsoDraft())!;
      expect(draft.pendingText, interrupt == 'hint-then-leave' ? 'I' : 'E');
      expect(draft.session.learnerTurns, 0);
      expect(t.controller.progress.history, isEmpty);
    });
  }

  for (final cards in [1, 2]) {
    testWidgets(
      'audit recall double Next cannot skip or overrun $cards cards',
      (tester) async {
        final t = await TestTraining.create();
        addTearDown(t.controller.dispose);
        await tester.pumpWidget(
          l10nApp(
            home: TelegraphRecallScreen(
              controller: t.controller,
              codebook: TelegraphCodebook.mainland,
              cards: cards,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final char = tester
            .widget<Text>(find.byKey(const Key('telegraph-prompt')))
            .data!;
        await tester.enterText(
          find.byKey(const Key('telegraph-code-field')),
          ChineseTelegraphCode.codeOf(char)!,
        );
        await tester.pump();
        await tester.tap(find.byKey(const Key('telegraph-check')));
        await tester.pump();
        final next = find.byKey(const Key('telegraph-next'));
        await tester.tap(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final stats = await t.controller.readTelegraphRecall();
        expect(stats.answered(TelegraphCodebook.mainland), cards == 1 ? 1 : 0);
        expect(
          find.byKey(const Key('telegraph-summary')),
          cards == 1 ? findsOneWidget : findsNothing,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets(
    'audit repeated recall save retries cannot credit the same round twice',
    (tester) async {
      final docs = _RecallDocs();
      final controller = TrainingController(
        progressStore: InMemoryTrainerStore(),
        settingsStore: InMemoryTrainingSettingsStore(),
        docs: docs,
      );
      await controller.load();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        l10nApp(
          home: TelegraphRecallScreen(
            controller: controller,
            codebook: TelegraphCodebook.mainland,
            cards: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final char = tester
          .widget<Text>(find.byKey(const Key('telegraph-prompt')))
          .data!;
      final code = ChineseTelegraphCode.codeOf(char)!;
      await tester.enterText(
        find.byKey(const Key('telegraph-code-field')),
        code,
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('telegraph-check')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('telegraph-next')));
      await tester.pumpAndSettle();
      final retry = find.byKey(const Key('telegraph-save-retry'));
      expect(retry, findsOneWidget);
      docs.failWrites = false;
      // A quick double tap occurs before the button's next frame removes it.
      await tester.tap(retry);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      final stats = await controller.readTelegraphRecall();
      expect(stats.answered(TelegraphCodebook.mainland), 1);
      expect(stats.of(TelegraphCodebook.mainland, char), (1, 1, 0));
    },
  );

  testWidgets('audit both codebooks finish ten mixed-direction recall cards', (
    tester,
  ) async {
    final docs = InMemoryTrainingDocStore();
    final controller = TrainingController(
      progressStore: InMemoryTrainerStore(),
      settingsStore: InMemoryTrainingSettingsStore(),
      docs: docs,
    );
    await controller.load();
    addTearDown(controller.dispose);
    for (final book in TelegraphCodebook.values) {
      await tester.pumpWidget(
        l10nApp(
          home: TelegraphRecallScreen(
            key: ValueKey(book),
            controller: controller,
            codebook: book,
            random: Random(1),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var index = 0; index < 10; index++) {
        final prompt = tester
            .widget<Text>(find.byKey(const Key('telegraph-prompt')))
            .data!;
        if (index == 0) {
          await tester.tap(find.byKey(const Key('telegraph-reveal')));
          await tester.pump();
        }
        if (index.isEven) {
          await tester.enterText(
            find.byKey(const Key('telegraph-code-field')),
            ChineseTelegraphCode.codeOf(prompt, codebook: book)!,
          );
          await tester.pump();
          await tester.tap(find.byKey(const Key('telegraph-check')));
        } else {
          final choice = ChineseTelegraphCode.charsOf(prompt, codebook: book)
              .map((c) => find.byKey(Key('telegraph-choice-$c')))
              .firstWhere((f) => f.evaluate().isNotEmpty);
          await tester.tap(choice);
        }
        await tester.pump();
        await tester.tap(find.byKey(const Key('telegraph-next')));
        await tester.pumpAndSettle();
      }
      expect(find.byKey(const Key('telegraph-summary')), findsOneWidget);
      final stats = TelegraphRecallStats.fromJson(
        await docs.read(TelegraphSessions.recallDoc),
      );
      expect(stats.answered(book), 10);
      expect(stats.accuracy(book), 1);
      expect(controller.progress.history, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets(
    'audit targeted sending limits three real attempts and model playback earns nothing',
    (tester) async {
      tester.view.physicalSize = const Size(430, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final t = await TestTraining.create(
        settings: const TrainingSettings(keyerMode: KeyerMode.straight),
      );
      final playback = FakeLearnPlaybackFactory();
      final template = SendSession(
        target: 'K',
        timing: const MorseTiming(wpm: 20),
        now: t.controller.now,
      );
      await tester.pumpWidget(
        l10nApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => openTargetedSendPractice(
                  context,
                  controller: t.controller,
                  playback: playback,
                  template: template,
                  text: 'E',
                ),
                child: const Text('Open targeted'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open targeted'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(en.learnRhythmPlayStandard));
      playback.clock.advance(const Duration(seconds: 2));
      await tester.pump();
      expect(t.controller.progress.history, isEmpty);
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(find.text(en.learnHiddenTarget), findsOneWidget);
      for (var attempt = 0; attempt < 3; attempt++) {
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(StraightKeyButton)),
        );
        playback.clock.advance(const Duration(milliseconds: 60));
        await gesture.up();
        playback.clock.advance(const Duration(milliseconds: 360));
        await tester.pump();
        await tester.tap(find.text(en.learnDone));
        await tester.pumpAndSettle();
        expect(t.controller.progress.history.length, attempt + 1);
        expect(t.controller.progress.history.last.source, ExerciseSource.send);
        expect(t.controller.progress.history.last.strictAccuracy, 1);
        if (attempt < 2) {
          await tester.tap(find.text(en.learnTryAnother));
          await tester.pumpAndSettle();
        }
      }
      expect(find.text(en.learnTryAnother), findsNothing);
      await tester.tap(find.text(en.learnDone));
      await tester.pumpAndSettle();
      expect(find.text('Open targeted'), findsOneWidget);
      expect(t.controller.progress.history, hasLength(3));
    },
  );

  for (final book in TelegraphCodebook.values) {
    test(
      'audit $book digit copying records codebook and excludes lesson unlock',
      () async {
        final t = await TestTraining.create(
          progress: TrainerProgress(currentLesson: 40),
          settings: const TrainingSettings(
            trainer: TrainerSettings(sessionLengthChars: 4),
          ),
        );
        final session = t.controller.startTelegraphDigitsSession(
          book,
          random: Random(1),
          now: t.controller.now,
        );
        expect(session.currentDrill.text, matches(RegExp(r'^\d{4}$')));
        final originalLesson = t.controller.currentLesson;
        session.submit(session.currentDrill.text);
        expect(session.isComplete, isTrue);
        final outcome = await t.controller.recordReceiveSession(session);
        expect(outcome.saved, isTrue);
        expect(outcome.advanced, isFalse);
        expect(t.controller.currentLesson, originalLesson);
        expect(
          t.controller.progress.history.single.sourceRef,
          TelegraphCurriculum.sourceRef(book),
        );
        expect(t.controller.telegraphDigitsResults(book), (1, 1.0));
        await t.controller.recordReceiveSession(session);
        expect(t.controller.telegraphDigitsResults(book), (1, 1.0));
      },
    );
  }
}
