import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';

import '../../i18n/l10n_extension.dart';
import 'telegraph_labels.dart';

/// "Interpret as Chinese telegraph code" (F13) for one message: every
/// whitespace-separated token in order — four-digit groups with all their
/// candidate characters (or an "unresolved" label), malformed digit runs
/// flagged, other text kept as written — with a mainland / Taiwan switch.
/// Local and read-only: the stored message never changes and nothing is
/// sent.
Future<void> showTelegraphInterpretation(BuildContext context, String text) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(child: TelegraphInterpretation(text: text)),
    );

class TelegraphInterpretation extends StatefulWidget {
  const TelegraphInterpretation({super.key, required this.text});

  final String text;

  @override
  State<TelegraphInterpretation> createState() =>
      _TelegraphInterpretationState();
}

class _TelegraphInterpretationState extends State<TelegraphInterpretation> {
  TelegraphCodebook _book = TelegraphCodebook.mainland;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final tokens = TelegraphGroups.parse(widget.text, codebook: _book);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(s.telegraphInterpretTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TelegraphCodebookPicker(
            value: _book,
            onChanged: (b) => setState(() => _book = b),
          ),
          const SizedBox(height: 8),
          Text(s.telegraphInterpretNote, style: theme.textTheme.bodySmall),
          const Divider(),
          for (final (i, t) in tokens.indexed)
            ListTile(
              key: ValueKey('telegraph-token-$i'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(
                width: 64,
                child: Text(
                  t.source,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              title: switch (t.kind) {
                TelegraphTokenKind.group when t.isUnresolved => Text(
                  s.telegraphUnresolved,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                TelegraphTokenKind.group => Text(
                  t.candidates.join(' / '),
                  style: theme.textTheme.headlineSmall,
                ),
                TelegraphTokenKind.malformedDigits => Text(
                  s.telegraphMalformed,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                TelegraphTokenKind.text => Text(s.telegraphNotCode),
              },
              subtitle: t.isAmbiguous ? Text(s.telegraphAmbiguous) : null,
            ),
        ],
      ),
    );
  }
}
