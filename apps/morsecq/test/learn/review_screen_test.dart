import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/review/review_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

Future<TestTraining> _openReview(
  WidgetTester tester, {
  TrainerProgress? progress,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final training = await TestTraining.create(
    settings: kShortSettings,
    progress: progress,
  );
  addTearDown(training.controller.dispose);
  await tester.pumpWidget(
    l10nApp(
      home: ReviewScreen(
        controller: training.controller,
        playback: FakeLearnPlaybackFactory(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return training;
}

void main() {
  testWidgets('empty review offers free practice without starting a review', (
    tester,
  ) async {
    await _openReview(tester);
    expect(find.text(en.learnReviewDueCount(0)), findsOneWidget);
    expect(find.byType(ReceiveDrillScreen), findsNothing);

    await tester.tap(find.byKey(const ValueKey('review-practice')));
    await tester.pumpAndSettle();
    final drill = tester.widget<ReceiveDrillScreen>(
      find.byType(ReceiveDrillScreen),
    );
    expect(drill.session.kind, ReceiveDrillKind.characters);
    expect(drill.session.countsTowardLesson, isFalse);
  });

  testWidgets(
    'due review previews the real pool and starts after confirmation',
    (tester) async {
      final at = kTestNow.subtract(const Duration(days: 3));
      final score = SessionScore.evaluate('KK MM', 'KK MM', at: at, lesson: 1);
      final progress = TrainerProgress().recordSession(
        score,
        now: at,
        lesson: 1,
      );
      final training = await _openReview(tester, progress: progress);
      final due = training.controller.reviewDueChars;
      expect(due, containsAll(['K', 'M']));
      expect(find.byType(ReceiveDrillScreen), findsNothing);
      expect(find.text(en.learnReviewDueCount(due.length)), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('review-practice')));
      await tester.pumpAndSettle();
      final drill = tester.widget<ReceiveDrillScreen>(
        find.byType(ReceiveDrillScreen),
      );
      expect(find.text(en.learnReviewTitle), findsOneWidget);
      expect(drill.session.kind, ReceiveDrillKind.review);
      expect(drill.session.countsTowardLesson, isFalse);
      expect(drill.session.chars.toSet(), due.toSet());
    },
  );
}
