import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/guided_send.dart';
import 'send_tips.dart';

/// A model first, then the operator's turn. Only a complete model unlocks it.
class SendGuideCard extends StatelessWidget {
  const SendGuideCard({
    super.key,
    required this.stage,
    required this.heard,
    required this.playing,
    required this.onHear,
  });

  final GuidedSendStage stage;
  final bool heard;
  final bool playing;
  final VoidCallback? onHear;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.sendGuideTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              s.sendGuideStep(stage.index + 1, GuidedSendStage.values.length),
            ),
            const SizedBox(height: 8),
            if (playing)
              Text(s.sendGuideListening)
            else if (heard)
              Text(s.sendGuideTry),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey('send-guide-hear'),
              onPressed: playing ? null : onHear,
              icon: const Icon(Icons.hearing),
              label: Text(s.sendGuideHear),
            ),
          ],
        ),
      ),
    );
  }
}

/// One actionable rhythm tip takes precedence over the detailed diagnostics.
class SendGuideResult extends StatelessWidget {
  const SendGuideResult({
    super.key,
    required this.stage,
    required this.diagnostics,
  });

  final GuidedSendStage stage;
  final SendDiagnostics diagnostics;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final passed = diagnostics.score.strictAccuracy == 1;
    final issues = diagnostics.issues.toList()
      ..sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return Card(
      key: const ValueKey('send-guide-result'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              passed
                  ? stage.next == null
                        ? s.sendGuideComplete
                        : s.sendGuidePassed
                  : s.sendGuideRetry,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!passed || issues.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                issues.isEmpty ? s.sendGuideRhythm : tipFor(s, issues.first),
                key: const ValueKey('send-guide-rhythm-tip'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
