// Regressions found by walking the first day in the running app (iPhone
// 16e simulator): a never-practised symbol labelled "due for review", a
// lesson pass with Done as the only way on, and the guided send key
// appearing below the fold after the model.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/lesson_card_extras.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_next_steps.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

void main() {
  group('first day: review state', () {
    test('symbols never practised are not due for review', () async {
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      final c = t.controller;
      expect(c.reviewDueChars, isEmpty);
      for (final char in c.learnedChars) {
        expect(
          chipStateOf(c, char, isNewest: char == c.newestChar),
          isNot(CharChipState.due),
          reason: '$char has no review record yet',
        );
      }
      // The review drill still has symbols to practise.
      expect(c.dueChars, containsAll(<String>['K', 'M']));
    });

    test('a practised symbol becomes due once its interval passes', () async {
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      final c = t.controller;
      final session = c.startLessonSession();
      while (!session.isComplete) {
        session.submit(session.currentDrill.text);
      }
      await c.recordReceiveSession(session);
      expect(c.currentLesson, 2);
      expect(c.reviewDueChars, isEmpty, reason: 'R is new, K/M just passed');
      t.clock.advance(const Duration(days: 60));
      expect(c.reviewDueChars, containsAll(<String>['K', 'M']));
      expect(c.reviewDueChars, isNot(contains('R')));
      expect(chipStateOf(c, 'K', isNewest: false), CharChipState.due);
    });

    testWidgets('fresh home says nothing is due', (tester) async {
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      tester.view.physicalSize = const Size(400, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        l10nApp(
          home: LearnHome(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.learnReviewDueCount(0)), findsOneWidget);
      expect(find.text(en.learnChipDue), findsNothing);
    });
  });

  testWidgets('a lesson pass leads to the new symbol, not only Done', (
    tester,
  ) async {
    final t = await TestTraining.create();
    addTearDown(t.controller.dispose);
    final c = t.controller;
    final session = c.startLessonSession();
    while (!session.isComplete) {
      session.submit(session.currentDrill.text);
    }
    final outcome = await c.recordReceiveSession(session);
    expect(verdictOf(outcome, session), ReceiveVerdict.unlocked);
    final factory = FakeLearnPlaybackFactory();
    final playback = await factory.create(c.settings);
    await tester.pumpWidget(
      l10nApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReceiveNextSteps(
              controller: c,
              playbackFactory: factory,
              playback: playback,
              session: session,
              outcome: outcome,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(en.learnPractiseNewChar('R')), findsOneWidget);
    // Done stays available but is no longer the primary action.
    expect(
      find.ancestor(
        of: find.text(en.learnDone),
        matching: find.byType(OutlinedButton),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('hear-new-char')));
    factory.clock.advance(const Duration(seconds: 2));
    await tester.pump();
    expect(
      factory.sink.events.where((e) => e.on).length,
      3,
      reason: 'R is .-.',
    );

    await tester.tap(find.byKey(const ValueKey('practise-new-char')));
    await tester.pumpAndSettle();
    final next = tester
        .widget<ReceiveDrillScreen>(find.byType(ReceiveDrillScreen))
        .session;
    expect(next.sourceRef, 'guided/2/single');
    expect(next.currentDrill.text.length, 1);
    expect(next.countsTowardLesson, isFalse);
    expect(c.currentLesson, 2);
  });

  testWidgets('after the guided model the key is scrolled into view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
    await tester.tap(find.byKey(const ValueKey('send-guide-hear')));
    playback.clock.advance(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    final key = find.byType(StraightKeyButton);
    expect(key, findsOneWidget);
    final screen = tester.getRect(find.byType(Scaffold));
    final keyRect = tester.getRect(key);
    expect(keyRect.top, greaterThanOrEqualTo(screen.top));
    expect(keyRect.bottom, lessThanOrEqualTo(screen.bottom));
    expect(
      tester.getRect(find.text(en.learnDone)).bottom,
      lessThanOrEqualTo(screen.bottom),
    );
    expect(key.hitTestable(), findsOneWidget);
  });
}
