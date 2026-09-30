/// English UI strings for the Learn tab, gathered here so a later l10n pass
/// only has to move them into ARB files. Keep them as plain `const`s; use the
/// functions for strings that interpolate values.
abstract final class LearnStrings {
  // Home
  static const String learnTitle = 'Learn';
  static const String lessonCardTitle = 'Koch lesson';
  static String lessonOf(int lesson, int total) => 'Lesson $lesson of $total';
  static String charsLearned(int count) =>
      count == 1 ? '1 character learned' : '$count characters learned';
  static const String newestChar = 'New this lesson';
  static const String courseComplete = 'Course complete - keep sharpening!';
  static const String dailyGoalTitle = 'Today';
  static String dailyGoalProgress(int done, int goal) => '$done / $goal chars';
  static const String dailyGoalMet = 'Daily goal reached';
  static String streakDays(int days) =>
      days == 1 ? '1 day streak' : '$days day streak';
  static const String noStreak = 'Start a streak today';
  static const String continueLesson = 'Continue lesson';
  static const String receivePractice = 'Receive practice';
  static const String sendPractice = 'Send practice';
  static const String reviewDue = 'Review due characters';
  static String reviewDueCount(int count) =>
      count == 0 ? 'Nothing due' : (count == 1 ? '1 due' : '$count due');
  static const String settings = 'Training settings';
  static const String statistics = 'Statistics';
  static const String loading = 'Loading your progress...';
  static const String identityRequired =
      'Create or unlock your identity to start training. Progress is stored '
      'with your identity so it travels with your backup.';
  static const String loadFailed =
      'Your saved progress could not be read. Starting fresh; the old file '
      'was kept as .corrupt.';
  static const String chooseDrill = 'Choose a drill';
  static const String drillGroups = 'Random groups';
  static const String drillWords = 'Words';
  static const String drillCallsigns = 'Callsigns';
  static const String drillQso = 'QSO';

  // Receive drill
  static const String receiveTitle = 'Receive';
  static const String reviewTitle = 'Review';
  static const String listen = 'Listen...';
  static const String ready = 'Ready';
  static const String replay = 'Replay';
  static const String play = 'Play';
  static const String answerHint = 'Type what you heard';
  static const String submit = 'Check';
  static const String next = 'Next';
  static const String finish = 'Finish';
  static const String done = 'Done';
  static const String backspace = 'Delete';
  static const String space = 'Space';
  static const String sent = 'Sent';
  static const String yourCopy = 'Your copy';
  static const String roundPerfect = 'Perfect copy!';
  static String roundScore(int correct, int total) =>
      '$correct of $total correct';
  static String roundOf(int round) => 'Round $round';
  static const String sessionSummary = 'Session summary';
  static String accuracyPercent(double accuracy) =>
      '${(accuracy * 100).round()}%';
  static String charsSent(int count) => '$count characters sent';
  static const String lessonPassed = 'Lesson passed';
  static String lessonUnlocked(String char) =>
      'Next character unlocked: $char';
  static const String lessonNotPassed = 'Keep at it: 90% unlocks the next one';
  static const String reviewRecorded = 'Review recorded';
  static const String weakChars = 'Needs work';
  static const String confusions = 'Confused';
  static String confusedAs(String target, String answered) => answered.isEmpty
      ? '$target missed'
      : '$target heard as $answered';
  static const String noFeedbackWarning =
      'Sound, flash and haptics are all off - the screen will flash instead.';

  // Send practice
  static const String sendTitle = 'Send';
  static const String sendThis = 'Send this';
  static const String copyFromMemory = 'From memory';
  static const String hiddenTarget = 'Hidden - key it from memory';
  static const String decoded = 'Decoded';
  static const String pending = 'Keying';
  static String wpm(double wpm) => '${wpm.toStringAsFixed(0)} wpm';
  static const String waitingForKey = 'Start keying when ready';
  static const String restart = 'Restart';
  static const String tryAnother = 'Try another';
  static const String keyerStraight = 'Straight';
  static const String keyerIambicA = 'Iambic A';
  static const String keyerIambicB = 'Iambic B';
  static const String legendStraight = 'Space = key';
  static const String legendPaddles = 'Left Ctrl = dit, Right Ctrl = dah';
  static const String sendClean = 'Clean fist - nothing to fix.';
  static const String sendIssues = 'Rhythm notes';
  static const String yourSending = 'Decoded as';
  static const String straightKeyLabel = 'KEY';
  static const String ditLabel = 'DIT';
  static const String dahLabel = 'DAH';

  // Settings
  static const String settingsTitle = 'Training settings';
  static const String characterSpeed = 'Character speed';
  static const String farnsworth = 'Farnsworth spacing';
  static const String farnsworthHelp =
      'Characters stay fast; the gaps between them stretch to this speed.';
  static const String effectiveSpeed = 'Effective speed';
  static const String tone = 'Tone';
  static String hz(double hz) => '${hz.round()} Hz';
  static const String playSample = 'Play sample';
  static const String sessionLength = 'Session length';
  static String charsCount(int count) => '$count characters';
  static const String feedback = 'Feedback';
  static const String sound = 'Sound';
  static const String flash = 'Screen flash';
  static const String haptic = 'Vibration';
  static const String keyer = 'Keyer';
  static const String dailyGoal = 'Daily goal';
  static const String sampleText = 'CQ';
}
