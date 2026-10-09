import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/learn/comprehension/listening_comprehension_screen.dart';
import 'package:morsecq/ui/learn/goals/goal_route_screen.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/mistakes/mistake_notebook_screen.dart';
import 'package:morsecq/ui/theme.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

void main() {
  for (final style in UiStyle.values) {
    for (final size in [const Size(320, 640), const Size(1280, 800)]) {
      testWidgets('advanced practice is reachable in ${style.name} at $size', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final training = await TestTraining.create();
        addTearDown(training.controller.dispose);
        await tester.pumpWidget(
          l10nApp(
            theme: MorsecqTheme.light(style: style),
            home: LearnHome(
              controller: training.controller,
              playback: FakeLearnPlaybackFactory(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final destination in <String, Type>{
          'learn-goal-route': GoalRouteScreen,
          'learn-comprehension': ListeningComprehensionScreen,
          'learn-mistakes': MistakeNotebookScreen,
        }.entries) {
          final entry = find.byKey(ValueKey(destination.key));
          await tester.ensureVisible(entry);
          await tester.tap(entry);
          await tester.pumpAndSettle();
          expect(find.byType(destination.value), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
        expect(training.controller.progress.lifetimeSessions, 0);
      });
    }
  }
}
