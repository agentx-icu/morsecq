import 'package:flutter/material.dart';

import '../../i18n/l10n_extension.dart';
import '../../training/training_controller.dart';
import '../appearance/style_tokens.dart';
import '../appearance/ui_style.dart';
import 'goal_ring.dart';
import 'styled_goal_card.dart';

export 'goal_ring.dart' show GoalRing;
export 'lesson_card.dart' show LearnedCharChip, LessonCard;
export 'lesson_card_extras.dart';
export 'quick_actions.dart';

/// Daily goal ring plus streak.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key, required this.controller});

  final TrainingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.s;
    final streak = controller.streak;
    final tokens = StyleTokens.of(context);
    final styled = tokens != null;
    if (tokens?.style == UiStyle.classic || tokens?.style == UiStyle.radio) {
      return StyledGoalCard(controller: controller);
    }
    return Card(
      color: tokens?.style == UiStyle.cartoon ? tokens?.receiveSurface : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            GoalRing(
              fraction: controller.dailyGoalFraction,
              size: styled ? 72 : 88,
              child: Text(
                s.learnAccuracyPercent(
                  (controller.dailyGoalFraction * 100).round(),
                ),
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    s.learnDailyGoalTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.learnDailyGoalProgress(
                      controller.charsToday,
                      controller.dailyGoal,
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                  if (controller.dailyGoalMet)
                    Text(
                      s.learnDailyGoalMet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.local_fire_department,
                        size: 20,
                        color: streak > 0 ? scheme.tertiary : scheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          streak > 0
                              ? s.learnStreakDays(streak)
                              : s.learnNoStreak,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
