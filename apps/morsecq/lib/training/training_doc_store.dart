import 'dart:io';

import 'package:morse_session/morse_session.dart';
import 'package:path/path.dart' as p;

import 'atomic_json_file.dart';

export 'package:morse_session/morse_session.dart'
    show InMemoryTrainingDocStore, TrainingDocStore;

/// `<dataDirectory>/training/docs/<name>.json`, written atomically with a
/// `.bak` fallback ([AtomicJsonFile]).
final class FileTrainingDocStore implements TrainingDocStore {
  FileTrainingDocStore(this.directory);

  factory FileTrainingDocStore.inDataDirectory(String dataDirectory) =>
      FileTrainingDocStore(
        Directory(p.join(dataDirectory, 'training', subdirectory)),
      );

  static const String subdirectory = 'docs';
  static final RegExp _safe = RegExp(r'^[a-z0-9_\-.]{1,120}$');

  final Directory directory;

  AtomicJsonFile _file(String name) {
    if (!_safe.hasMatch(name) || name.contains('..')) {
      throw ArgumentError.value(name, 'name', 'not a safe document name');
    }
    return AtomicJsonFile(File(p.join(directory.path, '$name.json')));
  }

  @override
  Future<Map<String, Object?>?> read(String name) => _file(name).read();

  @override
  Future<void> write(String name, Map<String, Object?> json) async {
    await directory.create(recursive: true);
    await _file(name).write(json);
  }

  @override
  Future<void> delete(String name) => _file(name).delete();

  @override
  Future<List<String>> names() async {
    if (!await directory.exists()) return const <String>[];
    final out = <String>{};
    await for (final entity in directory.list()) {
      final base = p.basename(entity.path);
      if (entity is! File) continue;
      final suffix = base.endsWith('.json.bak') ? '.json.bak' : '.json';
      if (!base.endsWith(suffix)) continue;
      final name = base.substring(0, base.length - suffix.length);
      if (_safe.hasMatch(name) && !name.contains('..')) out.add(name);
    }
    // A replacement interrupted after rotation leaves only .json.bak.
    // Include it so parked results can be discovered and recovered.
    return out.toList()..sort();
  }
}
