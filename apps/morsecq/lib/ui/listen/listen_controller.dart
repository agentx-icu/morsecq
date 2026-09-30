import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_dsp/morse_dsp.dart';

import 'listen_settings.dart';
import 'pcm_source.dart';

enum ListenStatus { idle, starting, listening, permissionDenied, failed }

/// Per-chunk meter state, kept out of the main notifier so only the meter
/// repaints at audio-chunk rate.
final class ListenMeter {
  const ListenMeter({
    this.level = 0,
    this.toneOn = false,
    this.hasSignal = false,
  });

  final double level;
  final bool toneOn;
  final bool hasSignal;

  @override
  bool operator ==(Object other) =>
      other is ListenMeter &&
      other.level == level &&
      other.toneOn == toneOn &&
      other.hasSignal == hasSignal;

  @override
  int get hashCode => Object.hash(level, toneOn, hasSignal);
}

/// Drives a [PcmSource] into an [AudioMorseDecoder] and exposes the result
/// to the Listen screen.
///
/// Notifies on status changes, decode events, tuning changes and settings;
/// the meter lives in [meter] and updates once per audio chunk.
final class ListenController extends ChangeNotifier {
  ListenController({
    required PcmSource source,
    bool ownsSource = false,
    this.sampleRate = 48000,
    ListenSettings settings = const ListenSettings(),
  })  : _source = source,
        _ownsSource = ownsSource,
        _settings = settings {
    _decoder = _buildDecoder();
  }

  final PcmSource _source;
  final bool _ownsSource;
  final int sampleRate;

  final ValueNotifier<ListenMeter> meter =
      ValueNotifier<ListenMeter>(const ListenMeter());

  ListenSettings _settings;
  late AudioMorseDecoder _decoder;
  StreamSubscription<DecodeEvent>? _eventSub;
  StreamSubscription<Uint8List>? _pcmSub;
  ListenStatus _status = ListenStatus.idle;
  String? _errorMessage;
  String _history = '';
  double _shownHz = 0;
  bool _shownLocked = false;
  bool _disposed = false;
  bool _stoppedInBackground = false;

  ListenStatus get status => _status;
  bool get isListening => _status == ListenStatus.listening;
  bool get isBusy => _status == ListenStatus.starting;

  /// Platform error text for [ListenStatus.failed].
  String? get errorMessage => _errorMessage;

  /// True after a lifecycle stop until the next start or clear.
  bool get stoppedInBackground => _stoppedInBackground;

  ListenSettings get settings => _settings;

  /// Everything decoded so far, including text from before a settings
  /// change rebuilt the decoder.
  String get text => _history + _decoder.text;
  String get pendingPattern => _decoder.pendingPattern;
  bool get hasText => text.isNotEmpty;

  double get frequencyHz => _decoder.detectedFrequency;
  bool get isToneLocked => _decoder.isToneLocked;

  /// Speed estimate once at least one mark has been heard, else null.
  double? get wpm =>
      _decoder.text.isEmpty && _decoder.pendingPattern.isEmpty
          ? null
          : _decoder.estimatedWpm;

  // ---------------------------------------------------------------------------
  // Capture

  Future<void> start() async {
    if (_disposed || isBusy || isListening) return;
    _stoppedInBackground = false;
    _errorMessage = null;
    _setStatus(ListenStatus.starting);
    try {
      final granted = await _source.hasPermission();
      if (_disposed) return;
      if (!granted) {
        _setStatus(ListenStatus.permissionDenied);
        return;
      }
      final stream = await _source.start(
        sampleRate: sampleRate,
        channels: 1,
      );
      if (_disposed) {
        unawaited(_source.stop());
        return;
      }
      _pcmSub = stream.listen(
        _onChunk,
        onError: _fail,
        onDone: _onStreamDone,
        cancelOnError: true,
      );
      _setStatus(ListenStatus.listening);
    } catch (error) {
      _fail(error);
    }
  }

  /// Stops capture and commits a half-received character.
  Future<void> stop({bool fromBackground = false}) async {
    final sub = _pcmSub;
    _pcmSub = null;
    await sub?.cancel();
    try {
      await _source.stop();
    } catch (_) {
      // Already stopped or the platform tore the session down; nothing to
      // report beyond the idle state below.
    }
    if (_disposed) return;
    if (_status == ListenStatus.listening || _status == ListenStatus.starting) {
      _decoder.commitPending();
      _stoppedInBackground = fromBackground;
      _setStatus(ListenStatus.idle);
    }
  }

  void _onChunk(Uint8List bytes) {
    if (_disposed) return;
    _decoder.feedBytes(bytes);
    meter.value = ListenMeter(
      level: _decoder.currentLevel,
      toneOn: _decoder.isToneOn,
      hasSignal: _decoder.hasSignal,
    );
    final hz = _decoder.detectedFrequency;
    final locked = _decoder.isToneLocked;
    if ((hz - _shownHz).abs() >= 1 || locked != _shownLocked) {
      _shownHz = hz;
      _shownLocked = locked;
      notifyListeners();
    }
  }

  void _onStreamDone() {
    if (_disposed || _pcmSub == null) return;
    _pcmSub = null;
    _decoder.commitPending();
    _setStatus(ListenStatus.idle);
  }

  void _fail(Object error) {
    if (_disposed) return;
    _errorMessage = error.toString();
    final sub = _pcmSub;
    _pcmSub = null;
    unawaited(sub?.cancel());
    unawaited(_source.stop().catchError((Object _) {}));
    _setStatus(ListenStatus.failed);
  }

  // ---------------------------------------------------------------------------
  // Text and tuning

  void clear() {
    _history = '';
    _decoder.clearText();
    _stoppedInBackground = false;
    notifyListeners();
  }

  /// Drags the tuning slider: fixes the frequency and turns auto-tune off.
  void setManualFrequency(double hz) {
    _settings = _settings.copyWith(autoTune: false, manualHz: hz);
    _decoder.manualFrequencyHz = hz;
    notifyListeners();
  }

  void setAutoTune(bool on) => updateSettings(_settings.copyWith(autoTune: on));

  /// Applies [next]. Block size and debounce need a new decoder; the text
  /// decoded so far is kept in [text].
  void updateSettings(ListenSettings next) {
    if (next == _settings) return;
    final rebuild = next.blockSize != _settings.blockSize ||
        next.minElementMs != _settings.minElementMs;
    _settings = next;
    if (rebuild) {
      _decoder.commitPending();
      _history = text;
      _eventSub?.cancel().ignore();
      _decoder.dispose();
      _decoder = _buildDecoder();
    } else {
      _decoder.autoTune = next.autoTune;
      if (!next.autoTune) _decoder.manualFrequencyHz = next.manualHz;
    }
    notifyListeners();
  }

  AudioMorseDecoder _buildDecoder() {
    final debounce = Duration(milliseconds: _settings.minElementMs);
    final decoder = AudioMorseDecoder(
      sampleRate: sampleRate,
      blockSize: _settings.blockSize,
      gateConfig: EnvelopeGateConfig(minOn: debounce, minOff: debounce),
      autoTune: _settings.autoTune,
      manualFrequencyHz: _settings.manualHz,
    );
    _eventSub = decoder.events.listen((_) => notifyListeners());
    return decoder;
  }

  void _setStatus(ListenStatus next) {
    if (_disposed) return;
    _status = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_pcmSub?.cancel());
    _pcmSub = null;
    unawaited(_eventSub?.cancel());
    _decoder.dispose();
    meter.dispose();
    unawaited(_shutdownSource());
    super.dispose();
  }

  Future<void> _shutdownSource() async {
    try {
      await _source.stop();
    } catch (_) {
      // Nothing was recording; fall through to dispose.
    }
    if (!_ownsSource) return;
    try {
      await _source.dispose();
    } catch (_) {
      // Plugin already torn down (e.g. engine shutdown); nothing to free.
    }
  }
}
