import 'package:flutter/material.dart';
import 'package:morse_session/morse_session.dart';

import '../../../i18n/l10n_extension.dart';
import '../../responsive.dart';
import '../learn_footer.dart';
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
    final hint = showHint
        ? SendFirstUseHint(
            mode: effectiveMode ?? mode,
            onDismiss: onDismissHint,
          )
        : null;
    final modePicker = guide == null
        ? selector
        : ExpansionTile(title: Text(s.learnKeyer), children: [selector]);
    final input = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canKey) keying,
        if (canKey && hasPhysicalKeyboardByDefault) ...[
          const SizedBox(height: 8),
          KeyerLegend(mode: effectiveMode ?? mode),
        ],
      ],
    );
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              return AdaptivePanelBody(
                breakpoint: 900,
                leading: [
                  ?guide,
                  if (!wide) ?hint,
                  if (wide) _readoutCard(SendReadout.target),
                  modePicker,
                  if (!wide) _readoutCard(SendReadout.all),
                  if (!wide && guide != null && canKey)
                    RevealOnAppear(child: input)
                  else
                    input,
                ],
                trailing: [
                  if (wide) _readoutCard(SendReadout.feedback),
                  if (wide) ?hint,
                ],
              );
            },
          ),
        ),
        LearnFooter(child: _actions(context)),
      ],
    );
  }

  Widget _readoutCard(SendReadout readout) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: SendLiveView(
        session: session,
        hideTarget: hideTarget,
        readout: readout,
      ),
    ),
  );

  Widget _actions(BuildContext context) {
    final s = context.s;
    return Row(
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
    );
  }
}

/// Scrolls [child] fully into view once, right after it first appears.
class RevealOnAppear extends StatefulWidget {
  const RevealOnAppear({super.key, required this.child});

  final Widget child;

  @override
  State<RevealOnAppear> createState() => _RevealOnAppearState();
}

class _RevealOnAppearState extends State<RevealOnAppear> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
