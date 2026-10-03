import 'reference_localized_text.dart';

/// Mnemonics shown when a learner long-presses a character in the reference.
///
/// Two layers: the spoken rhythm (`di-DAH`, or `嘀嗒` in Chinese), derived
/// from the pattern so it can never drift from `MorseAlphabet`, and a memory
/// phrase whose syllable stress mirrors the rhythm (a stressed syllable is a
/// dah). The phrases are English and phonetic, so they stay English in every
/// language; other languages get a translated description where the phrase
/// is descriptive (digits) or an explanation note where it is phonetic.
abstract final class ReferenceMnemonics {
  /// Memory phrases for letters and digits, upper-case key.
  static const Map<String, String> phrases = <String, String>{
    'A': 'a-PART',
    'B': 'BOB is the man',
    'C': 'CO-ca CO-la',
    'D': 'DOG did it',
    'E': 'eh',
    'F': 'fetch a FIRE-man',
    'G': 'GOOD GRA-vy',
    'H': 'hip-pi-ty hop',
    'I': 'it is',
    'J': 'in JAWS JAWS JAWS',
    'K': 'KANG-a-ROO',
    'L': 'a-LIGHT-en-ing',
    'M': 'MM MM',
    'N': 'NA-vy',
    'O': 'OH MY GOD',
    'P': 'a PIZ-ZA pie',
    'Q': 'GOD SAVE the QUEEN',
    'R': 'ro-TA-tion',
    'S': 'si si si',
    'T': 'TALL',
    'U': 'u-ni-FORM',
    'V': 'vic-to-ry VEE (Beethoven\'s Fifth)',
    'W': 'the WORLD WAR',
    'X': 'EX-tra ex-PENSE',
    'Y': 'YEL-low YO-YO',
    'Z': 'ZINC ZOO-kee-per',
    '1': 'one dit, then four dahs',
    '2': 'two dits, then three dahs',
    '3': 'three dits, then two dahs',
    '4': 'four dits, then one dah',
    '5': 'five dits',
    '6': 'one dah, then four dits',
    '7': 'two dahs, then three dits',
    '8': 'three dahs, then two dits',
    '9': 'four dahs, then one dit',
    '0': 'five dahs',
  };

  /// Translated phrases, by language then character, for phrases that
  /// describe the pattern rather than sound it out (the digits). A letter
  /// missing here keeps its English phrase plus [phraseNotes].
  static const Map<String, Map<String, String>> localizedPhrases =
      <String, Map<String, String>>{
    'zh': <String, String>{
      '1': '一点，然后四划',
      '2': '两点，然后三划',
      '3': '三点，然后两划',
      '4': '四点，然后一划',
      '5': '五点',
      '6': '一划，然后四点',
      '7': '两划，然后三点',
      '8': '三划，然后两点',
      '9': '四划，然后一点',
      '0': '五划',
    },
  };

  /// Explanation appended to an English phonetic phrase in other languages.
  static const Map<String, String> phraseNotes = <String, String>{
    'zh': '（英文口诀中重读音节为划）',
  };

  /// `.-` -> `di-DAH`, `-...` -> `DAH-di-di-dit`, `.` -> `dit`.
  ///
  /// The last dit is voiced `dit`; every dit before the end is `di`, the
  /// way operators say patterns aloud. In Chinese (any `zh` tag:
  /// `zh`, `zh_Hans`, `zh_Hant_TW`) the same pattern is read `嘀嗒` /
  /// `嗒嘀嘀嘀`, as Chinese hams voice it.
  static String spokenRhythm(String pattern, {String language = 'en'}) {
    final List<String> parts = <String>[];
    final bool zh = referenceLanguageCode(language) == 'zh';
    for (int i = 0; i < pattern.length; i++) {
      final String ch = pattern[i];
      if (ch == '-') {
        parts.add(zh ? '嗒' : 'DAH');
      } else if (ch == '.') {
        parts.add(zh ? '嘀' : (i == pattern.length - 1 ? 'dit' : 'di'));
      }
    }
    return parts.join(zh ? '' : '-');
  }

  /// Full mnemonic line for a character with [pattern] in [language], e.g.
  /// `A: di-DAH — "a-PART"` or `A：嘀嗒 — "a-PART"（英文口诀中重读音节为划）`.
  /// Falls back to the rhythm alone for characters without a phrase
  /// (punctuation). [language] may be any tag (`zh_Hant`); translated
  /// phrases and notes are looked up script/region-aware, like the rest of
  /// the reference content (`referenceLanguageKeys`).
  static String forCharacter(
    String char,
    String pattern, {
    String language = 'en',
  }) {
    final String head =
        '$char${referenceLabelSeparator(language)}${spokenRhythm(pattern, language: language)}';
    final String key = char.toUpperCase();
    final String? phrase = phrases[key];
    if (phrase == null) return head;
    final List<String> keys = referenceLanguageKeysForTag(language);
    for (final String k in keys) {
      final String? local = localizedPhrases[k]?[key];
      if (local != null) return '$head — $local';
    }
    final String note =
        keys.map((String k) => phraseNotes[k]).nonNulls.firstOrNull ?? '';
    return '$head — "$phrase"$note';
  }

  /// [forCharacter] for every language in [kReferenceLanguages].
  static Map<String, String> linesForCharacter(String char, String pattern) =>
      <String, String>{
        for (final String language in kReferenceLanguages)
          language: forCharacter(char, pattern, language: language),
      };

  /// Rhythm-only lines (`<AR>: di-DAH-di-DAH-dit`) for every language, used
  /// for prosigns, which have no memory phrase.
  static Map<String, String> rhythmLines(
    String label,
    String pattern,
  ) => <String, String>{
    for (final String language in kReferenceLanguages)
      language:
          '$label${referenceLabelSeparator(language)}${spokenRhythm(pattern, language: language)}',
  };
}
