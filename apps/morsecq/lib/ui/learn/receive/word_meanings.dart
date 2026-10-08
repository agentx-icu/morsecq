import 'package:flutter/widgets.dart' show Locale;

import '../../reference/reference_localized_text.dart';
import 'word_meanings_part_1.dart';
import 'word_meanings_part_2.dart';
import 'word_meanings_part_3.dart';
import 'word_meanings_part_4.dart';

/// Word meanings are lesson content, with the same locale fallback as the
/// reference catalogue. They are shown after a word has been answered.
final Map<String, Map<String, String>> kCommonWordMeanings = Map.unmodifiable({
  for (final part in <Map<String, (String, String, String)>>[
    wordMeaningsPart1,
    wordMeaningsPart2,
    wordMeaningsPart3,
    wordMeaningsPart4,
  ])
    for (final entry in part.entries)
      entry.key: Map<String, String>.unmodifiable({
        'en': entry.value.$1,
        'zh': entry.value.$2,
        'zh_Hant': entry.value.$3,
      }),
});

/// Distinct known words, in transmission order, up to eight explanations.
/// Custom words without a content entry are skipped. Definitions are short
/// common meanings for practice, rather than an exhaustive dictionary.
List<(String, String)> wordMeanings(String text, Locale locale) {
  final meanings = <(String, String)>[];
  final seen = <String>{};
  for (final word in text.split(RegExp(r'\s+'))) {
    final label = word.toUpperCase();
    if (label.isEmpty || !seen.add(label)) continue;
    final translations = kCommonWordMeanings[label];
    if (translations == null) continue;
    final meaning = localizedReferenceText(translations, locale);
    if (meaning != null) meanings.add((label, meaning));
    if (meanings.length == 8) break;
  }
  return meanings;
}
