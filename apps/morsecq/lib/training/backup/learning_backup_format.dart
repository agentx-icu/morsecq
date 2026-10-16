import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../audio_material_store.dart';
import '../file_trainer_store.dart';
import '../material_store.dart';
import 'learning_document_rules.dart';

/// Why a backup file was refused; [reason] selects the user-facing message.
enum LearningBackupProblem { tooLarge, notBackup, newerVersion, damaged }

final class LearningBackupException implements Exception {
  const LearningBackupException(this.reason, [this.detail = '']);
  final LearningBackupProblem reason;
  final String detail;
  @override
  String toString() => 'LearningBackupException(${reason.name}) $detail';
}

/// What a backup holds, for the confirmation before replacing anything.
final class LearningBackupSummary {
  const LearningBackupSummary({
    required this.lesson,
    required this.courseCompleted,
    required this.sessions,
    required this.materials,
    required this.audioMaterials,
    required this.documents,
  });
  final int lesson;
  final bool courseCompleted;
  final int sessions;
  final int materials;
  final int audioMaterials;
  final int documents;
}

/// One `*.morsecq-backup.json` file: the learning documents of a profile
/// (paths relative to `training/`) in a versioned, checksummed envelope.
///
/// The SHA-256 covers the canonical encoding (recursively sorted keys, no
/// whitespace) of every field but itself. It detects damage in transit; it
/// does not authenticate the file. Recording bytes are never included.
final class LearningBackup {
  LearningBackup({
    required this.createdAt,
    required Map<String, Map<String, Object?>> documents,
    this.appVersion = '',
  }) : documents = Map.unmodifiable(documents);

  static const String format = 'morsecq-learning-backup';
  static const int version = 1;
  static const String fileExtension = '.morsecq-backup.json';
  static const int maxBytes = 64 * 1024 * 1024;
  static const int maxDocuments = 20000;

  final DateTime createdAt;
  final String appVersion;
  final Map<String, Map<String, Object?>> documents;

  /// A default file name for [createdAt], e.g. `morsecq-20261016-2215`.
  String suggestedFileName() {
    final t = createdAt.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'morsecq-${t.year}${two(t.month)}${two(t.day)}-'
        '${two(t.hour)}${two(t.minute)}$fileExtension';
  }

  Map<String, Object?> _body() => <String, Object?>{
    'format': format,
    'version': version,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'appVersion': appVersion,
    'documents': documents,
  };

  /// The file contents. Every document is checked first, so a backup that
  /// this version would refuse to restore is never written.
  /// Throws [LearningBackupProblem.tooLarge] past [limit] bytes, the size
  /// [decode] accepts.
  List<int> encode({int limit = maxBytes}) {
    _checkDocuments(documents);
    final body = _body();
    final bytes = utf8.encode(
      jsonEncode(<String, Object?>{...body, 'sha256': checksum(body)}),
    );
    if (bytes.length > limit) {
      throw const LearningBackupException(LearningBackupProblem.tooLarge);
    }
    return bytes;
  }

  /// Parses and fully validates [bytes]; throws [LearningBackupException].
  static LearningBackup decode(List<int> bytes, {int limit = maxBytes}) {
    if (bytes.length > limit) {
      throw const LearningBackupException(LearningBackupProblem.tooLarge);
    }
    final Object? root;
    try {
      root = jsonDecode(utf8.decode(bytes));
    } on FormatException catch (e) {
      throw LearningBackupException(LearningBackupProblem.notBackup, '$e');
    }
    if (root is! Map<String, Object?> || root['format'] != format) {
      throw const LearningBackupException(LearningBackupProblem.notBackup);
    }
    final v = root['version'];
    if (v is! int || v < 1) {
      throw const LearningBackupException(LearningBackupProblem.notBackup);
    }
    if (v > version) {
      throw const LearningBackupException(LearningBackupProblem.newerVersion);
    }
    final digest = root['sha256'];
    final body = Map<String, Object?>.of(root)..remove('sha256');
    if (digest is! String || digest != checksum(body)) {
      throw const LearningBackupException(
        LearningBackupProblem.damaged,
        'checksum',
      );
    }
    final created = root['createdAt'];
    final raw = root['documents'];
    final createdAt = created is String ? DateTime.tryParse(created) : null;
    if (createdAt == null || raw is! Map<String, Object?>) {
      throw const LearningBackupException(LearningBackupProblem.damaged);
    }
    final documents = <String, Map<String, Object?>>{};
    for (final MapEntry(:key, :value) in raw.entries) {
      if (value is! Map<String, Object?>) {
        throw LearningBackupException(LearningBackupProblem.damaged, key);
      }
      documents[key] = value;
    }
    _checkDocuments(documents);
    final app = root['appVersion'];
    return LearningBackup(
      createdAt: createdAt,
      documents: documents,
      appVersion: app is String ? app : '',
    );
  }

  static void _checkDocuments(Map<String, Map<String, Object?>> documents) {
    if (documents.length > maxDocuments) {
      throw const LearningBackupException(LearningBackupProblem.tooLarge);
    }
    for (final MapEntry(:key, :value) in documents.entries) {
      if (!LearningDocumentRules.isKnown(key)) {
        throw LearningBackupException(LearningBackupProblem.damaged, key);
      }
      try {
        LearningDocumentRules.check(key, value);
      } on FormatException catch (e) {
        throw LearningBackupException(LearningBackupProblem.damaged, '$e');
      }
    }
  }

  LearningBackupSummary summary() {
    final raw = documents[LearningDocumentRules.progress];
    final progress = raw == null ? null : FileTrainerStore.decode(raw);
    int count(String doc) {
      final list = documents[LearningDocumentRules.docPath(doc)]?['materials'];
      return list is List ? list.length : 0;
    }

    return LearningBackupSummary(
      lesson: progress?.currentLesson ?? 1,
      courseCompleted: progress?.courseCompleted ?? false,
      sessions: progress?.lifetimeSessions ?? 0,
      materials: count(MaterialStore.doc),
      audioMaterials: count(AudioMaterialStore.doc),
      documents: documents.length,
    );
  }

  /// The SHA-256 of [body] (an envelope without `sha256`) in canonical form.
  static String checksum(Map<String, Object?> body) =>
      sha256.convert(utf8.encode(jsonEncode(_canonical(body)))).toString();

  static Object? _canonical(Object? value) => switch (value) {
    final Map<String, Object?> map => <String, Object?>{
      for (final key in map.keys.toList()..sort()) key: _canonical(map[key]),
    },
    final List<Object?> list => [for (final e in list) _canonical(e)],
    _ => value,
  };
}
