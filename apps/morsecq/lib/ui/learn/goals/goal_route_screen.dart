import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';
import '../../../i18n/l10n_extension.dart';
import '../../../training/training_controller.dart';
import '../../common/app_bar_title.dart';
import '../../common/feedback.dart';
import '../../common/field_label.dart';
import '../learn_playback.dart';
import 'goal_labels.dart';
import 'goal_practice_launcher.dart';

class GoalRouteScreen extends StatefulWidget {
  const GoalRouteScreen({
    super.key,
    required this.controller,
    required this.playback,
  });
  final TrainingController controller;
  final LearnPlaybackFactory playback;
  @override
  State<GoalRouteScreen> createState() => _GoalRouteScreenState();
}

class _GoalRouteScreenState extends State<GoalRouteScreen> {
  bool _saving = false;
  Future<void> _select(LearningGoal? goal) async {
    if (goal == null || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.controller.setLearningGoal(goal);
    } on Object {
      if (mounted) showSnack(context, context.s.learnProgressSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: AppBarTitle(context.s.goalsTitle)),
    body: SafeArea(
      // Side notches in landscape; the home indicator at the end.
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final c = widget.controller;
          final route = c.learningRoute;
          final s = context.s;
          final next = route.next;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<LearningGoal>(
                key: const ValueKey('goal-selector'),
                initialValue: c.progress.learningGoal,
                isExpanded: true,
                // Items size to their wrapped labels (long languages,
                // large text) instead of a fixed one-line height.
                itemHeight: null,
                decoration: InputDecoration(label: FieldLabel(s.goalsTitle)),
                items: [
                  for (final goal in LearningGoal.values)
                    DropdownMenuItem(
                      value: goal,
                      child: Text(goalLabel(s, goal)),
                    ),
                ],
                onChanged: _saving ? null : _select,
              ),
              const SizedBox(height: 16),
              Text(s.goalsExplanation),
              const SizedBox(height: 12),
              if (!c.isCourseComplete) Text(s.goalsBeginner),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: route.passedCount / route.milestones.length,
              ),
              const SizedBox(height: 8),
              Text('${route.passedCount} / ${route.milestones.length}'),
              const SizedBox(height: 12),
              if (next != null) ...[
                Text(
                  '${skillLabel(s, next.skill)} · ${s.learnWpmValue(next.wpm.toString())}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: const ValueKey('goal-next-practice'),
                  onPressed: _saving
                      ? null
                      : () =>
                            openGoalPractice(context, c, widget.playback, next),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(s.goalsPractice),
                ),
              ] else
                Text(s.goalsComplete),
              const SizedBox(height: 16),
              for (final milestone in route.milestones)
                ListTile(
                  key: ValueKey(
                    'goal-milestone-${milestone.wpm}-${milestone.skill.name}',
                  ),
                  leading: Icon(
                    milestone.passed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(skillLabel(s, milestone.skill)),
                  subtitle: Text(s.learnWpmValue(milestone.wpm.toString())),
                  trailing: Text('${milestone.attempts.clamp(0, 2)} / 2'),
                  onTap: () =>
                      openGoalPractice(context, c, widget.playback, milestone),
                ),
            ],
          );
        },
      ),
    ),
  );
}
