import 'package:morse_io/morse_io.dart';

/// A timeline may report completion only if key-down reached an enabled
/// output. Live keying continues to use the forgiving raw sink directly.
final class LearnPlaybackOutputSink implements MorseSink {
  LearnPlaybackOutputSink({
    required this.inner,
    required this.tone,
    this.allowAlternativeFeedback = false,
  });

  final MorseSink inner;
  final SidetoneSink? tone;
  final bool allowAlternativeFeedback;

  @override
  Future<void> prepare() => inner.prepare();
  @override
  Future<void> dispose() => inner.dispose();
  @override
  void off() => inner.off();
  @override
  void on() {
    inner.on();
    final output = tone;
    if (output == null || output.isOn || allowAlternativeFeedback) return;
    final error =
        output.lastOutputError ?? StateError('Sidetone was not audible');
    final trace = output.lastOutputStackTrace;
    if (trace != null) Error.throwWithStackTrace(error, trace);
    throw error;
  }
}
