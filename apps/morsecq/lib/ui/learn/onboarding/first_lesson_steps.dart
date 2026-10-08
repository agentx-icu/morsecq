import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';

import '../../../i18n/l10n_extension.dart';

/// One step of the first lesson: counter, title, body and content.
class FirstLessonStep extends StatelessWidget {
  const FirstLessonStep({
    super.key,
    required this.index,
    required this.total,
    required this.title,
    required this.body,
    required this.children,
  });

  final int index;
  final int total;
  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          context.s.firstLessonStep(index, total),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(body, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}

/// A big tappable tile that plays one sound: a dit, a dah, or a symbol with
/// its pattern as support for the ear.
class SoundTile extends StatelessWidget {
  const SoundTile({
    super.key,
    required this.label,
    required this.onPlay,
    this.pattern,
    this.playing = false,
  });

  final String label;
  final String? pattern;
  final bool playing;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        key: ValueKey<String>('sound-$label'),
        onTap: onPlay,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Icon(
                  playing ? Icons.volume_up : Icons.play_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(label, style: theme.textTheme.titleLarge),
                      if (pattern != null)
                        Text(
                          pattern!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The two answer buttons of the K / M trials, large enough for a thumb.
class TrialButtons extends StatelessWidget {
  const TrialButtons({
    super.key,
    required this.choices,
    required this.onAnswer,
    this.enabled = true,
  });

  final List<String> choices;
  final bool enabled;
  final void Function(String answer) onAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        for (final (i, c) in choices.indexed) ...<Widget>[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: FilledButton.tonal(
              key: ValueKey<String>('trial-$c'),
              onPressed: enabled ? () => onAnswer(c) : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(88),
                textStyle: theme.textTheme.displaySmall,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(c),
                  Text(
                    MorseEncoder.toPattern(c),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Shown when the learner heard nothing: tips plus the other modalities,
/// switchable right here.
class NoSoundCard extends StatelessWidget {
  const NoSoundCard({
    super.key,
    required this.flash,
    required this.haptic,
    required this.showHaptic,
    required this.onFlash,
    required this.onHaptic,
  });

  final bool flash;
  final bool haptic;

  /// Vibration exists on phones only.
  final bool showHaptic;
  final ValueChanged<bool> onFlash;
  final ValueChanged<bool> onHaptic;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    return Card(
      key: const ValueKey('no-sound-card'),
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.firstLessonNoSoundTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(s.firstLessonNoSoundBody, style: theme.textTheme.bodyMedium),
            SwitchListTile(
              key: const ValueKey('no-sound-flash'),
              contentPadding: EdgeInsets.zero,
              title: Text(s.firstLessonUseFlash),
              value: flash,
              onChanged: onFlash,
            ),
            if (showHaptic)
              SwitchListTile(
                key: const ValueKey('no-sound-haptic'),
                contentPadding: EdgeInsets.zero,
                title: Text(s.firstLessonUseVibration),
                value: haptic,
                onChanged: onHaptic,
              ),
          ],
        ),
      ),
    );
  }
}

/// The last step: result of the trials and the three ways on (short
/// practice, the lesson 1 challenge, sending) with first-use keying
/// guidance.
class FirstLessonNextPanel extends StatelessWidget {
  const FirstLessonNextPanel({
    super.key,
    required this.correct,
    required this.total,
    required this.lesson,
    required this.challengeChars,
    required this.nextChar,
    required this.onGuided,
    required this.onChallenge,
    required this.onSend,
    required this.onDone,
    this.onCompare,
  });

  final int correct;
  final int total;

  /// The lesson the challenge button starts (the learner's current one:
  /// the first lesson can be replayed later) and its symbol budget.
  final int lesson;
  final int challengeChars;

  /// The symbol that challenge unlocks; null on the last lesson, where
  /// passing completes the course instead.
  final String? nextChar;
  final VoidCallback onGuided;
  final VoidCallback onChallenge;
  final VoidCallback onSend;
  final VoidCallback onDone;
  final VoidCallback? onCompare;

  /// Total steps of the first lesson (this is the last one).
  static const int stepCount = 5;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final big = FilledButton.styleFrom(minimumSize: const Size.fromHeight(52));
    return FirstLessonStep(
      index: stepCount,
      total: stepCount,
      title: s.firstLessonNextTitle,
      body: s.firstLessonNextBody(correct, total),
      children: <Widget>[
        Text(
          correct == 0
              ? s.firstLessonZeroHint
              : correct < total
              ? s.firstLessonPartialHint
              : s.firstLessonPerfectHint,
        ),
        const SizedBox(height: 12),
        if (correct < total && onCompare != null) ...[
          OutlinedButton.icon(
            key: const ValueKey('next-contrast'),
            onPressed: onCompare,
            icon: const Icon(Icons.compare_arrows),
            label: Text(s.learnCompareWith('K', 'M')),
          ),
          const SizedBox(height: 12),
        ],
        FilledButton.icon(
          key: const ValueKey('next-guided'),
          onPressed: onGuided,
          icon: const Icon(Icons.bolt),
          label: Text(s.firstLessonNextGuided),
          style: big,
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          key: const ValueKey('next-challenge'),
          onPressed: onChallenge,
          icon: const Icon(Icons.school_outlined),
          label: Text(
            nextChar == null
                ? s.firstLessonNextChallengeLast(lesson, challengeChars)
                : s.firstLessonNextChallenge(lesson, challengeChars, nextChar!),
          ),
          style: big,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('next-send'),
          onPressed: onSend,
          icon: const Icon(Icons.touch_app_outlined),
          label: Text(s.firstLessonNextSend),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        const SizedBox(height: 12),
        Text(s.firstLessonSendGuide, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        Text(
          s.firstLessonReplayAnytime,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          key: const ValueKey('first-lesson-done'),
          onPressed: onDone,
          child: Text(s.learnDone),
        ),
      ],
    );
  }
}
