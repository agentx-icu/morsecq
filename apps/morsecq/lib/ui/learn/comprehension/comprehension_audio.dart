part of 'listening_comprehension_screen.dart';

/// A key-down must really reach the prepared sidetone. SidetoneSink keeps
/// live-keying recovery forgiving; head-copy grading needs this stricter
/// postcondition and the original API diagnostics on silent refusal.
final class _AudibleListeningSink implements MorseSink {
  _AudibleListeningSink(this.inner, this.tone);
  final MorseSink inner;
  final SidetoneSink? tone;

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
    if (output == null || output.isOn) return;
    final error =
        output.lastOutputError ?? StateError('Sidetone was not audible');
    final trace = output.lastOutputStackTrace;
    if (trace != null) Error.throwWithStackTrace(error, trace);
    throw error;
  }
}
