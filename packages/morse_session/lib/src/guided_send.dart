import 'package:morse_trainer/morse_trainer.dart';

/// A short, fixed sequence: one symbol, the second symbol, then groups.
enum GuidedSendStage {
  k('K', 'send-guide-k'),
  m('M', 'send-guide-m'),
  pair('KM', 'send-guide-pair'),
  group('KMKMK', 'send-guide-group');

  const GuidedSendStage(this.target, this.drillKind);

  final String target;
  final String drillKind;

  GuidedSendStage? get next =>
      index + 1 < values.length ? values[index + 1] : null;

  static GuidedSendStage? fromKind(String? kind) =>
      values.where((stage) => stage.drillKind == kind).firstOrNull;
}

/// Progress comes from completed, exactly decoded sending, never playback.
abstract final class GuidedSending {
  static GuidedSendStage? nextStage(List<SessionSummary> history) {
    GuidedSendStage? stage = GuidedSendStage.k;
    // TrainerProgress appends history in attempt order. Keep that order even
    // for tied timestamps or a system clock adjusted during practice.
    for (final record in history) {
      if (stage == null) break;
      if (record.source == ExerciseSource.send &&
          record.drillKind == stage.drillKind &&
          record.completed &&
          record.isKnownUnassisted &&
          record.totalChars == stage.target.length &&
          record.strictAccuracy == 1) {
        stage = stage.next;
      }
    }
    return stage;
  }

  static bool needed(List<SessionSummary> history) =>
      !history.any((r) => r.source == ExerciseSource.send) ||
      (history.any((r) => GuidedSendStage.fromKind(r.drillKind) != null) &&
          nextStage(history) != null);
}
