import 'dart:io';

import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:path/path.dart' as p;

import 'atomic_json_file.dart';

/// [TrainerStore] persisted as `<dataDirectory>/training/progress.json`.
///
/// The local profile owns learning progress. Writes are atomic, and a corrupt
/// file falls back to the previous save's `.bak`; see [AtomicJsonFile].
/// Documents are validated with [TrainerProgressCodec], shared with the
/// learning backup.
final class FileTrainerStore implements TrainerStore {
  FileTrainerStore(this.file) : _json = AtomicJsonFile(file);

  /// The conventional location under the local learning directory.
  factory FileTrainerStore.inDataDirectory(String dataDirectory) =>
      FileTrainerStore(File(p.join(dataDirectory, subdirectory, fileName)));

  static const String subdirectory = 'training';
  static const String fileName = 'progress.json';

  final File file;
  final AtomicJsonFile _json;

  @override
  Future<TrainerProgress?> load() =>
      _json.readDecoded(TrainerProgressCodec.decode);

  @override
  Future<void> save(TrainerProgress progress) =>
      _json.write(progress.toJson(), validate: TrainerProgressCodec.decode);

  @override
  Future<void> clear() => _json.delete();
}
