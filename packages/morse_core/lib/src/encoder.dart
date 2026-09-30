import 'element.dart';
import 'timing.dart';

/// Text -> Morse pattern string and text -> playable timeline.
abstract final class MorseEncoder {
  /// `"SOS"` -> `"... --- ..."`; words separated by ` / `.
  ///
  /// Unsupported characters are skipped (or mapped via [onUnsupported] when
  /// provided). `<AR>`-style prosigns in the input are honoured.
  static String toPattern(
    String text, {
    String Function(String char)? onUnsupported,
  }) =>
      throw UnimplementedError();

  /// Full on/off timeline for [text] at [timing].
  ///
  /// The timeline never starts or ends with a gap. Consecutive gaps are
  /// merged (a word gap replaces, not adds to, the preceding char gap).
  static List<MorseElement> encode(String text, MorseTiming timing) =>
      throw UnimplementedError();

  /// Total wall-clock length of a timeline.
  static Duration totalDuration(Iterable<MorseElement> elements) =>
      throw UnimplementedError();
}
