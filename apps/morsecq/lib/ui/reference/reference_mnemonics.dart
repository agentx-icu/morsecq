/// Mnemonics shown when a learner long-presses a character in the reference.
///
/// Two layers: the spoken rhythm (`di-DAH`), derived from the pattern so it
/// can never drift from `MorseAlphabet`, and a memory phrase whose syllable
/// stress mirrors the rhythm (a stressed syllable is a dah).
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

  /// `.-` -> `di-DAH`, `-...` -> `DAH-di-di-dit`, `.` -> `dit`.
  ///
  /// The last dit is voiced `dit`; every dit before the end is `di`, the
  /// way operators say patterns aloud.
  static String spokenRhythm(String pattern) {
    final List<String> parts = <String>[];
    for (int i = 0; i < pattern.length; i++) {
      final String ch = pattern[i];
      if (ch == '-') {
        parts.add('DAH');
      } else if (ch == '.') {
        parts.add(i == pattern.length - 1 ? 'dit' : 'di');
      }
    }
    return parts.join('-');
  }

  /// Full mnemonic line for a character with [pattern], e.g.
  /// `A: di-DAH — "a-PART"`. Falls back to the rhythm alone for characters
  /// without a phrase (punctuation).
  static String forCharacter(String char, String pattern) {
    final String rhythm = spokenRhythm(pattern);
    final String? phrase = phrases[char.toUpperCase()];
    if (phrase == null) return '$char: $rhythm';
    return '$char: $rhythm — "$phrase"';
  }
}
