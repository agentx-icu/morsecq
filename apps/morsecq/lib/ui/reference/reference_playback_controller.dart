import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';

import 'reference_playback_settings.dart';
import 'reference_player.dart';

/// Plays one reference entry / translator pattern at a time and exposes what
/// is sounding so widgets can highlight the active mark.
///
/// Owns the [MorsePlayer] built by the injected [MorsePlayerFactory] (and,
/// through [disposeReferencePlayer], the sink behind it). Starting a new
/// item stops the previous one; disposing the controller stops everything.
class ReferencePlaybackController extends ChangeNotifier {
  ReferencePlaybackController({
    required MorsePlayerFactory playerFactory,
    required this.settings,
  }) : _player = playerFactory() {
    _subscription = _player.events.listen(_onEvent);
    settings.addListener(_onSettingsChanged);
    retuneReferencePlayer(_player, settings.toneHz);
  }

  final ReferencePlaybackSettings settings;
  final MorsePlayer _player;
  late final StreamSubscription<PlayerEvent> _subscription;
  bool _disposed = false;

  String? _playingId;
  int _activeMark = -1;
  int _marksSeen = 0;

  /// Id of the item being played, or null when idle.
  String? get playingId => _playingId;

  bool get isPlaying => _playingId != null;

  /// Index among the marks (`.` / `-`) of the current timeline that is
  /// sounding right now; -1 when idle or during a gap before the first mark.
  int get activeMark => _activeMark;

  /// Index among the marks for [id], or null when [id] is not the item
  /// playing. Widgets call this from `build`.
  int? activeMarkFor(String id) =>
      _playingId == id && _activeMark >= 0 ? _activeMark : null;

  bool isPlayingId(String id) => _playingId == id;

  /// The output sink shared with playback, for a hand key that should sound
  /// like the reference does. A silent sink when the factory attached none.
  MorseSink get sink => referenceSinkOf(_player) ?? const NullSink();

  /// The timing playback uses right now.
  MorseTiming get timing => settings.timing;

  /// Encodes [text] at the current settings and plays it, replacing anything
  /// that was playing. Empty or entirely unsupported text is a no-op.
  void play(String id, String text) {
    if (_disposed) return;
    final List<MorseElement> elements = MorseEncoder.encode(text, timing);
    if (elements.isEmpty) {
      stop();
      return;
    }
    _player.stop();
    _playingId = id;
    _activeMark = -1;
    _marksSeen = 0;
    notifyListeners();
    _player.play(elements);
  }

  /// Stops playback (no-op when idle).
  void stop() => _player.stop();

  /// Plays [id] or, when it is already playing, stops it.
  void toggle(String id, String text) {
    if (_playingId == id) {
      stop();
    } else {
      play(id, text);
    }
  }

  void _onEvent(PlayerEvent event) {
    switch (event) {
      case PlayerElementStarted(:final MorseElement element):
        if (element.on) {
          _activeMark = _marksSeen;
          _marksSeen++;
          notifyListeners();
        }
      case PlayerCompleted():
      case PlayerStopped():
        if (_playingId == null) return;
        _playingId = null;
        _activeMark = -1;
        _marksSeen = 0;
        notifyListeners();
    }
  }

  void _onSettingsChanged() {
    if (_disposed) return;
    retuneReferencePlayer(_player, settings.toneHz);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    settings.removeListener(_onSettingsChanged);
    unawaited(_subscription.cancel());
    unawaited(disposeReferencePlayer(_player));
    super.dispose();
  }
}
