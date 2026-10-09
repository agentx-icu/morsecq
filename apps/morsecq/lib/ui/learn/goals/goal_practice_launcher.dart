import 'dart:math';
import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import '../../../training/receive_session.dart';
import '../../../training/send_session.dart';
import '../../../training/training_controller.dart';
import '../comprehension/listening_comprehension_screen.dart';
import '../learn_playback.dart';
import '../onboarding/first_lesson_screen.dart';
import '../qso/qso_setup_screen.dart';
import '../receive/receive_drill_screen.dart';
import '../send/send_practice_screen.dart';

Future<void> openGoalPractice(
  BuildContext context,
  TrainingController controller,
  LearnPlaybackFactory playback,
  RouteMilestone milestone,
) async {
  final speed = max(
    controller.trainerSettings.characterWpm,
    milestone.wpm.toDouble(),
  );
  final timing = MorseTiming(
    wpm: speed,
    farnsworthWpm: milestone.wpm < speed ? milestone.wpm.toDouble() : null,
  );
  final chars = controller.learnedChars;
  Widget screen;
  switch (milestone.skill) {
    case RouteSkill.copying:
      screen = controller.learnerStage == LearnerStage.firstUse
          ? FirstLessonScreen(controller: controller, playback: playback)
          : ReceiveDrillScreen(
              controller: controller,
              playback: playback,
              session: ReceiveSession(
                kind: ReceiveDrillKind.groups,
                generator: RandomGroupsDrill(
                  chars: chars,
                  groupCount: 1,
                  groupSize: 5,
                ),
                chars: chars,
                timing: timing,
                charBudget: 50,
                source: ExerciseSource.focus,
                lesson: controller.currentLesson,
                learnedChars: chars.toSet(),
                random: controller.random,
                now: controller.now,
              ),
            );
    case RouteSkill.sending:
      SendSession make() => SendSession(
        target: RandomGroupsDrill(
          chars: chars,
          groupCount: 1,
          groupSize: 5,
        ).generate(controller.random).text,
        timing: timing,
        lesson: controller.currentLesson,
        now: controller.now,
      );
      screen = SendPracticeScreen(
        controller: controller,
        playback: playback,
        session: make(),
        nextSession: () async => make(),
        maxAttempts: 2,
      );
    case RouteSkill.qso:
    case RouteSkill.contest:
      screen = QsoSetupScreen(
        controller: controller,
        playback: playback,
        initialScenario: milestone.skill == RouteSkill.contest
            ? QsoScenario.contestExchange
            : QsoScenario.respondToCq,
        practiceTiming: timing,
      );
    default:
      screen = ListeningComprehensionScreen(
        controller: controller,
        playback: playback,
        practiceTiming: timing,
        initialMode: switch (milestone.skill) {
          RouteSkill.words => ListeningMode.words,
          RouteSkill.phrases => ListeningMode.phrases,
          RouteSkill.story => ListeningMode.story,
          _ => ListeningMode.qso,
        },
      );
  }
  await Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => screen));
}
