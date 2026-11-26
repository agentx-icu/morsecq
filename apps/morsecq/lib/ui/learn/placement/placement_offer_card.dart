import 'package:flutter/material.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/training_controller.dart';
import 'package:morse_trainer/morse_trainer.dart';

/// For a brand-new learner: the guided first lesson first (hear, dit / dah,
/// K / M), the level check second, and skipping straight to the lesson 1
/// challenge as the explicit third choice. Gone after the first session or
/// once the first lesson was done.
class PlacementOfferCard extends StatelessWidget {
  const PlacementOfferCard({
    super.key,
    required this.controller,
    required this.onStartHere,
    required this.onFromZero,
    required this.onCheckLevel,
  });

  final TrainingController controller;

  /// Opens the guided first lesson.
  final VoidCallback onStartHere;

  /// Skips the intro: the lesson 1 challenge.
  final VoidCallback onFromZero;
  final VoidCallback onCheckLevel;

  static bool shows(TrainingController c) =>
      c.learnerStage == LearnerStage.firstUse;

  @override
  Widget build(BuildContext context) {
    if (!shows(controller)) return const SizedBox.shrink();
    final s = context.s;
    final theme = Theme.of(context);
    final startCard = Card(
      key: const ValueKey('placement-offer'),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.flag_outlined, size: 28),
            const SizedBox(height: 8),
            Text(s.learnStartHereTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(s.learnStartHereBody, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('start-here'),
              onPressed: onStartHere,
              icon: const Icon(Icons.flag_outlined),
              label: Text(s.learnStartHere),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            Text(s.placementOfferTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(s.placementOfferBody, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton(
                  key: const ValueKey('placement-check'),
                  onPressed: onCheckLevel,
                  child: Text(s.placementCheckLevel),
                ),
                TextButton(
                  key: const ValueKey('placement-skip-intro'),
                  onPressed: onFromZero,
                  child: Text(s.placementFromZero),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 852) return startCard;
        final steps = [
          s.firstLessonHearTitle,
          s.firstLessonSoundsTitle,
          s.firstLessonWorkedTitle,
          s.firstLessonTrialsTitle,
          s.firstLessonNextTitle,
        ];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Expanded(flex: 3, child: startCard),
            Expanded(
              flex: 2,
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        s.firstLessonTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      for (final (index, title) in steps.indexed)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Text('${index + 1}'),
                          title: Text(title),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
