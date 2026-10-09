import 'dart:convert';

import 'listening_comprehension.dart';
import 'morse_text.dart';

/// Semantic head-copy context: the complete audio and its information fields.
/// The learner's answers are never treated as a transcript of the audio.
final class MistakeListeningContext {
  MistakeListeningContext({
    required this.exercise,
    required Map<ListeningField, String> answers,
  }) : answers = Map.unmodifiable(answers);

  final ListeningExercise exercise;
  final Map<ListeningField, String> answers;

  bool get isCorrect {
    final score = exercise.score(answers);
    return score.correct == score.total;
  }

  String get answerSummary => [
    for (final question in exercise.questions)
      '${question.field.name}: ${answers[question.field] ?? ''}',
  ].join('\n');

  /// Missing symbols describe a learner's preview, rather than the exercise.
  /// Learning those symbols later must allow an independent retry.
  String get comparableKey {
    final snapshot = exercise.toJson()..remove('missingSymbols');
    snapshot['spokenText'] = MorseText.tokenize(exercise.spokenText).join();
    return jsonEncode(snapshot);
  }

  MistakeListeningContext withAnswers(Map<ListeningField, String> answers) =>
      MistakeListeningContext(exercise: exercise, answers: answers);

  Map<String, Object?> toJson() => {
    'exercise': exercise.toJson(),
    'answers': {for (final e in answers.entries) e.key.name: e.value},
  };

  static MistakeListeningContext? fromJson(Object? raw) {
    if (raw is! Map || raw['exercise'] is! Map || raw['answers'] is! Map) {
      return null;
    }
    try {
      final answers = <ListeningField, String>{};
      for (final entry in (raw['answers'] as Map).entries) {
        final field = ListeningField.values.firstWhere(
          (f) => f.name == entry.key,
        );
        if (entry.value is! String) return null;
        answers[field] = entry.value as String;
      }
      return MistakeListeningContext(
        exercise: ListeningExercise.fromJson(
          Map<String, Object?>.from(raw['exercise'] as Map),
        ),
        answers: answers,
      );
    } on Object {
      return null;
    }
  }
}
