/// Streaming decoder for hand-keyed input.
///
/// Feed [keyDown] / [keyUp] with monotonic timestamps (e.g. from a
/// `Stopwatch`), call [tick] periodically so pending gaps can resolve into
/// character / word boundaries, and read [text] or listen to [events].
///
/// Algorithm contract (see plan §4.1):
/// * dit length is estimated by two-cluster split of observed mark durations
///   (mean of the short cluster), seeded by [DecoderConfig.initialDit];
///   NOT the overall median (dah-heavy text would bias it).
/// * decision thresholds sit at the midpoints: mark > 2 dit => dah;
///   gap > 2 dit => character boundary; gap > 5 dit => word boundary.
/// * under Farnsworth-style keying the char/word gap thresholds adapt to the
///   observed gap distribution instead of fixed multiples.
/// * tolerance: ±30 % jitter must decode correctly.
final class DecoderConfig {
  const DecoderConfig({
    this.initialDit = const Duration(milliseconds: 80),
    this.adaptive = true,
    this.ditDahThreshold = 2.0,
    this.charGapThreshold = 2.0,
    this.wordGapThreshold = 5.0,
  });

  final Duration initialDit;
  final bool adaptive;
  final double ditDahThreshold;
  final double charGapThreshold;
  final double wordGapThreshold;
}

enum DecodeEventKind { element, character, word, unknownPattern }

final class DecodeEvent {
  const DecodeEvent(this.kind, {this.text, this.pattern, this.confidence = 1});

  final DecodeEventKind kind;

  /// Decoded character (or space for [DecodeEventKind.word]).
  final String? text;

  /// Raw `.`/`-` pattern for element and character events.
  final String? pattern;

  /// 0..1; lower when the mark/gap sat close to a threshold.
  final double confidence;
}

final class MorseDecoder {
  MorseDecoder({this.config = const DecoderConfig()});

  final DecoderConfig config;

  /// Current dit estimate.
  Duration get estimatedDit => throw UnimplementedError();

  /// Decoded text so far (characters and spaces).
  String get text => throw UnimplementedError();

  /// Pattern of the character currently being keyed (not yet committed).
  String get pendingPattern => throw UnimplementedError();

  Stream<DecodeEvent> get events => throw UnimplementedError();

  void keyDown(Duration at) => throw UnimplementedError();
  void keyUp(Duration at) => throw UnimplementedError();

  /// Resolve pending gaps as of [now]; call from a periodic timer.
  void tick(Duration now) => throw UnimplementedError();

  /// Commit whatever is pending and return the final text.
  String flush() => throw UnimplementedError();

  void reset() => throw UnimplementedError();

  /// Release the event stream. Call when the owning widget is disposed.
  void dispose() => throw UnimplementedError();
}
