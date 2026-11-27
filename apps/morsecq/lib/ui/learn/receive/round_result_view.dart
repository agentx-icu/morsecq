import 'package:flutter/material.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import 'shorthand_meanings.dart';
import 'word_meanings.dart';

/// Shows one answered round: the sent text against the copy, column by
/// column from the alignment, with misses and substitutions highlighted.
/// Word meanings and CW shorthand definitions follow the submitted copy,
/// so the vocabulary is explained without revealing the answer first.
class RoundResultView extends StatelessWidget {
  const RoundResultView({
    super.key,
    required this.round,
    this.kind,
    this.onReplaySymbol,
  });

  final ReceiveRound round;
  final ReceiveDrillKind? kind;
  final ValueChanged<String>? onReplaySymbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    final score = round.score;
    final differences = {
      for (final p in score.alignment)
        if (!p.isMatch) (p.target, p.answer),
    };
    final headline = score.isPerfect
        ? s.learnRoundPerfect
        : s.learnRoundScore(score.correctChars, score.totalChars);
    final locale = Localizations.localeOf(context);
    final meanings = kind == ReceiveDrillKind.words
        ? wordMeanings(round.drill.text, locale)
        : kShorthandDrillKinds.contains(kind)
        ? shorthandMeanings(round.drill.text, locale)
        : const <(String, String)>[];
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
        if (differences.isNotEmpty) ...[
          const SizedBox(height: 12),
          _LabelledRow(
            label: s.learnRoundDifferences,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (target, answer) in differences)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _description(
                            s,
                            AlignedPair(target: target, answer: answer),
                          ),
                        ),
                        if (onReplaySymbol case final replay?)
                          for (final symbol in [
                            target,
                            answer,
                          ].whereType<String>())
                            TextButton.icon(
                              onPressed: () => replay(symbol),
                              icon: const Icon(Icons.volume_up_outlined),
                              label: Text(s.learnRoundReplaySymbol(symbol)),
                            ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (meanings.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          _LabelledRow(
            label: s.learnMeaningsTitle,
            child: Column(
              key: const ValueKey('round-meanings'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final (word, meaning) in meanings)
                  Text('$word — $meaning', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

String _description(S s, AlignedPair pair) => switch (pair.op) {
  AlignmentOp.match => s.learnRoundCorrect(pair.target!),
  AlignmentOp.insertion => s.learnRoundExtra(pair.answer!),
  AlignmentOp.deletion => s.learnConfusedMissed(pair.target!),
  AlignmentOp.substitution => s.learnConfusedAs(pair.target!, pair.answer!),
};

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
    final scaler = MediaQuery.textScalerOf(context);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: <Widget>[
        for (final pair in alignment)
          Semantics(
            label: _description(context.s, pair),
            excludeSemantics: true,
            child: _cell(
              pair,
              style,
              scheme,
              width: cellWidth(pair, style, scaler),
            ),
          ),
      ],
    );
  }

  /// Width of the column for [pair], the same on the target and the answer
  /// row: wide enough for either side, so both rows wrap at the same places
  /// and each copied symbol sits under the one that was sent.
  static double cellWidth(
    AlignedPair pair,
    TextStyle? style,
    TextScaler scaler,
  ) {
    var widest = 0.0;
    for (final text in <String>[pair.target ?? '·', pair.answer ?? '·']) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      if (painter.width > widest) {
        widest = painter.width;
      }
      painter.dispose();
    }
    return widest + 12 < 32 ? 32 : widest + 12;
  }

  Widget _cell(
    AlignedPair pair,
    TextStyle? style,
    ColorScheme scheme, {
    required double width,
  }) {
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
        background = symbol == null ? scheme.surface : scheme.errorContainer;
        foreground = symbol == null
            ? scheme.onSurfaceVariant
            : scheme.onErrorContainer;
    }
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 36),
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
