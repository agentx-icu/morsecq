import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:morse_io/morse_io.dart';
import 'package:record/record.dart';

import 'pcm_source.dart';
import '../../diagnostics/local_diagnostics.dart';

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
/// platform-side interruption or transition to `stop` ends it. On iOS,
/// attaching or removing audio hardware can invalidate the input format
/// without a recorder state event, so a route change also ends capture.
///
/// On iOS the plugin switches the shared audio session to `playAndRecord`
/// (Bluetooth HFP allowed, not mixable) and leaves it there; [stop] puts the
/// playback session `morse_io` runs the sidetone in back, so the tone keeps
/// ignoring the silent switch, mixing with music and using A2DP.
/// On Android, each capture uses its own recorder so ending it also shuts
/// down the plug-in's Bluetooth SCO receiver.
final class RecordPcmSource implements PcmSource {
  RecordPcmSource({
    AudioRecorder? recorder,
    AudioRecorder Function()? androidRecorderFactory,
    AudioSessionApi audioSession = const PlatformAudioSessionApi(),
    Stream<AVAudioSessionRouteChange> Function()? iosRouteChanges,
  }) : _recorder = recorder,
       _androidRecorderFactory =
           androidRecorderFactory ??
           (recorder == null && !kIsWeb && Platform.isAndroid
               ? AudioRecorder.new
               : null),
       _audioSession = audioSession,
       _iosRouteChanges = iosRouteChanges ?? _platformRouteChanges;

  AudioRecorder? _recorder;
  final AudioRecorder Function()? _androidRecorderFactory;
  final AudioSessionApi _audioSession;
  final Stream<AVAudioSessionRouteChange> Function() _iosRouteChanges;
  _CaptureSession? _session;
  bool _capturing = false;

  /// Counts [start]s, so a capture that ends on its own does not stop or
  /// restore for a newer one.
  int _captures = 0;

  /// Tail of the start/stop chain. Every [start] and [stop] (recorder stop
  /// plus session restore) runs to completion before the next begins, so a
  /// quick restart can neither overtake a pending restore nor have its
  /// `_capturing` flag cleared by the stop it raced.
  Future<void> _tail = Future<void>.value();

  static Stream<AVAudioSessionRouteChange> _platformRouteChanges() =>
      !kIsWeb && Platform.isIOS
      ? AVAudioSession().routeChangeStream
      : const Stream.empty();

  AudioRecorder get _currentRecorder =>
      _recorder ??= (_androidRecorderFactory ?? AudioRecorder.new)();

  Future<T> _serial<T>(Future<T> Function() op) {
    final Future<T> result = _tail.then((_) => op());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  @override
  Future<bool> hasPermission({bool request = true}) =>
      _serial(() => _currentRecorder.hasPermission(request: request));

  @override
  Future<Stream<Uint8List>> start({
    required int sampleRate,
    required int channels,
  }) => _serial(() async {
    if (_capturing && _androidRecorderFactory != null) await _stopCapture();
    _endSession();
    final recorder = _currentRecorder;
    _capturing = true;
    final int capture = ++_captures;
    final session = _session = _CaptureSession()
      ..onSelfClose = (interrupted) =>
          _endedByPlatform(capture, interrupted: interrupted);
    try {
      // Subscribe before starting so the session sees its own `record`.
      session.watchStates(recorder.onStateChanged());
      session.watchRouteChanges(_iosRouteChanges());
      final pcm = await recorder.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: sampleRate,
          numChannels: channels,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: false,
          // A new capture always needs a new explicit user action.
          audioInterruption: AudioInterruptionMode.pause,
        ),
      );
      session.forwardPcm(pcm);
    } catch (_) {
      if (identical(_session, session)) _endSession();
      session
        ..onSelfClose = null
        ..close();
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
  Future<bool?> hasInputDevice() => _serial(() async {
    try {
      final devices = await _currentRecorder.listInputDevices();
      return devices.isNotEmpty;
    } catch (error) {
      LocalDiagnostics.report(DiagnosticContext.inputDeviceList, error);
      return null;
    }
  });

  /// Ends the current session first, so the plugin's own `stop` state for
  /// this explicit stop is not mistaken for an unexpected one.
  @override
  Future<void> stop() => _serial(_stopCapture);

  Future<void> _stopCapture() async {
    _endSession();
    try {
      await _recorder?.stop();
    } finally {
      await _releaseCapture();
    }
  }

  Future<void> _releaseCapture() async {
    if (!_capturing) return;
    _capturing = false;
    try {
      // record_android keeps its SCO receiver attached after stop(). The
      // receiver is installed when the wrapper is first created.
      if (_androidRecorderFactory != null) await _disposeRecorder();
    } finally {
      await _audioSession.configureForPlayback();
    }
  }

  Future<void> _disposeRecorder() async {
    final recorder = _recorder;
    _recorder = null;
    await recorder?.dispose();
  }

  @override
  Future<void> dispose() => _serial(() async {
    _endSession();
    await _disposeRecorder();
  });

  /// Restore the playback session before a quick restart can reuse it.
  /// An interruption only pauses the native recorder, so it also needs
  /// to be stopped. A native stop has already released the microphone.
  Future<void> _endedByPlatform(int capture, {required bool interrupted}) =>
      _serial(() async {
        if (capture != _captures || !_capturing) return;
        try {
          if (interrupted) {
            await _stopCapture();
          } else {
            _endSession();
            await _releaseCapture();
          }
        } on Object catch (error, stack) {
          LocalDiagnostics.report(
            DiagnosticContext.captureFailure,
            error,
            stack,
          );
        }
      });

  void _endSession() {
    final session = _session;
    _session = null;
    session
      ?..onSelfClose = null
      ..close();
  }
}

/// One capture: the merged stream handed to the caller plus the two plugin
/// subscriptions feeding it.
final class _CaptureSession {
  late final StreamController<Uint8List> _out = StreamController<Uint8List>(
    onCancel: _detachListener,
  );
  StreamSubscription<Uint8List>? _pcmSub;
  StreamSubscription<RecordState>? _stateSub;
  StreamSubscription<AVAudioSessionRouteChange>? _routeSub;
  bool _sawRecording = false;
  bool _closed = false;

  /// Called once when the capture ends by itself rather than through its
  /// owner (who clears it before closing). EOF follows the route cleanup.
  Future<void> Function(bool interrupted)? onSelfClose;

  Stream<Uint8List> get stream => _out.stream;

  void _detachListener() {
    // The owner calls stop after cancelling PCM delivery. Only the plug-in
    // can signal that native capture has already stopped.
    onSelfClose = null;
    close();
  }

  void watchStates(Stream<RecordState> states) {
    _stateSub = states.listen(
      _onState,
      onError: (Object error, StackTrace stack) {
        if (!_closed) _out.addError(error, stack);
      },
    );
  }

  void watchRouteChanges(Stream<AVAudioSessionRouteChange> routes) {
    _routeSub = routes.listen((change) {
      // The plug-in changes the category itself during startup. Only actual
      // device additions and removals interrupt an existing capture.
      final reason = change.reason;
      if (_sawRecording &&
          (reason == AVAudioSessionRouteChangeReason.newDeviceAvailable ||
              reason == AVAudioSessionRouteChangeReason.oldDeviceUnavailable)) {
        close(interrupted: true);
      }
    });
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
        // The recorder does not automatically resume after losing focus.
        if (_sawRecording) close(interrupted: true);
      case RecordState.stop:
        // Only after this session's own `record`: a late `stop` from the
        // previous capture can arrive after the next one subscribed.
        if (_sawRecording) close();
    }
  }

  /// Detach the plug-in streams immediately so native stop can release them.
  /// Keep output EOF out of the cleanup queue because an unlistened stream
  /// can take indefinitely to close.
  void close({bool interrupted = false}) {
    if (_closed) return;
    _closed = true;
    final onSelf = onSelfClose;
    onSelfClose = null;
    unawaited(_pcmSub?.cancel());
    unawaited(_stateSub?.cancel());
    unawaited(_routeSub?.cancel());
    _pcmSub = null;
    _stateSub = null;
    _routeSub = null;
    if (onSelf == null) {
      unawaited(_out.close());
    } else {
      unawaited(onSelf(interrupted).whenComplete(_out.close));
    }
  }
}
