import 'dart:io';

import 'package:path/path.dart' as p;

import '../atomic_json_file.dart';
import '../training_doc_store.dart';
import 'learning_document_rules.dart';

/// The learning documents read from a profile for a backup, plus every
/// path that could not be included (unreadable or unknown), so the learner
/// is told instead of silently losing it.
final class LearningSnapshot {
  const LearningSnapshot(this.documents, this.skipped);
  final Map<String, Map<String, Object?>> documents;
  final List<String> skipped;
}

/// Reads every logical learning document of the profile at [profileDir].
///
/// Each file goes through [AtomicJsonFile] with its [LearningDocumentRules]
/// check, so a damaged primary falls back to its `.bak` exactly as the app
/// does. Companions (`.bak`, `.tmp`, `.corrupt`) are never exported.
///
/// Call it while learning writes are held and drained: per-file ordering
/// alone does not make several documents one consistent snapshot.
Future<LearningSnapshot> captureLearning(String profileDir) async {
  final training = Directory(p.join(profileDir, 'training'));
  final documents = <String, Map<String, Object?>>{};
  final skipped = <String>[];
  if (!await training.exists()) return LearningSnapshot(documents, skipped);

  Future<void> take(String path) async {
    final file = File(p.joinAll([training.path, ...path.split('/')]));
    final json = AtomicJsonFile(file);
    // Checked before reading, which sets an unusable primary aside. Only
    // quarantined evidence left (from this or an earlier read) still means
    // the learner had this document.
    final existed =
        await file.exists() ||
        await json.backupFile.exists() ||
        await json.corruptFile.exists();
    final doc = await json.readDecoded((raw) {
      LearningDocumentRules.check(path, raw);
      return raw;
    });
    if (doc != null) {
      documents[path] = doc;
    } else if (existed) {
      skipped.add(path);
    }
  }

  await take(LearningDocumentRules.progress);
  await take(LearningDocumentRules.settings);
  final docs = FileTrainingDocStore.inDataDirectory(profileDir);
  final names = {...await docs.names(), ...await _quarantined(docs.directory)};
  for (final name in names) {
    final path = LearningDocumentRules.docPath(name);
    if (LearningDocumentRules.isKnown(path)) {
      await take(path);
    } else {
      skipped.add(path);
    }
  }
  return LearningSnapshot(documents, skipped..sort());
}

/// Documents only present as `<name>.json.corrupt`.
Future<List<String>> _quarantined(Directory docs) async {
  if (!await docs.exists()) return const <String>[];
  const suffix = '.json.corrupt';
  final names = <String>[];
  await for (final entity in docs.list()) {
    final base = p.basename(entity.path);
    if (entity is File && base.endsWith(suffix)) {
      names.add(base.substring(0, base.length - suffix.length));
    }
  }
  return names;
}
