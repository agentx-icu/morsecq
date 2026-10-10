// Follow-ups to the first-day walkthrough: interrupted rounds, the worked
// answer's buttons, the character-gap demonstration, distinguishable chip
// states and receive-specific summary wording.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/learn/lesson_card_extras.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_summary_view.dart';
import 'package:morsecq/ui/theme.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

Future<(TestTraining, ReceiveSession, FakeLearnPlaybackFactory)> _pumpChallenge(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final t = await TestTraining.create();
  addTearDown(t.controller.dispose);
  final playback = FakeLearnPlaybackFactory();
  final session = t.controller.startLessonSession();
  await tester.pumpWidget(
    l10nApp(
      home: ReceiveDrillScreen(
        controller: t.controller,
        playback: playback,
        session: session,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (t, session, playback);
}

Future<void> _playToEnd(
  WidgetTester tester,
  ReceiveSession session,
  FakeLearnPlaybackFactory playback,
) async {
  final total = MorseEncoder.totalDuration(session.currentTimeline);
  playback.clock.advance(total + const Duration(milliseconds: 1));
  await tester.pump();
}

Future<void> _background(WidgetTester tester) async {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await tester.pump();
  for (final state in [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await tester.pump();
}

/// Answers the rest perfectly and records it, as the screen would.
Future<ReceiveOutcome> _finishPerfectly(
  TrainingController c,
  ReceiveSession session,
) {
  while (!session.isComplete) {
    session.submit(session.currentDrill.text);
  }
  return c.recordReceiveSession(session);
}

double _distance(Color a, Color b) => math.sqrt(
  math.pow(a.r - b.r, 2) + math.pow(a.g - b.g, 2) + math.pow(a.b - b.b, 2),
);

void main() {
  group('round interrupted by the background', () {
    testWidgets(
      'heard round, background, replay: not assisted, challenge still passes',
      (tester) async {
        final (t, session, playback) = await _pumpChallenge(tester);
        await _playToEnd(tester, session, playback);
        expect(find.byKey(const ValueKey('round-interrupted')), findsNothing);
        await _background(tester);
        expect(find.text(en.learnRoundInterrupted), findsOneWidget);
        await tester.tap(find.text(en.learnReplay));
        await tester.pump();
        expect(session.isAssisted, isFalse);
        expect(find.text(en.learnRoundInterrupted), findsNothing);
        await _playToEnd(tester, session, playback);
        final outcome = await _finishPerfectly(t.controller, session);
        expect(outcome.advanced, isTrue);
        expect(t.controller.currentLesson, 2);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets(
      'an uninterrupted replay still counts as assistance',
      (tester) async {
        final (t, session, playback) = await _pumpChallenge(tester);
        await _playToEnd(tester, session, playback);
        await tester.tap(find.text(en.learnReplay));
        await tester.pump();
        expect(session.isAssisted, isTrue);
        final outcome = await _finishPerfectly(t.controller, session);
        expect(outcome.advanced, isFalse);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets(
      'after the restoring replay is heard, another replay is assistance',
      (tester) async {
        final (_, session, playback) = await _pumpChallenge(tester);
        await _playToEnd(tester, session, playback);
        await _background(tester);
        await tester.tap(find.text(en.learnReplay));
        await tester.pump();
        await _playToEnd(tester, session, playback);
        expect(session.isAssisted, isFalse);
        await tester.tap(find.text(en.learnReplay));
        await tester.pump();
        expect(session.isAssisted, isTrue);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  });

  group('first lesson', () {
    Future<(TestTraining, FakeLearnPlaybackFactory)> pumpIntro(
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      final playback = FakeLearnPlaybackFactory();
      await tester.pumpWidget(
        l10nApp(
          home: FirstLessonScreen(controller: t.controller, playback: playback),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('first-lesson-heard')));
      await tester.pumpAndSettle();
      return (t, playback);
    }

    testWidgets('short and long step plays the pause between characters', (
      tester,
    ) async {
      final (t, playback) = await pumpIntro(tester);
      expect(find.text(en.firstLessonPauseDemo('K', 'M')), findsOneWidget);
      await tester.tap(find.text(en.firstLessonPauseDemo('K', 'M')));
      await tester.pump();
      playback.clock.advance(const Duration(seconds: 10));
      await tester.pump();
      final events = playback.sink.events;
      expect(events.where((e) => e.on).length, 5, reason: '-.- then --');
      // events[5] ends K's last dah; events[6] starts M.
      final gap = events[6].at - events[5].at;
      expect(gap, t.controller.trainerSettings.toTiming().charGap);
    });

    testWidgets('worked answer buttons are numbered, not identical', (
      tester,
    ) async {
      await pumpIntro(tester);
      await tester.tap(
        find.byKey(const ValueKey('first-lesson-continue-worked')),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.firstLessonWorkedPlay(1)), findsOneWidget);
      expect(find.text(en.firstLessonWorkedPlay(2)), findsOneWidget);
      expect(find.text(en.firstLessonPlay), findsNothing);
      expect(find.bySemanticsLabel(en.firstLessonWorkedPlay(2)), findsWidgets);
      // The label never gives the answer away.
      expect(find.text('K'), findsNothing);
    });
  });

  testWidgets('new and mastered chips differ in every style and theme', (
    tester,
  ) async {
    for (final style in UiStyle.values) {
      for (final theme in [
        MorsecqTheme.light(style: style),
        MorsecqTheme.dark(style: style),
      ]) {
        late BuildContext ctx;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        );
        final label = '${style.name}/${theme.brightness.name}';
        final mastered = chipColors(ctx, CharChipState.mastered).$1;
        for (final other in CharChipState.values) {
          if (other == CharChipState.mastered) continue;
          expect(
            _distance(mastered, chipColors(ctx, other).$1),
            greaterThan(0.15),
            reason: '$label: mastered vs ${other.name}',
          );
        }
        expect(
          _distance(chipColors(ctx, CharChipState.introduced).$1, mastered),
          greaterThan(0.3),
          reason: '$label: new vs mastered',
        );
      }
    }
  });

  testWidgets('a listening summary counts characters heard, not sent', (
    tester,
  ) async {
    final t = await TestTraining.create();
    addTearDown(t.controller.dispose);
    final session = t.controller.startLessonSession();
    final outcome = await _finishPerfectly(t.controller, session);
    await tester.pumpWidget(
      l10nApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReceiveSummaryView(
              session: session,
              outcome: outcome,
              course: t.controller.course,
              unlockedChar: 'R',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(en.learnCharsHeard(50)), findsOneWidget);
    expect(en.learnCharsHeard(50), '50 characters heard');
  });
}
