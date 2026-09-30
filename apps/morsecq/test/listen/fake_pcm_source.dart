import 'dart:async';
import 'dart:typed_data';

import 'package:morsecq/ui/listen/pcm_source.dart';

/// Test double for the microphone: the test pushes PCM bytes by hand.
///
/// The stream is synchronous so a `push` is decoded before the call
/// returns, which keeps widget tests free of timing.
final class FakePcmSource implements PcmSource {
  FakePcmSource({this.permissionGranted = true, this.startError});

  /// Answer for [hasPermission].
  bool permissionGranted;

  /// When set, [start] throws it (simulates "no input device").
  Object? startError;

  StreamController<Uint8List>? _controller;
  int startCalls = 0;
  int stopCalls = 0;
  bool disposed = false;
  int? lastSampleRate;
  int? lastChannels;

  bool get isStreaming => _controller != null;

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<Stream<Uint8List>> start({
    required int sampleRate,
    required int channels,
  }) async {
    startCalls++;
    lastSampleRate = sampleRate;
    lastChannels = channels;
    final error = startError;
    if (error != null) throw error;
    _controller = StreamController<Uint8List>(sync: true);
    return _controller!.stream;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    // The controller is synchronous, so close() is immediate; its future is
    // the root-zone `_nullFuture` once the listener cancelled, which never
    // resumes under FakeAsync, so it must not be awaited.
    unawaited(_controller?.close());
    _controller = null;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await stop();
  }

  /// Delivers one chunk of little-endian PCM16 bytes to the listener.
  void push(Uint8List bytes) {
    final controller = _controller;
    if (controller == null) {
      throw StateError('FakePcmSource.push called while not streaming');
    }
    controller.add(bytes);
  }

  /// Ends the stream as the OS would when the device disappears.
  Future<void> endStream() async {
    unawaited(_controller?.close());
    _controller = null;
  }
}
