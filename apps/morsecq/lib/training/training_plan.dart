import 'dart:math';

import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';

import 'receive_session.dart';
import 'send_session.dart';
import 'training_controller.dart';

/// Daily plans and speed advice on top of [TrainingController] (functional
/// spec §4). The pure generator in `morse_trainer` decides; this layer
/// freezes, persists and executes its steps.
extension TrainingPlan on TrainingController {
  /// Today's plan, or null when none was made today (or it belongs to
  /// another profile).
  DailyPlan? get todayPlan {
    final plan = progress.dailyPlan;
    if (plan == null || !plan.isFor(now()) || plan.profileKey != profileKey) {
      return null;
    }
    return plan;
  }

  /// An unfinished plan from an earlier day, for inspection only.
  DailyPlan? get unfinishedEarlierPlan {
    final current = progress.dailyPlan;
    final earlier = current != null && !current.isFor(now())
        ? current
        : progress.previousPlan;
    if (earlier == null || earlier.isComplete || earlier.isFor(now())) {
      return null;
    }
    return earlier;
  }

  PlanInputs planInputs({int? budgetMinutes, int? seed}) {
    final t = trainerSettings;
    final char = t.characterWpm;
    final eff = t.isFarnsworth ? t.farnsworthWpm! : char;
    final due = progress.srs.dueChars(now());
    final current = {for (final c in learnedChars) c: recentEvidenceOf(c)};
    final planStats = <String, CharStats>{};
    final pairs = ConfusionMatrix();
    for (final entry in current.entries) {
      final evidence = entry.value;
      final stats = evidence.stats;
      final sampled = stats.attempts >= DailyPlanBuilder.minAttemptsForWeakness;
      // Plan-only weakness includes stray answers, after the genuine sample
      // floor is met. Lifetime totals and mastery attempt counts stay intact.
      planStats[entry.key] = sampled && evidence.insertions > 0
          ? CharStats(
              attempts: stats.attempts + evidence.insertions,
              correct: stats.correct,
            )
          : stats;
      if (!sampled ||
          evidence.strictAccuracy >= DailyPlanBuilder.weakAccuracy) {
        continue;
      }
      // Historical pairs are a contrast clue only while their target has
      // current independent evidence of trouble. Recovered symbols leave focus.
      for (final pair in progress.confusion.rowFor(entry.key).entries) {
        pairs.record(entry.key, pair.key, times: pair.value);
      }
    }
    return PlanInputs(
      now: now(),
      profileKey: profileKey,
      budgetMinutes: budgetMinutes ?? settings.planMinutes,
      lesson: currentLesson,
      course: course,
      due: due,
      charStats: planStats,
      confusion: pairs,
      settings: PlanSettings(
        characterWpm: char,
        effectiveWpm: eff,
        toneHz: t.toneHz,
        groupSize: t.groupSize,
      ),
      seed: seed ?? random.nextInt(1 << 31),
      stage: learnerStage,
      firstLessonDone: progress.firstLessonDone,
    );
  }

  /// Today's plan, made (and committed) on first use of the day.
  Future<DailyPlan> ensureTodayPlan() async {
    final existing = todayPlan;
    if (existing != null) return existing;
    final plan = DailyPlanBuilder.build(planInputs());
    await commitProgress((p) => p.withDailyPlan(plan));
    return plan;
  }

  /// Changes the plan length. An untouched plan is regenerated with the new
  /// budget; once a step has started only the remaining steps change.
  Future<void> setPlanBudget(int minutes) async {
    await updateSettings(settings.copyWith(planMinutes: minutes));
    final plan = todayPlan;
    if (plan == null) return;
    final untouched = plan.steps.every((s) => s.state == PlanStepState.pending);
    final next = untouched
        ? DailyPlanBuilder.build(planInputs(budgetMinutes: minutes))
        : DailyPlanBuilder.refreshPending(
            plan,
            planInputs(budgetMinutes: minutes, seed: plan.seed),
          );
    await commitProgress((p) => p.withDailyPlan(next));
  }

  /// Rebuilds the steps that have not started (after lesson/speed changes).
  Future<void> refreshPlan() async {
    final plan = todayPlan;
    if (plan == null) return;
    final next = DailyPlanBuilder.refreshPending(
      plan,
      planInputs(budgetMinutes: plan.budgetMinutes, seed: plan.seed),
    );
    await commitProgress((p) => p.withDailyPlan(next));
  }

  MorseTiming _timingOf(DailyPlan plan, PlanStep step) {
    final s = plan.settingsOf(step);
    return MorseTiming(
      wpm: s.characterWpm,
      farnsworthWpm: s.effectiveWpm < s.characterWpm ? s.effectiveWpm : null,
    );
  }

  /// Starts a receive step with the plan's frozen speeds and seed. Throws
  /// [StateError] when the step is not part of this profile's plan today,
  /// or when it is an `intro` or `send` step (those have their own
  /// starters).
  Future<ReceiveSession> startPlanReceiveStep(PlanStep step) async {
    if (step.kind == PlanStepKind.intro || step.kind == PlanStepKind.send) {
      throw StateError('${step.kind.name} steps are not receive sessions');
    }
    final started = _ownPlan(step).start(step.id);
    await commitProgress((p) => p.withDailyPlan(started));
    final plan = started;
    final frozen = plan.stepById(step.id)!;
    final effective = DailyPlanBuilder.effectiveStep(frozen, currentLesson);
    // The step's own seed and pool fix its content: reopening the step
    // after other steps changed, or after more practice, replays the same
    // questions (uniform weights, not live statistics).
    final seeded = Random(frozen.seed);
    final groupSize = frozen.groupSize ?? plan.settingsOf(frozen).groupSize;
    final challenge =
        step.kind == PlanStepKind.course && effective.unlockEligible;
    final kind = switch (step.kind) {
      PlanStepKind.review => ReceiveDrillKind.review,
      PlanStepKind.recognition => ReceiveDrillKind.characters,
      _ => ReceiveDrillKind.groups,
    };
    final DrillGenerator generator = challenge
        ? catalog.challengeDrill(
            chars: step.pool,
            lesson: step.lesson,
            charBudget: step.charBudget,
            groupSize: groupSize,
            weighted: false,
          )
        : step.kind == PlanStepKind.recognition
        ? LessonChallengeDrill(
            chars: step.pool,
            newChars: course.newCharsForLesson(step.lesson),
            charBudget: step.charBudget,
            groupSize: 1,
            minRequiredAttempts: LearnerStages.masteryAttempts,
          )
        : RandomGroupsDrill(
            chars: step.pool,
            groupCount: 1,
            groupSize: step.kind == PlanStepKind.recognition ? 1 : groupSize,
          );
    return ReceiveSession(
      kind: kind,
      generator: generator,
      chars: step.pool,
      timing: _timingOf(plan, frozen),
      charBudget: step.charBudget,
      lesson: step.lesson,
      countsTowardLesson: challenge,
      source: switch (step.kind) {
        PlanStepKind.review => ExerciseSource.review,
        PlanStepKind.focus || PlanStepKind.recognition => ExerciseSource.focus,
        _ => ExerciseSource.course,
      },
      planStepId: step.id,
      random: seeded,
      now: now,
    );
  }

  /// Starts the plan's `intro` step: the first lesson's trials session,
  /// bound to the step so finishing the trials completes it.
  Future<ReceiveSession> startPlanIntroStep(PlanStep step) async {
    if (step.kind != PlanStepKind.intro) {
      throw StateError('${step.kind.name} is not the intro step');
    }
    final started = _ownPlan(step).start(step.id);
    await commitProgress((p) => p.withDailyPlan(started));
    return startOnboardingSession(planStepId: step.id);
  }

  /// One target of a send step; the step completes after its number of
  /// keyed targets.
  Future<SendSession> startPlanSendStep(PlanStep step) async {
    final plan = _ownPlan(step).start(step.id);
    await commitProgress((p) => p.withDailyPlan(plan));
    final frozen = plan.stepById(step.id)!;
    if (GuidedSending.needed(progress.history)) {
      return startGuidedSendSession(
        planStepId: step.id,
        timing: _timingOf(plan, frozen),
      );
    }
    final done = progress.history.where((s) => s.planStepId == step.id).length;
    final seeded = Random(frozen.seed + done * 101);
    final words = WordDrill.commonWords(
      allowedChars: step.pool.toSet(),
      wordCount: 1,
    );
    final DrillGenerator generator = words.hasCandidates
        ? words
        : RandomGroupsDrill(
            chars: step.pool,
            groupCount: 1,
            groupSize: TrainingController.sendTargetChars,
          );
    return SendSession(
      target: generator.generate(seeded).text,
      timing: _timingOf(plan, frozen),
      now: now,
      lesson: step.lesson,
      planStepId: step.id,
    );
  }

  /// Keyed targets already recorded for a send step.
  int sendAttemptsFor(PlanStep step) =>
      progress.history.where((s) => s.planStepId == step.id).length;

  DailyPlan _ownPlan(PlanStep step) {
    final plan = todayPlan;
    if (plan == null || plan.stepById(step.id) == null) {
      throw StateError('step ${step.id} is not in today\'s plan');
    }
    return plan;
  }

  /// 1–3 symbols that need work, from today's plan attempts.
  List<String> planWeakSymbols({int limit = 3}) {
    final plan = todayPlan;
    if (plan == null) return const <String>[];
    final ids = plan.steps.map((s) => s.id).toSet();
    final totals = <String, CharStats>{};
    for (final s in progress.history) {
      if (s.planStepId == null || !ids.contains(s.planStepId)) continue;
      for (final e in (s.perChar ?? const <String, CharStats>{}).entries) {
        totals[e.key] = (totals[e.key] ?? CharStats.empty) + e.value;
      }
    }
    final weak = totals.entries.where((e) => e.value.accuracy < 0.9).toList()
      ..sort((a, b) {
        final byAcc = a.value.accuracy.compareTo(b.value.accuracy);
        return byAcc != 0 ? byAcc : a.key.compareTo(b.key);
      });
    return weak.take(limit).map((e) => e.key).toList();
  }

  /// Speed advice for the current speeds (never applied automatically).
  SpeedAdvice get speedAdvice {
    final t = trainerSettings;
    return SpeedRecommender.evaluate(
      progress.history,
      characterWpm: t.characterWpm,
      effectiveWpm: t.isFarnsworth ? t.farnsworthWpm! : t.characterWpm,
      now: now(),
      currentLesson: currentLesson,
    );
  }

  /// Advice worth showing: a change the learner has not seen for this
  /// evidence batch. Never while a new symbol is still being learnt: a
  /// speed change and unfamiliar symbols are not combined.
  SpeedAdvice? get pendingSpeedAdvice {
    switch (learnerStage) {
      case LearnerStage.firstUse:
      case LearnerStage.recognition:
        return null;
      case LearnerStage.copying:
      case LearnerStage.coursePassed:
        break;
    }
    final advice = speedAdvice;
    if (!advice.isChange || advice.evidenceKey == progress.speedAdviceKey) {
      return null;
    }
    return advice;
  }

  /// Persists the proposed speeds (only on explicit Apply).
  Future<void> applySpeedAdvice(SpeedAdvice advice) async {
    final t = trainerSettings;
    final char = advice.characterWpm;
    final eff = advice.effectiveWpm;
    await updateSettings(
      settings.copyWith(
        trainer: eff < char
            ? t.copyWith(characterWpm: char, farnsworthWpm: eff)
            : t.copyWith(characterWpm: char, clearFarnsworth: true),
      ),
    );
    await commitProgress((p) => p.copyWith(speedAdviceKey: advice.evidenceKey));
  }

  Future<void> dismissSpeedAdvice(SpeedAdvice advice) =>
      commitProgress((p) => p.copyWith(speedAdviceKey: advice.evidenceKey));
}
