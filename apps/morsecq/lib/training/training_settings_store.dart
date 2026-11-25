import 'dart:io';

import 'package:morse_session/morse_session.dart';
import 'package:path/path.dart' as p;

import 'atomic_json_file.dart';

export 'package:morse_session/morse_session.dart'
    show InMemoryTrainingSettingsStore, TrainingSettingsCodec, TrainingSettingsStore;

/// Settings as `<dataDirectory>/training/settings.json`, written atomically
/// with a `.bak` fallback (see [AtomicJsonFile]) and validated with
/// [TrainingSettingsCodec].
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
  Future<TrainingSettings?> load() =>
      _json.readDecoded(TrainingSettingsCodec.decode);

  @override
  Future<void> save(TrainingSettings settings) =>
      _json.write(settings.toJson(), validate: TrainingSettingsCodec.decode);

  @override
  Future<void> clear() => _json.delete();
}
