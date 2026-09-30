/// English UI strings for the Morse reference and translator screens.
///
/// Kept as plain constants so an i18n pass can lift them into ARB files
/// without touching widget code.
abstract final class ReferenceStrings {
  // Shared.
  static const String referenceTitle = 'Morse reference';
  static const String translatorTitle = 'Translator';
  static const String play = 'Play';
  static const String stop = 'Stop';
  static const String clear = 'Clear';
  static const String close = 'Close';
  static const String emptyOutput = '—';

  // Search.
  static const String searchHint = 'Search characters, prosigns, Q-codes…';
  static const String clearSearch = 'Clear search';
  static const String noResults = 'Nothing matches your search.';

  // Sections.
  static const String sectionAlphabet = 'Alphabet';
  static const String sectionPunctuation = 'Punctuation';
  static const String sectionProsigns = 'Prosigns';
  static const String sectionQCodes = 'Q-codes';
  static const String sectionAbbreviations = 'CW abbreviations';
  static const String sectionKoch = 'Koch order';
  static const String alphabetHint =
      'Tap a card to hear it. Long-press for a mnemonic.';
  static const String kochHint =
      'The order the Koch method introduces characters (LCWO sequence). '
      'Start with K and M; add one when you copy at 90 %.';
  static const String mnemonicTitle = 'Mnemonic';
  static const String kochPosition = 'Koch position';
  static const String meaningLabel = 'Meaning';
  static String entryCount(int n) => n == 1 ? '1 entry' : '$n entries';

  // Playback settings.
  static const String playbackSettings = 'Playback settings';
  static const String characterSpeed = 'Character speed';
  static const String farnsworth = 'Farnsworth spacing';
  static const String farnsworthHelp =
      'Characters stay at full speed; gaps stretch to the effective speed.';
  static const String effectiveSpeed = 'Effective speed';
  static const String tone = 'Tone';
  static String wpm(num value) => '${value.round()} WPM';
  static String hz(num value) => '${value.round()} Hz';

  // Translator modes.
  static const String modeTextToMorse = 'Text → Morse';
  static const String modeMorseToText = 'Morse → Text';
  static const String modeKey = 'Key';

  // Text -> Morse.
  static const String textInputLabel = 'Text';
  static const String textInputHint = 'Type text to encode…';
  static const String patternOutputLabel = 'Morse';
  static const String copyPattern = 'Copy pattern';
  static const String patternCopied = 'Pattern copied';
  static String skippedChars(String chars) =>
      'Skipped (no Morse code): $chars';

  // Morse -> Text.
  static const String patternInputLabel = 'Morse';
  static const String patternInputHint =
      'Type . and -, a space between letters, / between words';
  static const String textOutputLabel = 'Text';
  static const String copyText = 'Copy text';
  static const String textCopied = 'Text copied';
  static const String unknownPatternHelp =
      'Patterns with no character are shown as <pattern>.';
  static const String keypadDit = 'Dit';
  static const String keypadDah = 'Dah';
  static const String keypadCharGap = 'Letter gap';
  static const String keypadWordGap = 'Word gap';
  static const String keypadBackspace = 'Backspace';

  // Tap to key.
  static const String keyHint =
      'Press and hold the key to send. On a keyboard, hold Space.';
  static const String keyLabel = 'KEY';
  static const String keyDecodedLabel = 'Decoded';
  static const String keyPendingLabel = 'Keying';
  static String estimatedSpeed(num wpm) => 'Estimated ${wpm.round()} WPM';
}
