import 'package:morse_trainer/morse_trainer.dart';
import 'package:morse_core/morse_core.dart';

import 'drill_catalog.dart';
import 'send_session.dart';
import 'training_controller.dart';

export 'guided_send.dart';

/// Free send practice targets (re-exported by `training_controller.dart`).
extension SendPracticeStart on TrainingController {
  /// One short target (a word if the learned set allows, else a group).
  SendSession startSendSession() {
    if (GuidedSending.needed(progress.history)) return startGuidedSendSession();
    return startFreeSendSession();
  }

  /// Resume the next unpassed guide stage, or start at K after completion.
  /// [restart] explicitly revisits K; [stage] lets a guide repeat a failure.
  SendSession startGuidedSendSession({
    GuidedSendStage? stage,
    bool restart = false,
    String? planStepId,
    MorseTiming? timing,
  }) {
    final selected =
        stage ??
        (restart
            ? GuidedSendStage.k
            : GuidedSending.nextStage(progress.history)) ??
        GuidedSendStage.k;
    return SendSession(
      target: selected.target,
      timing: timing ?? trainerSettings.toTiming(),
      now: now,
      lesson: currentLesson,
      drillKind: selected.drillKind,
      planStepId: planStepId,
    );
  }

  /// Explicit free practice, also used after completing the guide.
  SendSession startFreeSendSession() {
    final chars = learnedChars;
    final words = WordDrill.commonWords(
      allowedChars: chars.toSet(),
      wordCount: 1,
    );
    final generator = words.hasCandidates
        ? words
        : RandomGroupsDrill(
            chars: chars,
            groupCount: 1,
            groupSize: TrainingController.sendTargetChars,
            weights: DrillCatalog(
              course: course,
              progress: progress,
              settings: trainerSettings,
            ).weights(),
          );
    return SendSession(
      target: generator.generate(random).text,
      timing: trainerSettings.toTiming(),
      now: now,
      lesson: currentLesson,
    );
  }
}
