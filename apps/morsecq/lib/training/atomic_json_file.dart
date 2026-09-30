import 'dart:convert';
import 'dart:io';

/// A JSON document on disk that is written atomically and read defensively.
///
/// * [write] serialises to `<path>.tmp`, moves the previous document to
///   `<path>.bak` and renames the temp file into place, so a crash mid-write
///   never leaves a half-written primary file.
/// * [read] parses the primary file; if it is missing the result is null, if
///   it is corrupt the corrupt file is set aside as `<path>.corrupt` and the
///   `.bak` copy is tried instead. Both corrupt yields null rather than an
///   exception so the caller can start fresh.
///
/// Every store in `lib/training/` is a thin typed wrapper over this class so
/// the crash-safety story is written (and tested) once.
final class AtomicJsonFile {
  AtomicJsonFile(this.file);

  final File file;

  File get tempFile => File('${file.path}.tmp');
  File get backupFile => File('${file.path}.bak');
  File get corruptFile => File('${file.path}.corrupt');

  /// The decoded document, or null when nothing readable exists.
  Future<Map<String, Object?>?> read() async {
    final primary = await _tryRead(file);
    if (primary != null) {
      return primary;
    }
    if (!await file.exists()) {
      // Nothing was ever written, or the last write died between the
      // "move to .bak" and "rename tmp" steps. The backup is then the latest
      // good document, so fall through and try it.
      return _tryRead(backupFile);
    }
    // The primary exists but is unreadable: keep it for inspection and use
    // the backup.
    await _setAside();
    return _tryRead(backupFile);
  }

  /// Persists [json]: temp file -> rotate previous into `.bak` -> rename.
  Future<void> write(Map<String, Object?> json) async {
    final encoded = const JsonEncoder.withIndent('  ').convert(json);
    await file.parent.create(recursive: true);
    final tmp = tempFile;
    await tmp.writeAsString(encoded, flush: true);
    if (await file.exists()) {
      await file.rename(backupFile.path);
    }
    await tmp.rename(file.path);
  }

  /// Removes the document and its companions.
  Future<void> delete() async {
    for (final f in <File>[file, tempFile, backupFile, corruptFile]) {
      if (await f.exists()) {
        await f.delete();
      }
    }
  }

  Future<Map<String, Object?>?> _tryRead(File f) async {
    if (!await f.exists()) {
      return null;
    }
    try {
      final decoded = jsonDecode(await f.readAsString());
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  Future<void> _setAside() async {
    try {
      if (await corruptFile.exists()) {
        await corruptFile.delete();
      }
      await file.rename(corruptFile.path);
    } on FileSystemException {
      // Best effort: a read-only volume must not stop the fallback read.
    }
  }
}
