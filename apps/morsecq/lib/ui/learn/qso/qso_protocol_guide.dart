import 'package:flutter/material.dart';

import '../../../i18n/l10n_extension.dart';
import '../../common/app_bar_title.dart';
import '../../responsive.dart';
import '../learn_platform.dart';

/// A reference route that leaves the setup or an active exchange in place.
class QsoProtocolGuideButton extends StatelessWidget {
  const QsoProtocolGuideButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.s.learnQsoHowTitle,
    icon: const Icon(Icons.menu_book_outlined),
    onPressed: () => Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const _QsoProtocolGuide())),
  );
}

class _QsoProtocolGuide extends StatelessWidget {
  const _QsoProtocolGuide();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final sampleLabels = [
      (s.learnQsoStageCallConfirm, 'R0EST DE T0EST K'),
      (s.learnQsoSignalReport, 'R UR RST 599 K'),
      (s.learnQsoStageClosing, 'R TU 73 R0EST DE T0EST <SK>'),
    ];
    return Scaffold(
      appBar: AppBar(title: AppBarTitle(s.learnQsoHowTitle)),
      body: SafeArea(
        child: AdaptivePanelBody(
          breakpoint: kLearnTwoColumnMinWidth,
          leading: [
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      s.learnQsoShortExchange,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  for (final (i, (label, example)) in sampleLabels.indexed)
                    ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(label),
                      subtitle: SelectableText(
                        example,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          trailing: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(s.learnQsoHowBody),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
