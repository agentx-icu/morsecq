import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';

import 'training_controller.dart';

/// Persistence and crediting for the interactive QSO simulator (F02).
///
/// The session (text and state only — never a held key or playback) is
/// kept as a draft document so an interrupted QSO can be resumed. A
/// finished QSO is one exercise of source `qso`: activity credit only, its
/// semantic score never touches copying statistics or lesson unlocks.
extension QsoPractice on TrainingController {
  static const String draftDoc = 'qso_draft';
  static const String stationDoc = 'qso_station';

  /// Whether the course is far enough along for the simulator.
  bool get qsoUnlocked => currentLesson >= TrainingController.qsoFromLesson;

  Future<QsoStation?> loadQsoStation() async {
    try {
      final json = await readDoc(stationDoc);
      return json == null ? null : QsoStation.fromJson(json);
    } on Object {
      return null;
    }
  }

  Future<void> saveQsoStation(QsoStation station) =>
      writeDoc(stationDoc, station.normalized().toJson());

  Future<QsoSession?> loadQsoDraft() async {
    try {
      final json = await readDoc(draftDoc);
      final raw = json?['session'];
      if (raw is! Map<String, Object?>) return null;
      final session = QsoSession.fromJson(raw);
      return session.isDone ? null : session;
    } on Object {
      return null;
    }
  }

  Future<void> saveQsoDraft(QsoSession session) => session.isDone
      ? deleteDoc(draftDoc)
      : writeDoc(draftDoc, <String, Object?>{'session': session.toJson()});

  Future<void> discardQsoDraft() => deleteDoc(draftDoc);

  /// Credits a finished QSO once (its id is derived from the seed, so a
  /// resumed and finished session cannot be credited twice).
  Future<ReceiveOutcome> recordQso(QsoSession session, Duration active) {
    final sent = session.turns
        .where((t) => !t.fromRemote && (t.accepted ?? false))
        .map((t) => t.text)
        .join(' ');
    final score = SessionScore.evaluate(
      sent,
      sent,
      at: now(),
      drillKind: 'qso-sim',
    );
    return recordExercise(
      score: score,
      id: 'qso_${session.scenario.name}_${session.seed}',
      source: ExerciseSource.qso,
      assistance: <Assistance>{
        if (session.hints > 0) Assistance.hint,
        if (session.repeats > 0) Assistance.replay,
      },
      answered: session.learnerTurns > 0,
      completed: session.isDone,
      timing: MorseTiming(
        wpm: session.characterWpm,
        farnsworthWpm: session.effectiveWpm < session.characterWpm
            ? session.effectiveWpm
            : null,
      ),
      active: active,
    );
  }
}
