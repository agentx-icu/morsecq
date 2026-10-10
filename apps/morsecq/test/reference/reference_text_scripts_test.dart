import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/reference/text/reference_texts.dart';

/// Characters that only exist in one of the two Chinese scripts.
const String _traditionalOnly = '這個為們說時對會來沒裡樣關麼還開過現點與號電話';
const String _simplifiedOnly = '这个为们说时对会来没里样关么还开过现点与号电话';

Iterable<(String, String)> _texts(ReferenceText t) sync* {
  for (final (name, table) in [
    ('qCodes', t.qCodes),
    ('abbreviations', t.abbreviations),
    ('prosigns', t.prosigns),
    ('punctuation', t.punctuation),
    ('digitPhrases', t.digitPhrases),
  ]) {
    for (final e in table.entries) {
      yield ('$name[${e.key}]', e.value);
    }
  }
  yield ('phraseNote', t.phraseNote);
}

void main() {
  test('both Chinese reference texts exist', () {
    expect(kReferenceTexts.keys, containsAll(<String>['zh', 'zh_Hant']));
  });

  test('Simplified Chinese reference text uses Simplified forms', () {
    for (final (where, text) in _texts(kReferenceTexts['zh']!)) {
      for (final ch in _traditionalOnly.split('')) {
        expect(text, isNot(contains(ch)), reason: 'zh $where: $ch');
      }
    }
  });

  test('Traditional Chinese reference text uses Traditional forms', () {
    for (final (where, text) in _texts(kReferenceTexts['zh_Hant']!)) {
      for (final ch in _simplifiedOnly.split('')) {
        expect(text, isNot(contains(ch)), reason: 'zh_Hant $where: $ch');
      }
    }
  });

  test('no language leaves an untranslated placeholder or stray markup', () {
    kReferenceTexts.forEach((tag, t) {
      for (final (where, text) in _texts(t)) {
        expect(
          text,
          isNot(matches(RegExp(r'TODO|FIXME|\{\w+\}|<\w+>'))),
          reason: '$tag $where',
        );
        // The phrase note is appended to a phrase and starts with a space.
        if (where == 'phraseNote') continue;
        expect(text, text.trim(), reason: '$tag $where: stray whitespace');
      }
    });
  });
}
