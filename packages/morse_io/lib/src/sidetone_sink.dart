import 'sink.dart';
import 'soloud_api.dart';

/// Sine-wave sidetone rendered through `flutter_soloud`.
///
/// Approach (chosen for latency, not simplicity): [prepare] starts a
/// looping sine voice at volume 0 and keeps it running for the life of the
/// sink. [on] / [off] then only ramp that voice's volume with the mixer's
/// built-in fader over [ramp] (default 5 ms). Nothing is allocated, decoded
/// or scheduled on the hot path, so keying latency is bounded by the audio
/// buffer size alone, and the short linear ramp removes the click a hard
/// gate would produce at a non-zero sample.
///
/// All engine access goes through [SoloudApi] so tests can substitute a fake.
final class SidetoneSink implements MorseSink {
  SidetoneSink({
    SoloudApi? api,
    double frequencyHz = 700,
    double volume = 0.8,
    this.ramp = const Duration(milliseconds: 5),
  })  : _api = api ?? FlutterSoloudApi(),
        _frequencyHz = frequencyHz,
        _volume = volume.clamp(0.0, 1.0);

  final SoloudApi _api;

  /// Attack / release time applied to every on/off transition.
  final Duration ramp;

  double _frequencyHz;
  double _volume;
  SidetoneSource? _source;
  SidetoneVoice? _voice;
  Future<void>? _preparing;
  bool _prepared = false;
  bool _isOn = false;

  bool get isPrepared => _prepared;
  bool get isOn => _isOn;

  double get frequencyHz => _frequencyHz;

  /// Retunes the running voice immediately (safe while keying).
  set frequencyHz(double hz) {
    _frequencyHz = hz;
    final source = _source;
    if (source != null) {
      _api.setWaveformFrequency(source, hz);
    }
  }

  double get volume => _volume;

  /// 0..1. Applied at the next [on], or right away while the tone is on.
  set volume(double value) {
    _volume = value.clamp(0.0, 1.0);
    final voice = _voice;
    if (voice != null && _isOn) {
      _api.setVolume(voice, _volume);
    }
  }

  @override
  Future<void> prepare() {
    if (_prepared) {
      return Future<void>.value();
    }
    return _preparing ??= _doPrepare();
  }

  Future<void> _doPrepare() async {
    await _api.init();
    final source = await _api.loadSineWaveform();
    _source = source;
    _api.setWaveformFrequency(source, _frequencyHz);
    _voice = _api.playLooping(source, volume: 0);
    _prepared = true;
  }

  @override
  void on() {
    final voice = _voice;
    if (voice == null || _isOn) {
      return;
    }
    _isOn = true;
    _api.fadeVolume(voice, _volume, ramp);
  }

  @override
  void off() {
    final voice = _voice;
    if (voice == null || !_isOn) {
      return;
    }
    _isOn = false;
    _api.fadeVolume(voice, 0, ramp);
  }

  @override
  Future<void> dispose() async {
    _isOn = false;
    _prepared = false;
    _preparing = null;
    final voice = _voice;
    final source = _source;
    _voice = null;
    _source = null;
    if (voice != null) {
      await _api.stop(voice);
    }
    if (source != null) {
      await _api.disposeSource(source);
    }
    _api.deinit();
  }
}
