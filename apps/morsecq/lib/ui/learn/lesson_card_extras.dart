import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../i18n/l10n_extension.dart';
import '../../training/training_controller.dart';
import '../appearance/style_tokens.dart';
import '../appearance/ui_style.dart';

/// How a symbol chip on the lesson card is coloured. Honest states instead
/// of "learned" for everything that was merely unlocked.
enum CharChipState { newest, introduced, practicing, mastered, weak, due }

CharChipState chipStateOf(
  TrainingController controller,
  String char, {
  required bool isNewest,
}) {
  if (isNewest) return CharChipState.newest;
  if (controller.reviewDueChars.contains(char)) return CharChipState.due;
  final evidence = controller.recentEvidenceOf(char);
  if (evidence.stats.attempts > 0 &&
      evidence.strictAccuracy < LearnerStages.masteryAccuracy) {
    return CharChipState.weak;
  }
  return switch (controller.masteryOf(char)) {
    CharMastery.introduced => CharChipState.introduced,
    CharMastery.practicing => CharChipState.practicing,
    CharMastery.mastered => CharChipState.mastered,
  };
}

/// Background / foreground for [state] in the current theme.
(Color, Color) chipColors(BuildContext context, CharChipState state) {
  final scheme = Theme.of(context).colorScheme;
  final tokens = StyleTokens.of(context);
  final styled = tokens != null && tokens.style != UiStyle.classic;
  return switch (state) {
    CharChipState.newest =>
      styled
          ? (tokens.newest, tokens.onNewest)
          : (scheme.primary, scheme.onPrimary),
    CharChipState.weak => (scheme.errorContainer, scheme.onErrorContainer),
    CharChipState.due => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
    CharChipState.practicing => (
      scheme.secondaryContainer,
      scheme.onSecondaryContainer,
    ),
    CharChipState.introduced => (
      scheme.surfaceContainerHigh,
      scheme.onSurfaceVariant,
    ),
    CharChipState.mastered => (
      scheme.surfaceContainerHighest,
      scheme.onSurface,
    ),
  };
}

String chipStateLabel(S s, CharChipState state) => switch (state) {
  CharChipState.newest => s.learnChipNew,
  CharChipState.introduced => s.learnChipNew,
  CharChipState.practicing => s.learnChipPractising,
  CharChipState.mastered => s.learnChipMastered,
  CharChipState.weak => s.learnChipWeak,
  CharChipState.due => s.learnChipDue,
};

/// Legend under the chips: a dot per state that is actually on the card.
class ChipLegend extends StatelessWidget {
  const ChipLegend({super.key, required this.states});

  final Set<CharChipState> states;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final style = Theme.of(context).textTheme.labelSmall;
    final shown = <CharChipState>[
      for (final state in CharChipState.values)
        if (state != CharChipState.introduced && states.contains(state)) state,
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: <Widget>[
        for (final state in shown)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: chipColors(context, state).$1,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(child: Text(chipStateLabel(s, state), style: style)),
            ],
          ),
      ],
    );
  }
}

/// The pattern neighbour of [char] a beginner most often confuses it with,
/// among [learned]; null when there is none.
String? confusableNeighbourOf(String char, List<String> learned) {
  for (final pair in ConfusableDrill.rankPairs(learned, null)) {
    if (pair.a == char) return pair.b;
    if (pair.b == char) return pair.a;
  }
  return null;
}

/// "Hear M" and "M vs K" for the symbol the lesson introduces; the pattern
/// diagram supports the ear, the buttons are the point.
class NewSymbolDemo extends StatelessWidget {
  const NewSymbolDemo({
    super.key,
    required this.char,
    required this.neighbour,
    required this.onPlay,
  });

  final String char;
  final String? neighbour;

  /// Plays [text] (one or two symbols separated by a space).
  final void Function(String text) onPlay;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        FilledButton.tonalIcon(
          key: const ValueKey('hear-newest'),
          onPressed: () => onPlay(char),
          icon: const Icon(Icons.volume_up_outlined),
          label: Text(s.learnHearChar(char)),
        ),
        if (neighbour case final String other)
          OutlinedButton.icon(
            key: const ValueKey('compare-newest'),
            onPressed: () => onPlay('$char $other'),
            icon: const Icon(Icons.compare_arrows),
            label: Text(s.learnCompareWith(char, other)),
          ),
      ],
    );
  }
}

/// "Now: … Next: …" for the learner's stage (pedagogy review A5).
String stageGoalText(S s, TrainingController c) {
  final course = c.course;
  final lesson = c.currentLesson;
  switch (c.learnerStage) {
    case LearnerStage.firstUse:
      return s.learnGoalFirstUse;
    case LearnerStage.recognition:
      return s.learnGoalRecognition(
        course.newCharsForLesson(lesson).join(' '),
        course.requiredNewCharAttempts(lesson),
        lesson,
      );
    case LearnerStage.copying:
      final next = course.isLastLesson(lesson)
          ? s.learnGoalNextOperating
          : s.learnGoalNextChar(course.newCharForLesson(lesson + 1));
      return s.learnGoalCopying(lesson, next);
    case LearnerStage.coursePassed:
      return s.learnGoalOperating;
  }
}
