import 'package:morse_trainer/morse_trainer.dart';

/// Plain-language coaching for each `SendIssueKind`. Kept separate from the
/// strings file because the wording depends on the measured ratio.
abstract final class SendTips {
  static String tipFor(SendIssue issue) {
    final ratio = issue.meanRatio;
    return switch (issue.kind) {
      SendIssueKind.ditTooLong =>
        'Your dits are running long (about ${_x(ratio)} of a dit). '
            "Think 'di', not 'daah' - a dit is a tap, not a press.",
      SendIssueKind.dahTooShort =>
        'Your dahs are short (about ${_x(ratio)} of a dit; aim for 3). '
            'Hold the dah for the length of three dits.',
      SendIssueKind.intraGapTooLong =>
        'Gaps inside characters are too wide (about ${_x(ratio)} of a dit). '
            'Keep the elements of one character tight together.',
      SendIssueKind.charGapTooShort =>
        'Characters are running into each other (gaps about ${_x(ratio)} '
            'of a dit; aim for 3). Leave a clear pause after each character.',
      SendIssueKind.wordGapTooShort =>
        'Words are too close (gaps about ${_x(ratio)} of a dit; aim for 7). '
            'Count a long pause between words.',
      SendIssueKind.speedUnsteady =>
        'Your speed wanders (variation ${(ratio * 100).round()}%). '
            'Settle on one tempo and hold it for the whole line.',
    };
  }

  /// Short headline for an issue kind.
  static String titleFor(SendIssueKind kind) => switch (kind) {
    SendIssueKind.ditTooLong => 'Dits too long',
    SendIssueKind.dahTooShort => 'Dahs too short',
    SendIssueKind.intraGapTooLong => 'Elements spread out',
    SendIssueKind.charGapTooShort => 'Characters crowded',
    SendIssueKind.wordGapTooShort => 'Words crowded',
    SendIssueKind.speedUnsteady => 'Speed unsteady',
  };

  static String severityLabel(SendSeverity severity) => switch (severity) {
    SendSeverity.minor => 'minor',
    SendSeverity.moderate => 'noticeable',
    SendSeverity.severe => 'major',
  };

  static String _x(double ratio) => '${ratio.toStringAsFixed(1)}x';
}
