import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_plan.dart';
import 'package:morsecq/training/training_settings.dart';

import 'helpers/test_controller.dart';

/// The plan's current speeds; a step freezes them when it starts.
const _planSpeeds = PlanSettings(
  characterWpm: 22,
  effectiveWpm: 12,
  toneHz: 650,
  groupSize: 5,
);

PlanStep _step(
  String id,
  PlanStepKind kind, {
  List<String> pool = const ['K', 'M', 'R', 'S'],
  PlanStepState state = PlanStepState.pending,
  int charBudget = 3,
  int seed = 41,
}) => PlanStep(
  id: id,
  kind: kind,
  pool: pool,
  minutes: 3,
  charBudget: charBudget,
  lesson: 3,
  reason: PlanReason.values.first,
  state: state,
  seed: seed,
);

DailyPlan _plan(List<PlanStep> steps) => DailyPlan(
  id: 'plan',
  date: DailyPlan.dateKey(kTestNow),
  profileKey: '',
  seed: 9,
  budgetMinutes: 15,
  settings: _planSpeeds,
  steps: steps,
);

/// A free (non-guided) send attempt: guided sending is then not needed.
SessionSummary _freeSend(int i) => SessionSummary(
  at: kTestNow.subtract(Duration(days: 2, hours: i)),
  totalChars: 5,
  correctChars: 5,
  drillKind: 'send',
  lesson: 3,
  id: 'send-$i',
  source: ExerciseSource.send,
  assistance: const {},
);

/// A receive record tied to [stepId] with per-symbol results.
SessionSummary _planAttempt(String stepId, Map<String, CharStats> perChar) {
  final total = perChar.values.fold(0, (n, s) => n + s.attempts);
  final correct = perChar.values.fold(0, (n, s) => n + s.correct);
  return SessionSummary(
    at: kTestNow.subtract(const Duration(minutes: 5)),
    totalChars: total,
    correctChars: correct,
    drillKind: 'groups',
    lesson: 3,
    id: 'rx-$stepId-${perChar.keys.join()}',
    source: ExerciseSource.focus,
    planStepId: stepId,
    perChar: perChar,
  );
}

Future<TrainingController> _controller(TrainerProgress progress) async =>
    (await TestTraining.create(progress: progress)).controller;

void main() {
  group('plan step starters', () {
    test('receive starter refuses steps with their own starters', () async {
      final kinds = [
        PlanStepKind.intro,
        PlanStepKind.send,
        PlanStepKind.comprehension,
        PlanStepKind.qso,
      ];
      final c = await _controller(
        TrainerProgress(
          currentLesson: 3,
          dailyPlan: _plan([for (final k in kinds) _step(k.name, k)]),
        ),
      );
      for (final k in kinds) {
        await expectLater(
          c.startPlanReceiveStep(c.todayPlan!.stepById(k.name)!),
          throwsStateError,
          reason: k.name,
        );
      }
      expect(
        c.todayPlan!.steps.every((s) => s.state == PlanStepState.pending),
        isTrue,
        reason: 'a refused start must not mark the step active',
      );
    });

    test('a step outside today\'s plan cannot be started', () async {
      final c = await _controller(TrainerProgress(currentLesson: 3));
      final stray = _step('stray', PlanStepKind.review);
      await expectLater(c.startPlanReceiveStep(stray), throwsStateError);
      await expectLater(c.startPlanSendStep(stray), throwsStateError);
      // Yesterday's plan is inspect-only.
      final old = TestClock();
      final y = await TestTraining.create(
        progress: TrainerProgress(
          currentLesson: 3,
          dailyPlan: _plan([_step('r', PlanStepKind.review)]),
        ),
        clock: old,
      );
      old.advance(const Duration(days: 1));
      await expectLater(
        y.controller.startPlanReceiveStep(_step('r', PlanStepKind.review)),
        throwsStateError,
      );
    });

    test('recognition and review steps replay their frozen content', () async {
      final c = await _controller(
        TrainerProgress(
          currentLesson: 3,
          dailyPlan: _plan([
            _step('rec', PlanStepKind.recognition, charBudget: 20),
            _step('rev', PlanStepKind.review, charBudget: 20),
          ]),
        ),
      );
      for (final id in ['rec', 'rev']) {
        final step = c.todayPlan!.stepById(id)!;
        final a = await c.startPlanReceiveStep(step);
        final b = await c.startPlanReceiveStep(step);
        expect(a.currentDrill.text, b.currentDrill.text, reason: id);
        expect(a.planStepId, id);
        expect(a.countsTowardLesson, isFalse, reason: 'practice never unlocks');
        expect(a.timing.wpm, _planSpeeds.characterWpm);
        expect(a.timing.farnsworthWpm, _planSpeeds.effectiveWpm);
        expect(c.todayPlan!.stepById(id)!.state, PlanStepState.active);
      }
      final rec = await c.startPlanReceiveStep(c.todayPlan!.stepById('rec')!);
      expect(rec.kind, ReceiveDrillKind.characters);
      expect(rec.source, ExerciseSource.focus);
      expect(rec.currentDrill.text.trim(), hasLength(1));
      final rev = await c.startPlanReceiveStep(c.todayPlan!.stepById('rev')!);
      expect(rev.kind, ReceiveDrillKind.review);
      expect(rev.source, ExerciseSource.review);
    });

    test('intro starter only accepts the intro step and binds it', () async {
      final c = await _controller(
        TrainerProgress(
          dailyPlan: _plan([
            _step('intro', PlanStepKind.intro, pool: const ['K', 'M']),
            _step('rev', PlanStepKind.review),
          ]),
        ),
      );
      await expectLater(
        c.startPlanIntroStep(c.todayPlan!.stepById('rev')!),
        throwsStateError,
      );
      final session = await c.startPlanIntroStep(
        c.todayPlan!.stepById('intro')!,
      );
      expect(session.planStepId, 'intro');
      expect(c.todayPlan!.stepById('intro')!.state, PlanStepState.active);
      expect(c.todayPlan!.stepById('rev')!.state, PlanStepState.pending);
    });

    test('free send targets come from the pool, fixed per attempt', () async {
      final pool = ['K', 'M', 'R', 'S', 'U', 'A'];
      final c = await _controller(
        TrainerProgress(
          currentLesson: 6,
          history: [_freeSend(0)],
          dailyPlan: _plan([_step('send', PlanStepKind.send, pool: pool)]),
        ),
      );
      final step = c.todayPlan!.stepById('send')!;
      final first = await c.startPlanSendStep(step);
      final again = await c.startPlanSendStep(step);
      expect(first.planStepId, 'send');
      expect(first.target, again.target, reason: 'reopening replays a target');
      expect(
        first.target.split('').where((ch) => ch != ' '),
        everyElement(isIn(pool)),
      );
      expect(first.nominalTiming.wpm, _planSpeeds.characterWpm);
      expect(first.nominalTiming.farnsworthWpm, _planSpeeds.effectiveWpm);
      expect(c.sendAttemptsFor(step), 0);
      first
        ..keyDown(Duration.zero)
        ..keyUp(const Duration(milliseconds: 60));
      await c.recordSendSession(first);
      expect(c.sendAttemptsFor(step), 1);
    });

    test('a pool without common words falls back to letter groups', () async {
      final c = await _controller(
        TrainerProgress(
          currentLesson: 6,
          history: [_freeSend(0)],
          dailyPlan: _plan([
            _step('send', PlanStepKind.send, pool: const ['Q', 'Z']),
          ]),
        ),
      );
      final session = await c.startPlanSendStep(c.todayPlan!.stepById('send')!);
      final symbols = session.target.replaceAll(' ', '');
      expect(symbols, hasLength(TrainingController.sendTargetChars));
      expect(symbols.split(''), everyElement(isIn(['Q', 'Z'])));
    });
  });

  test('a new budget only rebuilds the steps that have not started', () async {
    final t = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 10),
    );
    final c = t.controller;
    final plan = await c.ensureTodayPlan();
    final started = plan.steps.firstWhere(
      (s) => s.kind != PlanStepKind.send && s.kind != PlanStepKind.intro,
    );
    await c.startPlanReceiveStep(started);
    await c.setPlanBudget(30);
    final next = c.todayPlan!;
    expect(next.id, plan.id, reason: 'a started plan is refreshed, not remade');
    expect(c.settings.planMinutes, 30);
    final kept = next.stepById(started.id)!;
    expect(kept.state, PlanStepState.active);
    expect(kept.pool, started.pool);
  });

  test(
    'weak plan symbols: plan attempts only, worst first, ties by name',
    () async {
      final c = await _controller(
        TrainerProgress(
          currentLesson: 3,
          dailyPlan: _plan([
            _step('a', PlanStepKind.focus),
            _step('b', PlanStepKind.review),
          ]),
          history: [
            _planAttempt('a', const {
              'K': CharStats(attempts: 10, correct: 5),
              'M': CharStats(attempts: 10, correct: 10),
              'R': CharStats(attempts: 10, correct: 8),
            }),
            _planAttempt('b', const {
              'S': CharStats(attempts: 10, correct: 8),
              'K': CharStats(attempts: 10, correct: 5),
            }),
            // Not part of today's plan: ignored.
            _planAttempt('elsewhere', const {
              'M': CharStats(attempts: 10, correct: 0),
            }),
          ],
        ),
      );
      expect(c.planWeakSymbols(), ['K', 'R', 'S']);
      expect(c.planWeakSymbols(limit: 1), ['K']);
      final none = await _controller(TrainerProgress(currentLesson: 3));
      expect(none.planWeakSymbols(), isEmpty);
    },
  );

  group('speed advice', () {
    final now = kTestNow;
    final newest = KochCourse().newCharForLesson(10);
    List<SessionSummary> evidence({
      required int correct,
      double eff = 8,
      int lesson = 10,
    }) => <SessionSummary>[
      for (var i = 2; i >= 0; i--)
        SessionSummary(
          at: now.subtract(Duration(hours: i + 1)),
          totalChars: 60,
          correctChars: correct,
          drillKind: 'review',
          lesson: lesson,
          id: 'ex$i',
          source: ExerciseSource.review,
          characterWpm: 20,
          effectiveWpm: eff,
          insertions: 0,
          assistance: const {},
          perChar: {newest: const CharStats(attempts: 20, correct: 20)},
        ),
    ];
    TrainerProgress progress(List<SessionSummary> h, {int lesson = 10}) =>
        TrainerProgress(
          currentLesson: lesson,
          history: h,
          charStats: {newest: const CharStats(attempts: 20, correct: 20)},
        );

    test('dismissing hides the batch and keeps the speeds', () async {
      final t = await TestTraining.create(
        progress: progress(evidence(correct: 60)),
      );
      final c = t.controller;
      final before = c.settings;
      final advice = c.pendingSpeedAdvice!;
      await c.dismissSpeedAdvice(advice);
      expect(c.pendingSpeedAdvice, isNull);
      expect(c.settings, before);
      expect(c.progress.speedAdviceKey, advice.evidenceKey);
    });

    test('low accuracy proposes slower spacing', () async {
      final t = await TestTraining.create(
        progress: progress(evidence(correct: 40)),
      );
      final advice = t.controller.pendingSpeedAdvice!;
      expect(advice.kind, SpeedAdviceKind.decrease);
      expect(advice.effectiveWpm, lessThan(8));
      await t.controller.applySpeedAdvice(advice);
      expect(t.controller.trainerSettings.farnsworthWpm, advice.effectiveWpm);
      expect(t.controller.trainerSettings.characterWpm, 20);
    });

    test('raising both speeds clears Farnsworth spacing', () async {
      final t = await TestTraining.create(
        progress: progress(evidence(correct: 60, eff: 20)),
        settings: const TrainingSettings(
          trainer: TrainerSettings(characterWpm: 20, farnsworthWpm: null),
        ),
      );
      final advice = t.controller.pendingSpeedAdvice!;
      expect(advice.kind, SpeedAdviceKind.increaseBoth);
      await t.controller.applySpeedAdvice(advice);
      expect(t.controller.trainerSettings.characterWpm, advice.characterWpm);
      expect(t.controller.trainerSettings.characterWpm, greaterThan(20));
      expect(t.controller.trainerSettings.isFarnsworth, isFalse);
    });

    test('never while the first symbols are still being learnt', () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(history: evidence(correct: 60, lesson: 1)),
      );
      expect(t.controller.learnerStage, LearnerStage.firstUse);
      expect(t.controller.speedAdvice.isChange, isTrue);
      expect(t.controller.pendingSpeedAdvice, isNull);
    });
  });
}
