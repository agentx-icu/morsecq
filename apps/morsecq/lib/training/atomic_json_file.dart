import 'dart:io';

import 'package:morse_session/morse_session.dart';
import 'package:path/path.dart' as p;

/// [DocumentFs] over `dart:io`.
final class IoDocumentFs implements DocumentFs {
  const IoDocumentFs();

  @override
  Future<bool> exists(String path) => File(path).exists();

  @override
  Future<String?> readText(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    return file.readAsString();
  }

  @override
  Future<void> writeText(String path, String text) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(text, flush: true);
  }

  @override
  Future<void> rename(String from, String to) => File(from).rename(to);

  @override
  Future<void> delete(String path) => File(path).delete();

  @override
  String canonical(String path) => p.normalize(File(path).absolute.path);

  @override
  bool isIoFailure(Object error) => error is FileSystemException;
}

/// A JSON document on disk that is written atomically and read defensively:
/// [AtomicDocument] (package `morse_session`) over [IoDocumentFs]. See that
/// class for the temp / `.bak` / `.corrupt` protocol.
///
/// Every store in `lib/training/` is a thin typed wrapper over this class so
/// the crash-safety story is written (and tested) once.
final class AtomicJsonFile {
  AtomicJsonFile(this.file)
    : _doc = AtomicDocument(const IoDocumentFs(), file.path);

  final File file;
  final AtomicDocument _doc;

  File get tempFile => File(_doc.tempPath);
  File get backupFile => File(_doc.backupPath);
  File get corruptFile => File(_doc.corruptPath);

  /// The decoded document, or null when nothing readable exists.
  Future<Map<String, Object?>?> read() => _doc.read();

  /// Applies the typed codec before accepting a document, so an invalid
  /// document structure receives the same backup recovery as invalid JSON.
  Future<T?> readDecoded<T>(T Function(Map<String, Object?> json) decode) =>
      _doc.readDecoded(decode);

  /// Persists [json]: temp file -> rotate valid previous into `.bak` -> rename.
  /// [validate] checks the previous document's schema before rotating it.
  Future<void> write(
    Map<String, Object?> json, {
    void Function(Map<String, Object?> json)? validate,
  }) => _doc.write(json, validate: validate);

  /// Removes the document and its companions.
  Future<void> delete() => _doc.delete();
}
