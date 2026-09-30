import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';

/// Plays one message at a time through `morse_io` and exposes what is
/// sounding so bubbles can highlight the active mark.
///
/// One instance per app (or per conversation screen when none is provided)
/// owns the sidetone: playing a second message stops the first, and the
/// keying input reuses [sink] so hand-keyed sidetone and playback share the
/// same audio engine. Tests inject a [NullSink] and a `FakeClock`.
class MorsePlaybackController extends ChangeNotifier {
  MorsePlaybackController({MorseSink? sink, Clock? clock})
    : _sidetone = sink == null ? SidetoneSink() : null,
      clock = clock ?? SystemClock.shared {
    this.sink = sink ?? CompositeSink(<MorseSink>[_sidetone!, HapticSink()]);
    _player = MorsePlayer(sink: this.sink, clock: this.clock);
    _subscription = _player.events.listen(_onEvent);
  }

  /// Created here only when the caller did not inject a sink; lets
  /// [play] retune the tone to the listener's settings.
  final SidetoneSink? _sidetone;

  /// Shared output for playback and live keying.
  late final MorseSink sink;
  final Clock clock;
  late final MorsePlayer _player;
  late final StreamSubscription<PlayerEvent> _subscription;
  Future<void>? _prepared;
  bool _disposed = false;

  String? _playingId;
  int _activeMark = -1;
  int _marksBefore = 0;
  List<MorseElement> _elements = const <MorseElement>[];

  /// Id of the message being played, or null when idle.
  String? get playingId => _playingId;

  bool get isPlaying => _playingId != null;

  /// Index among the marks (`.`/`-`) of the current timeline, -1 when idle
  /// or before the first mark.
  int get activeMark => _activeMark;

  /// Index among the marks for [messageId], or null when that message is not
  /// the one playing. Bubbles call this from `build`.
  int? activeMarkFor(String messageId) =>
      _playingId == messageId && _activeMark >= 0 ? _activeMark : null;

  /// Prepares the sink (audio engine, vibrator probe) once.
  Future<void> prepare() => _prepared ??= sink.prepare().catchError((Object e) {
    // No audio device (CI, headless): keep going silently; the pattern
    // highlight still shows playback progress.
    debugPrint('morsecq: sink.prepare failed: $e');
  });

  /// Encodes [text] at [timing] and plays it, replacing anything playing.
  Future<void> play(
    String messageId,
    String text,
    MorseTiming timing, {
    double? toneHz,
  }) async {
    if (_disposed) return;
    if (toneHz != null && _sidetone != null) _sidetone.frequencyHz = toneHz;
    await prepare();
    if (_disposed) return;
    _elements = MorseEncoder.encode(text, timing);
    _playingId = messageId;
    _activeMark = -1;
    _marksBefore = 0;
    notifyListeners();
    _player.play(_elements);
  }

  void stop() => _player.stop();

  /// Toggles playback of [messageId].
  Future<void> toggle(
    String messageId,
    String text,
    MorseTiming timing, {
    double? toneHz,
  }) {
    if (_playingId == messageId) {
      stop();
      return Future<void>.value();
    }
    return play(messageId, text, timing, toneHz: toneHz);
  }

  void _onEvent(PlayerEvent event) {
    switch (event) {
      case PlayerElementStarted(:final index, :final element):
        if (element.on) {
          _activeMark = _marksBefore;
          _marksBefore++;
          notifyListeners();
        } else if (index == 0) {
          notifyListeners();
        }
      case PlayerCompleted():
      case PlayerStopped():
        if (_playingId == null) return;
        _playingId = null;
        _activeMark = -1;
        _elements = const <MorseElement>[];
        notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_subscription.cancel());
    unawaited(_player.dispose());
    unawaited(sink.dispose());
    super.dispose();
  }
}
