import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/training_settings.dart';

/// First-use keying guidance (pedagogy review): how to hold the control for
/// a dit and a dah and to pause between characters, worded for the keyer
/// the learner has selected. Shown until a send session was recorded or
/// the learner dismisses it; A / B differences stay in the settings help.
class SendFirstUseHint extends StatelessWidget {
  const SendFirstUseHint({
    super.key,
    required this.mode,
    required this.onDismiss,
  });

  final KeyerMode mode;
  final VoidCallback onDismiss;

  /// Whether [history] holds any recorded sending.
  static bool needed(List<SessionSummary> history) =>
      !history.any((s) => s.source == ExerciseSource.send);

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    return Card(
      key: const ValueKey('send-first-use'),
      color: theme.colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.sendFirstUseTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              mode.isPaddle ? s.sendFirstUsePaddles : s.sendFirstUseStraight,
              key: ValueKey<String>('send-first-use-${mode.name}'),
              style: theme.textTheme.bodySmall,
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onDismiss,
                child: Text(s.sendFirstUseDismiss),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
