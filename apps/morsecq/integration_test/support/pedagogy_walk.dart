// Real native Learn controls. Targets are read only by this automation to
// check navigation and scoring; this does not measure human Morse ability.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_trial_view.dart';
import 'package:morsecq/ui/learn/receive/answer_keypad.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_summary_view.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/send/send_live_view.dart';
import 'package:morse_io/morse_io.dart';

import 'scene_walk.dart';
import 'shot_harness.dart';

Future<void> tapKey(WidgetTester tester, String key) =>
    tapHittable(tester, find.byKey(ValueKey(key)), key);

Future<void> completeFirstLesson(WidgetTester tester) async {
  await tapKey(tester, 'first-lesson-play');
  await settle(tester, extra: const Duration(milliseconds: 700));
  await tapKey(tester, 'first-lesson-heard');
  await tapKey(tester, 'first-lesson-continue-worked');
  await tapKey(tester, 'worked-K');
  await settle(tester, extra: const Duration(milliseconds: 700));
  await tapKey(tester, 'first-lesson-continue-trials');
  for (var i = 0; i < 6; i++) {
    await settle(tester, extra: const Duration(milliseconds: 700));
    final view = tester.widget<FirstLessonTrialView>(
      find.byType(FirstLessonTrialView),
    );
    await tapKey(tester, 'trial-${view.session.currentDrill.text}');
    await tapKey(tester, 'trial-next');
  }
  expect(find.byKey(const ValueKey('next-guided')), findsOneWidget);
}

Future<void> completeReceive(WidgetTester tester, {bool perfect = true}) async {
  final screen = tester.widget<ReceiveDrillScreen>(
    find.byType(ReceiveDrillScreen),
  );
  final session = screen.session;
  while (!session.isFinished) {
    final elements = MorseEncoder.encode(
      session.currentDrill.text,
      session.timing,
    );
    final duration = elements.fold(Duration.zero, (sum, e) => sum + e.duration);
    await Future<void>.delayed(duration + const Duration(milliseconds: 100));
    await tester.pump();
    final s = S.of(tester.element(find.byType(ReceiveDrillScreen)));
    final target = session.currentDrill.text;
    final answer = !perfect && session.roundCount == 0 ? 'K' : target;
    if (find.byType(TextField).evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField), answer);
    } else {
      for (final symbol in MorseText.tokenize(answer)) {
        await _tapNow(
          tester,
          find.descendant(
            of: find.byType(AnswerKeypad),
            matching: find.text(symbol == ' ' ? s.learnSpace : symbol),
          ),
          'receive keypad $symbol',
        );
      }
    }
    await _tapNow(tester, find.text(s.learnSubmit), s.learnSubmit);
    await _tapNow(
      tester,
      find.text(session.isComplete ? s.learnFinish : s.learnNext),
      s.learnNext,
    );
  }
  await waitForNative(
    tester,
    find.byType(ReceiveSummaryView),
    'saved receive summary',
  );
}

/// Demonstrates the real player and a touch-keyed K via the real decoder.
Future<void> keyGuidedK(WidgetTester tester) async {
  await tapKey(tester, 'send-guide-hear');
  await settle(tester, extra: const Duration(seconds: 1));
  final key = find.byType(StraightKeyButton);
  expect(key, findsOneWidget);
  await tester.ensureVisible(key);
  await tester.pump();
  const dit = Duration(milliseconds: 60);
  for (final mark in [dit * 3, dit, dit * 3]) {
    final gesture = await tester.startGesture(tester.getCenter(key));
    await Future<void>.delayed(mark);
    await gesture.up();
    await Future<void>.delayed(dit);
  }
  await settle(tester, extra: const Duration(milliseconds: 300));
  final live = tester.widget<SendLiveView>(find.byType(SendLiveView));
  expect(live.session.decodedText.trim(), 'K');
  final s = S.of(tester.element(find.byType(SendPracticeScreen)));
  await tapText(tester, s.learnDone);
  await waitForNative(
    tester,
    find.byKey(const ValueKey('send-guide-result')),
    'saved send guide result',
  );
}

/// Extra gallery routes are pushed from the real seeded home; no live data.
Future<void> capturePedagogy(
  WidgetTester tester,
  ShotHarness shots,
  String locale,
) async {
  final home = tester.widget<LearnHome>(find.byType(LearnHome));
  final nav = Navigator.of(tester.element(find.byType(LearnHome)));
  unawaited(
    nav.push(
      MaterialPageRoute<Object?>(
        builder: (_) => FirstLessonScreen(
          controller: home.controller,
          playback: home.playback,
        ),
      ),
    ),
  );
  await settle(tester);
  expect(find.byType(FirstLessonScreen), findsOneWidget);
  await shots.capture(tester, locale, 'first_lesson');
  await popIfCan(tester);
  unawaited(
    nav.push(
      MaterialPageRoute<Object?>(
        builder: (_) => ReceiveDrillScreen(
          controller: home.controller,
          playback: home.playback,
          session: home.controller.startGuidedSession(),
        ),
      ),
    ),
  );
  await settle(tester);
  await completeReceive(tester);
  await shots.capture(tester, locale, 'receive_summary');
  await popIfCan(tester);
  unawaited(
    nav.push(
      MaterialPageRoute<Object?>(
        builder: (_) => SendPracticeScreen(
          controller: home.controller,
          playback: home.playback,
          session: home.controller.startGuidedSendSession(restart: true),
        ),
      ),
    ),
  );
  await settle(tester);
  expect(find.byKey(const ValueKey('send-guide-hear')), findsOneWidget);
  await tapKey(tester, 'send-guide-hear');
  await settle(tester, extra: const Duration(seconds: 1));
  expect(
    find.byType(PaddleButtons).evaluate().isNotEmpty ||
        find.byType(StraightKeyButton).evaluate().isNotEmpty,
    isTrue,
    reason: 'completed model exposes a real keying control',
  );
  await shots.capture(tester, locale, 'guided_send');
  await popIfCan(tester);
}

Future<void> _tapNow(WidgetTester tester, Finder finder, String label) async {
  expect(finder, findsOneWidget, reason: label);
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 100));
  expect(finder.hitTestable(), findsOneWidget, reason: label);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 100));
}

/// Native file and audio work can complete after the last animation. Wait
/// for the observable result, with a deadline; keep all exceptions visible.
Future<void> waitForNative(
  WidgetTester tester,
  Finder finder,
  String label,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await tester.pump();
  }
  expect(finder, findsOneWidget, reason: label);
}
