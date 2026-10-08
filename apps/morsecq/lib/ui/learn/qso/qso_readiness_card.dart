import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';

/// Separates symbols never taught from taught symbols needing current
/// recognition, then meanings and an independent interactive exchange.
/// Every unmet condition remains visible during voluntary exploration.
class QsoReadinessCard extends StatelessWidget {
  const QsoReadinessCard({
    super.key,
    required this.readiness,
    required this.onHear,
    required this.onPractiseSymbols,
    required this.onPractiseShorthand,
    required this.onPractiseProtocol,
    required this.onPractiseExchange,
  });

  final QsoReadiness readiness;
  final void Function(String char) onHear;
  final VoidCallback? onPractiseSymbols;
  final VoidCallback? onPractiseShorthand;
  final VoidCallback onPractiseProtocol;
  final VoidCallback? onPractiseExchange;

  Widget _symbols(Iterable<String> symbols, String prefix) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final c in symbols)
        ActionChip(
          key: ValueKey('qso-$prefix-$c'),
          avatar: const Icon(Icons.volume_up_outlined, size: 18),
          label: Text('$c ${MorseEncoder.toPattern(c)}'),
          onPressed: () => onHear(c),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final level = readiness.level;
    return Card(
      key: ValueKey('qso-readiness-${level.name}'),
      color: readiness.isReady
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  readiness.isReady
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(switch (level) {
                    QsoReadinessLevel.symbols => s.learnQsoNotReadyTitle,
                    QsoReadinessLevel.consolidate => s.learnQsoConsolidateTitle,
                    QsoReadinessLevel.shorthand => s.learnQsoShorthandTitle,
                    QsoReadinessLevel.protocol => s.learnQsoProtocolTitle,
                    QsoReadinessLevel.exchange => s.learnQsoExchangeTitle,
                    QsoReadinessLevel.ready => s.learnQsoReadyTitle,
                  }, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            if (readiness.missing.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(s.learnQsoMissingBody, style: theme.textTheme.bodySmall),
              _symbols(readiness.missing, 'missing'),
            ],
            if (readiness.unmastered.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(s.learnQsoConsolidateHint, style: theme.textTheme.bodySmall),
              _symbols(readiness.unmastered, 'unmastered'),
              OutlinedButton.icon(
                key: const ValueKey('qso-practise-symbols'),
                onPressed: onPractiseSymbols,
                icon: const Icon(Icons.hearing),
                label: Text(s.learnQsoPractiseSymbols),
              ),
            ],
            if (!readiness.shorthandPractised) ...[
              const SizedBox(height: 12),
              Text(s.learnQsoShorthandHint, style: theme.textTheme.bodySmall),
              OutlinedButton.icon(
                key: const ValueKey('qso-practise-shorthand'),
                onPressed: onPractiseShorthand,
                icon: const Icon(Icons.short_text),
                label: Text(s.learnQsoPractiseShorthand),
              ),
            ],
            if (!readiness.protocolPractised) ...[
              const SizedBox(height: 12),
              Text(s.learnQsoProtocolHint, style: theme.textTheme.bodySmall),
              OutlinedButton.icon(
                key: const ValueKey('qso-practise-protocol'),
                onPressed: onPractiseProtocol,
                icon: const Icon(Icons.quiz_outlined),
                label: Text(s.learnQsoProtocolStart),
              ),
            ],
            if (!readiness.exchangePractised) ...[
              const SizedBox(height: 12),
              Text(
                s.learnQsoShortExchangeHint,
                style: theme.textTheme.bodySmall,
              ),
              OutlinedButton.icon(
                key: const ValueKey('qso-practise-exchange'),
                onPressed: onPractiseExchange,
                icon: const Icon(Icons.forum_outlined),
                label: Text(s.learnQsoShortExchange),
              ),
            ],
            if (readiness.isReady) ...[
              const SizedBox(height: 8),
              Text(s.learnQsoReadyHint, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            Text(s.learnQsoHowTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(s.learnQsoHowBody, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
