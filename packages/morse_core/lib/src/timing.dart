/// PARIS-standard timing with optional Farnsworth spacing.
///
/// `dit = 1200 / wpm` milliseconds. dah = 3 dit, intra-character gap = 1 dit,
/// character gap = 3 dit, word gap = 7 dit.
///
/// Farnsworth: characters are keyed at [wpm] but the character and word gaps
/// are stretched so the overall throughput equals [farnsworthWpm]
/// (ARRL formula). When [farnsworthWpm] is null or >= [wpm], standard
/// spacing applies.
final class MorseTiming {
  const MorseTiming({required this.wpm, this.farnsworthWpm})
      : assert(wpm > 0, 'wpm must be positive'),
        assert(farnsworthWpm == null || farnsworthWpm > 0,
            'farnsworthWpm must be positive');

  /// Character (element) speed in words per minute.
  final double wpm;

  /// Effective overall speed when Farnsworth spacing is in use.
  final double? farnsworthWpm;

  /// Standard 20 WPM character speed used by the Koch method.
  static const MorseTiming koch20 = MorseTiming(wpm: 20);

  /// Whether Farnsworth stretching is active.
  bool get isFarnsworth => farnsworthWpm != null && farnsworthWpm! < wpm;

  /// One dit in milliseconds (fractional; callers round when they need ints).
  double get ditMs => throw UnimplementedError();

  Duration get dit => throw UnimplementedError();
  Duration get dah => throw UnimplementedError();
  Duration get intraGap => throw UnimplementedError();

  /// Character gap after Farnsworth stretching (3 dit when not stretched).
  Duration get charGap => throw UnimplementedError();

  /// Word gap after Farnsworth stretching (7 dit when not stretched).
  Duration get wordGap => throw UnimplementedError();

  MorseTiming copyWith({double? wpm, double? farnsworthWpm}) =>
      throw UnimplementedError();

  @override
  String toString() => 'MorseTiming(wpm: $wpm, farnsworthWpm: $farnsworthWpm)';
}
