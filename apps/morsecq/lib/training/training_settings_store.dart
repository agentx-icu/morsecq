import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'atomic_json_file.dart';
import 'training_settings.dart';

/// Persistence boundary for [TrainingSettings]; mirrors `TrainerStore`.
abstract interface class TrainingSettingsStore {
  /// Saved settings, or null when nothing has been saved yet.
  Future<TrainingSettings?> load();

  Future<void> save(TrainingSettings settings);

  Future<void> clear();
}

/// Settings as `<dataDirectory>/training/settings.json`, written atomically
/// with a `.bak` fallback (see [AtomicJsonFile]).
final class FileTrainingSettingsStore implements TrainingSettingsStore {
  FileTrainingSettingsStore(this.file) : _json = AtomicJsonFile(file);

  factory FileTrainingSettingsStore.inDataDirectory(String dataDirectory) =>
      FileTrainingSettingsStore(
        File(p.join(dataDirectory, subdirectory, fileName)),
      );

  static const String subdirectory = 'training';
  static const String fileName = 'settings.json';

  final File file;
  final AtomicJsonFile _json;

  @override
  Future<TrainingSettings?> load() async {
    final json = await _json.read();
    if (json == null) {
      return null;
    }
    try {
      return TrainingSettings.fromJson(json);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(TrainingSettings settings) =>
      _json.write(settings.toJson());

  @override
  Future<void> clear() => _json.delete();
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
    return TrainingSettings.fromJson(
      jsonDecode(json) as Map<String, Object?>,
    );
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
