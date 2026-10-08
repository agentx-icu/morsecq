// Tests for the 2026-10-08 pedagogy review: lesson evidence, the challenge
// drill's coverage guarantee, course completion, learner stages, QSO
// readiness and stage-aware plans.
import 'dart:math';

import 'package:morse_trainer/morse_trainer.dart';
import 'package:test/test.dart';

String repeat(String s, int n) => List.filled(n, s).join();

void main() {
  final course = KochCourse();

  group('KochCourse.evaluate', () {
    test('new symbols of a lesson', () {
      expect(course.newCharsForLesson(1), ['K', 'M']);
      expect(course.newCharsForLesson(2), ['R']);
      expect(course.newCharsForLesson(42), ['<AR>']);
      expect(course.requiredNewCharAttempts(1), 10);
      expect(course.requiredNewCharAttempts(2), 10);
    });

    test('45 K right and 5 M wrong is 90 % but does not pass lesson 1', () {
      final target = '${repeat('K', 45)}${repeat('M', 5)}';
      final answer = repeat('K', 50);
      final score = SessionScore.evaluate(target, answer);
      expect(score.strictAccuracy, closeTo(0.9, 1e-9));
      expect(course.passes(score), isTrue, reason: 'score-only rule');
      // M was sent 5 times only: no evidence either way.
      expect(course.evaluate(score, 1), LessonVerdict.newSymbolsUncovered);
      expect(course.uncoveredNewChars(score, 1), ['M']);
    });

    test('a covered but weak new symbol fails on its own', () {
      // 40 K right, 10 M of which 8 wrong: 84 % overall → accuracy first.
      final target = '${repeat('K', 40)}${repeat('M', 10)}';
      final weak = SessionScore.evaluate(
        target,
        '${repeat('K', 40)}${repeat('K', 8)}MM',
      );
      expect(course.evaluate(weak, 1), LessonVerdict.belowPassAccuracy);
      // 90 K right, 10 M of which 2 wrong: 98 % overall, M at 80 %.
      final target2 = '${repeat('K', 90)}${repeat('M', 10)}';
      final weak2 = SessionScore.evaluate(
        target2,
        '${repeat('K', 90)}${repeat('M', 8)}KK',
      );
      expect(weak2.strictAccuracy, greaterThan(0.9));
      expect(course.evaluate(weak2, 1), LessonVerdict.newSymbolsBelowPass);
      expect(course.weakNewChars(weak2, 1), ['M']);
      expect(course.uncoveredNewChars(weak2, 1), isEmpty);
    });

    test('numbers-only copying never passes lesson 23 (new symbol /)', () {
      final score = SessionScore.evaluate(repeat('05', 25), repeat('05', 25));
      expect(score.isPerfect, isTrue);
      expect(course.evaluate(score, 23), LessonVerdict.newSymbolsUncovered);
      expect(course.nextLesson(23, score), 23);
    });

    test('too short is reported before anything else', () {
      final score = SessionScore.evaluate(repeat('KM', 10), repeat('KM', 10));
      expect(course.evaluate(score, 1), LessonVerdict.tooShort);
    });

    test('a short configured course keeps its first lesson passable', () {
      final short = KochCourse(
        order: const ['K', 'M', 'R'],
        minCharsPerSession: 4,
      );
      expect(short.requiredNewCharAttempts(1), 2);
      expect(short.requiredNewCharAttempts(2), 4);
      final score = SessionScore.evaluate('KMKM', 'KMKM');
      expect(short.evaluate(score, 1), LessonVerdict.passed);
      expect(short.evaluate(score, 2), LessonVerdict.newSymbolsUncovered);
    });
  });

  group('LessonChallengeDrill', () {
    /// Generates a whole session and returns how often each symbol came up.
    Map<String, int> run(
      LessonChallengeDrill drill, {
      required int charBudget,
      int seed = 1,
    }) {
      final random = Random(seed);
      final counts = <String, int>{};
      var sent = 0;
      while (sent < charBudget) {
        final drillText = drill.generate(random);
        for (final c in MorseText.symbols(drillText.text)) {
          counts[c] = (counts[c] ?? 0) + 1;
          sent++;
        }
      }
      return counts;
    }

    for (final (lesson, groupSize, budget) in <(int, int, int)>[
      (1, 5, 50),
      (1, 1, 50),
      (1, 10, 50),
      (10, 5, 50),
      (10, 1, 50),
      (10, 3, 55),
      (23, 5, 50),
      (42, 10, 200),
      (42, 5, 50),
      (42, 1, 50),
    ]) {
      test('covers the new symbols: lesson $lesson, groups of $groupSize, '
          'budget $budget', () {
        final chars = course.charsForLesson(lesson);
        final required = course.newCharsForLesson(lesson);
        for (var seed = 1; seed <= 20; seed++) {
          final drill = LessonChallengeDrill(
            chars: chars,
            newChars: required,
            charBudget: budget,
            groupSize: groupSize,
            weights: CharWeights.fromStats(
              const <String, CharStats>{},
              recent: course.recentCharsForLesson(lesson),
            ),
          );
          expect(drill.quota, course.requiredNewCharAttempts(lesson));
          final counts = run(drill, charBudget: budget, seed: seed);
          for (final c in required) {
            expect(
              counts[c] ?? 0,
              greaterThanOrEqualTo(drill.quota),
              reason: 'seed $seed: $c in $counts',
            );
          }
        }
      });
    }

    test('mixed copying survives: at group size 1 most rounds are random', () {
      final chars = course.charsForLesson(10);
      var forcedLike = 0;
      for (var seed = 1; seed <= 10; seed++) {
        final drill = LessonChallengeDrill(
          chars: chars,
          newChars: const ['O'],
          charBudget: 50,
          groupSize: 1,
        );
        final counts = run(drill, charBudget: 50, seed: seed);
        forcedLike += counts['O'] ?? 0;
        expect(counts.keys.length, greaterThan(4), reason: 'seed $seed');
      }
      // 11 symbols, uniform: ~4.5 natural O per 50 plus the quota top-up.
      expect(forcedLike / 10, lessThan(20));
    });

    test('the quota is met at the planned end; extra rounds stay valid', () {
      final drill = LessonChallengeDrill(
        chars: course.charsForLesson(5),
        newChars: const ['U'],
        charBudget: 50,
        groupSize: 5,
      );
      final random = Random(9);
      var u = 0;
      for (var i = 0; i < drill.plannedRounds; i++) {
        expect(drill.targetAfter(i + 1), lessThanOrEqualTo(drill.quota));
        u += MorseText.symbols(drill.generate(random).text)
            .where((c) => c == 'U')
            .length;
      }
      expect(u, greaterThanOrEqualTo(10));
      expect(drill.emittedCount('U'), u);
      // A session that keeps going (its last round overshot the budget, or
      // a longer budget than planned) gets ordinary groups of the pool.
      for (var i = 0; i < 3; i++) {
        final extra = drill.generate(random);
        expect(extra.charCount, 5);
        expect(extra.chars, everyElement(isIn(course.charsForLesson(5))));
      }
      expect(drill.roundsGenerated, drill.plannedRounds + 3);
      expect(drill.emittedCount('U'), greaterThanOrEqualTo(10));
    });

    test('the quota always fits the plan; past the plan the target is the '
        'whole quota', () {
      // The quota is `min(minAttempts, budget ~/ required)`, so by the end
      // of the planned rounds every required symbol has reached it (the
      // slots exist and a deficit is forced before they run out); the
      // post-plan branch is a safety net for a session that plays more
      // rounds than the drill was planned for, never a normal path.
      final drill = LessonChallengeDrill(
        chars: const ['K', 'M', 'R', 'S', 'U', 'A'],
        newChars: const ['K', 'A'],
        charBudget: 6,
        groupSize: 1,
        minRequiredAttempts: 3,
      );
      expect(drill.quota, 3);
      expect(drill.targetAfter(0), 0);
      expect(drill.targetAfter(drill.plannedRounds), 3);
      expect(drill.targetAfter(drill.plannedRounds + 5), 3);
      for (var seed = 0; seed < 20; seed++) {
        final d = LessonChallengeDrill(
          chars: const ['K', 'M', 'R', 'S', 'U', 'A'],
          newChars: const ['K', 'A'],
          charBudget: 6,
          groupSize: 1,
          minRequiredAttempts: 3,
        );
        final random = Random(seed);
        for (var i = 0; i < d.plannedRounds; i++) {
          d.generate(random);
        }
        expect(d.emittedCount('K'), 3, reason: 'seed $seed');
        expect(d.emittedCount('A'), 3, reason: 'seed $seed');
      }
    });

    test('deterministic for a seed and kind groups', () {
      LessonChallengeDrill make() => LessonChallengeDrill(
        chars: course.charsForLesson(3),
        newChars: const ['S'],
        charBudget: 50,
      );
      final a = make();
      final b = make();
      final ra = Random(5);
      final rb = Random(5);
      for (var i = 0; i < 10; i++) {
        expect(a.generate(ra).text, b.generate(rb).text);
      }
      expect(a.kind, 'groups');
    });

    test('the fixture budget of 5 forces what fits', () {
      final drill = LessonChallengeDrill(
        chars: const ['K', 'M'],
        newChars: const ['K', 'M'],
        charBudget: 5,
        groupSize: 5,
      );
      expect(drill.quota, 2);
      final text = drill.generate(Random(1)).text;
      expect(text.split('').where((c) => c == 'K').length, greaterThanOrEqualTo(2));
      expect(text.split('').where((c) => c == 'M').length, greaterThanOrEqualTo(2));
    });
  });

  group('session scoring', () {
    test('combined rounds keep a missed symbol missed', () {
      // Joined and re-aligned, KKKKM/KKKKMM + MKKKK/KKKK would read as a
      // perfect copy; combined per round the M misses stay visible.
      final rounds = <SessionScore>[
        for (var i = 0; i < 5; i++) ...<SessionScore>[
          SessionScore.evaluate('KKKKM', 'KKKKMM'),
          SessionScore.evaluate('MKKKK', 'KKKK'),
        ],
      ];
      final joined = SessionScore.evaluate(
        rounds.map((r) => r.target).join(' '),
        rounds.map((r) => r.answer).join(' '),
      );
      expect(joined.charStats['M']!.correct, 10, reason: 'the old trap');
      final combined = SessionScore.combine(rounds);
      expect(combined.totalChars, 50);
      expect(combined.charStats['M'], const CharStats(attempts: 10, correct: 5));
      expect(combined.strictAccuracy, lessThan(0.9));
      expect(KochCourse().evaluate(combined, 1), isNot(LessonVerdict.passed));
    });
  });

  group('TrainerProgress course completion', () {
    final small = KochCourse(
      order: const ['K', 'M', 'R'],
      minCharsPerSession: 4,
    );

    test('passing the last lesson records completion and is sticky', () {
      var p = TrainerProgress(currentLesson: 2);
      expect(p.courseCompleted, isFalse);
      final noR = SessionScore.evaluate('KMKM', 'KMKM');
      p = p.advanceIfPassed(small, noR);
      expect(p.courseCompleted, isFalse);
      // Lesson 2's only new symbol is R; a 4-symbol course needs it 4x.
      final withR = SessionScore.evaluate('RRRR', 'RRRR');
      p = p.advanceIfPassed(small, withR);
      expect(p.currentLesson, 2);
      expect(p.courseCompleted, isTrue);
      expect(p.withLesson(1).courseCompleted, isTrue);
      expect(p.advanceIfPassed(small, withR), same(p));
    });

    test('JSON round trip and legacy files', () {
      final p = TrainerProgress(
        currentLesson: 2,
        courseCompleted: true,
        firstLessonDoneAt: DateTime(2026, 10, 8, 9, 30),
      );
      final json = p.toJson();
      expect(json['courseCompleted'], isTrue);
      expect(json['firstLessonDoneAt'], '2026-10-08T09:30:00.000');
      final back = TrainerProgress.fromJson(json);
      expect(back.courseCompleted, isTrue);
      expect(back.firstLessonDoneAt, DateTime(2026, 10, 8, 9, 30));
      expect(back.firstLessonDone, isTrue);
      final legacy = TrainerProgress.fromJson(<String, Object?>{
        'currentLesson': 42,
      });
      expect(legacy.courseCompleted, isFalse);
      expect(legacy.firstLessonDone, isFalse);
      expect(TrainerProgress(currentLesson: 42).toJson(), isNot(contains('courseCompleted')));
    });

    test('withFirstLessonDone keeps the first completion', () {
      final first = DateTime(2026, 10, 8);
      final p = TrainerProgress().withFirstLessonDone(first);
      expect(p.firstLessonDoneAt, first);
      expect(p.withFirstLessonDone(DateTime(2026, 10, 9)).firstLessonDoneAt, first);
    });
  });

  group('LearnerStage', () {
    TrainerProgress withStats(Map<String, CharStats> stats, {int lesson = 1}) =>
        TrainerProgress(currentLesson: lesson, charStats: stats, history: [
          SessionSummary(at: DateTime.now(),
            totalChars: stats.values.fold(0, (n, s) => n + s.attempts),
            correctChars: stats.values.fold(0, (n, s) => n + s.correct),
            source: ExerciseSource.focus, perChar: stats,
            characterWpm: 20, effectiveWpm: 8, assistance: const {},
          ),
        ]);

    test('first use needs lesson 1, no evidence and no first lesson', () {
      expect(LearnerStages.of(TrainerProgress(), course), LearnerStage.firstUse);
      expect(
        LearnerStages.of(TrainerProgress().withFirstLessonDone(DateTime(2026)), course),
        LearnerStage.recognition,
      );
      // Placed at lesson 15 without any copying: not a first-time user.
      expect(
        LearnerStages.of(TrainerProgress(currentLesson: 15), course),
        LearnerStage.recognition,
      );
    });

    test('recognition until the new symbols are mastered', () {
      final some = withStats(const {
        'K': CharStats(attempts: 12, correct: 12),
        'M': CharStats(attempts: 4, correct: 4),
      });
      expect(LearnerStages.of(some, course), LearnerStage.recognition);
      final both = withStats(const {
        'K': CharStats(attempts: 12, correct: 12),
        'M': CharStats(attempts: 10, correct: 9),
      });
      expect(LearnerStages.of(both, course), LearnerStage.copying);
      final weak = withStats(const {
        'K': CharStats(attempts: 12, correct: 12),
        'M': CharStats(attempts: 10, correct: 8),
      });
      expect(LearnerStages.of(weak, course), LearnerStage.recognition);
      expect(LearnerStages.masteryOf(null), CharMastery.introduced);
      expect(LearnerStages.masteryOf(const CharStats(attempts: 1, correct: 0)), CharMastery.practicing);
    });

    test('course passed', () {
      final p = TrainerProgress(currentLesson: 42, courseCompleted: true);
      expect(LearnerStages.of(p, course), LearnerStage.coursePassed);
      expect(
        LearnerStages.of(TrainerProgress(currentLesson: 42), course),
        LearnerStage.recognition,
      );
    });
  });

  group('QsoReadiness', () {
    SessionSummary drill(String kind, double accuracy, {bool assisted = false}) {
      final total = 20;
      final correct = (total * accuracy).round();
      final target = repeat('A', total);
      final answer = '${repeat('A', correct)}${repeat('B', total - correct)}';
      return SessionSummary.exercise(
        SessionScore.evaluate(target, answer, drillKind: kind),
        id: 'x$kind$accuracy$assisted',
        source: ExerciseSource.focus,
        at: DateTime(2026, 10, 8),
        assistance: assisted ? const {Assistance.replay} : const {},
        characterWpm: 20, effectiveWpm: 8,
      );
    }

    test('the simulator script fits the required set', () {
      const local = QsoStation(callsign: 'K1ABC', name: 'BOB', qth: 'BOSTON');
      const remote = QsoStation(callsign: 'DL2XYZ', name: 'HANS', qth: 'BERLIN');
      for (final scenario in QsoScenario.values) {
        for (final stage in QsoStage.values) {
          final text = QsoScript.remoteBefore(
            scenario,
            stage,
            local: local,
            remote: remote,
            report: '5NN',
          );
          if (text == null) continue;
          expect(
            MorseText.charSet(text).difference(QsoReadiness.requiredChars),
            isEmpty,
            reason: '$scenario/$stage: $text',
          );
        }
      }
      expect(QsoReadiness.requiredChars, isNot(contains('<BT>')));
    });

    test('levels distinguish introduction, recognition and protocol evidence', () {
      final at = DateTime(2026, 10, 8, 12);
      final all = course.charsForLesson(42);
      final target = [for (final c in QsoReadiness.requiredChars) repeat(c, 10)].join(' ');
      final recognition = SessionSummary.exercise(
        SessionScore.evaluate(target, target, drillKind: 'groups'),
        id: 'recognition', source: ExerciseSource.focus, at: at,
        assistance: const {}, characterWpm: 20, effectiveWpm: 8,
      );
      QsoReadiness readiness(List<SessionSummary> rows, {List<String>? learned}) =>
          QsoReadiness.of(learned: learned ?? all, history: rows, now: at,
              characterWpm: 20, effectiveWpm: 8);
      final atThirty = readiness([], learned: course.charsForLesson(30));
      expect(atThirty.level, QsoReadinessLevel.symbols);
      expect(atThirty.missing, ['?', '4', '2', '7', 'C', '1', 'D', '6', 'X', '<SK>']);
      expect(readiness([]).level, QsoReadinessLevel.consolidate);
      expect(readiness([recognition]).level, QsoReadinessLevel.shorthand);
      expect(readiness([recognition, drill('abbreviations', 0.7)]).level,
          QsoReadinessLevel.consolidate,
          reason: 'recent errors also weaken symbol recognition');
      expect(readiness([recognition, drill('abbreviations', 0.9, assisted: true)]).level,
          QsoReadinessLevel.shorthand);
      expect(readiness([recognition, drill('abbreviations', 0.9)]).level,
          QsoReadinessLevel.protocol);
      expect(readiness([recognition, drill('abbreviations', 0.9), drill('qso', 0.85)]).isReady,
          isFalse, reason: 'copying is not meaning or interactive evidence');
    });
  });

  group('QsoDrill with allowedChars', () {
    test('unrestricted keeps every template feasible', () {
      final gen = QsoDrill(full: true);
      expect(gen.isComplete, isTrue);
      expect(gen.canGenerate, isTrue);
      expect(QsoDrill().feasibleTemplates, hasLength(QsoDrill.defaultTemplates.length));
    });

    test('phrases become feasible before the full script', () {
      final early = QsoDrill.progressive(allowedChars: course.charSetForLesson(10));
      expect(early.canGenerate, isFalse, reason: 'no D/E/C/Q yet');
      final mid = QsoDrill.progressive(allowedChars: course.charSetForLesson(26));
      expect(mid.canGenerate, isTrue);
      expect(mid.isComplete, isFalse);
      for (var seed = 0; seed < 30; seed++) {
        final text = mid.generate(Random(seed)).text;
        expect(
          MorseText.usesOnly(text, course.charSetForLesson(26)),
          isTrue,
          reason: text,
        );
        expect(text, isNot(contains('{')));
      }
      final late = QsoDrill.progressive(allowedChars: course.charSetForLesson(42));
      expect(late.isComplete, isTrue);
      expect(late.templates, QsoDrill.defaultTemplates);
    });

    test('a slot the chosen template does not use cannot block it', () {
      // At lesson 22 (5 just learnt, 9 not yet) `5NN` is the only report
      // and the rig list is empty; the report phrase must still generate.
      final allowed = course.charSetForLesson(22);
      final gen = QsoDrill(
        allowedChars: allowed,
        templates: const ['UR RST {RST} {RST}', 'RIG IS {RIG}'],
      );
      expect(gen.feasibleTemplates, ['UR RST {RST} {RST}']);
      expect(gen.generate(Random(1)).text, 'UR RST 5NN 5NN');
      expect(QsoDrill(allowedChars: allowed, full: true).canGenerate, isFalse);
    });

    test('an injected callsign generator decides callsign feasibility', () {
      final gen = QsoDrill(
        allowedChars: course.charSetForLesson(42),
        callsigns: CallsignDrill(count: 1, allowedChars: const {'K', 'M'}),
        templates: const ['CQ CQ CQ DE {CALL1} K', 'UR RST {RST} {RST}'],
      );
      expect(gen.feasibleTemplates, ['UR RST {RST} {RST}']);
    });
  });

  group('stage-aware plans', () {
    const settings = PlanSettings(
      characterWpm: 20,
      effectiveWpm: 8,
      toneHz: 700,
      groupSize: 5,
    );
    PlanInputs inputs({
      LearnerStage stage = LearnerStage.copying,
      bool firstLessonDone = false,
      int lesson = 1,
      List<String> due = const [],
    }) => PlanInputs(
      now: DateTime(2026, 10, 8, 8),
      profileKey: 'p',
      budgetMinutes: 10,
      lesson: lesson,
      course: course,
      due: due,
      charStats: const {},
      confusion: ConfusionMatrix(),
      settings: settings,
      seed: 7,
      stage: stage,
      firstLessonDone: firstLessonDone,
    );

    test('first day: intro, single symbols, guided groups, optional send', () {
      final plan = DailyPlanBuilder.build(inputs(stage: LearnerStage.firstUse));
      expect(plan.steps.map((s) => s.kind), [
        PlanStepKind.intro,
        PlanStepKind.recognition,
        PlanStepKind.course,
        PlanStepKind.send,
      ]);
      final intro = plan.steps[0];
      expect(intro.pool, ['K', 'M']);
      expect(intro.charBudget, DailyPlanBuilder.introTrials);
      expect(intro.reason, PlanReason.firstLesson);
      expect(plan.steps[1].groupSize, 1);
      expect(plan.steps[1].reason, PlanReason.recognition);
      final guided = plan.steps[2];
      expect(guided.unlockEligible, isFalse);
      expect(guided.groupSize, DailyPlanBuilder.guidedGroupSize);
      expect(guided.reason, PlanReason.courseGuided);
      expect(guided.charBudget, DailyPlanBuilder.guidedMaxChars);
      expect(guided.charBudget, lessThan(course.minCharsPerSession));
      final send = plan.steps[3];
      expect(send.optional, isTrue);
      expect(send.reason, PlanReason.sendOptional);
      expect(plan.estimatedMinutes, closeTo(10, 1e-9));
      // Optional sending does not hold the plan open.
      var p = plan;
      for (final s in plan.steps.where((s) => !s.optional)) {
        p = p.complete(s.id, exerciseId: 'e${s.id}');
      }
      expect(p.isComplete, isTrue);
      expect(p.nextStep, isNull);
      // ... unless it was started.
      final started = p.start(send.id);
      expect(started.isComplete, isFalse);
      expect(started.nextStep!.id, send.id);
    });

    test('after the first lesson: recognition plus the challenge', () {
      final plan = DailyPlanBuilder.build(
        inputs(stage: LearnerStage.firstUse, firstLessonDone: true),
      );
      expect(plan.steps.map((s) => s.kind), [
        PlanStepKind.recognition,
        PlanStepKind.course,
        PlanStepKind.send,
      ]);
      expect(plan.steps[1].unlockEligible, isTrue);
      expect(plan.steps[1].groupSize, isNull);
      expect(plan.steps[2].optional, isTrue);
    });

    test('later stages keep the classic plan', () {
      for (final stage in [LearnerStage.copying, LearnerStage.coursePassed]) {
        final plan = DailyPlanBuilder.build(
          inputs(stage: stage, lesson: 10, due: const ['K', 'M']),
        );
        expect(plan.steps.map((s) => s.kind), [
          PlanStepKind.review,
          PlanStepKind.course,
          PlanStepKind.send,
        ]);
        expect(plan.steps.last.optional, isFalse);
        expect(plan.steps.every((s) => s.groupSize == null), isTrue);
      }
    });

    test('a started guided step keeps its place on refresh', () {
      final first = DailyPlanBuilder.build(inputs(stage: LearnerStage.firstUse));
      final guided = first.steps.firstWhere((s) => s.kind == PlanStepKind.course);
      final started = first.start(guided.id);
      final refreshed = DailyPlanBuilder.refreshPending(
        started,
        inputs(stage: LearnerStage.recognition, firstLessonDone: true),
      );
      final courses = refreshed.steps.where((s) => s.kind == PlanStepKind.course);
      expect(courses.single.id, guided.id);
      expect(courses.single.reason, PlanReason.courseGuided);
      expect(refreshed.steps.any((s) => s.kind == PlanStepKind.intro), isFalse);
    });

    test('group size and optional round-trip through JSON', () {
      final plan = DailyPlanBuilder.build(inputs(stage: LearnerStage.firstUse));
      final back = DailyPlan.fromJson(plan.toJson());
      expect(back.toJson(), plan.toJson());
      expect(back.steps[1].groupSize, 1);
      expect(back.steps[3].optional, isTrue);
      final legacy = PlanStep.fromJson(<String, Object?>{
        'id': 'x',
        'kind': 'course',
        'pool': ['K', 'M'],
        'minutes': 3,
        'charBudget': 50,
        'lesson': 1,
        'reason': 'courseChallenge',
        'groupSize': 0,
      });
      expect(legacy.groupSize, isNull);
      expect(legacy.optional, isFalse);
    });
  });

  group('speed advice lesson restriction', () {
    test('focus sessions of an earlier lesson are not comparable', () {
      SessionSummary s(int lesson, ExerciseSource source, int i) =>
          SessionSummary.exercise(
            SessionScore.evaluate(repeat('KM', 30), repeat('KM', 30)),
            id: 'id$lesson$source$i',
            source: source,
            at: DateTime(2026, 10, 8, 8 + i),
            assistance: const {},
            lesson: lesson,
            characterWpm: 20,
            effectiveWpm: 8,
          );
      final old = [for (var i = 0; i < 5; i++) s(3, ExerciseSource.focus, i)];
      final advice = SpeedRecommender.evaluate(
        old,
        characterWpm: 20,
        effectiveWpm: 8,
        now: DateTime(2026, 10, 8, 20),
        currentLesson: 5,
      );
      expect(advice.kind, SpeedAdviceKind.insufficient);
      final current = [for (var i = 0; i < 5; i++) s(5, ExerciseSource.focus, i)];
      final advice2 = SpeedRecommender.evaluate(
        current,
        characterWpm: 20,
        effectiveWpm: 8,
        now: DateTime(2026, 10, 8, 20),
        currentLesson: 5,
      );
      expect(advice2.kind, isNot(SpeedAdviceKind.insufficient));
    });
  });
}
