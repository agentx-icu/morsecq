import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/goals/goal_route_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

void main() {
  testWidgets(
    'switching the goal saves selection and renders appropriate route',
    (tester) async {
      final training = await TestTraining.create();
      await tester.pumpWidget(
        l10nApp(
          home: GoalRouteScreen(
            controller: training.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.goalsBeginner), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('goal-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.goalsContest).last);
      await tester.pumpAndSettle();
      expect(training.controller.progress.learningGoal, LearningGoal.contest);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('goal-milestone-15-contest')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(en.goalsCompetition), findsWidgets);
      expect(tester.takeException(), isNull);
      training.controller.dispose();
    },
  );

  testWidgets('route stays usable on a narrow phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final training = await TestTraining.create();
    await tester.pumpWidget(
      l10nApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: GoalRouteScreen(
            controller: training.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('goal-next-practice')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('goal-next-practice')), findsOneWidget);
    expect(tester.takeException(), isNull);
    training.controller.dispose();
  });
}
