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

  /// Staged readiness for the simulator: symbols, shorthand practised, one
  /// exchange practised. Never a lesson number.
  QsoReadiness get qsoReadiness => QsoReadiness.of(
    learned: learnedChars,
    history: progress.history,
    now: now(),
    characterWpm: trainerSettings.characterWpm,
    effectiveWpm: trainerSettings.farnsworthWpm ?? trainerSettings.characterWpm,
  );

  /// Protocol meanings earn activity, never copying statistics or unlocks.
  Future<ReceiveOutcome> recordQsoProtocol(
    QsoProtocolAttempt attempt, {
    required MorseTiming timing,
    Duration active = Duration.zero,
  }) => recordExercise(
    score: SessionScore.evaluate(
      attempt.targetText,
      attempt.answerText,
      at: attempt.at,
      drillKind: QsoProtocolAttempt.drillKind,
    ),
    id: attempt.id,
    source: ExerciseSource.qso,
    sourceRef: attempt.sourceRef,
    assistance: const {},
    completed: attempt.completed,
    answered: attempt.answered > 0,
    timing: timing,
    active: active,
  );

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

  /// The saved draft: unfinished text state, or a finished QSO whose
  /// result was not saved yet (see [finishQso]).
  Future<QsoDraft?> loadQsoDraft() async {
    try {
      final json = await readDoc(draftDoc);
      final raw = json?['session'];
      if (raw is! Map<String, Object?>) return null;
      return QsoDraft(
        session: QsoSession.fromJson(raw),
        pendingText: json!['pendingText'] as String? ?? '',
        pendingId: json['pendingId'] as String?,
        typedReply: json['typedReply'] as bool? ?? false,
        pendingWasTyped:
            json['pendingWasTyped'] as bool? ??
            (json['typedReply'] as bool? ?? false),
        active: Duration(
          milliseconds: (json['activeMs'] as num?)?.toInt() ?? 0,
        ),
      );
    } on Object {
      return null;
    }
  }

  /// Keeps text and state only (never a held key or playback), including a
  /// keyed reply that was not sent yet and its submission id.
  Future<void> saveQsoDraft(
    QsoSession session, {
    String pendingText = '',
    String? pendingId,
    bool typedReply = false,
    bool pendingWasTyped = false,
    Duration active = Duration.zero,
  }) => writeDoc(draftDoc, <String, Object?>{
    'session': session.toJson(),
    'pendingText': pendingText,
    'pendingId': pendingId,
    'typedReply': typedReply,
    'pendingWasTyped': pendingWasTyped,
    'activeMs': active.inMilliseconds,
  });

  Future<void> discardQsoDraft() => deleteDoc(draftDoc);

  /// Parked finished QSOs, one document each (`qso_finished_<seed>`).
  static const String finishedPrefix = 'qso_finished_';

  static String _finishedDoc(QsoSession s) =>
      '$finishedPrefix${s.scenario.name}_${s.seed}'.toLowerCase();

  static DateTime? _completedAt(Map<String, Object?>? json) {
    final raw = json?['completedAt'];
    return raw is String ? DateTime.tryParse(raw) : null;
  }

  /// Records a finished QSO. It is first parked in its own document (never
  /// overwritten by another QSO), then credited, then removed — only once
  /// the result is on disk, so a crash or a failed write never loses it.
  /// [recoverFinishedQso] commits parked QSOs again; their ids are never
  /// evicted from de-duplication, so this cannot credit twice.
  Future<bool> finishQso(QsoSession session, Duration active) async {
    final doc = _finishedDoc(session);
    var completedAt = now();
    var completionDateKnown = true;
    try {
      // A retry preserves the first completion date, even across launches.
      final parked = await readDoc(doc);
      final originalDate = _completedAt(parked);
      completionDateKnown = parked == null || originalDate != null;
      completedAt = originalDate ?? completedAt;
      await writeDoc(doc, <String, Object?>{
        'session': session.toJson(),
        'activeMs': active.inMilliseconds,
        if (completionDateKnown) 'completedAt': completedAt.toIso8601String(),
      });
      await discardQsoDraft();
    } on Object {
      // Recording below still runs; only crash recovery is weaker.
    }
    final outcome = await recordQso(
      session,
      active,
      at: completedAt,
      completionDateKnown: completionDateKnown,
    );
    if (!outcome.saved) return false;
    try {
      await deleteDoc(doc);
    } on Object {
      // Committing it again later is a no-op (same, protected id).
    }
    return true;
  }

  /// Commits every QSO parked by [finishQso] whose save did not complete.
  /// Runs whenever learning data loads.
  Future<void> recoverFinishedQso() async {
    List<String> names;
    try {
      names = await docNames();
    } on Object {
      return;
    }
    for (final name in names.where((n) => n.startsWith(finishedPrefix))) {
      try {
        final json = await readDoc(name);
        final raw = json?['session'];
        if (raw is! Map<String, Object?>) continue;
        final session = QsoSession.fromJson(raw);
        final active = Duration(
          milliseconds: (json!['activeMs'] as num?)?.toInt() ?? 0,
        );
        final completedAt = _completedAt(json);
        final outcome = await recordQso(
          session,
          active,
          at: completedAt,
          completionDateKnown: completedAt != null,
        );
        if (outcome.saved) await deleteDoc(name);
      } on Object {
        // Tried again next time.
      }
    }
  }

  /// Credits a finished QSO once (its id is derived from the seed, so a
  /// resumed and finished session cannot be credited twice).
  Future<ReceiveOutcome> recordQso(
    QsoSession session,
    Duration active, {
    DateTime? at,
    bool completionDateKnown = true,
  }) {
    final sent = session.turns
        .where((t) => !t.fromRemote && (t.accepted ?? false))
        .map((t) => t.text)
        .join(' ');
    final score = SessionScore.evaluate(
      sent,
      sent,
      at: at ?? now(),
      drillKind: 'qso-sim',
    );
    return recordExercise(
      score: score,
      id: 'qso_${session.scenario.name}_${session.seed}',
      planStepId: session.planStepId,
      planAccuracy: session.answerStages > 0
          ? session.firstTryStages / session.answerStages
          : null,
      source: ExerciseSource.qso,
      sourceRef:
          'qso:${session.scenario.name}:${session.firstTryStages}/${session.answerStages}',
      assistance: <Assistance>{
        if (session.hints > 0) Assistance.hint,
        // Typed responses practise the protocol but do not demonstrate
        // independent sending. The protocol field score is still retained.
        if (session.typedReplies > 0) Assistance.hint,
        // Legacy parked results still restore activity, but an unknown
        // completion date cannot establish recent independent practice.
        if (!completionDateKnown) Assistance.hint,
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

/// A stored simulator draft.
final class QsoDraft {
  const QsoDraft({
    required this.session,
    this.pendingText = '',
    this.pendingId,
    this.typedReply = false,
    this.pendingWasTyped = false,
    this.active = Duration.zero,
  });

  final QsoSession session;

  /// A keyed reply that was not sent yet.
  final String pendingText;

  /// Its submission id, so sending it after a restore cannot double-submit.
  final String? pendingId;
  final bool typedReply;
  final bool pendingWasTyped;
  final Duration active;
}
