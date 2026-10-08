// Back-port of DitMesh mobile review T2 (2026-10-08): Android gesture
// navigation reserves a back-gesture zone on both screen edges
// (`systemGestureInsets.left/right`, ~30 dp). A paddle press that starts
// there and drifts inward becomes a system back instead of a dah, so the
// send-practice paddles must stay clear of those zones while keeping their
// touch target.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq/training/send_session.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

const FakeViewPadding kGestureNavInsets = FakeViewPadding(
  left: 30,
  right: 30,
  bottom: 30,
);

/// The two paddle surfaces (raw listeners inside [PaddleButtons]).
Finder get _paddles => find.descendant(
  of: find.byType(PaddleButtons),
  matching: find.byType(Listener),
);

void main() {
  for (final Size size in <Size>[
    const Size(390, 844),
    const Size(320, 568),
    const Size(667, 375),
  ]) {
    testWidgets('send-practice paddles avoid the back-gesture zones at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = size.width > size.height
          ? const FakeViewPadding(left: 47, right: 47, bottom: 21)
          : const FakeViewPadding(top: 47, bottom: 34);
      tester.view.systemGestureInsets = kGestureNavInsets;
      addTearDown(tester.view.reset);
      final t = await TestTraining.create(
        settings: const TrainingSettings(keyerMode: KeyerMode.iambicB),
      );
      addTearDown(t.controller.dispose);
      final session = SendSession(
        target: 'KM',
        timing: const MorseTiming(wpm: 20),
        now: () => t.clock.now,
        lesson: 1,
      );
      await tester.pumpWidget(
        l10nApp(
          home: SendPracticeScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
            session: session,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(PaddleButtons));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_paddles, findsNWidgets(2));
      final Rect left = tester.getRect(_paddles.first);
      final Rect right = tester.getRect(_paddles.last);
      expect(left.left, greaterThanOrEqualTo(kGestureNavInsets.left));
      expect(
        right.right,
        lessThanOrEqualTo(size.width - kGestureNavInsets.right),
      );
      for (final Rect pad in <Rect>[left, right]) {
        expect(pad.height, greaterThanOrEqualTo(PaddleButtons.minTouchTarget));
        expect(pad.width, greaterThanOrEqualTo(PaddleButtons.minTouchTarget));
      }
    });
  }
}
