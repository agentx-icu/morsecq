import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/receive_session.dart';
import '../../../training/training_controller.dart';
import 'receive_widgets.dart';

/// End-of-session card: accuracy, the verdict with a one-line explanation,
/// weak symbols and the most frequent confusions. Rendered after the
/// controller has recorded the session, so [outcome] reflects what was
/// actually committed (never the score alone: an assisted or non-course
/// attempt is never "passed").
class ReceiveSummaryView extends StatelessWidget {
  const ReceiveSummaryView({
    super.key,
    required this.session,
    required this.outcome,
    required this.course,
    this.unlockedChar,
  });

  final ReceiveSession session;
  final ReceiveOutcome outcome;
  final KochCourse course;

  /// The symbol the newly unlocked lesson introduces, when [outcome]
  /// advanced.
  final String? unlockedChar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.s;
    final score = outcome.score;
    final weak = score.weakChars();
    final confusions = session.confusionPairs();
    final verdict = verdictOf(outcome, session);
    final (headline, icon) = _headline(s, verdict);
    final explanation = _explanation(s, verdict);
    final Color accent = verdict.isPositive
        ? scheme.primary
        : verdict.isFailedChallenge
        ? scheme.error
        : scheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          s.learnSessionSummary,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // The strict figure is what the Koch unlock rule uses, so the number
        // shown always agrees with the verdict colour.
        Text(
          formatAccuracy(s, score.strictAccuracy),
          style: theme.textTheme.displayMedium?.copyWith(
            color: accent,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          s.learnCharsSent(score.totalChars),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: accent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                headline,
                key: const ValueKey('receive-verdict'),
                style: theme.textTheme.titleSmall,
              ),
            ),
          ],
        ),
        if (explanation != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            explanation,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (weak.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          _Section(
            title: s.learnWeakChars,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                for (final c in weak.take(10))
                  Chip(
                    label: Text(
                      '$c ${formatAccuracy(s, score.perCharAccuracy[c] ?? 0)}',
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (confusions.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          _Section(
            title: s.learnConfusions,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final (target, answered, count) in confusions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${confusedAs(s, target, answered)}  ×$count',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  (String, IconData) _headline(S s, ReceiveVerdict verdict) {
    final lesson = outcome.attemptedLesson;
    final newChars = lesson != null && course.isValidLesson(lesson)
        ? course.newCharsForLesson(lesson)
        : const <String>[];
    return switch (verdict) {
      ReceiveVerdict.notCredited => (
        s.learnVerdictNotCredited,
        Icons.block_outlined,
      ),
      ReceiveVerdict.assisted => (s.learnVerdictAssisted, Icons.help_outline),
      ReceiveVerdict.practice => (
        s.learnVerdictPractice,
        Icons.check_circle_outline,
      ),
      ReceiveVerdict.reviewRecorded => (
        s.learnReviewRecorded,
        Icons.check_circle_outline,
      ),
      ReceiveVerdict.unlocked => (
        s.learnLessonUnlocked(unlockedChar ?? ''),
        Icons.lock_open,
      ),
      ReceiveVerdict.courseComplete => (
        s.learnVerdictCourseComplete,
        Icons.emoji_events_outlined,
      ),
      ReceiveVerdict.tooShort => (
        s.learnVerdictTooShort(
          outcome.score.totalChars,
          course.minCharsPerSession,
        ),
        Icons.hourglass_bottom,
      ),
      ReceiveVerdict.belowAccuracy => (
        s.learnLessonNotPassed,
        Icons.trending_up,
      ),
      ReceiveVerdict.newSymbolsUncovered => (
        s.learnVerdictUncovered(
          course
              .uncoveredNewChars(outcome.score, lesson ?? 1)
              .join(' ')
              .ifEmpty(newChars.join(' ')),
        ),
        Icons.hearing,
      ),
      ReceiveVerdict.newSymbolsBelowPass => (
        s.learnVerdictNewSymbolWeak(
          course
              .weakNewChars(outcome.score, lesson ?? 1)
              .join(' ')
              .ifEmpty(newChars.join(' ')),
        ),
        Icons.trending_up,
      ),
    };
  }

  String? _explanation(S s, ReceiveVerdict verdict) {
    final lesson = outcome.attemptedLesson ?? 1;
    final required = course.isValidLesson(lesson)
        ? course.requiredNewCharAttempts(lesson)
        : course.minNewCharAttempts;
    return switch (verdict) {
      ReceiveVerdict.assisted => s.learnVerdictAssistedHint,
      ReceiveVerdict.practice when session.conditions == null =>
        s.learnVerdictPracticeHint,
      ReceiveVerdict.tooShort => s.learnVerdictTooShortHint(
        course.minCharsPerSession,
      ),
      ReceiveVerdict.belowAccuracy => s.learnVerdictBelowAccuracyHint,
      ReceiveVerdict.newSymbolsUncovered => s.learnVerdictUncoveredHint(
        required,
      ),
      ReceiveVerdict.newSymbolsBelowPass => s.learnVerdictNewSymbolWeakHint,
      _ => null,
    };
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
