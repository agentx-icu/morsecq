import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/receive_session.dart';

/// Shows one answered round: the sent text against the copy, column by
/// column from the alignment, with misses and substitutions highlighted.
class RoundResultView extends StatelessWidget {
  const RoundResultView({super.key, required this.round});

  final ReceiveRound round;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    final score = round.score;
    final headline = score.isPerfect
        ? s.learnRoundPerfect
        : s.learnRoundScore(score.correctChars, score.totalChars);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          headline,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _LabelledRow(
          label: s.learnSent,
          child: AlignedSymbols(alignment: score.alignment, showTarget: true),
        ),
        const SizedBox(height: 8),
        _LabelledRow(
          label: s.learnYourCopy,
          child: AlignedSymbols(alignment: score.alignment, showTarget: false),
        ),
      ],
    );
  }
}

/// One row of aligned symbols: target or answer side of each column.
///
/// Colours: match = plain, substitution = error container, missing symbol
/// (deletion on the answer side / insertion on the target side) = a dotted
/// placeholder.
class AlignedSymbols extends StatelessWidget {
  const AlignedSymbols({
    super.key,
    required this.alignment,
    required this.showTarget,
  });

  final List<AlignedPair> alignment;
  final bool showTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = theme.textTheme.titleLarge?.copyWith(
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: <Widget>[
        for (final pair in alignment)
          _cell(pair, style, scheme),
      ],
    );
  }

  Widget _cell(AlignedPair pair, TextStyle? style, ColorScheme scheme) {
    final symbol = showTarget ? pair.target : pair.answer;
    final Color background;
    final Color foreground;
    switch (pair.op) {
      case AlignmentOp.match:
        background = scheme.surfaceContainerHighest;
        foreground = scheme.onSurface;
      case AlignmentOp.substitution:
        background = scheme.errorContainer;
        foreground = scheme.onErrorContainer;
      case AlignmentOp.deletion:
      case AlignmentOp.insertion:
        background = symbol == null
            ? scheme.surface
            : scheme.errorContainer;
        foreground = symbol == null
            ? scheme.onSurfaceVariant
            : scheme.onErrorContainer;
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: symbol == null
            ? Border.all(color: scheme.outlineVariant, width: 1)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(symbol ?? '·', style: style?.copyWith(color: foreground)),
    );
  }
}

class _LabelledRow extends StatelessWidget {
  const _LabelledRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
