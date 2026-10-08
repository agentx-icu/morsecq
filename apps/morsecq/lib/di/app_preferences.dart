import 'dart:convert';

import 'package:flutter/material.dart';

import '../i18n/key_value_store.dart';
import '../ui/listen/listen_preferences.dart';
import '../ui/listen/listen_settings.dart';
import '../ui/reference/reference_playback_settings.dart';
import 'app_settings.dart';

/// Restores preferences before providers are exposed and saves changes through
/// the same local store as language/window settings.
final class AppPreferences {
  AppPreferences(this._store) {
    settings = AppSettings(store: _store);
    final r = _read('reference.playback');
    reference = ReferencePlaybackSettings(
      wpm: _number(r, 'wpm', 15),
      farnsworthWpm: r['farnsworthWpm'] is num
          ? _number(r, 'farnsworthWpm', 8)
          : null,
      toneHz: _number(r, 'toneHz', 700),
    );
    final l = _read('listen.decoder');
    final block = _number(l, 'blockSize', 256).toInt();
    listen = ListenPreferences(
      ListenSettings(
        blockSize: ListenSettings.blockSizes.contains(block) ? block : 256,
        minElementMs: _number(l, 'minElementMs', 12).clamp(4, 40).toInt(),
        autoTune: _bool(l, 'autoTune', true),
        manualHz: _number(l, 'manualHz', 700).clamp(400.0, 1000.0),
      ),
    );
    _watch(
      reference,
      () => _saveJson('reference.playback', {
        'wpm': reference.wpm,
        'farnsworthWpm': reference.farnsworthWpm,
        'toneHz': reference.toneHz,
      }),
    );
    _watch(
      listen,
      () => _saveJson('listen.decoder', {
        'blockSize': listen.settings.blockSize,
        'minElementMs': listen.settings.minElementMs,
        'autoTune': listen.settings.autoTune,
        'manualHz': listen.settings.manualHz,
      }),
    );
  }

  final KeyValueStore _store;
  late final AppSettings settings;
  late final ReferencePlaybackSettings reference;
  late final ListenPreferences listen;
  final Map<ChangeNotifier, VoidCallback> _listeners = {};
  Future<void> _pending = Future<void>.value();
  final Map<String, ({String? value, Object version})> _dirty = {};
  final Map<String, Object> _saveErrors = {};
  bool _disposed = false;

  static bool _bool(Map<String, Object?> m, String k, bool fallback) =>
      m[k] is bool ? m[k]! as bool : fallback;
  static double _number(Map<String, Object?> m, String k, double fallback) {
    final value = m[k];
    return value is num && value.isFinite ? value.toDouble() : fallback;
  }

  Map<String, Object?> _read(String key) {
    try {
      final raw = _store.getString(key);
      final value = raw == null ? null : jsonDecode(raw);
      return value is Map<String, Object?> ? value : {};
    } on FormatException {
      return {};
    }
  }

  void _watch(ChangeNotifier model, VoidCallback callback) {
    _listeners[model] = callback;
    model.addListener(callback);
  }

  void _saveJson(String key, Map<String, Object?> values) =>
      _save(key, jsonEncode(values));

  void _save(String key, String value) {
    if (_disposed) return;
    _change(key, value);
  }

  void _change(String key, String? value) {
    final write = (value: value, version: Object());
    _dirty[key] = write;
    _enqueue(key, write);
  }

  void _enqueue(String key, ({String? value, Object version}) write) {
    _pending = _pending.then((_) async {
      try {
        final value = write.value;
        if (value == null) {
          await _store.remove(key);
        } else {
          await _store.setString(key, value);
        }
        if (identical(_dirty[key]?.version, write.version)) {
          _dirty.remove(key);
          _saveErrors.remove(key);
        }
      } on Object catch (error, stack) {
        if (identical(_dirty[key]?.version, write.version)) {
          _saveErrors[key] = error;
        }
        debugPrint('[AppPreferences] save failed for $key: $error\n$stack');
      }
    });
  }

  Future<void> _drain() async {
    Future<void> pending;
    do {
      pending = _pending;
      await pending;
    } while (!identical(pending, _pending));
  }

  Future<void> flush() async {
    await Future.wait([settings.flush(), _drain()]);
    // Retry retained snapshots, including removals, once per flush. A save to
    // another key cannot erase a failure or commit its optimistic model value.
    for (final entry in _dirty.entries.toList()) {
      _enqueue(entry.key, entry.value);
    }
    await _drain();
    if (_dirty.isNotEmpty) {
      throw StateError('Could not save app preferences: $_saveErrors');
    }
  }

  void dispose() {
    _disposed = true;
    settings.dispose();
    for (final entry in _listeners.entries) {
      entry.key.removeListener(entry.value);
      entry.key.dispose();
    }
  }
}
