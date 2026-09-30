/// English UI strings for the training statistics dashboard, gathered here so
/// a later l10n pass only has to move them into ARB files. Plain `const`s;
/// functions for strings that interpolate values.
abstract final class StatsStrings {
  // Screen
  static const String title = 'Statistics';
  static const String loading = 'Loading your statistics...';
  static const String loadFailed =
      'Your progress could not be loaded. Pull down or reopen to retry.';
  static const String retry = 'Retry';

  // Empty state
  static const String emptyTitle = 'No sessions yet';
  static const String emptyBody =
      'Finish your first receive or send session and this page fills up with '
      'your accuracy trend, per-character strengths and a practice calendar.';
  static const String emptyCallToAction =
      'Head to Learn and press "Continue lesson" to start.';

  // Overview tiles
  static const String overviewTitle = 'Overview';
  static const String tileLesson = 'Koch lesson';
  static String lessonOf(int lesson, int total) => '$lesson / $total';
  static String charsLearned(int count) =>
      count == 1 ? '1 character learned' : '$count characters learned';
  static const String tileAccuracy = 'Accuracy';
  static const String accuracyLast7Days = 'last 7 days';
  static const String accuracyAllTime = 'all time';
  static String percent(double fraction) =>
      '${(fraction * 100).toStringAsFixed(fraction >= 0.995 ? 0 : 1)}%';
  static const String noData = '--';
  static const String tilePractice = 'Practice';
  static String charsCopied(int count) =>
      count == 1 ? '1 char copied' : '$count chars copied';
  static String sessions(int count) =>
      count == 1 ? '1 session' : '$count sessions';
  static const String tileStreak = 'Streak';
  static String days(int count) => count == 1 ? '1 day' : '$count days';
  static String bestStreak(int count) => 'best ${days(count)}';
  static const String tileDailyGoal = 'Daily goal';
  static String goalProgress(int done, int goal) => '$done / $goal chars';
  static const String goalMet = 'Reached today';
  static String goalRemaining(int remaining) =>
      remaining == 1 ? '1 char to go' : '$remaining chars to go';

  // Summary card
  static const String summaryTitle = 'Your stats';
  static const String summaryOpen = 'View statistics';

  // Accuracy trend
  static const String trendTitle = 'Accuracy trend';
  static String trendSubtitle(int count) =>
      count == 1 ? 'Last session' : 'Last $count sessions';
  static const String trendHint = 'Tap a point to inspect a session.';
  static const String seriesReceive = 'Receive';
  static const String seriesSend = 'Send';
  static const String seriesAll = 'Sessions';
  static const String axisSessions = 'Session';
  static const String axisAccuracy = 'Accuracy';
  static String tooltipSession(int index, int total) =>
      'Session $index of $total';
  static String tooltipCopied(int correct, int total) =>
      '$correct / $total correct';
  static String tooltipLesson(int lesson) => 'Lesson $lesson';

  // Character grid
  static const String charsTitle = 'Characters';
  static const String charsSubtitle = 'Koch order. Tap a character for detail.';
  static const String charsNotStarted = 'Not practised yet';
  static String attempts(int count) =>
      count == 1 ? '1 attempt' : '$count attempts';
  static String correctOf(int correct, int attempts) =>
      '$correct of $attempts correct';
  static String lessonIntroduced(int lesson) => 'Introduced in lesson $lesson';
  static const String notInCourse = 'Not part of the Koch course';
  static const String srsTitle = 'Spaced repetition';
  static String srsBox(int box, int maxBox) => 'Box $box of $maxBox';
  static const String srsNotTracked = 'Not scheduled yet';
  static const String srsDueNow = 'Due now';
  static String srsDueIn(int days) =>
      days == 1 ? 'Due tomorrow' : 'Due in $days days';
  static const String confusionsTitle = 'Most often confused with';
  static const String confusionsNone = 'No confusions recorded';
  static const String confusionMissed = 'missed';
  static String times(int count) => count == 1 ? '1 time' : '$count times';

  // Accuracy buckets (grid legend)
  static const String bucketLegendTitle = 'Accuracy';
  static const String bucketNone = 'None';
  static const String bucketWeak = '< 70%';
  static const String bucketFair = '70-89%';
  static const String bucketGood = '90-97%';
  static const String bucketStrong = '>= 98%';

  // Confusion heatmap
  static const String heatmapTitle = 'Confusions';
  static const String heatmapSubtitle =
      'Rows are the sent character, columns what you answered. '
      'Darker means more often.';
  static const String heatmapEmpty =
      'No confusions yet. Wrong answers will show up here.';
  static const String heatmapLegendLow = 'Rare';
  static const String heatmapLegendHigh = 'Frequent';
  static const String heatmapAxisTarget = 'Sent';
  static const String heatmapAxisAnswered = 'Answered';
  static String heatmapCell(String target, String answered, int count) =>
      '$target answered as $answered, ${times(count)}';

  // Practice calendar
  static const String calendarTitle = 'Practice calendar';
  static const String calendarSubtitle = 'Last 12 weeks';
  static const String calendarLegendLess = 'Less';
  static const String calendarLegendMore = 'More';
  static String calendarDay(String date, int chars) =>
      chars == 0 ? '$date: no practice' : '$date: $chars chars';
  static String activeDays(int count) =>
      count == 1 ? '1 active day' : '$count active days';
  static const String streakExplanation =
      'A streak counts consecutive calendar days with at least one session. '
      'Skipping a whole day resets it; practising twice in a day counts once.';
}
