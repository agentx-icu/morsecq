import 'dart:async';

import 'package:morse_trainer/morse_trainer.dart';

import 'receive_session.dart';
import 'training_controller.dart';
import 'training_plan.dart';

/// Size of a guided (beginner) session: one symbol per round first, then
/// short groups, then full groups (pedagogy review, stages 1–2).
enum GuidedLevel {
  single(groupSize: 1, chars: 10),
  short(groupSize: 3, chars: 15),
  groups(groupSize: 5, chars: 20);

  const GuidedLevel({required this.groupSize, required this.chars});

  final int groupSize;
  final int chars;
}

/// Starting receive sessions. An extension so the controller stays within
/// the size gate; exported by `training_controller.dart`.
///
/// Only [startLessonSession] (and an eligible daily-plan course step) is a
/// course challenge. Everything else is practice: it may feed statistics,
/// reviews and activity, but never advances the course (review A1).
extension ReceiveSessionStart on TrainingController {
  /// Rounds of the first lesson's K / M trials.
  static const int onboardingRounds = DailyPlanBuilder.introTrials;

  /// Symbols of a short targeted drill offered from a session summary.
  static const int shortFocusChars = 20;

  /// The Koch lesson challenge: weighted groups over the learned set that
  /// are guaranteed to cover the lesson's new symbols. No time cap: a
  /// challenge runs to its symbol budget, because ending early could only
  /// fail it.
  ReceiveSession startLessonSession() {
    final chars = learnedChars;
    final t = trainerSettings;
    return ReceiveSession(
      kind: ReceiveDrillKind.groups,
      generator: catalog.challengeDrill(
        chars: chars,
        lesson: currentLesson,
        charBudget: t.sessionLengthChars,
        groupSize: t.groupSize,
      ),
      chars: chars,
      timing: t.toTiming(),
      charBudget: t.sessionLengthChars,
      lesson: currentLesson,
      countsTowardLesson: true,
      source: ExerciseSource.course,
      random: random,
      now: now,
    );
  }

  /// Free practice of [kind]. [preset] other than clear plays every round
  /// under simulated radio conditions (F11) at the learner's own speeds;
  /// such a session earns activity only. Never a course challenge.
  ReceiveSession startReceiveSession(
    ReceiveDrillKind kind, {
    RadioPreset preset = RadioPreset.clear,
  }) {
    if (kind == ReceiveDrillKind.review) {
      return startReviewSession();
    }
    final chars = learnedChars;
    final t = trainerSettings;
    final generator = catalog.generatorFor(kind, chars);
    final timing = t.toTiming();
    final conditions = preset == RadioPreset.clear
        ? null
        : RadioScenario.preset(
            preset,
            seed: random.nextInt(1 << 31),
            characterWpm: timing.wpm,
            effectiveWpm: timing.farnsworthWpm ?? timing.wpm,
            toneHz: t.toneHz,
          );
    return ReceiveSession(
      kind: kind,
      generator: generator,
      chars: chars,
      timing: timing,
      charBudget: t.sessionLengthChars,
      timeBudget: _timeBudget,
      lesson: currentLesson,
      conditions: conditions,
      random: random,
      now: now,
    );
  }

  /// SRS review: due symbols only (falls back to the whole learned set when
  /// nothing is due), weighted by weakness. Never advances the lesson.
  ReceiveSession startReviewSession() {
    final due = dueChars;
    final pool = due.length >= 2 ? due : learnedChars;
    final t = trainerSettings;
    return ReceiveSession(
      kind: ReceiveDrillKind.review,
      generator: RandomGroupsDrill(
        chars: pool,
        groupCount: 1,
        groupSize: t.groupSize,
        weights: catalog.weights(),
      ),
      chars: pool,
      timing: t.toTiming(),
      charBudget: t.sessionLengthChars,
      timeBudget: _timeBudget,
      lesson: currentLesson,
      random: random,
      now: now,
    );
  }

  /// A short guided session over the learned set: single symbols, short
  /// groups or full groups by [level]. Practice, never a challenge.
  GuidedLevel get recommendedGuidedLevel {
    var index = 0;
    final timing = trainerSettings.toTiming();
    for (final row in progress.history) {
      if (row.lesson != currentLesson ||
          row.source != ExerciseSource.focus ||
          !RecentPractice.isCurrent(
            row,
            now: now(),
            characterWpm: timing.wpm,
            effectiveWpm: timing.farnsworthWpm ?? timing.wpm,
          )) {
        continue;
      }
      for (final level in GuidedLevel.values) {
        if (row.sourceRef != 'guided/$currentLesson/${level.name}') continue;
        final covered = course.newCharsForLesson(currentLesson).every((c) {
          final stats = row.perChar?[c] ?? CharStats.empty;
          return stats.attempts >= 5 && stats.accuracy >= course.passAccuracy;
        });
        if (row.totalChars >= level.chars &&
            row.strictAccuracy >= course.passAccuracy &&
            covered) {
          index = (level.index + 1).clamp(0, GuidedLevel.values.length - 1);
        } else if (level.index <= index) {
          index = level.index;
        }
      }
    }
    return GuidedLevel.values[index];
  }

  ReceiveSession startGuidedSession({GuidedLevel? level}) {
    final selected = level ?? recommendedGuidedLevel;
    final chars = learnedChars;
    return ReceiveSession(
      kind: selected.groupSize == 1
          ? ReceiveDrillKind.characters
          : ReceiveDrillKind.groups,
      generator: LessonChallengeDrill(
        chars: chars,
        newChars: course.newCharsForLesson(currentLesson),
        minRequiredAttempts: 5,
        charBudget: selected.chars,
        groupSize: selected.groupSize,
        weights: catalog.weights(),
      ),
      chars: chars,
      timing: trainerSettings.toTiming(),
      charBudget: selected.chars,
      lesson: currentLesson,
      source: ExerciseSource.focus,
      sourceRef: 'guided/$currentLesson/${selected.name}',
      random: random,
      now: now,
    );
  }

  /// Recognition proof for previously taught QSO symbols. Each selected
  /// symbol is heard at least ten times so late-course learners have a
  /// direct route to evidence, without relying on random whole-course groups.
  ReceiveSession? startQsoSymbolSession(Iterable<String> symbols) {
    final pool = symbols.where(learnedChars.contains).toSet().take(4).toList();
    if (pool.isEmpty) return null;
    // A one-option keypad would reveal every answer. Keep a taught contrast
    // in the pool even when only one QSO symbol still needs evidence.
    if (pool.length == 1) {
      final contrast = learnedChars.where((c) => !pool.contains(c)).firstOrNull;
      if (contrast == null) return null;
      pool.add(contrast);
    }
    final budget = pool.length * LearnerStages.masteryAttempts;
    return ReceiveSession(
      kind: ReceiveDrillKind.characters,
      generator: LessonChallengeDrill(
        chars: pool,
        newChars: pool,
        minRequiredAttempts: LearnerStages.masteryAttempts,
        charBudget: budget,
        groupSize: 1,
      ),
      chars: pool,
      timing: trainerSettings.toTiming(),
      charBudget: budget,
      lesson: currentLesson,
      source: ExerciseSource.focus,
      sourceRef: 'qso-symbols',
      random: random,
      now: now,
    );
  }

  /// A focused drill on [symbols] restricted to the learned set (topped up
  /// to two symbols), or null when none of them is learned. [charBudget]
  /// defaults to the session length; summaries pass [shortFocusChars].
  ReceiveSession? startFocusSession(
    Iterable<String> symbols, {
    int? charBudget,
  }) {
    final learned = learnedChars;
    final pool = symbols.where(learned.contains).toSet().toList();
    if (pool.isEmpty) return null;
    for (final c in learned.reversed) {
      if (pool.length >= 2) break;
      if (!pool.contains(c)) pool.add(c);
    }
    final t = trainerSettings;
    return ReceiveSession(
      kind: ReceiveDrillKind.groups,
      generator: RandomGroupsDrill(
        chars: pool,
        groupCount: 1,
        groupSize: t.groupSize,
      ),
      chars: pool,
      timing: t.toTiming(),
      charBudget: charBudget ?? t.sessionLengthChars,
      lesson: currentLesson,
      source: ExerciseSource.focus,
      random: random,
      now: now,
    );
  }

  /// The first lesson's trials: the two symbols of lesson 1, one per round,
  /// [onboardingRounds] rounds. Practice (replays allowed; an assisted run is
  /// activity only). Without [planStepId] it attaches today's pending
  /// `intro` plan step, if there is one, and marks it started, so the plan
  /// completes through this very session.
  ReceiveSession startOnboardingSession({String? planStepId}) {
    final chars = course.charsForLesson(course.firstLesson);
    var stepId = planStepId;
    if (stepId == null) {
      final plan = todayPlan;
      final intro = plan?.steps
          .where((s) => s.kind == PlanStepKind.intro && !s.isDone)
          .firstOrNull;
      if (plan != null && intro != null) {
        stepId = intro.id;
        if (intro.state == PlanStepState.pending) {
          // Deferred: a screen starts this session while it is being built,
          // and the commit notifies the home's listeners.
          unawaited(
            Future<void>.microtask(
              () => commitProgress((p) {
                // Start on the live plan: the trials may already have
                // completed the step by now, and `start` leaves a done or
                // active step alone.
                final current = p.dailyPlan;
                if (current == null || current.id != plan.id) return p;
                return p.withDailyPlan(current.start(intro.id));
              }),
            ).then((_) {}, onError: (Object _) {}),
          );
        }
      }
    }
    final session = ReceiveSession(
      kind: ReceiveDrillKind.characters,
      generator: RandomGroupsDrill(chars: chars, groupCount: 1, groupSize: 1),
      chars: chars,
      timing: trainerSettings.toTiming(),
      charBudget: onboardingRounds,
      lesson: course.firstLesson,
      source: ExerciseSource.focus,
      planStepId: stepId,
      random: random,
      now: now,
    );
    session.markAssistance(Assistance.answerOptions);
    return session;
  }

  Duration? get _timeBudget => trainerSettings.sessionLengthSeconds == null
      ? null
      : Duration(seconds: trainerSettings.sessionLengthSeconds!);
}
