/// International (ITU) Morse alphabet plus common prosigns.
///
/// Patterns use `.` for dit and `-` for dah. Prosigns are addressed by their
/// bracketed form, e.g. `<AR>`, `<SK>`, `<BT>`, `<SOS>`, and encode as one
/// run of elements with no character gap inside.
abstract final class MorseAlphabet {
  /// Upper-case letter / digit / punctuation -> pattern.
  ///
  /// Keys are single characters. Lookups are case-insensitive via [encodeChar].
  static const Map<String, String> international = <String, String>{
    // Filled in by the implementation; must cover A-Z, 0-9 and the ITU
    // punctuation set (. , ? ' ! / ( ) & : ; = + - _ " $ @).
  };

  /// Prosign name (without brackets, upper-case) -> pattern.
  static const Map<String, String> prosigns = <String, String>{
    // AR, SK, BT, KN, AS, SN, SOS, CT, HH (error) ...
  };

  /// Pattern for one character, or null if unsupported. Case-insensitive.
  static String? encodeChar(String char) => throw UnimplementedError();

  /// Pattern for a prosign name such as `AR` or `SOS`, or null.
  static String? encodeProsign(String name) => throw UnimplementedError();

  /// Character (upper-case) for a pattern such as `.-`, or null.
  static String? decodePattern(String pattern) => throw UnimplementedError();

  /// Prosign name for a pattern such as `.-.-.` (AR), or null.
  static String? decodeProsignPattern(String pattern) =>
      throw UnimplementedError();

  /// All characters the alphabet supports, in Koch teaching order
  /// (K M R S U A P T L O W I . N J E F 0 Y , V G 5 / Q 9 Z H 3 8 B ? 4 2 7 C 1 D 6 X <BT> <SK> <AR>).
  static const List<String> kochOrder = <String>[];
}
