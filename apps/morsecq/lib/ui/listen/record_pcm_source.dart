import 'dart:typed_data';

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
/// On iOS the plugin switches the shared audio session to `playAndRecord`
/// (Bluetooth HFP allowed, not mixable) and leaves it there; [stop] puts the
/// playback session `morse_io` runs the sidetone in back, so the tone keeps
/// ignoring the silent switch, mixing with music and using A2DP.
final class RecordPcmSource implements PcmSource {
  RecordPcmSource({
    AudioRecorder? recorder,
    AudioSessionApi session = const PlatformAudioSessionApi(),
  }) : _recorder = recorder ?? AudioRecorder(),
       _session = session;

  final AudioRecorder _recorder;
  final AudioSessionApi _session;
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
  }) => _serial(() {
    _capturing = true;
    return _recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: channels,
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
      ),
    );
  });

  @override
  Future<void> stop() => _serial(() async {
    try {
      await _recorder.stop();
    } finally {
      if (_capturing) {
        _capturing = false;
        await _session.configureForPlayback();
      }
    }
  });

  @override
  Future<void> dispose() => _serial(_recorder.dispose);
}
