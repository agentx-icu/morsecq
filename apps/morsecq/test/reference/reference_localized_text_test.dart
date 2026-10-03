import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/reference/reference_catalog.dart';
import 'package:morsecq/ui/reference/reference_localized_text.dart';
import 'package:morsecq/ui/reference/reference_mnemonics.dart';
import 'package:morsecq/ui/reference/reference_qcodes.dart';

const Locale _zhHant = Locale.fromSubtags(
  languageCode: 'zh',
  scriptCode: 'Hant',
);
const Locale _zhHantTw = Locale.fromSubtags(
  languageCode: 'zh',
  scriptCode: 'Hant',
  countryCode: 'TW',
);

void main() {
  group('referenceLanguageKeys', () {
    test('most specific first, English last', () {
      expect(referenceLanguageKeys(_zhHantTw), <String>[
        'zh_Hant_TW',
        'zh_Hant',
        'zh_TW',
        'zh',
        'en',
      ]);
      expect(referenceLanguageKeys(const Locale('zh', 'TW')), <String>[
        'zh_TW',
        'zh',
        'en',
      ]);
      expect(referenceLanguageKeys(const Locale('en')), <String>['en']);
    });

    test('referenceLanguageFor picks the shipped column', () {
      expect(referenceLanguageFor(_zhHantTw), 'zh');
      expect(referenceLanguageFor(_zhHant), 'zh');
      expect(referenceLanguageFor(const Locale('zh', 'HK')), 'zh');
      expect(referenceLanguageFor(const Locale('fr', 'FR')), 'en');
    });
  });

  group('localizedReferenceText', () {
    const Map<String, String> row = <String, String>{
      'en': 'Hello',
      'zh': '你好',
      'zh_Hant': '妳好',
    };

    test('prefers script, then language, then English', () {
      expect(localizedReferenceText(row, _zhHantTw), '妳好');
      expect(localizedReferenceText(row, _zhHant), '妳好');
      expect(localizedReferenceText(row, const Locale('zh', 'CN')), '你好');
      expect(localizedReferenceText(row, const Locale('de')), 'Hello');
      expect(localizedReferenceText(const <String, String>{}, _zhHant), isNull);
    });

    test('Traditional Chinese UI reads the zh tables, not English', () {
      expect(ReferenceQCodes.meaning('QRZ', _zhHantTw), '谁在呼叫我？');
      expect(
        ReferenceQCodes.meaning('QRZ', const Locale('ko')),
        'Who is calling me?',
      );
      final ReferenceEntry a = ReferenceCatalog.alphabet.first;
      expect(a.mnemonic(_zhHant), startsWith('A：嘀嗒'));
      expect(a.mnemonic(_zhHantTw), a.mnemonic(const Locale('zh')));
      expect(a.mnemonic(const Locale('fr')), startsWith('A: di-DAH'));
    });
  });

  group('separator and rhythm by language code', () {
    test('full-width colon for zh and ja tags', () {
      expect(referenceLabelSeparator('zh'), '：');
      expect(referenceLabelSeparator('zh_Hant'), '：');
      expect(referenceLabelSeparator('zh-Hant-TW'), '：');
      expect(referenceLabelSeparator('ja'), '：');
      expect(referenceLabelSeparator('en'), ': ');
      expect(referenceLabelSeparator('fr_FR'), ': ');
    });

    test('a zh_Hant UI hears the Chinese rhythm', () {
      expect(ReferenceMnemonics.spokenRhythm('.-', language: 'zh_Hant'), '嘀嗒');
      expect(
        ReferenceMnemonics.spokenRhythm(
          '.-',
          language: referenceLanguageFor(_zhHantTw),
        ),
        '嘀嗒',
      );
      expect(ReferenceMnemonics.spokenRhythm('.-', language: 'de'), 'di-DAH');
    });

    test('forCharacter accepts tiered tags for phrases and notes', () {
      expect(
        ReferenceMnemonics.forCharacter('1', '.----', language: 'zh_Hant_TW'),
        ReferenceMnemonics.forCharacter('1', '.----', language: 'zh'),
      );
      expect(
        ReferenceMnemonics.forCharacter('A', '.-', language: 'zh_Hant'),
        'A：嘀嗒 — "a-PART"（英文口诀中重读音节为划）',
      );
      expect(
        ReferenceMnemonics.forCharacter('A', '.-', language: 'fr'),
        'A: di-DAH — "a-PART"',
      );
    });
  });
}
