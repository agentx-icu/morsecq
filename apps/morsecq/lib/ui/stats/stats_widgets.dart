import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';

import 'stats_model.dart';
import 'stats_strings.dart';

/// Card wrapper every dashboard section uses: title, optional subtitle, body.
class StatsSection extends StatelessWidget {
  const StatsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// One headline number with a label above and a detail line below.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.icon,
  });

  final String label;
  final String value;
  final String? detail;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: '$label: $value${detail == null ? '' : ', $detail'}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.headlineSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (detail != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                detail!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Formats a duration as `Xh Ym`, `Ym` or `Zs` for the practice tile.
String formatPracticeDuration(Duration d) {
  if (d.inHours >= 1) {
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }
  if (d.inMinutes >= 1) {
    return '${d.inMinutes}m';
  }
  return '${d.inSeconds}s';
}

/// The overview tile grid: lesson, accuracy, practice, streak, daily goal.
class OverviewTiles extends StatelessWidget {
  const OverviewTiles({super.key, required this.snapshot});

  final StatsSnapshot snapshot;

  static String _acc(double? value) =>
      value == null ? StatsStrings.noData : StatsStrings.percent(value);

  @override
  Widget build(BuildContext context) {
    final s = snapshot;
    final tiles = <Widget>[
      StatTile(
        icon: Icons.school_outlined,
        label: StatsStrings.tileLesson,
        value: StatsStrings.lessonOf(s.currentLesson, s.lessonCount),
        detail: StatsStrings.charsLearned(s.learnedChars.length),
      ),
      StatTile(
        icon: Icons.track_changes_outlined,
        label: StatsStrings.tileAccuracy,
        value: _acc(s.accuracyLast7Days),
        detail:
            '${StatsStrings.accuracyLast7Days} / '
            '${_acc(s.accuracyAllTime)} ${StatsStrings.accuracyAllTime}',
      ),
      StatTile(
        icon: Icons.timer_outlined,
        label: StatsStrings.tilePractice,
        value: formatPracticeDuration(s.totalPracticeTime),
        detail:
            '${StatsStrings.charsCopied(s.totalChars)} / '
            '${StatsStrings.sessions(s.sessionCount)}',
      ),
      StatTile(
        icon: Icons.local_fire_department_outlined,
        label: StatsStrings.tileStreak,
        value: StatsStrings.days(s.currentStreak),
        detail: StatsStrings.bestStreak(s.bestStreak),
      ),
      StatTile(
        icon: Icons.flag_outlined,
        label: StatsStrings.tileDailyGoal,
        value: StatsStrings.goalProgress(s.charsToday, s.dailyGoal),
        detail: s.dailyGoalMet
            ? StatsStrings.goalMet
            : StatsStrings.goalRemaining(s.dailyGoal - s.charsToday),
      ),
    ];
    return StatsSection(
      title: StatsStrings.overviewTitle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 560
              ? 3
              : (constraints.maxWidth >= 340 ? 2 : 1);
          const gap = 8.0;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: <Widget>[
              for (final t in tiles) SizedBox(width: width, child: t),
            ],
          );
        },
      ),
    );
  }
}

/// Compact card the Learn home can embed: three numbers and an optional
/// "View statistics" action. Renders sensibly for a fresh identity too.
class StatsSummaryCard extends StatelessWidget {
  const StatsSummaryCard({
    super.key,
    required this.progress,
    this.course,
    this.now,
    this.onOpen,
  });

  final TrainerProgress progress;
  final KochCourse? course;

  /// Injected clock for tests; defaults to `DateTime.now()`.
  final DateTime? now;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = StatsSnapshot.from(progress, course: course, now: now);
    final accuracy = s.accuracyLast7Days ?? s.accuracyAllTime;
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      StatsStrings.summaryTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (onOpen != null)
                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 8),
              if (s.isEmpty)
                Text(StatsStrings.emptyTitle, style: theme.textTheme.bodyMedium)
              else
                Row(
                  children: <Widget>[
                    _SummaryStat(
                      label: StatsStrings.tileAccuracy,
                      value: accuracy == null
                          ? StatsStrings.noData
                          : StatsStrings.percent(accuracy),
                    ),
                    _SummaryStat(
                      label: StatsStrings.tileStreak,
                      value: StatsStrings.days(s.currentStreak),
                    ),
                    _SummaryStat(
                      label: StatsStrings.sessions(s.sessionCount),
                      value: '${s.sessionCount}',
                    ),
                  ],
                ),
              if (onOpen != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  StatsStrings.summaryOpen,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: theme.textTheme.titleLarge),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Shown for a fresh identity with no sessions in history.
class StatsEmptyState extends StatelessWidget {
  const StatsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.insights_outlined, size: 56, color: scheme.primary),
              const SizedBox(height: 16),
              Text(
                StatsStrings.emptyTitle,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                StatsStrings.emptyBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                StatsStrings.emptyCallToAction,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
