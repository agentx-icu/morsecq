import 'package:morse_trainer/morse_trainer.dart';
import '../../../i18n/l10n_extension.dart';

String goalLabel(S s, LearningGoal goal) => switch (goal) {
  LearningGoal.firstQso => s.goalsFirstQso,
  LearningGoal.conversation => s.goalsConversation,
  LearningGoal.contest => s.goalsContest,
};

String skillLabel(S s, RouteSkill skill) => switch (skill) {
  RouteSkill.copying => s.goalsCopying,
  RouteSkill.sending => s.goalsSending,
  RouteSkill.words => s.goalsWords,
  RouteSkill.phrases => s.goalsPhrases,
  RouteSkill.information => s.goalsInformation,
  RouteSkill.story => s.goalsStory,
  RouteSkill.qso => s.goalsQso,
  RouteSkill.contest => s.goalsCompetition,
};
