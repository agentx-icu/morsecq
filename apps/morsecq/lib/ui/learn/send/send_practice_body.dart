import 'package:flutter/material.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/send_session.dart';
import '../../../training/training_settings.dart';
import '../learn_platform.dart';
import 'keyer_legend.dart';
import 'send_first_use_hint.dart';
import 'send_live_view.dart';

/// The reusable touch/keyboard keying surface; the screen owns its keyer.
class SendPracticeBody extends StatelessWidget {
  const SendPracticeBody({
    super.key,
    required this.session,
    required this.mode,
    required this.onMode,
    required this.hideTarget,
    required this.keying,
    required this.onRestart,
    required this.onFinish,
    required this.showHint,
    required this.onDismissHint,
    this.guide,
    this.canKey = true,
    this.effectiveMode,
  });

  final SendSession session;
  final KeyerMode mode;
  final KeyerMode? effectiveMode;
  final ValueChanged<KeyerMode> onMode;
  final bool hideTarget;
  final Widget keying;
  final VoidCallback onRestart;
  final VoidCallback onFinish;
  final bool showHint;
  final VoidCallback onDismissHint;
  final Widget? guide;
  final bool canKey;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final selector = SegmentedButton<KeyerMode>(
      segments: [
        ButtonSegment(
          value: KeyerMode.straight,
          label: Text(s.learnKeyerStraight),
        ),
        ButtonSegment(
          value: KeyerMode.iambicA,
          label: Text(s.learnKeyerIambicA),
        ),
        ButtonSegment(
          value: KeyerMode.iambicB,
          label: Text(s.learnKeyerIambicB),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (modes) => onMode(modes.first),
      showSelectedIcon: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?guide,
        if (showHint)
          SendFirstUseHint(
            mode: effectiveMode ?? mode,
            onDismiss: onDismissHint,
          ),
        if (guide == null)
          selector
        else
          ExpansionTile(title: Text(s.learnKeyer), children: [selector]),
        const SizedBox(height: 16),
        SendLiveView(session: session, hideTarget: hideTarget),
        const SizedBox(height: 20),
        if (canKey) keying,
        if (canKey && hasPhysicalKeyboardByDefault) ...[
          const SizedBox(height: 8),
          KeyerLegend(mode: effectiveMode ?? mode),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh),
                label: Text(s.learnRestart),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<void>(
                stream: session.changes,
                builder: (context, _) => FilledButton.icon(
                  onPressed: canKey && session.hasInput ? onFinish : null,
                  icon: const Icon(Icons.check),
                  label: Text(s.learnDone),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
