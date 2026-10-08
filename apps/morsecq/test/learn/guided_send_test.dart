import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/send_session.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/send/send_live_view.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

void main() {
  test('new learner sends one K rather than a five-symbol group', () async {
    final t = await TestTraining.create();
    addTearDown(t.controller.dispose);
    final session = t.controller.startSendSession();
    addTearDown(session.dispose);
    expect(session.target, 'K');
  });

  testWidgets('guided sending asks to hear before exposing the key', (
    tester,
  ) async {
    final t = await TestTraining.create(
      settings: const TrainingSettings(keyerMode: KeyerMode.straight),
    );
    addTearDown(t.controller.dispose);
    final playback = FakeLearnPlaybackFactory();
    await tester.pumpWidget(
      l10nApp(
        home: SendPracticeScreen(controller: t.controller, playback: playback),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StraightKeyButton), findsNothing);
    expect(find.byKey(const ValueKey('send-guide-hear')), findsOneWidget);
    expect(t.controller.progress.history, isEmpty);
  });

  test(
    'failed sending repeats K; exact decoded sending resumes each stage',
    () async {
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      var session = t.controller.startSendSession();
      _keyText(session, 'E');
      await t.controller.recordSendSession(session);
      session.dispose();
      session = t.controller.startSendSession();
      expect(
        session.target,
        'K',
        reason: 'activity alone does not pass a stage',
      );
      session.dispose();
      for (final expected in ['K', 'M', 'KM', 'KMKMK']) {
        session = t.controller.startSendSession();
        expect(session.target, expected);
        _keyText(session, expected);
        expect(session.finish().attempt.decoded.replaceAll(' ', ''), expected);
        await t.controller.recordSendSession(session);
        session.dispose();
        t.clock.advance(const Duration(seconds: 1));
      }
      expect(GuidedSending.nextStage(t.controller.progress.history), isNull);
      expect(t.controller.progress.currentLesson, 1);
      expect(t.controller.progress.charStats, isEmpty);
      session = t.controller.startSendSession();
      expect(session.drillKind, 'send');
      session.dispose();
      session = t.controller.startGuidedSendSession();
      expect(session.target, 'K', reason: 'a completed guide can be revisited');
      session.dispose();
    },
  );

  test('resuming a guide preserves plan linkage; restart revisits K', () async {
    final t = await TestTraining.create();
    addTearDown(t.controller.dispose);
    final first = t.controller.startGuidedSendSession(planStepId: 'plan-send');
    _keyText(first, 'K');
    await t.controller.recordSendSession(first);
    first.dispose();
    final resumed = t.controller.startGuidedSendSession(
      planStepId: 'plan-send',
    );
    expect(resumed.target, 'M');
    expect(resumed.planStepId, 'plan-send');
    resumed.dispose();
    final restarted = t.controller.startGuidedSendSession(restart: true);
    expect(restarted.target, 'K');
    restarted.dispose();
  });

  test(
    'incomplete, assisted or inserted-symbol records do not pass a stage',
    () {
      SessionSummary record({
        bool completed = true,
        Set<Assistance> help = const {},
        int inserted = 0,
      }) => SessionSummary(
        at: DateTime(2026, 10, 8),
        totalChars: 1,
        correctChars: 1,
        source: ExerciseSource.send,
        drillKind: GuidedSendStage.k.drillKind,
        completed: completed,
        assistance: help,
        insertions: inserted,
      );
      for (final invalid in [
        record(completed: false),
        record(help: {Assistance.decoder}),
        record(inserted: 1),
      ]) {
        expect(GuidedSending.nextStage([invalid]), GuidedSendStage.k);
      }
    },
  );

  test('guide follows recorded order when device time moves backwards', () {
    SessionSummary passed(GuidedSendStage stage, DateTime at) => SessionSummary(
      at: at,
      totalChars: stage.target.length,
      correctChars: stage.target.length,
      source: ExerciseSource.send,
      drillKind: stage.drillKind,
      assistance: const {},
      insertions: 0,
    );
    expect(
      GuidedSending.nextStage([
        passed(GuidedSendStage.k, DateTime(2026, 10, 8)),
        passed(GuidedSendStage.m, DateTime(2026, 10, 7)),
      ]),
      GuidedSendStage.pair,
    );
  });

  testWidgets(
    'touch and keyboard advance K, M and groups; failure repeats target',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final t = await TestTraining.create(
        settings: const TrainingSettings(keyerMode: KeyerMode.straight),
      );
      addTearDown(t.controller.dispose);
      final playback = FakeLearnPlaybackFactory();
      await tester.pumpWidget(
        l10nApp(
          home: SendPracticeScreen(
            controller: t.controller,
            playback: playback,
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> hear() async {
        final hear = find.byKey(const ValueKey('send-guide-hear'));
        await tester.ensureVisible(hear);
        await tester.tap(hear);
        await tester.pump();
        expect(find.byType(StraightKeyButton), findsNothing);
        playback.clock.advance(const Duration(seconds: 10));
        await tester.pumpAndSettle();
        expect(find.byType(StraightKeyButton), findsOneWidget);
      }

      Future<void> finishAndContinue(
        String text, {
        bool keyboard = false,
        bool passed = true,
      }) async {
        await hear();
        expect(
          t.controller.progress.history.length,
          lessThan(6),
          reason: 'hearing is not a recorded attempt',
        );
        final key = find.byType(StraightKeyButton);
        await tester.ensureVisible(key);
        await tester.pumpAndSettle();
        for (final element in MorseEncoder.encode(
          text,
          const MorseTiming(wpm: 20),
        )) {
          if (element.on) {
            if (keyboard) {
              await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
              playback.clock.advance(element.duration);
              await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
            } else {
              final touch = await tester.startGesture(tester.getCenter(key));
              playback.clock.advance(element.duration);
              await touch.up();
            }
          } else {
            playback.clock.advance(element.duration);
          }
          await tester.pump();
        }
        playback.clock.advance(const Duration(milliseconds: 300));
        await tester.pump();
        final done = find.widgetWithText(FilledButton, en.learnDone);
        await tester.ensureVisible(done);
        await tester.tap(done);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('send-guide-result')), findsOneWidget);
        if (!passed) {
          expect(
            find.byKey(const ValueKey('send-guide-rhythm-tip')),
            findsOneWidget,
          );
        }
        final next = find.widgetWithText(
          FilledButton,
          passed ? en.learnTryAnother : en.sendGuideRetry,
        );
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }

      await finishAndContinue('E', passed: false);
      expect(find.text('K'), findsOneWidget);
      await finishAndContinue('K');
      expect(find.text('M'), findsOneWidget);
      await finishAndContinue('M', keyboard: true);
      expect(find.text('KM'), findsOneWidget);
      await finishAndContinue('KM');
      expect(find.text('KMKMK'), findsOneWidget);
      await finishAndContinue('KMKMK', keyboard: true);
      expect(find.byKey(const ValueKey('send-guide-hear')), findsNothing);
      expect(GuidedSending.nextStage(t.controller.progress.history), isNull);
      expect(t.controller.progress.history.length, 5);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'interrupted model must be heard fully before the key is enabled',
    (tester) async {
      final t = await TestTraining.create(
        settings: const TrainingSettings(keyerMode: KeyerMode.straight),
      );
      addTearDown(t.controller.dispose);
      final playback = FakeLearnPlaybackFactory();
      await tester.pumpWidget(
        l10nApp(
          home: SendPracticeScreen(
            controller: t.controller,
            playback: playback,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('send-guide-hear')));
      await tester.pump();
      playback.clock.advance(const Duration(milliseconds: 60));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(
        playback.sink.isOn,
        isFalse,
        reason: 'background must stop the model sound',
      );
      playback.clock.advance(const Duration(seconds: 10));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(
        find.byType(StraightKeyButton),
        findsNothing,
        reason: 'interrupted demonstration did not finish',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('next guide target retains frozen timing and plan linkage', (
    tester,
  ) async {
    final t = await TestTraining.create(
      settings: const TrainingSettings(keyerMode: KeyerMode.straight),
    );
    addTearDown(t.controller.dispose);
    final playback = FakeLearnPlaybackFactory();
    const frozen = MorseTiming(wpm: 18, farnsworthWpm: 5);
    final session = SendSession(
      target: 'K',
      timing: frozen,
      now: t.controller.now,
      drillKind: GuidedSendStage.k.drillKind,
      planStepId: 'frozen-plan-send',
    );
    await tester.pumpWidget(
      l10nApp(
        home: SendPracticeScreen(
          controller: t.controller,
          playback: playback,
          session: session,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('send-guide-hear')));
    playback.clock.advance(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    _keyText(session, 'K');
    await tester.pump();
    final done = find.widgetWithText(FilledButton, en.learnDone);
    await tester.ensureVisible(done);
    await tester.tap(done);
    await tester.pumpAndSettle();
    final next = find.widgetWithText(FilledButton, en.learnTryAnother);
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    final continued = tester
        .widget<SendLiveView>(find.byType(SendLiveView))
        .session;
    expect(continued.target, 'M');
    expect(continued.nominalTiming.wpm, 18);
    expect(continued.nominalTiming.farnsworthWpm, 5);
    expect(continued.planStepId, 'frozen-plan-send');
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('completed guide continues through the supplied plan factory', (
    tester,
  ) async {
    final t = await TestTraining.create(
      settings: const TrainingSettings(keyerMode: KeyerMode.straight),
    );
    addTearDown(t.controller.dispose);
    final playback = FakeLearnPlaybackFactory();
    var called = 0;
    final session = t.controller.startGuidedSendSession(
      stage: GuidedSendStage.group,
      timing: const MorseTiming(wpm: 18, farnsworthWpm: 5),
      planStepId: 'send-five-targets',
    );
    await tester.pumpWidget(
      l10nApp(
        home: SendPracticeScreen(
          controller: t.controller,
          playback: playback,
          session: session,
          nextSession: () async {
            called++;
            return SendSession(
              target: 'MMKMM',
              timing: session.nominalTiming,
              now: t.controller.now,
              planStepId: session.planStepId,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('send-guide-hear')));
    playback.clock.advance(const Duration(seconds: 20));
    await tester.pumpAndSettle();
    _keyText(session, 'KMKMK');
    await tester.pump();
    final done = find.widgetWithText(FilledButton, en.learnDone);
    await tester.ensureVisible(done);
    await tester.tap(done);
    await tester.pumpAndSettle();
    final next = find.widgetWithText(FilledButton, en.learnTryAnother);
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(called, 1);
    final continued = tester
        .widget<SendLiveView>(find.byType(SendLiveView))
        .session;
    expect(continued.target, 'MMKMM');
    expect(continued.planStepId, 'send-five-targets');
    expect(continued.nominalTiming.wpm, 18);
    expect(continued.nominalTiming.farnsworthWpm, 5);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

void _keyText(SendSession session, String text) {
  var at = Duration.zero;
  for (final element in MorseEncoder.encode(text, session.nominalTiming)) {
    if (element.on) {
      session.keyDown(at);
      session.keyUp(at + element.duration);
    }
    at += element.duration;
    session.tick(at);
  }
}
