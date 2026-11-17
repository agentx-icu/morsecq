import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';

import 'soloud_api.dart';

/// Plays a short in-memory WAV clip (a recording selection), optionally
/// looping. Used by the recorded-audio workbench; the live sidetone keeps
/// using `SidetoneSink`.
abstract interface class ClipPlayer {
  bool get isPlaying;

  /// Fires `true` when a clip starts and `false` when it stops or ends.
  Stream<bool> get playing;

  /// Stops anything playing, then plays [wav] (RIFF/WAVE bytes).
  Future<void> play(
    Uint8List wav, {
    required Duration length,
    bool loop = false,
  });

  Future<void> stop();

  /// Releases the engine lease. The player cannot be used afterwards.
  Future<void> dispose();
}

/// [ClipPlayer] on the shared SoLoud engine. The engine lease is taken via
/// [FlutterSoloudApi] so the engine is shared with every sidetone sink and
/// shut down only by the last holder (see `EngineLeases`).
final class SoloudClipPlayer implements ClipPlayer {
  SoloudClipPlayer({FlutterSoloudApi? lease})
    : this._(lease ?? FlutterSoloudApi(), null);

  /// Uses [engine] for both the audio lease and the clip, for native tests.
  SoloudClipPlayer.withEngine(SoLoud engine)
    : this._(FlutterSoloudApi(engine: engine), engine);

  SoloudClipPlayer._(this._lease, this._injectedEngine);

  final FlutterSoloudApi _lease;
  final SoLoud? _injectedEngine;
  SoLoud get _engine => _injectedEngine ?? SoLoud.instance;
  static int _nextSource = 0;
  final String _sourceName = 'workbench_clip_${_nextSource++}.wav';
  final StreamController<bool> _playing = StreamController<bool>.broadcast();
  AudioSource? _source;
  SoundHandle? _handle;
  Timer? _end;
  Future<void> _tail = Future<void>.value();
  Future<void>? _disposing;
  int _generation = 0;

  @override
  bool get isPlaying => _handle != null;

  @override
  Stream<bool> get playing => _playing.stream;

  @override
  Future<void> play(
    Uint8List wav, {
    required Duration length,
    bool loop = false,
  }) async {
    if (_disposing != null) throw StateError('clip player disposed');
    final generation = ++_generation;
    return _serial(() async {
      if (generation != _generation) return;
      await _releaseClip();
      if (generation != _generation) return;
      await _lease.init();
      if (generation != _generation) return;
      final engine = _engine;
      final source = _source = await engine.loadMem(_sourceName, wav);
      if (generation != _generation) {
        await _releaseClip();
        return;
      }
      try {
        _handle = engine.play(source, looping: loop);
      } on Object {
        await _releaseClip();
        rethrow;
      }
      _playing.add(true);
      if (!loop) {
        _end = Timer(length + const Duration(milliseconds: 50), () {
          if (generation == _generation) unawaited(stop());
        });
      }
    });
  }

  @override
  Future<void> stop() {
    final disposing = _disposing;
    if (disposing != null) return disposing;
    // A play still loading its clip must not start after this stop.
    _generation++;
    return _serial(_releaseClip);
  }

  Future<void> _serial(Future<void> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<void> _releaseClip() async {
    _end?.cancel();
    _end = null;
    final handle = _handle;
    final source = _source;
    _handle = null;
    _source = null;
    if (handle == null && source == null) return;
    try {
      final engine = _engine;
      try {
        if (handle != null && engine.getIsValidVoiceHandle(handle)) {
          await engine.stop(handle);
        }
      } finally {
        if (source != null) await engine.disposeSource(source);
      }
    } on Object catch (_) {
      // The engine went away (lease released elsewhere): nothing to stop.
    }
    if (handle != null) _playing.add(false);
  }

  @override
  Future<void> dispose() {
    final disposing = _disposing;
    if (disposing != null) return disposing;
    _generation++;
    return _disposing = _serial(() async {
      await _releaseClip();
      try {
        await _lease.deinit();
      } finally {
        await _playing.close();
      }
    });
  }
}
