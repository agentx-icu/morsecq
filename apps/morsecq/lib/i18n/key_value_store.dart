import 'dart:convert';
import 'dart:io';

/// Minimal string key/value persistence that [LocaleController] is written
/// against, so the language choice can be stored without the app committing
/// to a preferences plugin. Production wires a real store (a JSON file via
/// [JsonFileKeyValueStore], or an adapter over `shared_preferences`); tests
/// use [InMemoryKeyValueStore].
abstract interface class KeyValueStore {
  /// The stored value for [key], or null when nothing was saved.
  String? getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);
}

/// Map-backed store for tests and for the fake backend.
final class InMemoryKeyValueStore implements KeyValueStore {
  InMemoryKeyValueStore([Map<String, String>? initial])
    : _values = {...?initial};

  final Map<String, String> _values;

  /// Snapshot of the current contents (for assertions).
  Map<String, String> get values => Map.unmodifiable(_values);

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}

/// Store persisted as one small JSON object (`{"key": "value"}`) in [file].
///
/// The whole file is read once in [open] and rewritten on every change via a
/// temporary file + rename, so a crash mid-write cannot leave a truncated
/// file behind. Malformed content is treated as empty rather than fatal: the
/// language preference is a convenience, never worth blocking startup for.
final class JsonFileKeyValueStore implements KeyValueStore {
  JsonFileKeyValueStore._(this.file, this._values);

  /// Reads [file] (if it exists) and returns a ready store.
  static Future<JsonFileKeyValueStore> open(File file) async {
    final values = <String, String>{};
    if (await file.exists()) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final key = entry.key;
            final value = entry.value;
            if (key is String && value is String) values[key] = value;
          }
        }
      } on FormatException {
        // Corrupt preferences file: start over, do not crash.
      }
    }
    return JsonFileKeyValueStore._(file, values);
  }

  final File file;
  final Map<String, String> _values;
  Future<void> _writes = Future<void>.value();

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) => _update(key, value);

  @override
  Future<void> remove(String key) => _update(key, null);

  Future<void> _update(String key, String? value) {
    final write = _writes.then((_) async {
      if (value == null && !_values.containsKey(key)) return;
      // Clone the last committed map inside the queue. A failed write must
      // never leak into a later successful save of an unrelated preference.
      final next = {..._values};
      if (value == null) {
        next.remove(key);
      } else {
        next[key] = value;
      }
      await file.parent.create(recursive: true);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(jsonEncode(next), flush: true);
      await tmp.rename(file.path);
      _values
        ..clear()
        ..addAll(next);
    });
    _writes = write.catchError((Object error) {});
    return write;
  }
}
