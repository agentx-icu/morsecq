import 'dart:async';

import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';

/// Plays receive practice under simulated radio conditions (F11): renders
/// the round with [RadioRenderer] and hands the WAV to a [ClipPlayer] on the
/// shared audio engine (engine leases), so the low-latency keying sidetone
/// is never replaced. Audio only: an unaffected flash or haptic track would
/// give the answer away.
final class ConditionsPlayback {
  ConditionsPlayback({ClipPlayer? player})
    : _player = player ?? SoloudClipPlayer();

  final ClipPlayer _player;
  bool _disposed = false;

  bool get isPlaying => _player.isPlaying;

  /// `true` when a rendering starts, `false` when it ends or is stopped.
  Stream<bool> get playing => _player.playing;

  /// Stops anything playing, then plays [text] under [scenario].
  Future<void> play(String text, RadioScenario scenario) async {
    if (_disposed) return;
    final samples = RadioRenderer.render(text, scenario);
    await _player.play(
      RadioRenderer.wav(samples),
      length: RadioRenderer.lengthOf(samples),
    );
  }

  Future<void> stop() => _disposed ? Future<void>.value() : _player.stop();

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _player.dispose();
  }
}

/// What the preset preview keys: audio only, never shown as text.
const String kConditionsPreviewText = 'CQ CQ DE DL1ABC K';

/// User-facing name of a preset.
String radioPresetLabel(S s, RadioPreset preset) => switch (preset) {
  RadioPreset.clear => s.conditionsClear,
  RadioPreset.light => s.conditionsLight,
  RadioPreset.radio => s.conditionsRadio,
};

/// One-line description of a preset.
String radioPresetHint(S s, RadioPreset preset) => switch (preset) {
  RadioPreset.clear => s.conditionsClearHint,
  RadioPreset.light => s.conditionsLightHint,
  RadioPreset.radio => s.conditionsRadioHint,
};
