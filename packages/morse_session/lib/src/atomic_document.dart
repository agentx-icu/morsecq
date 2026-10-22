import 'dart:convert';

/// The file operations an [AtomicDocument] needs, supplied by the host: the
/// app implements it over `dart:io`, the mini-program bridge over the mini
/// program's file system manager.
abstract interface class DocumentFs {
  Future<bool> exists(String path);

  /// The file's text, or null when it does not exist. Storage failures are
  /// thrown; [isIoFailure] tells them apart from programming errors.
  Future<String?> readText(String path);

  /// Writes [text], creating parent directories; durable when it returns.
  Future<void> writeText(String path, String text);

  Future<void> rename(String from, String to);

  Future<void> delete(String path);

  /// One key per file, so operations on the same document serialize even
  /// when callers spell its path differently.
  String canonical(String path);

  /// Whether [error] is a storage failure that a defensive read or a
  /// best-effort step may swallow, as opposed to a bug.
  bool isIoFailure(Object error);
}

/// A JSON document that is written atomically and read defensively.
///
/// * [write] serialises to `<path>.tmp`, moves the previous document to
///   `<path>.bak` and renames the temp file into place, so a crash mid-write
///   never leaves a half-written primary file.
/// * [read] parses the primary file and falls back to `.bak` when it is
///   missing or unreadable. Corrupt primaries are set aside as `<path>.corrupt`.
///   [readDecoded] also validates the typed document before accepting it.
///   No usable document yields null so the caller can start fresh.
///
/// Every learning store is a thin typed wrapper over this class, so the
/// crash-safety story is written (and tested) once for every host.
final class AtomicDocument {
  AtomicDocument(this.fs, this.path);

  final DocumentFs fs;
  final String path;

  // Documents can be recreated while earlier operations are still running.
  // Serialize by canonical path, rather than by instance.
  static final Map<String, Future<void>> _operations = {};

  String get tempPath => '$path.tmp';
  String get backupPath => '$path.bak';
  String get corruptPath => '$path.corrupt';

  /// The decoded document, or null when nothing readable exists.
  Future<Map<String, Object?>?> read() => readDecoded((json) => json);

  /// Applies the typed codec before accepting a document, so an invalid
  /// document structure receives the same backup recovery as invalid JSON.
  Future<T?> readDecoded<T>(T Function(Map<String, Object?> json) decode) =>
      _serialize(() => _readDecoded(decode));

  Future<T?> _readDecoded<T>(
    T Function(Map<String, Object?> json) decode,
  ) async {
    final primary = await _tryRead(path, decode);
    if (primary != null) {
      return primary;
    }
    if (!await fs.exists(path)) {
      // Nothing was ever written, or the last write died between the
      // "move to .bak" and "rename tmp" steps. The backup is then the latest
      // good document, so fall through and try it.
      return _tryRead(backupPath, decode);
    }
    // The primary exists but is unreadable: keep it for inspection and use
    // the backup.
    await _setAside();
    return _tryRead(backupPath, decode);
  }

  /// Persists [json]: temp file -> rotate valid previous into `.bak` -> rename.
  /// [validate] checks the previous document's schema before rotating it.
  Future<void> write(
    Map<String, Object?> json, {
    void Function(Map<String, Object?> json)? validate,
  }) {
    // Take the snapshot at invocation, before callers can update their map.
    final encoded = const JsonEncoder.withIndent('  ').convert(json);
    return _serialize(() => _write(encoded, validate));
  }

  Future<void> _write(
    String encoded,
    void Function(Map<String, Object?> json)? validate,
  ) async {
    await fs.writeText(tempPath, encoded);
    if (await fs.exists(path)) {
      final previous = await _tryRead(path, (json) {
        validate?.call(json);
        return json;
      });
      if (previous == null) {
        // Never rotate a corrupt primary over the last usable backup.
        await _setAside();
      } else {
        await fs.rename(path, backupPath);
      }
    }
    await fs.rename(tempPath, path);
  }

  /// Removes the document and its companions.
  Future<void> delete() => _serialize(_delete);

  Future<void> _delete() async {
    for (final p in <String>[path, tempPath, backupPath, corruptPath]) {
      if (await fs.exists(p)) {
        await fs.delete(p);
      }
    }
  }

  Future<T?> _tryRead<T>(
    String p,
    T Function(Map<String, Object?> json) decode,
  ) async {
    final String? text;
    try {
      text = await fs.readText(p);
    } on Object catch (error) {
      if (fs.isIoFailure(error)) return null;
      rethrow;
    }
    if (text == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, Object?>) return null;
      try {
        return decode(decoded);
      } on Object {
        return null;
      }
    } on FormatException {
      return null;
    }
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final key = fs.canonical(path);
    final previous = _operations[key] ?? Future<void>.value();
    final result = previous.then((_) => operation());
    late final Future<void> settled;
    void release() {
      if (identical(_operations[key], settled)) _operations.remove(key);
    }

    // Keep the queue usable after a failed operation; the original result
    // still delivers the error to its caller.
    settled = result.then<void>(
      (_) => release(),
      onError: (Object error) {
        release();
      },
    );
    _operations[key] = settled;
    return result;
  }

  Future<void> _setAside() async {
    try {
      if (await fs.exists(corruptPath)) {
        await fs.delete(corruptPath);
      }
      await fs.rename(path, corruptPath);
    } on Object catch (error) {
      // Best effort: a read-only volume must not stop the fallback read.
      if (!fs.isIoFailure(error)) rethrow;
    }
  }
}
