import 'package:flutter/material.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/training_controller.dart';

String guidedLevelLabel(S s, GuidedLevel level) => switch (level) {
  GuidedLevel.single => s.learnGuidedSingle,
  GuidedLevel.short => s.learnGuidedShort,
  GuidedLevel.groups => s.learnGuidedGroups,
};

/// Every stage is reachable; the recommendation comes from actual copying,
/// rather than making the learner search for a group-size setting.
Future<GuidedLevel?> showGuidedPracticeSheet(
  BuildContext context,
  GuidedLevel recommended,
) => showModalBottomSheet<GuidedLevel>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) {
    final s = context.s;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.learnGuidedPractice,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(s.learnGuidedProgressHint),
          const SizedBox(height: 12),
          for (final level in GuidedLevel.values)
            ListTile(
              key: ValueKey('guided-level-${level.name}'),
              leading: Icon(
                level == recommended
                    ? Icons.arrow_circle_right_outlined
                    : Icons.hearing,
              ),
              title: Text(guidedLevelLabel(s, level)),
              subtitle: level == recommended
                  ? Text(s.learnGuidedRecommended)
                  : null,
              onTap: () => Navigator.of(context).pop(level),
            ),
        ],
      ),
    );
  },
);
