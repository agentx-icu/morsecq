import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/placement/placement_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

void main() {
  testWidgets('placement waits for complete playback before accepting a copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final t = await TestTraining.create();
    final playback = FakeLearnPlaybackFactory();
    await tester.pumpWidget(
      l10nApp(
        home: PlacementScreen(
          controller: t.controller,
          playback: playback,
          seed: 5,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('placement-start')));
    await tester.pump();
    final submit = find.byKey(const ValueKey('placement-submit'));
    final answer = find.byType(TextField);
    await tester.enterText(answer, 'KM');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    expect(tester.widget<TextField>(answer).controller!.text, 'KM');

    playback.clock.advance(const Duration(minutes: 1));
    await tester.pump();
    expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
  });

  testWidgets('placement only verifies copies without partial replays', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final t = await TestTraining.create();
    final c = t.controller;
    final playback = FakeLearnPlaybackFactory();
    final expected = PlacementAssessment(course: c.course, seed: 5);
    final rounds = expected.tiers.first.rounds;
    expected.recordTier(rounds, assisted: {0});
    await tester.pumpWidget(
      l10nApp(
        home: PlacementScreen(controller: c, playback: playback, seed: 5),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('placement-start')));
    await tester.pump();
    expect(playback.sink.isOn, isTrue);
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
    await tester.tap(find.text(en.learnReplay));
    for (final round in rounds) {
      playback.clock.advance(const Duration(minutes: 1));
      await tester.pump();
      await tester.enterText(find.byType(TextField), round);
      await tester.tap(find.byKey(const ValueKey('placement-submit')));
      await tester.pump();
    }
    await tester.tap(find.text(en.placementStop));
    await tester.pumpAndSettle();
    expect(
      find.text(
        en.placementVerified(
          expected.result().verifiedPrefix,
          c.course.order.length,
        ),
      ),
      findsOneWidget,
    );
    expect(c.progress.history.single.assistance, contains(Assistance.replay));
  });

  testWidgets('placement suggests a lesson and changes nothing until adopted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final t = await TestTraining.create();
    final c = t.controller;
    final playback = FakeLearnPlaybackFactory();
    // Same seed as the screen: the test knows what will be played.
    final expected = PlacementAssessment(course: c.course, seed: 5);
    await tester.pumpWidget(
      l10nApp(
        home: PlacementScreen(controller: c, playback: playback, seed: 5),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('placement-start')));
    await tester.pump();
    for (final round in expected.tiers.first.rounds) {
      playback.clock.advance(const Duration(minutes: 1));
      await tester.pump();
      await tester.enterText(find.byType(TextField), round);
      await tester.tap(find.byKey(const ValueKey('placement-submit')));
      await tester.pump();
    }
    expect(find.text(en.placementTierPassed), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('placement-next-tier')));
    await tester.pump();
    for (var i = 0; i < expected.tiers[1].rounds.length; i++) {
      playback.clock.advance(const Duration(minutes: 1));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('placement-submit')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    final lesson = c.course.lessonFor(c.course.order[10])!;
    expect(find.text(en.placementSuggestion(lesson)), findsOneWidget);
    final adopt = find.byKey(const ValueKey('placement-adopt'));
    final keep = find.byKey(const ValueKey('placement-keep-current'));
    expect(keep, findsOneWidget);
    expect(
      tester.getTopLeft(keep).dy,
      greaterThan(tester.getBottomLeft(adopt).dy),
    );
    expect(c.currentLesson, 1, reason: 'nothing applied yet');
    // Placement is activity only: no SRS, no stats.
    expect(c.progress.history.single.source, ExerciseSource.placement);
    expect(c.progress.charStats, isEmpty);
    await tester.tap(find.byKey(const ValueKey('placement-adopt')));
    await tester.pumpAndSettle();
    expect(c.currentLesson, lesson);
  });

  testWidgets('blank placement answers earn no activity credit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final t = await TestTraining.create();
    final playback = FakeLearnPlaybackFactory();
    await tester.pumpWidget(
      l10nApp(
        home: PlacementScreen(
          controller: t.controller,
          playback: playback,
          seed: 5,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('placement-start')));
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      playback.clock.advance(const Duration(minutes: 1));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('placement-submit')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text(en.placementSuggestion(1)), findsOneWidget);
    expect(t.controller.progress.lifetimeSessions, 0);
  });
}
