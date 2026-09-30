import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/reference/reference_abbreviations.dart';
import 'package:morsecq/ui/reference/reference_catalog.dart';
import 'package:morsecq/ui/reference/reference_mnemonics.dart';

void main() {
  group('ReferenceCatalog', () {
    test('alphabet has A-Z and 0-9 in that order', () {
      final labels = ReferenceCatalog.alphabet.map((e) => e.label).toList();
      expect(labels.length, 36);
      expect(labels.first, 'A');
      expect(labels[25], 'Z');
      expect(labels[26], '0');
      expect(labels.last, '9');
    });

    test('punctuation is everything else in the international table', () {
      final int total = MorseAlphabet.international.length;
      expect(
        ReferenceCatalog.alphabet.length + ReferenceCatalog.punctuation.length,
        total,
      );
      expect(ReferenceCatalog.punctuation.any((e) => e.label == '?'), isTrue);
      expect(ReferenceCatalog.punctuation.any((e) => e.label == 'A'), isFalse);
    });

    test('every alphabet entry has a mnemonic with its spoken rhythm', () {
      for (final entry in ReferenceCatalog.alphabet) {
        expect(entry.mnemonic, isNotNull, reason: entry.label);
        expect(
          entry.mnemonic,
          contains(ReferenceMnemonics.spokenRhythm(entry.pattern)),
          reason: entry.label,
        );
      }
      final a = ReferenceCatalog.alphabet.first;
      expect(a.mnemonic, startsWith('A: di-DAH'));
    });

    test('prosigns are bracketed, playable and explained', () {
      for (final entry in ReferenceCatalog.prosigns) {
        expect(entry.label, matches(RegExp(r'^<[A-Z]+>$')));
        expect(MorseEncoder.toPattern(entry.playText), entry.pattern);
        expect(entry.meaning, isNotEmpty, reason: entry.label);
      }
    });

    test('Q-codes carry the standard set with meanings', () {
      final labels = ReferenceCatalog.qCodes.map((e) => e.label).toSet();
      for (final code in <String>[
        'QRL', 'QRM', 'QRN', 'QRO', 'QRP', 'QRQ', 'QRS', 'QRT', 'QRU', //
        'QRV', 'QRX', 'QRZ', 'QSB', 'QSL', 'QSO', 'QSY', 'QTH',
      ]) {
        expect(labels, contains(code));
      }
      for (final entry in ReferenceCatalog.qCodes) {
        expect(entry.meaning, isNotEmpty, reason: entry.label);
        expect(entry.pattern, MorseEncoder.toPattern(entry.label));
      }
    });

    test('every trainer CW abbreviation has a meaning', () {
      final labels = ReferenceCatalog.abbreviations.map((e) => e.label).toList();
      for (final name in WordLists.cwAbbreviations) {
        expect(labels, contains(name));
        expect(ReferenceAbbreviations.meaningOf(name), isNotEmpty, reason: name);
      }
      expect(labels.toSet().length, labels.length, reason: 'no duplicates');
    });

    test('Koch order carries 1-based positions matching MorseAlphabet', () {
      final koch = ReferenceCatalog.koch;
      expect(koch.length, MorseAlphabet.kochOrder.length);
      for (int i = 0; i < koch.length; i++) {
        expect(koch[i].position, i + 1);
        expect(koch[i].label, MorseAlphabet.kochOrder[i]);
      }
      expect(koch.first.label, 'K');
      expect(koch.last.label, '<AR>');
      expect(koch.last.pattern, MorseAlphabet.prosigns['AR']);
    });

    test('ids are unique across the whole catalog', () {
      final ids = ReferenceCatalog.all.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('ReferenceCatalog.search', () {
    test('empty query returns every section', () {
      expect(ReferenceCatalog.search('').keys, ReferenceSection.values);
    });

    test('matches labels case-insensitively across sections', () {
      final hits = ReferenceCatalog.search('qrl');
      expect(hits.keys, <ReferenceSection>[ReferenceSection.qCodes]);
      expect(hits[ReferenceSection.qCodes]!.single.label, 'QRL');
    });

    test('matches meanings', () {
      final hits = ReferenceCatalog.search('who is calling');
      expect(hits[ReferenceSection.qCodes]!.single.label, 'QRZ');
    });

    test('matches raw and display patterns', () {
      expect(
        ReferenceCatalog.search('.-.-.')[ReferenceSection.prosigns]!.single.label,
        '<AR>',
      );
      expect(
        ReferenceCatalog.search('−−−')[ReferenceSection.alphabet]!
            .any((e) => e.label == 'O'),
        isTrue,
      );
    });

    test('a character shows up in alphabet and Koch order', () {
      final hits = ReferenceCatalog.search('K');
      expect(hits[ReferenceSection.alphabet]!.any((e) => e.label == 'K'), isTrue);
      expect(hits[ReferenceSection.koch]!.first.label, 'K');
      expect(hits[ReferenceSection.koch]!.first.position, 1);
    });

    test('no hits gives an empty map', () {
      expect(ReferenceCatalog.search('zzzzzz'), isEmpty);
    });
  });

  group('ReferenceMnemonics.spokenRhythm', () {
    test('voices dits and dahs the way operators do', () {
      expect(ReferenceMnemonics.spokenRhythm('.-'), 'di-DAH');
      expect(ReferenceMnemonics.spokenRhythm('-...'), 'DAH-di-di-dit');
      expect(ReferenceMnemonics.spokenRhythm('.'), 'dit');
      expect(ReferenceMnemonics.spokenRhythm('---'), 'DAH-DAH-DAH');
    });
  });
}
