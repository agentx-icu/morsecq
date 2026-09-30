import 'package:flutter_soloud/flutter_soloud.dart';

/// Opaque id of a loaded waveform source (a `flutter_soloud` `AudioSource`).
extension type const SidetoneSource(int id) {}

/// Opaque id of a playing voice (a `flutter_soloud` `SoundHandle`).
extension type const SidetoneVoice(int id) {}

/// The slice of the `flutter_soloud` API that [SidetoneSink] needs.
///
/// Exists so tests inject [FakeSoloudApi]-style doubles and CI never loads
/// the native SoLoud library. Keep it minimal: one method per engine call.
abstract interface class SoloudApi {
  bool get isInitialized;

  /// Starts the engine. Must be idempotent.
  Future<void> init();

  /// Loads a plain (non-super) sine waveform source.
  Future<SidetoneSource> loadSineWaveform();

  void setWaveformFrequency(SidetoneSource source, double hz);

  /// Starts [source] looping forever at [volume] and returns its voice.
  SidetoneVoice playLooping(SidetoneSource source, {required double volume});

  void setVolume(SidetoneVoice voice, double volume);

  /// Ramps the voice volume to [to] over [over] (linear, done by the mixer).
  void fadeVolume(SidetoneVoice voice, double to, Duration over);

  Future<void> stop(SidetoneVoice voice);

  Future<void> disposeSource(SidetoneSource source);

  /// Shuts the engine down if this adapter started it.
  void deinit();
}

/// Production [SoloudApi] on top of `flutter_soloud`.
///
/// Latency notes (needs on-device verification, see README):
/// * [bufferSize] 512 frames at 48 kHz is ~10.7 ms per buffer; SoLoud adds
///   one extra buffer of output latency, so ~21 ms before OS/driver latency.
///   256 frames halves that but underruns on weaker Android devices.
/// * `lowLatency: true` selects AAudio MMAP on Android (the default).
/// * Mono output halves mixer work; the sidetone is a single sine anyway.
final class FlutterSoloudApi implements SoloudApi {
  FlutterSoloudApi({
    SoLoud? engine,
    this.sampleRate = 48000,
    this.bufferSize = 512,
    this.channels = Channels.mono,
  }) : _engine = engine ?? SoLoud.instance;

  final SoLoud _engine;
  final int sampleRate;
  final int bufferSize;
  final Channels channels;

  final Map<int, AudioSource> _sources = <int, AudioSource>{};
  bool _startedEngine = false;

  @override
  bool get isInitialized => _engine.isInitialized;

  @override
  Future<void> init() async {
    if (_engine.isInitialized) {
      // Somebody else (e.g. a music player elsewhere in the app) owns the
      // engine; share it and never deinit it.
      return;
    }
    await _engine.init(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
      channels: channels,
    );
    _startedEngine = true;
  }

  @override
  Future<SidetoneSource> loadSineWaveform() async {
    final source = await _engine.loadWaveform(WaveForm.sin, false, 1, 0);
    _sources[source.soundHash.hash] = source;
    return SidetoneSource(source.soundHash.hash);
  }

  @override
  void setWaveformFrequency(SidetoneSource source, double hz) {
    _engine.setWaveformFreq(_source(source), hz);
  }

  @override
  SidetoneVoice playLooping(SidetoneSource source, {required double volume}) {
    final handle = _engine.play(_source(source), volume: volume, looping: true);
    // Never let voice culling steal the sidetone voice when the app plays
    // other sounds at the same time.
    _engine.setProtectVoice(handle, true);
    return SidetoneVoice(handle.id);
  }

  @override
  void setVolume(SidetoneVoice voice, double volume) {
    _engine.setVolume(SoundHandle(voice.id), volume);
  }

  @override
  void fadeVolume(SidetoneVoice voice, double to, Duration over) {
    _engine.fadeVolume(SoundHandle(voice.id), to, over);
  }

  @override
  Future<void> stop(SidetoneVoice voice) => _engine.stop(SoundHandle(voice.id));

  @override
  Future<void> disposeSource(SidetoneSource source) async {
    final audioSource = _sources.remove(source.id);
    if (audioSource != null) {
      await _engine.disposeSource(audioSource);
    }
  }

  @override
  void deinit() {
    if (_startedEngine && _engine.isInitialized) {
      _engine.deinit();
    }
    _startedEngine = false;
    _sources.clear();
  }

  AudioSource _source(SidetoneSource id) {
    final source = _sources[id.id];
    if (source == null) {
      throw StateError('Unknown sidetone source ${id.id}');
    }
    return source;
  }
}
