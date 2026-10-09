import 'package:test/test.dart';
import 'package:morse_trainer/src/learning_goal.dart';

void main() {
  final now = DateTime(2026, 10, 9);
  GoalEvidence evidence(
    RouteSkill skill, {
    double speed = 25,
    bool assisted = false,
    DateTime? at,
    double accuracy = 1,
    int samples = 100,
  }) => GoalEvidence(
    skill: skill,
    at: at ?? now,
    effectiveWpm: speed,
    accuracy: accuracy,
    assisted: assisted,
    samples: samples,
  );

  test('legacy or unknown goal defaults to first QSO', () {
    expect(LearningGoal.parse(null), LearningGoal.firstQso);
    expect(LearningGoal.parse('future'), LearningGoal.firstQso);
    expect(LearningGoal.parse('contest'), LearningGoal.contest);
  });
  test('goals expose Academy speed stages and different skills', () {
    expect(
      LearningRoute.evaluate(
        LearningGoal.firstQso,
        [],
        now: now,
      ).milestones.map((m) => m.wpm).toSet(),
      {10, 13},
    );
    final conversational = LearningRoute.evaluate(
      LearningGoal.conversation,
      [],
      now: now,
    );
    expect(
      conversational.milestones.any((m) => m.skill == RouteSkill.story),
      isTrue,
    );
    final contest = LearningRoute.evaluate(LearningGoal.contest, [], now: now);
    expect(contest.milestones.map((m) => m.wpm).toSet(), {
      10,
      13,
      15,
      18,
      20,
      25,
    });
    expect(contest.milestones.last.skill, RouteSkill.contest);
  });
  test(
    'assisted, stale, future, slow and undersampled evidence cannot pass',
    () {
      final rejected = [
        evidence(RouteSkill.copying, assisted: true),
        evidence(
          RouteSkill.copying,
          at: now.subtract(const Duration(days: 29)),
        ),
        evidence(RouteSkill.copying, at: now.add(const Duration(days: 1))),
        evidence(RouteSkill.copying, speed: 5),
        evidence(RouteSkill.copying, samples: 2),
        evidence(RouteSkill.copying, accuracy: .7),
      ];
      expect(
        LearningRoute.evaluate(
          LearningGoal.firstQso,
          rejected,
          now: now,
        ).milestones.first.passed,
        isFalse,
      );
    },
  );
  test(
    'two independent comparable attempts pass a stage and locate next gap',
    () {
      var route = LearningRoute.evaluate(LearningGoal.firstQso, [
        evidence(RouteSkill.copying),
      ], now: now);
      expect(route.milestones.first.passed, isFalse);
      route = LearningRoute.evaluate(LearningGoal.firstQso, [
        evidence(RouteSkill.copying),
        evidence(RouteSkill.copying),
      ], now: now);
      expect(route.milestones.first.passed, isTrue);
      expect(route.next!.skill, isNot(RouteSkill.copying));
      expect(route.complete, isFalse);
    },
  );
  test('all required skills at target speed complete the route', () {
    final evidenceSet = [
      for (final skill in RouteSkill.values)
        for (var i = 0; i < 2; i++) evidence(skill),
    ];
    expect(
      LearningRoute.evaluate(
        LearningGoal.contest,
        evidenceSet,
        now: now,
      ).complete,
      isTrue,
    );
    expect(
      LearningRoute.evaluate(
        LearningGoal.conversation,
        evidenceSet,
        now: now,
      ).next,
      isNull,
    );
  });
}
