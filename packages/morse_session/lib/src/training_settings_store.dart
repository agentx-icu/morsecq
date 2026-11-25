import 'dart:convert';

import 'training_settings.dart';

/// Persistence boundary for [TrainingSettings]; mirrors `TrainerStore`.
abstract interface class TrainingSettingsStore {
  /// Saved settings, or null when nothing has been saved yet.
  Future<TrainingSettings?> load();

  Future<void> save(TrainingSettings settings);

  Future<void> clear();
}

/// Typed validation and clamping of a stored `settings.json`, shared by the
/// app's file store, the learning backup and the mini-program bridge.
abstract final class TrainingSettingsCodec {
  static TrainingSettings decode(Map<String, Object?> json) {
    final settings = TrainingSettings.fromJson(json);
    final trainer = settings.trainer;
    final parameters = <double?>[
      trainer.characterWpm,
      trainer.farnsworthWpm,
      trainer.toneHz,
    ];
    if (parameters.any((v) => v != null && (!v.isFinite || v <= 0)) ||
        trainer.sessionLengthChars <= 0 ||
        (trainer.sessionLengthSeconds != null &&
            trainer.sessionLengthSeconds! <= 0) ||
        trainer.groupSize <= 0) {
      throw const FormatException('Invalid training settings');
    }
    // Keep every value inside what the settings screen can set: a positive
    // but absurd speed (say 1e300 WPM) would round the dit to zero and break
    // playback and keying. Older builds also offered sessions down to 20
    // symbols, too short for a lesson session to ever unlock the next
    // lesson; those are lifted to the floor.
    final wpm = trainer.characterWpm.clamp(
      TrainingSettings.minCharacterWpm,
      TrainingSettings.maxCharacterWpm,
    );
    final farnsworth = trainer.farnsworthWpm?.clamp(
      TrainingSettings.minFarnsworthWpm,
      wpm,
    );
    final bounded = trainer.copyWith(
      characterWpm: wpm,
      farnsworthWpm: farnsworth,
      toneHz: trainer.toneHz.clamp(
        TrainingSettings.minToneHz,
        TrainingSettings.maxToneHz,
      ),
      sessionLengthChars: trainer.sessionLengthChars.clamp(
        TrainingSettings.minSessionChars,
        TrainingSettings.maxSessionChars,
      ),
    );
    return bounded == trainer ? settings : settings.copyWith(trainer: bounded);
  }
}

/// Round-trips through JSON in memory so tests exercise the real codec.
final class InMemoryTrainingSettingsStore implements TrainingSettingsStore {
  InMemoryTrainingSettingsStore([TrainingSettings? initial])
    : _json = initial == null ? null : jsonEncode(initial.toJson());

  String? _json;
  int _saveCount = 0;

  int get saveCount => _saveCount;

  @override
  Future<TrainingSettings?> load() async {
    final json = _json;
    if (json == null) {
      return null;
    }
    return TrainingSettings.fromJson(jsonDecode(json) as Map<String, Object?>);
  }

  @override
  Future<void> save(TrainingSettings settings) async {
    _json = jsonEncode(settings.toJson());
    _saveCount++;
  }

  @override
  Future<void> clear() async {
    _json = null;
  }
}
