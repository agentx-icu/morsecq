import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/stats/accuracy_trend_chart.dart';
import 'package:morsecq/ui/stats/confusion_heatmap.dart';
import 'package:morsecq/ui/stats/practice_calendar.dart';
import 'package:morsecq/ui/stats/stats_details_picker.dart';
import 'package:morsecq/ui/stats/stats_model.dart';

import '../learn/helpers/l10n.dart';
import 'stats_model_test.dart' show buildProgress, kNow;

Future<void> _pump(
  WidgetTester tester,
  Widget chart, {
  double scale = 1,
  Locale? locale,
}) async {
  tester.view.physicalSize = const Size(320, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    l10nApp(
      locale: locale,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: Scaffold(body: SingleChildScrollView(child: chart)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectDetails(
  WidgetTester tester,
  String chart,
  StatsSnapshot data,
  int index,
) {
  switch (chart) {
    case 'calendar':
      final day = data.calendar[index];
      expect(
        find.text(
          en.statsCalendarDay(DateFormat.yMd('en').format(day.day), day.chars),
        ),
        findsOneWidget,
      );
    case 'trend':
      expect(
        find.textContaining(
          en.statsTooltipSession(data.trend[index].index, data.trend.length),
        ),
        findsOneWidget,
      );
    case 'confusion':
      final target = data.confusedTargets[index ~/ data.confusedAnswers.length];
      final answer = data.confusedAnswers[index % data.confusedAnswers.length];
      expect(
        find.text(
          en.statsHeatmapCell(
            target,
            answer,
            data.confusionCount(target, answer),
          ),
        ),
        findsOneWidget,
      );
  }
}

void main() {
  final snapshot = StatsSnapshot.from(
    buildProgress().recordSession(
      SessionScore.evaluate('KM', 'RS', at: kNow),
      now: kNow,
    ),
    now: kNow,
  );
  final cases = <String, Widget Function()>{
    'calendar': () => PracticeCalendar(snapshot: snapshot),
    'trend': () => AccuracyTrendChart(snapshot: snapshot),
    'confusion': () => ConfusionHeatmap(snapshot: snapshot),
  };
  for (final entry in cases.entries) {
    testWidgets(
      '${entry.key} large German labels keep a real 48dp menu target',
      (tester) async {
        await _pump(
          tester,
          entry.value(),
          scale: 3.1,
          locale: const Locale('de'),
        );
        final picker = find.byType(DropdownButton<int>);
        await tester.ensureVisible(picker);
        await tester.pumpAndSettle();
        expect(tester.getSize(picker).height, greaterThanOrEqualTo(48));
        expect(tester.getSize(picker).width, greaterThanOrEqualTo(48));
        await tester.tap(picker);
        await tester.pumpAndSettle();
        final row = find.byType(DropdownMenuItem<int>).first;
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        final bounds = tester.getRect(row);
        expect(bounds.height, greaterThanOrEqualTo(48));
        expect(bounds.width, greaterThanOrEqualTo(48));
        await tester.tapAt(bounds.topLeft + const Offset(2, 2));
        await tester.pumpAndSettle();
        expect(
          tester.widget<DropdownButton<int>>(picker).value,
          0,
          reason: 'Visible menu row bounds: $bounds',
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets(
      '${entry.key} details are keyboard reachable through 48dp control',
      (tester) async {
        await _pump(tester, entry.value());
        final picker = find.byType(DropdownButton<int>);
        expect(picker, findsOneWidget);
        expect(tester.getSize(picker).height, greaterThanOrEqualTo(48));
        final button = tester.widget<DropdownButton<int>>(picker);
        expect(button.items, isNotEmpty);
        expect(button.value, isNull);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(tester.widget<DropdownButton<int>>(picker).value, 0);
        _expectDetails(tester, entry.key, snapshot, 0);
        // Reopen and reach the last existing item without a pointer.
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        for (var i = 1; i < button.items!.length; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(
          tester.widget<DropdownButton<int>>(picker).value,
          button.items!.length - 1,
        );
        _expectDetails(tester, entry.key, snapshot, button.items!.length - 1);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );
  }

  testWidgets(
    'semantics activates picker and a full-size localized option',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pump(tester, ConfusionHeatmap(snapshot: snapshot));
        final picker = find.byType(StatsDetailsPicker);
        var node = tester.getSemantics(picker);
        expect(node.getSemanticsData().label, contains(en.statsHeatmapTitle));
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        node.owner!.performAction(node.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        final target = snapshot.confusedTargets.last;
        final answer = snapshot.confusedAnswers.last;
        final optionLabel = en.statsHeatmapCell(
          target,
          answer,
          snapshot.confusionCount(target, answer),
        );
        final option = find.text(optionLabel).last;
        final row = find
            .ancestor(of: option, matching: find.byType(DropdownMenuItem<int>))
            .last;
        expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
        node = tester.getSemantics(option);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        node.owner!.performAction(node.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(picker).getSemanticsData().value,
          optionLabel,
        );
        _expectDetails(
          tester,
          'confusion',
          snapshot,
          snapshot.confusedTargets.length * snapshot.confusedAnswers.length - 1,
        );
      } finally {
        semantics.dispose();
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'pointer detail and standard selection share the existing state',
    (tester) async {
      await _pump(tester, PracticeCalendar(snapshot: snapshot));
      final chart = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is CalendarPainter,
      );
      final painter =
          tester.widget<CustomPaint>(chart).painter! as CalendarPainter;
      final index = snapshot.calendar.length - 1;
      await tester.tapAt(
        tester.getTopLeft(chart) + painter.geometry.rectFor(index).center,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButton<int>>(find.byType(DropdownButton<int>))
            .value,
        index,
      );
      _expectDetails(tester, 'calendar', snapshot, index);
    },
  );

  testWidgets(
    'empty trend disables selection and empty confusion keeps its message',
    (tester) async {
      final empty = StatsSnapshot.from(TrainerProgress(), now: kNow);
      await _pump(tester, AccuracyTrendChart(snapshot: empty));
      final picker = tester.widget<DropdownButton<int>>(
        find.byType(DropdownButton<int>),
      );
      expect(picker.items, isEmpty);
      expect(picker.onChanged, isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(DropdownMenuItem<int>), findsNothing);
      await _pump(tester, ConfusionHeatmap(snapshot: empty));
      expect(find.byType(DropdownButton<int>), findsNothing);
      expect(find.text(en.statsHeatmapEmpty), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a menu opened on an old snapshot cannot select stale coordinates',
    (tester) async {
      var current = snapshot;
      late StateSetter update;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (_, setState) {
            update = setState;
            return ConfusionHeatmap(snapshot: current);
          },
        ),
      );
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      final target = snapshot.confusedTargets.last;
      final answer = snapshot.confusedAnswers.last;
      final option = en.statsHeatmapCell(
        target,
        answer,
        snapshot.confusionCount(target, answer),
      );
      update(() => current = StatsSnapshot.from(buildProgress(), now: kNow));
      await tester.pumpAndSettle();
      expect(find.text(option), findsNothing);
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<DropdownButton<int>>(find.byType(DropdownButton<int>))
            .value,
        isNull,
      );
    },
  );
}
