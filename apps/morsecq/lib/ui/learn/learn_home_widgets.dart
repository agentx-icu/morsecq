import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../i18n/l10n_extension.dart';
import '../../training/training_controller.dart';
import '../../training/training_settings.dart';
import '../appearance/radio_mascot.dart';
import '../appearance/style_tokens.dart';
import '../appearance/ui_style.dart';
import 'goal_ring.dart';
import 'learn_playback.dart';
import 'lesson_card_extras.dart';
import 'styled_goal_card.dart';

export 'goal_ring.dart' show GoalRing;
export 'lesson_card_extras.dart';
export 'quick_actions.dart';

/// Koch position: lesson n / total, the symbol set with honest states
/// (new, practising, mastered, weak, due), the newest symbol playable and
/// comparable with its neighbour, the stage goal, and the lesson challenge.
class LessonCard extends StatefulWidget {
  const LessonCard({
    super.key,
    required this.controller,
    this.onContinue,
    this.onGuided,
    this.playback,
  });

  final TrainingController controller;

  /// Starts the lesson challenge.
  final VoidCallback? onContinue;

  /// Starts a short guided session (beginner stages).
  final VoidCallback? onGuided;

  /// When given, chips and the new-symbol row play through it.
  final LearnPlaybackFactory? playback;

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool _expanded = false;
  LearnPlayback? _player;

  /// The settings [_player] was built from: a bundle is a settings snapshot
  /// and must be rebuilt once sound, flash, haptics or tone change.
  TrainingSettings? _playerSettings;
  Future<LearnPlayback>? _creating;

  TrainingController get controller => widget.controller;
  VoidCallback? get onContinue => widget.onContinue;

  @override
  void dispose() {
    unawaited(_player?.dispose());
    super.dispose();
  }

  /// Plays [text] at the learner's speeds; the playback is created on the
  /// first tap so opening the home never touches the audio engine, and
  /// rebuilt when the settings it was built from changed.
  Future<void> _play(String text) async {
    final factory = widget.playback;
    if (factory == null) return;
    final settings = controller.settings;
    var player = _player;
    if (player != null && _playerSettings != settings) {
      _player = null;
      _creating = null;
      player.player.stop();
      await player.dispose();
      player = null;
    }
    if (player == null) {
      final creating = _creating ??= factory.create(settings);
      player = await creating;
      // Several taps may await the same creation: the first installs the
      // bundle, the others reuse it; only a creation that was superseded
      // (settings changed meanwhile) is thrown away.
      if (identical(_creating, creating)) {
        _creating = null;
        if (!mounted) {
          await player.dispose();
          return;
        }
        setState(() {
          _player = player;
          _playerSettings = settings;
        });
      } else if (!identical(_player, player)) {
        await player.dispose();
        return;
      }
      if (!mounted) return;
    }
    player.player.stop();
    player.player.play(
      MorseEncoder.encode(text, controller.trainerSettings.toTiming()),
    );
  }

  double _labelWidth(BuildContext context, String char) {
    final painter = TextPainter(
      text: TextSpan(
        text: char,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width + 20;
    painter.dispose();
    return width;
  }

  Widget _continueButton(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: onContinue,
      icon: const Icon(Icons.play_arrow),
      label: Text(context.s.learnContinueLesson),
    ),
  );

  Widget _guidedButton(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      key: const ValueKey('guided-practice'),
      onPressed: widget.onGuided,
      icon: const Icon(Icons.bolt),
      label: Text(context.s.learnGuidedPractice),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.s;
    final learned = controller.learnedChars;
    final classic =
        StyleTokens.of(context)?.style == UiStyle.classic ||
        StyleTokens.of(context) == null;
    final collapsible = classic && learned.length > 10;
    // Keep the newest symbol visible first in the compact set. Expanding
    // restores the complete teaching order.
    final visible = collapsible && !_expanded
        ? learned.sublist(learned.length - 10).reversed.toList()
        : learned;
    final newest = controller.newestChar;
    final states = <String, CharChipState>{
      for (final c in learned)
        c: chipStateOf(controller, c, isNewest: c == newest),
    };
    // Mastery is independent of how a chip is coloured (the newest and due
    // states win the colour, not the count).
    final mastered = learned
        .where((c) => controller.masteryOf(c) == CharMastery.mastered)
        .length;
    final t = controller.trainerSettings;
    final showGuided = widget.onGuided != null;
    final flash = _player?.flash;
    final card = Card(
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
            // Intro/today's learning leads the home. The challenge remains
            // available as a secondary, deliberate assessment.
            if (onContinue != null) ...[
              _continueButton(context),
              const SizedBox(height: 8),
            ],
            Text(
              s.learnCharsIntroducedMastered(learned.length, mastered),
              key: const ValueKey('chars-introduced'),
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: classic ? 4 : 8),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  for (final c in visible)
                    LearnedCharChip(
                      char: c,
                      state: states[c]!,
                      onTap: widget.playback == null ? null : () => _play(c),
                      width: math.max(
                        math.max(
                          ((constraints.maxWidth - 24) / 5).clamp(36.0, 52.0),
                          MediaQuery.textScalerOf(context).scale(
                                theme.textTheme.titleMedium?.fontSize ?? 16,
                              ) +
                              20,
                        ),
                        _labelWidth(context, c),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ChipLegend(states: states.values.toSet()),
            if (widget.playback != null)
              Text(
                s.learnTapChipHint,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            if (collapsible)
              TextButton(
                key: const ValueKey('learned-chars-toggle'),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded
                      ? s.learnShowFewerChars
                      : s.learnShowAllChars(learned.length),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              controller.isCourseComplete
                  ? s.learnCourseComplete
                  : controller.allCharsUnlocked
                  ? s.learnAllUnlockedNotPassed
                  : s.learnNewestCharIs(newest),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (widget.playback != null && !controller.isCourseComplete) ...[
              const SizedBox(height: 8),
              NewSymbolDemo(
                char: newest,
                neighbour: confusableNeighbourOf(newest, learned),
                onPlay: _play,
              ),
            ],
            const SizedBox(height: 10),
            Text(
              stageGoalText(s, controller),
              key: const ValueKey('stage-goal'),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(s.learnRecentEvidenceHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              s.learnChallengeHint(
                t.sessionLengthChars,
                controller.course.requiredNewCharAttempts(
                  controller.currentLesson,
                ),
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (showGuided) ...[
              const SizedBox(height: 8),
              _guidedButton(context),
            ],
          ],
        ),
      ),
    );
    // Flash-only learners (or a sidetone that failed to start) still see
    // the symbol they tapped.
    return flash == null ? card : FlashOverlay(isOn: flash, child: card);
  }
}

/// One symbol of the course, coloured by [state]; tappable to hear it.
class LearnedCharChip extends StatelessWidget {
  const LearnedCharChip({
    super.key,
    required this.char,
    required this.state,
    this.onTap,
    this.width = 52,
  });

  final String char;
  final CharChipState state;
  final VoidCallback? onTap;
  final double width;

  bool get isNewest => state == CharChipState.newest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = StyleTokens.of(context);
    final styled = tokens != null && tokens.style != UiStyle.classic;
    final (background, foreground) = chipColors(context, state);
    final radius = BorderRadius.circular(tokens?.chipRadius ?? 8);
    final label = isNewest
        ? context.s.learnCharNewSemantics(char)
        : '$char, ${chipStateLabel(context.s, state)}';
    return Semantics(
      label: label,
      button: onTap != null,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            width: width,
            constraints: BoxConstraints(
              minWidth: 36,
              minHeight: styled ? 68 : 36,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: isNewest
                  ? Border.all(color: scheme.primary, width: 2)
                  : null,
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
