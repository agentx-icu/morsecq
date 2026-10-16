import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/send_session.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/materials/materials_screen.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_setup_screen.dart';
import 'package:morsecq/ui/learn/receive/drill_picker_sheet.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/review/review_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_practice_screen.dart';
import 'package:morsecq/ui/stats/stats_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

Future<TrainingController> _pumpHome(
  WidgetTester tester, {
  int lesson = 10,
  TrainerProgress? progress,
}) async {
  tester.view.physicalSize = const Size(430, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final t = await TestTraining.create(
    progress: progress ?? TrainerProgress(currentLesson: lesson),
  );
  addTearDown(t.controller.dispose);
  await tester.pumpWidget(
    l10nApp(
      home: LearnHome(
        controller: t.controller,
        playback: FakeLearnPlaybackFactory(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return t.controller;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
  expect(find.byType(LearnHome), findsOneWidget);
}

Future<void> _openMore(WidgetTester tester) async {
  final more = find.byKey(const ValueKey('more-practice'));
  await _tap(tester, more);
}

void main() {
  testWidgets('receive practice runs the drill picked in the sheet', (
    tester,
  ) async {
    final c = await _pumpHome(tester);
    await _tap(tester, find.text(en.learnReceivePractice));
    final kind = c.availableReceiveKinds.first;
    await _tap(tester, find.byKey(DrillPickerList.tileKey(kind)));
    final drill = tester.widget<ReceiveDrillScreen>(
      find.byType(ReceiveDrillScreen),
    );
    expect(drill.session.kind, kind);
    expect(
      drill.session.countsTowardLesson,
      isFalse,
      reason: 'free practice never unlocks a lesson',
    );
  });

  testWidgets('dismissing the drill sheet opens nothing', (tester) async {
    await _pumpHome(tester);
    await _tap(tester, find.text(en.learnReceivePractice));
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(ReceiveDrillScreen), findsNothing);
    expect(find.byType(LearnHome), findsOneWidget);
  });

  testWidgets('each quick action opens its own screen', (tester) async {
    await _pumpHome(tester);
    await _tap(tester, find.text(en.learnSendPractice));
    expect(find.byType(SendPracticeScreen), findsOneWidget);
    await _back(tester);

    await _tap(tester, find.text(en.learnReviewDue));
    expect(find.byType(ReviewScreen), findsOneWidget);
    await _back(tester);

    await _tap(tester, find.text(en.learnQsoAction));
    expect(find.byType(QsoSetupScreen), findsOneWidget);
    await _back(tester);

    await _openMore(tester);
    await _tap(tester, find.text(en.materialsTitle));
    expect(find.byType(MaterialsScreen), findsOneWidget);
    await _back(tester);

    await _tap(tester, find.text(en.telegraphTitle));
    expect(find.byType(TelegraphPracticeScreen), findsOneWidget);
    await _back(tester);

    await _tap(tester, find.byKey(const ValueKey('guided-send')));
    final send = tester.widget<SendPracticeScreen>(
      find.byType(SendPracticeScreen),
    );
    expect(send.session, isA<SendSession>());
    await _back(tester);

    await _tap(tester, find.byTooltip(en.learnStatistics));
    expect(find.byType(StatsScreen), findsOneWidget);
  });

  testWidgets('continue runs the lesson challenge, the only unlock path', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _tap(tester, find.text(en.learnContinueLesson).first);
    final drill = tester.widget<ReceiveDrillScreen>(
      find.byType(ReceiveDrillScreen),
    );
    expect(drill.session.countsTowardLesson, isTrue);
    expect(drill.session.lesson, 10);
  });

  testWidgets('guided practice uses the level picked in the sheet', (
    tester,
  ) async {
    await _pumpHome(tester, lesson: 2);
    await _tap(tester, find.byKey(const ValueKey('guided-practice')));
    final levels = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('guided-level-'),
    );
    expect(levels, findsWidgets);
    await _tap(tester, levels.first);
    final drill = tester.widget<ReceiveDrillScreen>(
      find.byType(ReceiveDrillScreen),
    );
    expect(drill.session.countsTowardLesson, isFalse);
  });

  testWidgets('beginners can replay the first lesson', (tester) async {
    final c = await _pumpHome(
      tester,
      progress: TrainerProgress(firstLessonDoneAt: kTestNow),
    );
    expect(
      c.learnerStage,
      anyOf(LearnerStage.firstUse, LearnerStage.recognition),
    );
    await _tap(tester, find.byKey(const ValueKey('replay-first-lesson')));
    expect(find.byType(FirstLessonScreen), findsOneWidget);
  });
}
