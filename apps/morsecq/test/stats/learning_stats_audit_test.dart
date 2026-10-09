import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/stats/stats_model.dart';
import 'package:morsecq/ui/stats/practice_calendar.dart';
import 'package:morsecq/ui/stats/stats_screen.dart';

import '../learn/helpers/l10n.dart';

void main() {
  final now = DateTime(2026, 10, 9);
  TrainerProgress listeningOnly() {
    var progress = TrainerProgress();
    for (var i = 2; i >= 0; i--) {
      progress = progress.recordListening(
        ListeningAttempt(
          id: 'listening-$i',
          at: now.subtract(Duration(days: i)),
          mode: ListeningMode.words,
          correct: 1,
          total: 1,
          characterWpm: 20,
          effectiveWpm: 13,
        ),
      );
    }
    return progress;
  }

  test('listening activity appears without adding copying statistics', () {
    final snapshot = StatsSnapshot.from(listeningOnly(), now: now);
    expect(snapshot.isEmpty, isFalse);
    expect(snapshot.sessionCount, 3);
    expect(snapshot.activeDays, 3);
    expect(snapshot.bestStreak, 3);
    expect(snapshot.totalChars, 0);
    expect(snapshot.accuracyLast7Days, isNull);
    expect(snapshot.accuracyAllTime, isNull);
    expect(snapshot.trend, isEmpty);
  });

  test('guided sending is identified as sending in the accuracy trend', () {
    final snapshot = StatsSnapshot.from(
      TrainerProgress(
        history: [
          SessionSummary(
            at: now,
            totalChars: 1,
            correctChars: 1,
            source: ExerciseSource.send,
            drillKind: 'send-guide-k',
          ),
        ],
      ),
      now: now,
    );
    expect(snapshot.trend.single.isSend, isTrue);
  });

  testWidgets('listening-only progress opens the populated statistics view', (
    tester,
  ) async {
    await tester.pumpWidget(
      l10nApp(
        home: StatsScreen(loadProgress: () async => listeningOnly(), now: now),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StatsDashboard), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining(en.statsActiveDays(3)),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining(en.statsActiveDays(3)), findsWidgets);
    final paint = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is CalendarPainter,
    );
    await tester.ensureVisible(paint);
    final painter =
        tester.widget<CustomPaint>(paint).painter! as CalendarPainter;
    final today = painter.days.indexWhere((day) => day.day == now);
    await tester.tapAt(
      tester.getTopLeft(paint) + painter.geometry.rectFor(today).center,
    );
    await tester.pump();
    expect(find.textContaining(en.comprehensionTitle), findsOneWidget);
    expect(find.textContaining(en.statsSessions(1)), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
