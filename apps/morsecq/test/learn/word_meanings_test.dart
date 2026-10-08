import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/receive/word_meanings.dart';

void main() {
  test('every built-in common word has English and both Chinese meanings', () {
    expect(kCommonWordMeanings.keys, unorderedEquals(WordLists.commonWords));
    for (final word in WordLists.commonWords) {
      final translations = kCommonWordMeanings[word]!;
      for (final language in <String>['en', 'zh', 'zh_Hant']) {
        expect(
          translations[language]?.trim(),
          isNotEmpty,
          reason: '$word $language',
        );
      }
    }
  });

  test('script and region variants resolve Traditional Chinese content', () {
    expect(
      wordMeanings(
        'RADIO HEAR',
        const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
      ),
      <(String, String)>[('RADIO', '無線電；收音機'), ('HEAR', '聽見')],
    );
    expect(
      wordMeanings(
        'RADIO',
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ),
      <(String, String)>[('RADIO', '无线电；收音机')],
    );
  });

  test('unsupported languages fall back to English definitions', () {
    expect(wordMeanings('THE', const Locale('fr')), <(String, String)>[
      ('THE', 'indicates a specific person or thing'),
    ]);
  });

  test('meanings are distinct and follow the transmitted word order', () {
    expect(
      wordMeanings('  radio\nHEAR\tRadio THE ', const Locale('zh')),
      <(String, String)>[
        ('RADIO', '无线电；收音机'),
        ('HEAR', '听见'),
        ('THE', '这／那；特指的人或事物'),
      ],
    );
  });

  test('unknown and custom vocabulary does not invent a definition', () {
    expect(wordMeanings('BI1ABC CQ FOO', const Locale('zh')), isEmpty);
    expect(wordMeanings('', const Locale('en')), isEmpty);
  });

  test(
    'long custom word rounds keep the explanation list to eight entries',
    () {
      final meanings = wordMeanings(
        'THE BE TO OF AND A IN THAT HAVE I',
        const Locale('en'),
      );
      expect(meanings.map((entry) => entry.$1), <String>[
        'THE',
        'BE',
        'TO',
        'OF',
        'AND',
        'A',
        'IN',
        'THAT',
      ]);
    },
  );
}
