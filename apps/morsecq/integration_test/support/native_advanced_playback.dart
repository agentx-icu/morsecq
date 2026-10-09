import 'package:morse_io/morse_io.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';

/// A recorded real-time timeline for native UI/file tests. Hosted runners may
/// have no audio device; device availability is tested separately, without
/// allowing this fixture to change production's sound-only assessment rule.
final class NativeAdvancedPlayback implements LearnPlaybackFactory {
  final sink = _RecordingSink();
  int get marks => sink.marks;

  @override
  Future<LearnPlayback> create(TrainingSettings settings) async =>
      LearnPlayback(
        sink: sink,
        clock: SystemClock.shared,
        flash: null,
        dispose: sink.dispose,
      );
}

final class _RecordingSink implements MorseSink {
  int marks = 0;
  @override
  Future<void> prepare() async {}
  @override
  void on() => marks++;
  @override
  void off() {}
  @override
  Future<void> dispose() async {}
}
