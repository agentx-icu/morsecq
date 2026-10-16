import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'atomic_json_file.dart';

/// Recordings that were on this device when a learning backup was restored
/// (`media/recordings_kept.json`). The restored entries may not mention
/// them, but they are the learner's files: the workbench sweep of
/// unreferenced recordings must not delete them.
///
/// The list lives beside the recordings, outside the `training/` directory
/// a restore replaces, and is removed with them when learning is cleared.
final class KeptRecordings {
  KeptRecordings(String profileDir)
    : _json = AtomicJsonFile(
        File(p.join(profileDir, 'media', 'recordings_kept.json')),
      );

  final AtomicJsonFile _json;

  // Every operation is a read-modify-write of one file, and the read
  // bypasses AtomicJsonFile's per-write queue: serialize whole operations by
  // path, across instances in this process.
  static final Map<String, Future<void>> _queues = {};

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final key = p.normalize(_json.file.absolute.path);
    final result = (_queues[key] ?? Future<void>.value()).then(
      (_) => operation(),
    );
    late final Future<void> settled;
    settled = result.then<void>((_) {}, onError: (Object _) {}).whenComplete(
      () {
        if (identical(_queues[key], settled)) _queues.remove(key);
      },
    );
    _queues[key] = settled;
    return result;
  }

  /// The kept recordings from a valid primary list. Null when it is missing
  /// or unusable but any trace of a list remains (`.bak`, `.corrupt`,
  /// `.tmp`): nothing may be deleted on the strength of a damaged list, nor
  /// of a `.bak`, which can predate a later restore and protect less.
  Future<Set<String>?> load() => _serialized(_load);

  Future<Set<String>?> _load() async {
    try {
      final json = jsonDecode(await _json.file.readAsString());
      if (json is Map<String, Object?>) return _decode(json);
    } on FileSystemException {
      // Missing or unreadable: decided below.
    } on FormatException {
      return null;
    }
    final evidence = <File>[
      _json.file,
      _json.backupFile,
      _json.corruptFile,
      _json.tempFile,
    ];
    for (final f in evidence) {
      if (await f.exists()) return null;
    }
    return <String>{};
  }

  static Set<String> _decode(Map<String, Object?> json) {
    final files = json['files'];
    if (files is! List || files.any((f) => f is! String)) {
      throw const FormatException('Invalid kept recordings');
    }
    return files.cast<String>().toSet();
  }

  Future<void> save(Set<String> files) => _serialized(() => _save(files));

  Future<void> _save(Set<String> files) async {
    await _json.file.parent.create(recursive: true);
    await _json.write(<String, Object?>{
      'files': files.toList()..sort(),
    }, validate: _decode);
  }

  /// The list, or, when it cannot be read, [present] (every recording on
  /// disk now) saved as the new list. A failed save throws.
  Future<Set<String>> loadOrRebuild(Future<Set<String>> Function() present) =>
      _serialized(() async {
        final current = await _load();
        if (current != null) return current;
        final rebuilt = await present();
        await _save(rebuilt);
        return rebuilt;
      });

  /// Adds every file in [files] (a restore keeps what is on disk now).
  Future<void> addAll(Set<String> files) => _serialized(() async {
    if (files.isEmpty) return;
    final current = await _load() ?? <String>{};
    await _save({...current, ...files});
  });

  /// Lets the sweep collect [file] again once its last entry is gone. An
  /// unreadable list is left alone.
  Future<void> release(String file) => _serialized(() async {
    final current = await _load();
    if (current != null && current.remove(file)) await _save(current);
  });
}
