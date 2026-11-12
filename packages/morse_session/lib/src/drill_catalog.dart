import 'package:morse_trainer/morse_trainer.dart';

import 'receive_session.dart';

/// Which drill generator serves each [ReceiveDrillKind] for a learner's
/// current state. Single source of truth for both the drill picker and the
/// sessions that are started.
///
/// Availability follows the learned symbol set, never a lesson number: a
/// drill is offered as soon as the learned symbols can carry it, and its
/// content never leaves them (pedagogy review A5).
final class DrillCatalog {
  const DrillCatalog({
    required this.course,
    required this.progress,
    required this.settings,
  });

  /// Abbreviations / Q-codes needed before that drill is offered.
  static const int minShorthandWords = 3;

  final KochCourse course;
  final TrainerProgress progress;
  final TrainerSettings settings;

  int get lesson => progress.currentLesson;

  CharWeights weights() => CharWeights.fromStats(
    progress.charStats,
    recent: course.recentCharsForLesson(lesson),
  );

  /// The lesson challenge drill: weighted groups over [chars] that cover
  /// the new symbols of [lesson] often enough for the lesson rule.
  LessonChallengeDrill challengeDrill({
    required List<String> chars,
    required int lesson,
    required int charBudget,
    required int groupSize,
    bool weighted = true,
  }) => LessonChallengeDrill(
    chars: chars,
    newChars: course.isValidLesson(lesson)
        ? course.newCharsForLesson(lesson)
        : const <String>[],
    charBudget: charBudget,
    groupSize: groupSize,
    minRequiredAttempts: course.isValidLesson(lesson)
        ? course.requiredNewCharAttempts(lesson)
        : 0,
    weights: weighted ? weights() : null,
  );

  /// The drill for [kind], falling back to lesson groups when [chars]
  /// cannot support it yet.
  DrillGenerator generatorFor(ReceiveDrillKind kind, List<String> chars) =>
      drillFor(kind, chars) ?? drillFor(ReceiveDrillKind.groups, chars)!;

  /// The drill for [kind] over [chars], or null when [chars] cannot
  /// support it.
  DrillGenerator? drillFor(ReceiveDrillKind kind, List<String> chars) {
    final allowed = chars.toSet();
    final t = settings;
    switch (kind) {
      case ReceiveDrillKind.groups:
      case ReceiveDrillKind.review:
        return RandomGroupsDrill(
          chars: chars,
          groupCount: 1,
          groupSize: t.groupSize,
          weights: weights(),
        );
      case ReceiveDrillKind.characters:
        return RandomGroupsDrill(
          chars: chars,
          groupCount: 1,
          groupSize: 1,
          weights: weights(),
        );
      case ReceiveDrillKind.words:
        final words = WordDrill.commonWords(
          allowedChars: allowed,
          wordCount: 2,
        );
        return words.hasCandidates ? words : null;
      case ReceiveDrillKind.abbreviations:
        final shorthand = WordDrill.radioShorthand(
          allowedChars: allowed,
          wordCount: 2,
        );
        // `K` alone is an abbreviation; a drill of only `K K` is not one.
        return shorthand.candidates.length >= minShorthandWords
            ? shorthand
            : null;
      case ReceiveDrillKind.numbers:
        final numbers = NumberGroupsDrill(
          groupSize: t.groupSize,
          allowedChars: allowed,
        );
        return numbers.canGenerate ? numbers : null;
      case ReceiveDrillKind.callsigns:
        final calls = CallsignDrill(count: 1, allowedChars: allowed);
        return calls.canGenerate ? calls : null;
      case ReceiveDrillKind.confusables:
        final pairs = ConfusableDrill(
          chars: chars,
          confusion: progress.confusion,
          groupSize: t.groupSize,
        );
        return pairs.canGenerate ? pairs : null;
      case ReceiveDrillKind.qso:
        // Short phrases first, whole lines as their symbols arrive; the
        // text never leaves the learned set.
        final qso = QsoDrill.progressive(allowedChars: allowed);
        return qso.canGenerate ? qso : null;
      case ReceiveDrillKind.contest:
        final contest = ContestExchangeDrill(allowedChars: allowed);
        return contest.canGenerate ? contest : null;
    }
  }
}
