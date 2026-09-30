/// English UI strings for the Listen screen, gathered here so a later l10n
/// pass only has to move them into ARB files. Plain `const`s; functions for
/// strings that interpolate values.
abstract final class ListenStrings {
  static const String title = 'Listen';
  static const String start = 'Start';
  static const String stop = 'Stop';
  static const String starting = 'Starting microphone...';
  static const String clear = 'Clear text';
  static const String copy = 'Copy text';
  static const String copied = 'Decoded text copied';
  static const String settings = 'Listen settings';
  static const String decoded = 'Decoded';
  static const String emptyHint =
      'Point the microphone at a Morse tone. Decoded text appears here.';
  static const String idleHint = 'Tap Start to listen for a Morse tone.';
  static const String pending = 'Receiving';
  static const String speed = 'Speed';
  static const String speedUnknown = '-- WPM';
  static String wpm(double value) => '${value.round()} WPM';
  static const String level = 'Signal';
  static const String toneOn = 'Tone';

  // Frequency
  static const String tone = 'Tone frequency';
  static String hz(double value) => '${value.round()} Hz';
  static const String toneLocked = 'Locked';
  static const String toneSearching = 'Searching';
  static const String toneManual = 'Manual';
  static const String autoTune = 'Auto-tune';
  static const String autoTuneHelp =
      'Follow the strongest tone between 400 and 1000 Hz. Drag the slider to '
      'tune by hand instead.';
  static const String retune = 'Auto';

  // Settings
  static const String blockSize = 'Analysis block';
  static const String blockSizeHelp =
      'Smaller blocks place mark edges more precisely but pick up more noise. '
      '256 samples (5.3 ms) suits 5-40 WPM.';
  static String blockSamples(int samples, double ms) =>
      '$samples samples (${ms.toStringAsFixed(1)} ms)';
  static const String minElement = 'Shortest element';
  static const String minElementHelp =
      'Tones and gaps shorter than this are ignored as clicks and dropouts.';
  static String ms(int value) => '$value ms';

  // States
  static const String permissionDenied =
      'Microphone access was denied. Allow it in the system settings, then '
      'try again.';
  static const String permissionRetry = 'Try again';
  static const String startFailed = 'Could not start the microphone.';
  static const String noInput =
      'No microphone was found. Connect one and try again.';
  static const String stoppedInBackground =
      'Listening stopped while the app was in the background.';
}
