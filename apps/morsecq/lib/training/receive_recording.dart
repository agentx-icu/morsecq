import 'receive_session.dart';
import 'training_controller.dart';
import 'package:morse_trainer/morse_trainer.dart';

/// Recording a finished [ReceiveSession]; an extension so the controller
/// stays within the size gate. Exported by `training_controller.dart`.
extension ReceiveSessionRecording on TrainingController {
  /// Folds a finished receive session into progress (stats, streak, SRS,
  /// confusion) and, for lesson sessions, applies the Koch unlock rule.
  /// A session played under radio conditions (F11) is recorded with its
  /// scenario and earns activity only.
  Future<ReceiveOutcome> recordReceiveSession(ReceiveSession session) {
    final score = session.finish();
    final reference = session.sourceRef;
    final retry = reference?.startsWith('mistake:') ?? false;
    final notebook = progress.mistakeNotebook.recordExercise(
      exerciseId: session.id,
      assisted: session.assistance.isNotEmpty,
      retryEntryId: retry ? reference!.substring('mistake:'.length) : null,
      attempts: [
        for (final round in session.rounds)
          MistakeAttempt(
            target: round.drill.text,
            answer: round.answer,
            source: session.source,
            drillKind: session.kind.name,
            at: round.score.at ?? now(),
            characterWpm: session.timing.wpm,
            effectiveWpm: session.timing.farnsworthWpm ?? session.timing.wpm,
            sourceRef: reference,
            conditions: session.conditions?.forRound(round.index),
          ),
      ],
    );
    return recordExercise(
      score: score,
      id: session.id,
      source: session.source,
      assistance: session.assistance,
      answered: session.hasAnswers,
      lesson: session.lesson,
      timing: session.timing,
      active: session.activeElapsed,
      planStepId: session.planStepId,
      sourceRef: session.sourceRef,
      learned: session.learnedChars,
      countsTowardLesson: session.countsTowardLesson,
      conditions: session.conditions,
      mistakeNotebook: notebook,
    );
  }
}
