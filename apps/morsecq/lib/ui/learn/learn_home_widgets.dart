import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';

import '../../i18n/l10n_extension.dart';
import '../../training/training_controller.dart';
import '../appearance/radio_mascot.dart';
import '../appearance/style_tokens.dart';
import '../appearance/ui_style.dart';
import 'styled_goal_card.dart';

/// Koch position: lesson n / total, the learned set with the newest symbol
/// highlighted.
class LessonCard extends StatelessWidget {
  const LessonCard({super.key, required this.controller, this.onContinue});

  final TrainingController controller;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.s;
    final learned = controller.learnedChars;
    final newest = controller.newestChar;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.learnLessonCardTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (StyleTokens.of(context)?.style == UiStyle.cartoon)
                  const RadioMascot(size: 48),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              s.learnLessonOf(controller.currentLesson, controller.lessonCount),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: controller.lessonCount == 0
                  ? 0
                  : controller.currentLesson / controller.lessonCount,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 12),
            Text(
              s.learnCharsLearned(learned.length),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  for (final c in learned)
                    LearnedCharChip(
                      char: c,
                      isNewest: c == newest,
                      accuracy: controller.accuracyOf(c),
                      width: math.max(
                        ((constraints.maxWidth - 24) / 5).clamp(36.0, 52.0),
                        // Large accessibility text can wrap to more rows;
                        // reserve enough space for a glyph and its padding.
                        MediaQuery.textScalerOf(context).scale(
                              theme.textTheme.titleMedium?.fontSize ?? 16,
                            ) +
                            20,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.isCourseComplete
                  ? s.learnCourseComplete
                  : s.learnNewestCharIs(newest),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (onContinue != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(s.learnContinueLesson),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One learned symbol. The newest is filled with the primary colour; the
/// others tint by lifetime accuracy so weak symbols stand out at a glance.
class LearnedCharChip extends StatelessWidget {
  const LearnedCharChip({
    super.key,
    required this.char,
    required this.isNewest,
    this.accuracy,
    this.width = 52,
  });

  final String char;
  final bool isNewest;
  final double? accuracy;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = StyleTokens.of(context);
    final styled = tokens != null && tokens.style != UiStyle.classic;
    final Color background;
    final Color foreground;
    if (isNewest) {
      background = styled ? tokens.newest : scheme.primary;
      foreground = styled ? tokens.onNewest : scheme.onPrimary;
    } else if (accuracy != null && accuracy! < 0.9) {
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
    } else {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurface;
    }
    return Semantics(
      label: isNewest ? context.s.learnCharNewSemantics(char) : char,
      child: Container(
        width: styled ? width : null,
        constraints: BoxConstraints(minWidth: 36, minHeight: styled ? 68 : 36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(tokens?.chipRadius ?? 8),
          border: isNewest ? Border.all(color: scheme.primary, width: 2) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              char,
              style: theme.textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: isNewest ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (styled) ...[
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  MorseEncoder.toPattern(char),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
    final styled = tokens != null && tokens.style != UiStyle.classic;
    if (tokens?.style == UiStyle.paper || tokens?.style == UiStyle.radio) {
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

/// A circular progress ring with a centred child.
class GoalRing extends StatelessWidget {
  const GoalRing({
    super.key,
    required this.fraction,
    this.size = 80,
    this.strokeWidth = 8,
    this.child,
  });

  final double fraction;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          track: scheme.surfaceContainerHighest,
          fill: fraction >= 1 ? scheme.tertiary : scheme.primary,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.strokeWidth,
    required this.track,
    required this.fill,
  });

  final double fraction;
  final double strokeWidth;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(strokeWidth / 2);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(inset, 0, 2 * math.pi, false, trackPaint);
    if (fraction > 0) {
      canvas.drawArc(
        inset,
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.strokeWidth != strokeWidth ||
      old.track != track ||
      old.fill != fill;
}

/// The four entry points into practice.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.dueCount,
    required this.onContinueLesson,
    required this.onReceivePractice,
    required this.onSendPractice,
    required this.onReview,
    this.showContinue = true,
  });

  final int dueCount;
  final VoidCallback onContinueLesson;
  final VoidCallback onReceivePractice;
  final VoidCallback onSendPractice;
  final VoidCallback onReview;
  final bool showContinue;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showContinue)
          FilledButton.icon(
            onPressed: onContinueLesson,
            icon: const Icon(Icons.play_arrow),
            label: Text(s.learnContinueLesson),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
        if (showContinue) const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.hearing,
          label: s.learnReceivePractice,
          onTap: onReceivePractice,
          color: StyleTokens.of(context)?.receiveSurface,
        ),
        _ActionTile(
          icon: Icons.touch_app_outlined,
          label: s.learnSendPractice,
          onTap: onSendPractice,
          color: StyleTokens.of(context)?.sendSurface,
        ),
        _ActionTile(
          icon: Icons.replay,
          label: s.learnReviewDue,
          trailing: s.learnReviewDueCount(dueCount),
          onTap: onReview,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.color,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        minTileHeight: 56,
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label),
        trailing: trailing == null
            ? const Icon(Icons.chevron_right)
            : Text(trailing!, style: theme.textTheme.labelLarge),
        onTap: onTap,
      ),
    );
  }
}
