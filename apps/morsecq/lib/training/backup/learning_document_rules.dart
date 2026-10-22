import 'package:morse_trainer/morse_trainer.dart';

import '../audio_material_store.dart';
import '../file_trainer_store.dart';
import '../material_store.dart';
import '../qso_practice.dart';
import '../send_detail_store.dart';
import '../telegraph_sessions.dart';
import '../training_settings_store.dart';

/// Which files of the `training/` directory a learning backup carries, and
/// how each is checked before it is exported or restored.
///
/// Names are paths relative to `training/`: the two typed stores and the
/// `docs/<name>.json` documents of [FileTrainingDocStore]. A check throws
/// for a document the app could not use as a whole; per-entry damage that
/// the loaders already skip (one bad material) is accepted, as at runtime.
abstract final class LearningDocumentRules {
  static const String progress = 'progress.json';
  static const String settings = 'settings.json';
  static const String docsPrefix = 'docs/';

  static const Set<String> _fixedDocs = <String>{
    MaterialStore.doc,
    AudioMaterialStore.doc,
    QsoPractice.stationDoc,
    QsoPractice.draftDoc,
    TelegraphSessions.recallDoc,
    SendDetailStore.indexDoc,
  };
  static final RegExp _sendDetail = RegExp(r'^send_[a-z0-9_]{1,115}$');
  static final RegExp _finishedQso = RegExp(
    '^${QsoPractice.finishedPrefix}[a-z0-9_\\-]{1,100}\$',
  );

  /// The document name inside `docs/` for a backup path, or null.
  static String? docName(String path) {
    if (!path.startsWith(docsPrefix) || !path.endsWith('.json')) return null;
    return path.substring(docsPrefix.length, path.length - '.json'.length);
  }

  static String docPath(String name) => '$docsPrefix$name.json';

  /// Whether [path] is a document this version backs up and restores.
  static bool isKnown(String path) {
    if (path == progress || path == settings) return true;
    final name = docName(path);
    if (name == null || name.contains('..')) return false;
    return _fixedDocs.contains(name) ||
        _sendDetail.hasMatch(name) ||
        _finishedQso.hasMatch(name);
  }

  /// Throws [FormatException] unless [json] is a usable [path] document.
  static void check(String path, Map<String, Object?> json) {
    try {
      _check(path, json);
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw FormatException('Invalid $path: $error');
    }
  }

  static void _check(String path, Map<String, Object?> json) {
    if (path == progress) {
      FileTrainerStore.decode(json);
      return;
    }
    if (path == settings) {
      FileTrainingSettingsStore.decode(json);
      return;
    }
    final name = docName(path);
    if (name == null || !isKnown(path)) {
      throw FormatException('Unknown learning document $path');
    }
    switch (name) {
      case MaterialStore.doc || AudioMaterialStore.doc:
        UnsupportedDataVersion.check(json['v'], supported: 1, document: path);
        _require(json['materials'] is List, path);
      case QsoPractice.stationDoc:
        QsoStation.fromJson(json);
      case TelegraphSessions.recallDoc:
        _require(!TelegraphRecallStats.isNewer(json), path);
        TelegraphRecallStats.fromJson(json);
      case SendDetailStore.indexDoc:
        _require(json['entries'] is List, path);
      case QsoPractice.draftDoc:
        QsoPractice.decodeDraft(json);
      case _ when name.startsWith(QsoPractice.finishedPrefix):
        QsoPractice.decodeFinished(json);
      default:
        SendDetail.fromJson(json);
    }
  }

  static void _require(bool ok, String path) {
    if (!ok) throw FormatException('Invalid $path');
  }
}
