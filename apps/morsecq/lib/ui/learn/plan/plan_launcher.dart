import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morse_core/morse_core.dart';

import '../../../training/training_controller.dart';
import '../../../training/training_plan.dart';
import '../learn_playback.dart';
import '../onboarding/first_lesson_screen.dart';
import '../receive/receive_drill_screen.dart';
import '../send/send_practice_screen.dart';
import '../comprehension/listening_comprehension_screen.dart';
import '../qso/qso_setup_screen.dart';

/// Opens the drill screen for one daily-plan step. The step's content is
/// frozen by the plan (speeds, seed, pool); completion is recorded by the
/// controller in the same write as the exercise.
Future<void> openPlanStep(
  BuildContext context, {
  required TrainingController controller,
  required LearnPlaybackFactory playback,
  required PlanStep step,
}) async {
  final navigator = Navigator.of(context);
  if (step.kind == PlanStepKind.comprehension ||
      step.kind == PlanStepKind.qso) {
    final frozen = await controller.startGoalPlanStep(step);
    final settings = controller.todayPlan!.settingsOf(frozen);
    final timing = MorseTiming(
      wpm: settings.characterWpm,
      farnsworthWpm: settings.effectiveWpm < settings.characterWpm
          ? settings.effectiveWpm
          : null,
    );
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => frozen.kind == PlanStepKind.comprehension
            ? ListeningComprehensionScreen(
                controller: controller,
                playback: playback,
                initialMode: ListeningMode.values.firstWhere(
                  (mode) => mode.name == frozen.pool.single,
                  orElse: () => ListeningMode.words,
                ),
                planStepId: frozen.id,
                practiceTiming: timing,
              )
            : QsoSetupScreen(
                controller: controller,
                playback: playback,
                initialScenario: QsoScenario.parse(frozen.pool.single),
                practiceTiming: timing,
                planStepId: frozen.id,
              ),
      ),
    );
    return;
  }
  if (step.kind == PlanStepKind.intro) {
    final session = await controller.startPlanIntroStep(step);
    await navigator.push(
      MaterialPageRoute<Object?>(
        builder: (_) => FirstLessonScreen(
          controller: controller,
          playback: playback,
          trialSession: session,
        ),
      ),
    );
    return;
  }
  if (step.kind == PlanStepKind.send) {
    final session = await controller.startPlanSendStep(step);
    await navigator.push(
      MaterialPageRoute<Object?>(
        builder: (_) => SendPracticeScreen(
          controller: controller,
          playback: playback,
          session: session,
          nextSession: () => controller.startPlanSendStep(step),
        ),
      ),
    );
    return;
  }
  final session = await controller.startPlanReceiveStep(step);
  await navigator.push(
    MaterialPageRoute<Object?>(
      builder: (_) => ReceiveDrillScreen(
        controller: controller,
        playback: playback,
        session: session,
      ),
    ),
  );
}
