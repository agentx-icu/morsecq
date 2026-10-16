// Labels that a clamped box used to clip at large text sizes, found by the
// layout harness's clip check. These fast cases run without the sweep's real
// fonts; the listening-mode and theme-mode cases only reproduce with real
// glyph metrics, so the font-gated sweep covers them.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/goals/goal_route_screen.dart';
import 'package:morsecq/ui/reference/reference_screen.dart';
import 'package:morsecq/ui/reference/translator_screen.dart';

import '../learn/helpers/fake_playback.dart';
import '../learn/helpers/l10n.dart';
import '../learn/helpers/test_controller.dart';
import '../reference/reference_test_support.dart';
import 'layout_harness.dart';

/// Clip findings for [home] on a [screen] phone at [scale]. The test font is
/// far wider than real text, so busy screens use a milder size than 3.1.
Future<Set<String>> _cut(
  WidgetTester tester,
  Widget home, {
  Locale locale = const Locale('en'),
  Size screen = const Size(320, 568),
  double scale = 3.1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = screen;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(l10nApp(home: home, locale: locale));
  await tester.pumpAndSettle();
  final found = <String>{};
  scanTruncated(screen, found);
  expect(tester.takeException(), isNull);
  return found;
}

void main() {
  testWidgets('translator modes wrap instead of clipping', (tester) async {
    final fake = FakeReferencePlayer();
    final found = await _cut(
      tester,
      TranslatorScreen(playerFactory: fake.create, clock: fake.clock),
      locale: const Locale('ru'),
      screen: const Size(390, 844),
      scale: 2,
    );
    expect(found, isEmpty);
  });

  testWidgets('the selected learning goal wraps', (tester) async {
    final training = await TestTraining.create(
      progress: TrainerProgress(learningGoal: LearningGoal.conversation),
    );
    addTearDown(training.controller.dispose);
    final found = await _cut(
      tester,
      GoalRouteScreen(
        controller: training.controller,
        playback: FakeLearnPlaybackFactory(),
      ),
    );
    expect(found, isEmpty);
  });

  testWidgets('reference tabs grow with their labels', (tester) async {
    final fake = FakeReferencePlayer();
    final found = await _cut(
      tester,
      ReferenceScreen(playerFactory: fake.create),
      screen: const Size(390, 844),
    );
    // The test font's wide glyphs also cut the search hint; real fonts fit.
    expect(found.where((problem) => problem.startsWith('clipped')), isEmpty);
  });
}
