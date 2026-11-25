import 'dart:convert';

/// Named JSON documents beside the training progress: simulator drafts,
/// materials, rhythm details. Each lives under the learning profile's
/// `training/` directory alongside the rest of the local learning files.
abstract interface class TrainingDocStore {
  Future<Map<String, Object?>?> read(String name);

  Future<void> write(String name, Map<String, Object?> json);

  Future<void> delete(String name);

  /// Every stored document name (for cache trimming).
  Future<List<String>> names();
}

/// Keeps documents as JSON strings so tests exercise (de)serialisation.
final class InMemoryTrainingDocStore implements TrainingDocStore {
  final Map<String, String> docs = <String, String>{};

  @override
  Future<Map<String, Object?>?> read(String name) async {
    final raw = docs[name];
    return raw == null ? null : jsonDecode(raw) as Map<String, Object?>;
  }

  @override
  Future<void> write(String name, Map<String, Object?> json) async {
    docs[name] = jsonEncode(json);
  }

  @override
  Future<void> delete(String name) async {
    docs.remove(name);
  }

  @override
  Future<List<String>> names() async => docs.keys.toList()..sort();
}
