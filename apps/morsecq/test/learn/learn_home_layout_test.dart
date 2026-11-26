import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/learn_home_widgets.dart';
import 'package:morsecq/ui/learn/plan/today_plan_card.dart';
import 'package:morsecq/ui/theme.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

Future<TestTraining> _pumpLearnHome(
  WidgetTester tester, {
  required Size size,
  required double scale,
  required int lesson,
  UiStyle? style = UiStyle.classic,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final training = await TestTraining.create(
    progress: TrainerProgress(currentLesson: lesson),
  );
  addTearDown(training.controller.dispose);
  await tester.pumpWidget(
    l10nApp(
      theme: style == null ? null : MorsecqTheme.light(style: style),
      home: LearnHome(
        controller: training.controller,
        playback: FakeLearnPlaybackFactory(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return training;
}

void main() {
  testWidgets('wide first lesson labels both introduced symbols as new', (
    tester,
  ) async {
    await _pumpLearnHome(
      tester,
      size: const Size(1280, 880),
      scale: 1,
      lesson: 1,
    );
    expect(find.text(en.learnNewestCharIs('K / M')), findsOneWidget);
  });

  for (final style in [UiStyle.classic, null]) {
    testWidgets('wide learning home uses 24 dp outer gutters ($style)', (
      tester,
    ) async {
      const size = Size(1440, 900);
      await _pumpLearnHome(
        tester,
        size: size,
        scale: 1.8,
        lesson: 4,
        style: style,
      );

      final plan = tester.getRect(find.byType(TodayPlanCard));
      expect(plan.left, 24);
      final rightEdge = style == null
          ? plan.right
          : tester.getRect(find.byType(DailyGoalCard)).right;
      expect(size.width - rightEdge, 24);
      expect(
        find.byKey(const ValueKey('plan-start')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('resizing keeps phone gutters until the 900 dp breakpoint', (
    tester,
  ) async {
    const size = Size(390, 640);
    await _pumpLearnHome(tester, size: size, scale: 1.8, lesson: 4);
    final plan = find.byType(TodayPlanCard);
    final course = find.byType(LessonCard);
    final goal = find.byType(DailyGoalCard);
    final primary = find.byKey(const ValueKey('plan-start'));

    for (final width in [390.0, 899.0, 900.0, 1024.0, 390.0]) {
      tester.view.physicalSize = Size(width, size.height);
      await tester.pumpAndSettle();

      final wide = width >= 900;
      final inset = wide ? 24 : 16;
      final planBounds = tester.getRect(plan);
      expect(planBounds.left, inset);
      if (!wide) expect(width - planBounds.right, inset);
      expect(primary.hitTestable(), findsOneWidget);
      final courseBounds = tester.getRect(course);
      final goalBounds = tester.getRect(goal);
      if (wide) {
        expect(planBounds.top, goalBounds.top);
        expect(courseBounds.top, greaterThan(planBounds.bottom));
        expect(width - goalBounds.right, closeTo(inset, 0.01));
        expect(goalBounds.left, greaterThan(courseBounds.right));
      } else {
        expect(goalBounds.top, greaterThan(courseBounds.bottom));
      }
      expect(tester.takeException(), isNull);
    }
  });

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(900, 800),
  ]) {
    for (final scale in [1.0, 1.8]) {
      testWidgets(
        'Brass Handbook lesson action precedes compact chips at $size/$scale',
        (tester) async {
          await _pumpLearnHome(tester, size: size, scale: scale, lesson: 4);
          final chips = find.byType(LearnedCharChip);
          final first = tester.getRect(chips.at(0));
          final second = tester.getRect(chips.at(1));
          final action = tester.getRect(find.text(en.learnContinueLesson));
          final primary = find.byKey(const ValueKey('plan-start'));
          expect(first.width, lessThan(80));
          expect(second.top, first.top);
          expect(action.bottom, lessThan(first.top));
          expect(tester.getRect(primary).bottom, lessThan(size.height));
          expect(primary.hitTestable(), findsOneWidget);
          expect(tester.getRect(primary).bottom, lessThan(action.top));
          expect(find.text(en.learnContinueLesson), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'unstyled long learned set shows newest and expands all characters',
    (tester) async {
      final training = await _pumpLearnHome(
        tester,
        size: const Size(320, 640),
        scale: 1.8,
        lesson: 42,
        style: null,
      );
      final learned = training.controller.learnedChars;
      expect(learned.length, greaterThan(10));
      var chips = tester.widgetList<LearnedCharChip>(
        find.byType(LearnedCharChip),
      );
      expect(chips.length, lessThanOrEqualTo(10));
      expect(
        chips.any((chip) => chip.char == training.controller.newestChar),
        isTrue,
      );
      final newestChip = find.widgetWithText(
        LearnedCharChip,
        training.controller.newestChar,
      );
      final primary = find.byKey(const ValueKey('plan-start'));
      expect(primary.hitTestable(), findsOneWidget);
      expect(tester.getRect(primary).bottom, lessThan(640));
      await tester.ensureVisible(newestChip);
      await tester.pumpAndSettle();
      expect(newestChip.hitTestable(), findsOneWidget);
      final toggle = find.byKey(const ValueKey('learned-chars-toggle'));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      chips = tester.widgetList<LearnedCharChip>(find.byType(LearnedCharChip));
      expect(chips.map((chip) => chip.char), learned);
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byType(LearnedCharChip), findsNWidgets(10));
      expect(tester.takeException(), isNull);
    },
  );
}
