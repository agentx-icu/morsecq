import 'dart:math';

import 'package:morse_core/morse_core.dart';

part 'listening_material.dart';
part 'listening_attempt.dart';

/// Head-copy skills: recognise a complete sound pattern, then retain meaning.
/// All practice text is original and ships offline.
enum ListeningMode { words, phrases, qso, pota, story }

enum ListeningField {
  answer,
  callsign,
  otherCallsign,
  name,
  qth,
  rst,
  park,
  person,
  destination,
  time,
  action,
}

final class ListeningQuestion {
  ListeningQuestion({
    required this.field,
    required String answer,
    List<String> alternatives = const [],
  }) : answer = answer.trim(),
       alternatives = List.unmodifiable(alternatives) {
    if (this.answer.isEmpty ||
        this.answer.length > 200 ||
        alternatives.length > 8 ||
        alternatives.any((a) => a.trim().isEmpty || a.length > 200)) {
      throw ArgumentError('Listening answers must not be empty');
    }
  }

  final ListeningField field;
  final String answer;
  final List<String> alternatives;

  Map<String, Object?> toJson() => {
    'field': field.name,
    'answer': answer,
    'alternatives': alternatives,
  };

  factory ListeningQuestion.fromJson(Map<String, Object?> json) {
    try {
      return ListeningQuestion(
        field: ListeningField.values.firstWhere((f) => f.name == json['field']),
        answer: json['answer'] as String,
        alternatives: (json['alternatives'] as List<Object?>? ?? const [])
            .cast<String>(),
      );
    } on Object {
      throw const FormatException('Invalid listening question');
    }
  }

  bool accepts(String input) {
    final actual = _normalize(input, field);
    return actual.isNotEmpty &&
        [answer, ...alternatives].any((a) => _normalize(a, field) == actual);
  }

  static String _normalize(String value, ListeningField field) {
    final upper = value.toUpperCase().trim();
    if (field == ListeningField.park) {
      return upper.replaceAll(RegExp(r'[\s-]'), '');
    }
    if (field == ListeningField.callsign ||
        field == ListeningField.otherCallsign ||
        field == ListeningField.rst) {
      return upper.replaceAll(RegExp(r'\s'), '');
    }
    return upper
        .replaceAll(RegExp(r'[.,!?;:]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

final class ListeningExercise {
  ListeningExercise({
    required this.mode,
    required this.spokenText,
    required List<ListeningQuestion> questions,
    List<String> missingSymbols = const [],
  }) : questions = List.unmodifiable(questions),
       missingSymbols = List.unmodifiable(missingSymbols) {
    if (spokenText.trim().isEmpty ||
        spokenText.length > 800 ||
        spokenText
            .split('')
            .any(
              (c) => c.trim().isNotEmpty && MorseAlphabet.encodeChar(c) == null,
            ) ||
        missingSymbols.any((c) => c.length != 1 || !spokenText.contains(c)) ||
        questions.isEmpty ||
        questions.length > 12 ||
        questions.map((q) => q.field).toSet().length != questions.length) {
      throw ArgumentError(
        'An exercise needs text and distinct question fields',
      );
    }
  }

  final ListeningMode mode;
  final String spokenText;
  final List<ListeningQuestion> questions;
  final List<String> missingSymbols;
  bool get previewRequired => missingSymbols.isNotEmpty;

  Map<String, Object?> toJson() => {
    'mode': mode.name,
    'spokenText': spokenText,
    'questions': questions.map((q) => q.toJson()).toList(),
    'missingSymbols': missingSymbols,
  };

  factory ListeningExercise.fromJson(Map<String, Object?> json) {
    try {
      return ListeningExercise(
        mode: ListeningMode.values.firstWhere((m) => m.name == json['mode']),
        spokenText: json['spokenText'] as String,
        questions: [
          for (final q in json['questions'] as List<Object?>)
            ListeningQuestion.fromJson((q as Map).cast<String, Object?>()),
        ],
        missingSymbols: (json['missingSymbols'] as List<Object?>? ?? const [])
            .cast<String>(),
      );
    } on Object {
      throw const FormatException('Invalid listening exercise');
    }
  }

  ListeningExercise forAlphabet(Iterable<String> allowedChars) {
    final allowed = allowedChars.map((c) => c.toUpperCase()).toSet();
    final missing =
        spokenText
            .split('')
            .where((c) => c.trim().isNotEmpty)
            .toSet()
            .difference(allowed)
            .toList()
          ..sort();
    return ListeningExercise(
      mode: mode,
      spokenText: spokenText,
      questions: questions,
      missingSymbols: missing,
    );
  }

  /// A saved seed regenerates the same lesson. When no complete candidate
  /// fits the learned alphabet, return an explicitly assisted preview.
  factory ListeningExercise.generate({
    required ListeningMode mode,
    required int seed,
    Iterable<String>? allowedChars,
  }) {
    final all = _listeningCandidates(mode);
    final allowed = allowedChars?.map((c) => c.toUpperCase()).toSet();
    Set<String> symbols(ListeningExercise e) =>
        e.spokenText.split('').where((c) => c.trim().isNotEmpty).toSet();
    final eligible = allowed == null
        ? all
        : all.where((e) => symbols(e).difference(allowed).isEmpty).toList();
    final choices = eligible.isEmpty ? all : eligible;
    final chosen = choices[Random(seed).nextInt(choices.length)];
    final missing = allowed == null
        ? <String>[]
        : (symbols(chosen).difference(allowed).toList()..sort());
    return ListeningExercise(
      mode: mode,
      spokenText: chosen.spokenText,
      questions: chosen.questions,
      missingSymbols: missing,
    );
  }

  ListeningScore score(Map<ListeningField, String> answers) => ListeningScore(
    mode: mode,
    results: {
      for (final q in questions) q.field: q.accepts(answers[q.field] ?? ''),
    },
    previewRequired: previewRequired,
  );
}
