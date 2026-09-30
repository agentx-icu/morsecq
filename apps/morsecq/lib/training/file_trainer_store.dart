import 'dart:io';

import 'package:morse_trainer/morse_trainer.dart';
import 'package:path/path.dart' as p;

import 'atomic_json_file.dart';

/// [TrainerStore] persisted as `<dataDirectory>/training/progress.json`.
///
/// Progress lives inside the identity's data directory (product decision:
/// training requires an identity), so switching or deleting an identity
/// switches or deletes its training progress with it. Writes are atomic and
/// a corrupt file falls back to the `.bak` of the previous save; see
/// [AtomicJsonFile].
final class FileTrainerStore implements TrainerStore {
  FileTrainerStore(this.file) : _json = AtomicJsonFile(file);

  /// The conventional location under an identity's data directory.
  factory FileTrainerStore.inDataDirectory(String dataDirectory) =>
      FileTrainerStore(File(p.join(dataDirectory, subdirectory, fileName)));

  static const String subdirectory = 'training';
  static const String fileName = 'progress.json';

  final File file;
  final AtomicJsonFile _json;

  @override
  Future<TrainerProgress?> load() async {
    final json = await _json.read();
    if (json == null) {
      return null;
    }
    try {
      return TrainerProgress.fromJson(json);
    } on Object {
      // Structurally valid JSON that is not a progress document (e.g. an
      // older schema we cannot read). Treat like a missing file; the next
      // save rotates it into .bak so nothing is lost.
      return null;
    }
  }

  @override
  Future<void> save(TrainerProgress progress) => _json.write(progress.toJson());

  @override
  Future<void> clear() => _json.delete();
}
