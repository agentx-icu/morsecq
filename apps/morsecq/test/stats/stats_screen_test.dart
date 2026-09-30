import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/stats/accuracy_trend_chart.dart';
import 'package:morsecq/ui/stats/char_grid.dart';
import 'package:morsecq/ui/stats/confusion_heatmap.dart';
import 'package:morsecq/ui/stats/practice_calendar.dart';
import 'package:morsecq/ui/stats/stats_model.dart';
import 'package:morsecq/ui/stats/stats_screen.dart';
import 'package:morsecq/ui/stats/stats_strings.dart';
import 'package:morsecq/ui/stats/stats_widgets.dart';

import 'stats_model_test.dart' show buildProgress, kNow;

const Size kPhone = Size(390, 844);
const Size kDesktop = Size(1280, 900);

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required Future<TrainerProgress> Function() load,
  ThemeData? theme,
}) async {
  await _setSize(tester, size);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: StatsScreen(loadProgress: load, now: kNow),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('StatsScreen', () {
    testWidgets('shows the empty state for a fresh identity', (tester) async {
      await _pump(tester, size: kPhone, load: () async => TrainerProgress());
      expect(find.text(StatsStrings.title), findsOneWidget);
      expect(find.text(StatsStrings.emptyTitle), findsOneWidget);
      expect(find.text(StatsStrings.emptyCallToAction), findsOneWidget);
      expect(find.byType(OverviewTiles), findsNothing);
      expect(find.byType(AccuracyTrendChart), findsNothing);
    });

    testWidgets('shows a loading state until the future resolves', (
      tester,
    ) async {
      await _setSize(tester, kPhone);
      await tester.pumpWidget(
        MaterialApp(
          home: StatsScreen(
            loadProgress: () => Future<TrainerProgress>.delayed(
              const Duration(seconds: 1),
              TrainerProgress.new,
            ),
            now: kNow,
          ),
        ),
      );
      await tester.pump();
      expect(find.text(StatsStrings.loading), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text(StatsStrings.emptyTitle), findsOneWidget);
    });

    testWidgets('shows an error state with retry', (tester) async {
      var calls = 0;
      await _pump(
        tester,
        size: kPhone,
        load: () {
          calls++;
          if (calls == 1) {
            return Future<TrainerProgress>.error(StateError('disk'));
          }
          return Future<TrainerProgress>.value(buildProgress());
        },
      );
      expect(find.text(StatsStrings.loadFailed), findsOneWidget);
      await tester.tap(find.text(StatsStrings.retry));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.byType(OverviewTiles), findsOneWidget);
    });

    testWidgets('renders overview tiles on a phone', (tester) async {
      await _pump(
        tester,
        size: kPhone,
        load: () async => buildProgress(days: 3),
      );
      expect(find.text(StatsStrings.tileLesson), findsOneWidget);
      expect(find.text(StatsStrings.lessonOf(3, 42)), findsOneWidget);
      expect(find.text(StatsStrings.charsLearned(4)), findsOneWidget);
      expect(find.text(StatsStrings.percent(34 / 36)), findsOneWidget);
      expect(
        find.text(formatPracticeDuration(const Duration(minutes: 6))),
        findsOneWidget,
      );
      expect(find.text(StatsStrings.days(3)), findsOneWidget);
      expect(find.text(StatsStrings.bestStreak(3)), findsOneWidget);
      expect(find.text(StatsStrings.goalProgress(12, 20)), findsOneWidget);
      expect(find.text(StatsStrings.goalRemaining(8)), findsOneWidget);
      expect(find.text(StatsStrings.trendTitle), findsOneWidget);

      // Single column: the trend chart sits below the overview.
      final overview = tester.getRect(find.byType(OverviewTiles));
      final trend = tester.getRect(find.byType(AccuracyTrendChart));
      expect(trend.top, greaterThanOrEqualTo(overview.bottom));
      expect(trend.left, closeTo(overview.left, 1));
    });

    testWidgets('uses two columns at desktop width', (tester) async {
      await _pump(
        tester,
        size: kDesktop,
        load: () async => buildProgress(days: 3),
      );
      final trend = tester.getRect(find.byType(AccuracyTrendChart));
      final chars = tester.getRect(find.byType(CharGrid));
      expect(chars.top, closeTo(trend.top, 1));
      expect(chars.left, greaterThan(trend.right - 1));
      expect(find.byType(ConfusionHeatmap), findsOneWidget);
      expect(find.byType(PracticeCalendar), findsOneWidget);
    });

    testWidgets('daily goal met is reported', (tester) async {
      final progress = buildProgress(days: 1).copyWith(dailyGoalChars: 10);
      await _pump(tester, size: kPhone, load: () async => progress);
      expect(find.text(StatsStrings.goalMet), findsOneWidget);
    });

    testWidgets('tapping the trend chart shows a session tooltip', (
      tester,
    ) async {
      await _pump(
        tester,
        size: kDesktop,
        load: () async => buildProgress(days: 3),
      );
      expect(find.text(StatsStrings.trendHint), findsOneWidget);
      final chart = find.descendant(
        of: find.byType(AccuracyTrendChart),
        matching: find.byType(CustomPaint),
      );
      final rect = tester.getRect(chart.first);
      // The newest session sits at the right edge of the plot.
      await tester.tapAt(
        Offset(rect.right - TrendGeometry.kRightInset, rect.center.dy),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining(StatsStrings.tooltipSession(3, 3)),
        findsOneWidget,
      );
      expect(find.text(StatsStrings.trendHint), findsNothing);
    });

    testWidgets('legend appears only when send and receive both exist', (
      tester,
    ) async {
      await _pump(
        tester,
        size: kDesktop,
        load: () async => buildProgress(days: 2, withSendToday: true),
      );
      expect(find.text(StatsStrings.seriesReceive), findsOneWidget);
      expect(find.text(StatsStrings.seriesSend), findsOneWidget);
    });

    testWidgets('tapping a character opens the detail sheet', (tester) async {
      await _pump(
        tester,
        size: kDesktop,
        load: () async => buildProgress(days: 3),
      );
      final cell = find.byWidgetPredicate(
        (w) => w is CharCell && w.char == 'S',
      );
      expect(cell, findsOneWidget);
      await tester.tap(cell);
      await tester.pumpAndSettle();
      expect(find.byType(CharDetailSheet), findsOneWidget);
      expect(find.text(StatsStrings.srsTitle), findsOneWidget);
      expect(find.text(StatsStrings.correctOf(7, 9)), findsOneWidget);
      expect(find.text(StatsStrings.confusionsTitle), findsOneWidget);
      expect(find.text(StatsStrings.times(2)), findsOneWidget);
      // Two demotions at box 0 then one promotion: box 1, due tomorrow.
      expect(find.textContaining(StatsStrings.srsBox(1, 4)), findsOneWidget);
      expect(find.textContaining(StatsStrings.srsDueIn(1)), findsOneWidget);
    });

    testWidgets('unpractised character reports no data', (tester) async {
      await _pump(
        tester,
        size: kDesktop,
        load: () async => buildProgress(days: 1),
      );
      await tester.tap(
        find.byWidgetPredicate((w) => w is CharCell && w.char == 'U'),
      );
      await tester.pumpAndSettle();
      expect(find.text(StatsStrings.charsNotStarted), findsWidgets);
      expect(find.text(StatsStrings.lessonIntroduced(4)), findsOneWidget);
      expect(find.text(StatsStrings.srsNotTracked), findsOneWidget);
      expect(find.text(StatsStrings.confusionsNone), findsOneWidget);
    });

    testWidgets('heatmap hides when nothing was confused', (tester) async {
      await _pump(
        tester,
        size: kDesktop,
        load: () async => buildProgress(days: 1),
      );
      expect(find.text(StatsStrings.heatmapEmpty), findsOneWidget);
    });

    testWidgets('heatmap renders and reads a tapped cell', (tester) async {
      await _pump(
        tester,
        size: kDesktop,
        load: () async => buildProgress(days: 3),
      );
      expect(find.text(StatsStrings.heatmapEmpty), findsNothing);
      final paint = find.descendant(
        of: find.byType(ConfusionHeatmap),
        matching: find.byType(CustomPaint),
      );
      final rect = tester.getRect(paint.first);
      const cell = ConfusionHeatmap.kCell;
      await tester.tapAt(rect.topLeft + const Offset(cell * 1.5, cell * 1.5));
      await tester.pumpAndSettle();
      expect(find.text(StatsStrings.heatmapCell('S', 'R', 2)), findsOneWidget);
    });

    testWidgets('calendar shows active days and streak explanation', (
      tester,
    ) async {
      await _pump(
        tester,
        size: kDesktop,
        load: () async => buildProgress(days: 3),
      );
      expect(find.textContaining(StatsStrings.activeDays(3)), findsOneWidget);
      expect(find.text(StatsStrings.streakExplanation), findsOneWidget);
    });

    testWidgets('renders under the dark theme', (tester) async {
      await _pump(
        tester,
        size: kDesktop,
        load: () async => buildProgress(days: 3, withSendToday: true),
        theme: ThemeData.dark(useMaterial3: true),
      );
      expect(find.byType(OverviewTiles), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('StatsSummaryCard', () {
    testWidgets('shows headline numbers', (tester) async {
      await _setSize(tester, kPhone);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsSummaryCard(progress: buildProgress(days: 3), now: kNow),
          ),
        ),
      );
      expect(find.text(StatsStrings.summaryTitle), findsOneWidget);
      expect(find.text(StatsStrings.percent(34 / 36)), findsOneWidget);
      expect(find.text(StatsStrings.days(3)), findsOneWidget);
      expect(find.text(StatsStrings.summaryOpen), findsNothing);
    });

    testWidgets('empty progress and open action', (tester) async {
      var opened = 0;
      await _setSize(tester, kPhone);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsSummaryCard(
              progress: TrainerProgress(),
              now: kNow,
              onOpen: () => opened++,
            ),
          ),
        ),
      );
      expect(find.text(StatsStrings.emptyTitle), findsOneWidget);
      await tester.tap(find.text(StatsStrings.summaryOpen));
      expect(opened, 1);
    });
  });

  group('geometry helpers', () {
    test('TrendGeometry spaces points across the plot', () {
      final points = <TrendPoint>[
        for (var i = 0; i < 3; i++)
          TrendPoint(
            index: i + 1,
            summary: SessionSummary(
              at: kNow,
              totalChars: 10,
              correctChars: 5 + i * 2,
            ),
            isSend: false,
          ),
      ];
      final g = TrendGeometry(points: points, size: const Size(300, 200));
      expect(g.xs.first, TrendGeometry.kLeftInset);
      expect(g.xs.last, 300 - TrendGeometry.kRightInset);
      expect(g.xs[1], closeTo((g.xs.first + g.xs.last) / 2, 1e-9));
      expect(g.ys.first, greaterThan(g.ys.last));
      expect(g.ys.every((y) => y >= g.plot.top && y <= g.plot.bottom), isTrue);
    });

    test('a single point is centred', () {
      final g = TrendGeometry(
        points: <TrendPoint>[
          TrendPoint(
            index: 1,
            summary: SessionSummary(at: kNow, totalChars: 4, correctChars: 4),
            isSend: true,
          ),
        ],
        size: const Size(300, 200),
      );
      expect(g.xs.single, closeTo(g.plot.center.dx, 1e-9));
    });

    test('CalendarGeometry fits and hit-tests squares', () {
      final g = CalendarGeometry.fit(dayCount: 84, maxWidth: 200);
      expect(g.weeks, 12);
      expect(g.cell, lessThanOrEqualTo(CalendarGeometry.kMaxCell));
      expect(g.size.width, lessThanOrEqualTo(200 + 1e-9));
      expect(g.indexAt(g.rectFor(0).center), 0);
      expect(g.indexAt(g.rectFor(83).center), 83);
      expect(g.indexAt(g.rectFor(9).center), 9);
      expect(g.indexAt(const Offset(0, 0)), isNull);
      expect(g.indexAt(Offset(g.size.width + 5, g.size.height + 5)), isNull);
    });

    test('CalendarGeometry grows squares on wide layouts up to the cap', () {
      final g = CalendarGeometry.fit(dayCount: 84, maxWidth: 1000);
      expect(g.cell, CalendarGeometry.kMaxCell);
    });
  });
}
