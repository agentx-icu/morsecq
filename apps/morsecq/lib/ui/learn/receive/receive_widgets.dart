import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';

/// Whole-percent accuracy (`0.923` -> `92%`) in the current locale.
String formatAccuracy(S s, double accuracy) =>
    s.learnAccuracyPercent((accuracy * 100).round());

/// Keep a result on the correct side of the displayed challenge threshold.
String formatChallengeAccuracy(S s, double accuracy, double threshold) {
  final rounded = (accuracy * 100).round();
  final limit = (threshold * 100).round();
  if (accuracy >= threshold || rounded != limit) {
    return formatAccuracy(s, accuracy);
  }
  if ((accuracy * 10000).round() >= (threshold * 10000).round()) {
    return '< ${formatAccuracy(s, threshold)}';
  }
  final percent = NumberFormat.percentPattern(s.localeName)
    ..minimumFractionDigits = 1
    ..maximumFractionDigits = 2;
  return percent.format(accuracy);
}

String challengeRule(S s, KochCourse course, int lesson) {
  final describe = course.isLastLesson(lesson)
      ? s.learnChallengeHintLast
      : s.learnChallengeHint;
  return describe(
    course.minCharsPerSession,
    course.requiredNewCharAttempts(lesson),
    formatAccuracy(s, course.passAccuracy),
  );
}

/// One confusion pair: "K heard as M", or "K missed" when nothing was
/// answered for the target.
String confusedAs(S s, String target, String answered) => answered.isEmpty
    ? s.learnConfusedMissed(target)
    : s.learnConfusedAs(target, answered);

/// "Playing" / "Ready" with the Replay button. They share a line when it
/// fits; on a narrow phone, a long language or large text Replay wraps below
/// so the status is never cut off.
class PlaybackStatusRow extends StatelessWidget {
  const PlaybackStatusRow({
    super.key,
    required this.playing,
    required this.onReplay,
    required this.replayLabel,
    this.heard = false,
  });

  final bool playing;
  final VoidCallback? onReplay;
  final String replayLabel;
  final bool heard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              playing
                  ? Icons.volume_up
                  : heard
                  ? Icons.check_circle_outline
                  : Icons.hearing,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                playing
                    ? s.learnListen
                    : heard
                    ? s.learnRoundHeard
                    : s.learnReady,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: onReplay,
          icon: const Icon(Icons.replay),
          label: Text(replayLabel),
        ),
      ],
    );
  }
}
