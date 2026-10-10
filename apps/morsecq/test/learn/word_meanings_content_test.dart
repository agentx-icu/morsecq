import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/learn/receive/word_meanings.dart';
import 'package:morsecq/ui/learn/receive/word_meanings_part_1.dart';
import 'package:morsecq/ui/learn/receive/word_meanings_part_2.dart';
import 'package:morsecq/ui/learn/receive/word_meanings_part_3.dart';
import 'package:morsecq/ui/learn/receive/word_meanings_part_4.dart';

/// Characters that only exist in one of the two Chinese scripts. A word's
/// Simplified meaning must not use the Traditional form and vice versa.
const String _traditionalOnly = '這個為們說時對會來沒裡樣關麼還開過現點與從';
const String _simplifiedOnly = '这个为们说时对会来没里样关么还开过现点与从';

void main() {
  final parts = [
    wordMeaningsPart1,
    wordMeaningsPart2,
    wordMeaningsPart3,
    wordMeaningsPart4,
  ];

  test('the four content parts never define a word twice', () {
    final seen = <String, int>{};
    for (final (i, part) in parts.indexed) {
      for (final word in part.keys) {
        expect(
          seen[word],
          isNull,
          reason: '$word in parts ${seen[word]} and $i',
        );
        seen[word] = i;
      }
    }
    expect(seen.length, kCommonWordMeanings.length);
    expect(seen.keys.toSet(), WordLists.commonWords.toSet());
  });

  test('words are transmittable Morse words', () {
    for (final word in kCommonWordMeanings.keys) {
      expect(word, matches(RegExp(r'^[A-Z0-9]+$')), reason: word);
    }
  });

  test('each script uses its own character forms', () {
    for (final part in parts) {
      part.forEach((word, meaning) {
        final (english, simplified, traditional) = meaning;
        expect(english.trim(), isNotEmpty, reason: word);
        expect(
          english.toUpperCase(),
          isNot(word),
          reason: '$word: a meaning, not the word itself',
        );
        for (final ch in _traditionalOnly.split('')) {
          expect(simplified, isNot(contains(ch)), reason: '$word zh: $ch');
        }
        for (final ch in _simplifiedOnly.split('')) {
          expect(
            traditional,
            isNot(contains(ch)),
            reason: '$word zh_Hant: $ch',
          );
        }
      });
    }
  });

  test('languages without Chinese content read the English meaning', () {
    for (final locale in S.supportedLocales) {
      if (locale.languageCode == 'zh') continue;
      expect(
        wordMeanings('RADIO', locale).single.$2,
        kCommonWordMeanings['RADIO']!['en'],
        reason: '$locale',
      );
    }
  });
}
