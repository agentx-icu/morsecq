import 'package:flutter/material.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/receive_session.dart';
import 'first_lesson_steps.dart';

/// One K/M answer, feedback and pace choice. Pace stays fixed once an
/// answer was submitted so a stored attempt always means one speed.
class FirstLessonTrialView extends StatelessWidget {
  const FirstLessonTrialView({
    super.key,
    required this.session,
    required this.round,
    required this.choices,
    required this.ready,
    required this.recording,
    required this.beginnerPace,
    required this.onAnswer,
    required this.onReplay,
    required this.onCompare,
    required this.onNext,
    required this.onPace,
  });

  final ReceiveSession session;
  final ReceiveRound? round;
  final List<String> choices;
  final bool ready;
  final bool recording;
  final bool beginnerPace;
  final ValueChanged<String> onAnswer;
  final VoidCallback onReplay;
  final ValueChanged<String> onCompare;
  final VoidCallback onNext;
  final ValueChanged<bool> onPace;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final answered = round;
    final total = session.charBudget;
    final current = (session.roundCount + (answered == null ? 1 : 0)).clamp(
      1,
      total,
    );
    return FirstLessonStep(
      index: 4,
      total: 5,
      title: s.firstLessonTrialsTitle,
      body: s.firstLessonTrialsBody,
      children: <Widget>[
        Text(
          s.firstLessonTrialRound(current, total),
          style: theme.textTheme.labelLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (answered == null) ...[
          TrialButtons(choices: choices, enabled: ready, onAnswer: onAnswer),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('trial-replay'),
            onPressed: ready ? onReplay : null,
            icon: const Icon(Icons.replay),
            label: Text(s.learnReplay),
          ),
        ] else ...[
          Text(
            answered.score.isPerfect
                ? s.firstLessonTrialCorrect(answered.drill.text)
                : s.firstLessonTrialWrong(answered.drill.text, answered.answer),
            key: const ValueKey('trial-feedback'),
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (!answered.score.isPerfect)
            OutlinedButton.icon(
              key: const ValueKey('trial-compare'),
              onPressed: () =>
                  onCompare('${answered.drill.text} ${answered.answer}'),
              icon: const Icon(Icons.compare_arrows),
              label: Text(
                s.learnCompareWith(answered.drill.text, answered.answer),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            key: const ValueKey('trial-next'),
            onPressed: recording ? null : onNext,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              session.isComplete
                  ? s.firstLessonContinue
                  : s.firstLessonTrialNext,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SwitchListTile(
          key: const ValueKey('beginner-pace'),
          contentPadding: EdgeInsets.zero,
          title: Text(s.firstLessonTooFast, style: theme.textTheme.bodySmall),
          value: beginnerPace,
          onChanged: ready && session.roundCount == 0 ? onPace : null,
        ),
        if (session.roundCount > 0)
          Text(s.firstLessonPaceLocked, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
