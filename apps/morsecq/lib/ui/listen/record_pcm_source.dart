import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:morse_io/morse_io.dart';
import 'package:record/record.dart';

import 'pcm_source.dart';

/// [PcmSource] backed by the `record` plugin (Android, iOS, macOS, Windows,
/// Linux via `parecord`, web).
///
/// The recorder is asked for raw PCM with every "helpful" DSP turned off:
/// automatic gain, echo cancellation and noise suppression all distort a
/// steady tone and its gaps, which is exactly what the decoder measures.
///
/// The plugin reports asynchronous capture failures (Android's
/// `AudioRecord` errors such as `ERROR_DEAD_OBJECT`, encoder failures) on
/// `onStateChanged()`, not on the PCM stream, and the PCM stream is only
/// closed by an explicit `stop()`. [start] therefore returns a stream that
/// merges both: state-stream errors become errors on the PCM stream, and a
/// platform-side transition to `stop` while capturing ends it.
///
/// On iOS the plugin switches the shared audio session to `playAndRecord`
/// (Bluetooth HFP allowed, not mixable) and leaves it there; [stop] puts the
/// playback session `morse_io` runs the sidetone in back, so the tone keeps
/// ignoring the silent switch, mixing with music and using A2DP.
final class RecordPcmSource implements PcmSource {
  RecordPcmSource({
    AudioRecorder? recorder,
    AudioSessionApi audioSession = const PlatformAudioSessionApi(),
  }) : _recorder = recorder ?? AudioRecorder(),
       _audioSession = audioSession;

  final AudioRecorder _recorder;
  final AudioSessionApi _audioSession;
  _CaptureSession? _session;
  bool _capturing = false;

  /// Tail of the start/stop chain. Every [start] and [stop] (recorder stop
  /// plus session restore) runs to completion before the next begins, so a
  /// quick restart can neither overtake a pending restore nor have its
  /// `_capturing` flag cleared by the stop it raced.
  Future<void> _tail = Future<void>.value();

  Future<T> _serial<T>(Future<T> Function() op) {
    final Future<T> result = _tail.then((_) => op());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<Stream<Uint8List>> start({
    required int sampleRate,
    required int channels,
  }) => _serial(() async {
    _endSession();
    _capturing = true;
    final session = _session = _CaptureSession();
    // Watch states before starting so the session sees its own `record`.
    session.watchStates(_recorder.onStateChanged());
    try {
      final pcm = await _recorder.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: sampleRate,
          numChannels: channels,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: false,
        ),
      );
      session.forwardPcm(pcm);
    } catch (_) {
      if (identical(_session, session)) _endSession();
      session.close();
      rethrow;
    }
    return session.stream;
  });

  /// `record` 6.2 implements `listInputDevices` on every target: Android
  /// (`AudioManager.getDevices(GET_DEVICES_INPUTS)`), iOS
  /// (`AVAudioSession.availableInputs`), macOS (`AVCaptureDevice`
  /// discovery), Windows (Media Foundation audio-capture enumeration) and
  /// Linux (`pactl list sources`). Any failure of the query itself (no
  /// `pactl`, audio session error, an older plugin) means "cannot tell".
  @override
  Future<bool?> hasInputDevice() async {
    try {
      final devices = await _recorder.listInputDevices();
      return devices.isNotEmpty;
    } catch (error) {
      debugPrint('[RecordPcmSource] listInputDevices failed: $error');
      return null;
    }
  }

  /// Ends the current session first, so the plugin's own `stop` state for
  /// this explicit stop is not mistaken for an unexpected one.
  @override
  Future<void> stop() => _serial(() async {
    _endSession();
    try {
      await _recorder.stop();
    } finally {
      if (_capturing) {
        _capturing = false;
        await _audioSession.configureForPlayback();
      }
    }
  });

  @override
  Future<void> dispose() => _serial(() async {
    _endSession();
    await _recorder.dispose();
  });

  void _endSession() {
    final session = _session;
    _session = null;
    session?.close();
  }
}

/// One capture: the merged stream handed to the caller plus the two plugin
/// subscriptions feeding it.
final class _CaptureSession {
  /// The listener cancelling (e.g. `cancelOnError`) ends the session too.
  late final StreamController<Uint8List> _out = StreamController<Uint8List>(
    onCancel: close,
  );
  StreamSubscription<Uint8List>? _pcmSub;
  StreamSubscription<RecordState>? _stateSub;
  bool _sawRecording = false;
  bool _closed = false;

  Stream<Uint8List> get stream => _out.stream;

  void watchStates(Stream<RecordState> states) {
    _stateSub = states.listen(
      _onState,
      onError: (Object error, StackTrace stack) {
        if (!_closed) _out.addError(error, stack);
      },
    );
  }

  void forwardPcm(Stream<Uint8List> pcm) {
    if (_closed) return;
    _pcmSub = pcm.listen(
      _out.add,
      onError: (Object error, StackTrace stack) {
        if (!_closed) _out.addError(error, stack);
      },
      onDone: close,
    );
  }

  void _onState(RecordState state) {
    switch (state) {
      case RecordState.record:
        _sawRecording = true;
      case RecordState.pause:
        break;
      case RecordState.stop:
        // Only after this session's own `record`: a late `stop` from the
        // previous capture can arrive after the next one subscribed.
        if (_sawRecording) close();
    }
  }

  /// Idempotent. Nothing here is awaited: cancelling only stops delivery,
  /// and `close()` on a stream nobody listens to never completes.
  void close() {
    if (_closed) return;
    _closed = true;
    unawaited(_pcmSub?.cancel());
    unawaited(_stateSub?.cancel());
    _pcmSub = null;
    _stateSub = null;
    unawaited(_out.close());
  }
}
