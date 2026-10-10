import 'package:flutter/material.dart';

import '../../i18n/l10n_extension.dart';
import '../common/feedback.dart';

/// Plain-language explanations of the jargon the Learn tab cannot avoid
/// (Koch, WPM, Farnsworth, QSO, RST / 73). The professional terms stay in
/// the UI; this says what they mean.
Future<void> showLearnGlossary(BuildContext context) {
  final s = context.s;
  return showDialog<void>(
    context: context,
    builder: (context) => ScrollingAlertDialog(
      title: Text(s.learnGlossaryTitle),
      content: Column(
        key: const ValueKey('learn-glossary'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final text in <String>[
            s.glossaryKoch,
            s.glossaryWpm,
            s.glossaryFarnsworth,
            s.glossaryQso,
            s.glossaryRst,
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(text),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.learnDone),
        ),
      ],
    ),
  );
}

/// The help icon that opens [showLearnGlossary].
class LearnGlossaryButton extends StatelessWidget {
  const LearnGlossaryButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    key: const ValueKey('learn-glossary-button'),
    tooltip: context.s.learnGlossaryTitle,
    icon: const Icon(Icons.help_outline),
    onPressed: () => showLearnGlossary(context),
  );
}
