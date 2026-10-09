/// Optional learning destinations. These never replace Koch course evidence.
enum LearningGoal {
  firstQso,
  conversation,
  contest;

  static LearningGoal parse(String? raw) =>
      values.firstWhere((g) => g.name == raw, orElse: () => firstQso);
}

enum RouteSkill {
  copying,
  sending,
  words,
  phrases,
  information,
  story,
  qso,
  contest,
}

/// Comparable evidence supplied by the app, independent of UI and storage.
final class GoalEvidence {
  const GoalEvidence({
    required this.skill,
    required this.at,
    required this.effectiveWpm,
    required this.accuracy,
    required this.assisted,
    required this.samples,
  });

  final RouteSkill skill;
  final DateTime at;
  final double effectiveWpm;
  final double accuracy;
  final bool assisted;
  final int samples;
}

final class RouteMilestone {
  const RouteMilestone({
    required this.skill,
    required this.wpm,
    required this.attempts,
  });
  final RouteSkill skill;
  final int wpm;
  final int attempts;
  bool get passed => attempts >= LearningRoute.requiredAttempts;
}

/// Advisory milestones inspired by CW Academy's intermediate speed stages.
/// Recent assisted work, unknown timings and small samples cannot certify one.
final class LearningRoute {
  LearningRoute._(this.goal, List<RouteMilestone> milestones)
    : milestones = List.unmodifiable(milestones);
  final LearningGoal goal;
  final List<RouteMilestone> milestones;
  static const requiredAttempts = 2;
  static const evidenceWindow = Duration(days: 28);
  static const speeds = [10, 13, 15, 18, 20, 25];

  RouteMilestone? get next {
    for (final milestone in milestones) {
      if (!milestone.passed) return milestone;
    }
    return null;
  }

  bool get complete => next == null;
  int get passedCount => milestones.where((m) => m.passed).length;

  static LearningRoute evaluate(
    LearningGoal goal,
    Iterable<GoalEvidence> evidence, {
    required DateTime now,
  }) {
    final eligible = evidence
        .where(
          (e) =>
              !e.assisted &&
              !e.at.isAfter(now) &&
              !e.at.isBefore(now.subtract(evidenceWindow)) &&
              e.accuracy >= .9 &&
              e.effectiveWpm.isFinite &&
              e.samples >= _minimumSamples(e.skill),
        )
        .toList();
    final limit = switch (goal) {
      LearningGoal.firstQso => 13,
      LearningGoal.conversation => 20,
      LearningGoal.contest => 25,
    };
    final milestones = <RouteMilestone>[];
    for (final speed in speeds.where((s) => s <= limit)) {
      for (final skill in _skillsFor(goal, speed)) {
        milestones.add(
          RouteMilestone(
            skill: skill,
            wpm: speed,
            attempts: eligible
                .where((e) => e.skill == skill && e.effectiveWpm >= speed)
                .length,
          ),
        );
      }
    }
    return LearningRoute._(goal, milestones);
  }

  static int _minimumSamples(RouteSkill skill) => switch (skill) {
    RouteSkill.copying => 50,
    RouteSkill.sending => 5,
    RouteSkill.information || RouteSkill.qso || RouteSkill.contest => 3,
    RouteSkill.story => 2,
    _ => 1,
  };

  static List<RouteSkill> _skillsFor(LearningGoal goal, int speed) => [
    RouteSkill.copying,
    RouteSkill.sending,
    RouteSkill.words,
    if (speed >= 13) RouteSkill.phrases,
    if (speed >= 13) RouteSkill.information,
    if (speed >= 13) RouteSkill.qso,
    if (goal == LearningGoal.conversation && speed >= 18) RouteSkill.story,
    if (goal == LearningGoal.contest && speed >= 15) RouteSkill.contest,
  ];
}
