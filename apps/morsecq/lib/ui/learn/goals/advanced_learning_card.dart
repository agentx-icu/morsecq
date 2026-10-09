import 'package:flutter/material.dart';
import '../../../i18n/l10n_extension.dart';
import '../../../training/training_controller.dart';
import '../comprehension/listening_comprehension_screen.dart';
import '../learn_playback.dart';
import '../mistakes/mistake_notebook_screen.dart';
import 'goal_labels.dart';
import 'goal_route_screen.dart';

/// Persistent entry points shown in every appearance and device layout.
class AdvancedLearningCard extends StatelessWidget {
  const AdvancedLearningCard({
    super.key,
    required this.controller,
    required this.playback,
  });
  final TrainingController controller;
  final LearnPlaybackFactory playback;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    void open(Widget screen) => Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => screen));
    return Card(
      child: Column(
        children: [
          ListTile(
            key: const ValueKey('learn-goal-route'),
            leading: const Icon(Icons.route_outlined),
            title: Text(s.goalsTitle),
            subtitle: Text(goalLabel(s, controller.progress.learningGoal)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => open(
              GoalRouteScreen(controller: controller, playback: playback),
            ),
          ),
          ListTile(
            key: const ValueKey('learn-comprehension'),
            leading: const Icon(Icons.hearing_outlined),
            title: Text(s.comprehensionTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => open(
              ListeningComprehensionScreen(
                controller: controller,
                playback: playback,
              ),
            ),
          ),
          ListTile(
            key: const ValueKey('learn-mistakes'),
            leading: const Icon(Icons.history_edu_outlined),
            title: Text(s.mistakesTitle),
            trailing: Text(
              '${controller.progress.mistakeNotebook.pending.length}',
            ),
            onTap: () => open(
              MistakeNotebookScreen(controller: controller, playback: playback),
            ),
          ),
        ],
      ),
    );
  }
}
