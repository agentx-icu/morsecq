part of 'listening_comprehension.dart';

final class ListeningScore {
  ListeningScore({
    required this.mode,
    required Map<ListeningField, bool> results,
    required this.previewRequired,
  }) : results = Map.unmodifiable(results);

  final ListeningMode mode;
  final Map<ListeningField, bool> results;
  final bool previewRequired;
  int get correct => results.values.where((v) => v).length;
  int get total => results.length;

  ListeningAttempt attempt({
    required String id,
    required DateTime at,
    required double characterWpm,
    required double effectiveWpm,
    bool replayed = false,
    bool revealed = false,
    String? planStepId,
    ListeningExercise? exercise,
    Map<ListeningField, String> answers = const {},
    String? retryEntryId,
  }) => ListeningAttempt(
    id: id,
    at: at,
    mode: mode,
    correct: correct,
    total: total,
    characterWpm: characterWpm,
    effectiveWpm: effectiveWpm,
    assisted: previewRequired || replayed || revealed,
    planStepId: planStepId,
    exercise: exercise,
    answers: answers,
    retryEntryId: retryEntryId,
  );
}

/// Listening evidence is separate from character SRS and Koch unlocks.
final class ListeningAttempt {
  ListeningAttempt({
    required this.id,
    required this.at,
    required this.mode,
    required this.correct,
    required this.total,
    required this.characterWpm,
    required this.effectiveWpm,
    this.assisted = false,
    this.planStepId,
    this.exercise,
    Map<ListeningField, String> answers = const {},
    this.retryEntryId,
  }) : answers = Map.unmodifiable(answers) {
    if (id.trim().isEmpty ||
        total <= 0 ||
        total > 100 ||
        correct < 0 ||
        correct > total ||
        !characterWpm.isFinite ||
        !effectiveWpm.isFinite ||
        characterWpm <= 0 ||
        characterWpm > 100 ||
        effectiveWpm <= 0 ||
        effectiveWpm > characterWpm ||
        (planStepId != null && planStepId!.trim().isEmpty) ||
        (retryEntryId != null && retryEntryId!.trim().isEmpty) ||
        answers.values.any((value) => value.length > 800) ||
        (exercise == null && answers.isNotEmpty) ||
        (exercise != null &&
            (exercise!.mode != mode ||
                exercise!.score(answers).correct != correct ||
                exercise!.questions.length != total ||
                answers.keys.any(
                  (f) => !exercise!.questions.any((q) => q.field == f),
                ) ||
                (exercise!.previewRequired && !assisted)))) {
      throw ArgumentError('Invalid listening evidence');
    }
  }

  final String id;
  final DateTime at;
  final ListeningMode mode;
  final int correct;
  final int total;
  final double characterWpm;
  final double effectiveWpm;
  final bool assisted;
  final String? planStepId;
  final ListeningExercise? exercise;
  final Map<ListeningField, String> answers;
  final String? retryEntryId;
  double get accuracy => correct / total;
  bool get independent => !assisted;

  Map<String, Object?> toJson() => {
    'id': id,
    'at': at.toIso8601String(),
    'mode': mode.name,
    'correct': correct,
    'total': total,
    'characterWpm': characterWpm,
    'effectiveWpm': effectiveWpm,
    'assisted': assisted,
    if (planStepId != null) 'planStepId': planStepId,
    if (exercise != null) 'exercise': exercise!.toJson(),
    if (exercise != null)
      'answers': {for (final e in answers.entries) e.key.name: e.value},
    if (retryEntryId != null) 'retryEntryId': retryEntryId,
  };

  factory ListeningAttempt.fromJson(Map<String, Object?> json) {
    try {
      if (json.containsKey('assisted') && json['assisted'] is! bool) {
        throw const FormatException('Invalid listening assistance');
      }
      return ListeningAttempt(
        id: json['id'] as String,
        at: DateTime.parse(json['at'] as String),
        mode: ListeningMode.values.firstWhere((m) => m.name == json['mode']),
        correct: json['correct'] as int,
        total: json['total'] as int,
        characterWpm: (json['characterWpm'] as num).toDouble(),
        effectiveWpm: (json['effectiveWpm'] as num).toDouble(),
        assisted: json['assisted'] as bool? ?? false,
        planStepId: json['planStepId'] as String?,
        exercise: json['exercise'] == null
            ? null
            : ListeningExercise.fromJson(
                (json['exercise'] as Map).cast<String, Object?>(),
              ),
        answers: {
          for (final e in (json['answers'] as Map? ?? {}).entries)
            ListeningField.values.firstWhere((f) => f.name == e.key):
                e.value as String,
        },
        retryEntryId: json['retryEntryId'] as String?,
      );
    } on Object {
      throw const FormatException('Invalid listening attempt');
    }
  }
}
