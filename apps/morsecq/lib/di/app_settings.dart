import 'dart:convert';

import 'package:flutter/material.dart';

import '../i18n/key_value_store.dart';
import '../ui/appearance/ui_style.dart';

/// App-wide user preferences that are not tied to an identity. Training and
/// playback defaults belong to the learn UI; this only carries what the shell
/// itself needs.
class AppSettings extends ChangeNotifier {
  AppSettings({required this.backendLabel, KeyValueStore? store})
    : _store = store ?? InMemoryKeyValueStore() {
    final saved = _store.getString(storageKey);
    if (saved == null) return;
    try {
      final decoded = jsonDecode(saved);
      if (decoded is! Map<String, dynamic>) return;
      _style = UiStyle.values.firstWhere(
        (value) => value.name == decoded['style'],
        orElse: () => UiStyle.classic,
      );
      _themeMode = ThemeMode.values.firstWhere(
        (value) => value.name == decoded['mode'],
        orElse: () => ThemeMode.system,
      );
    } on FormatException {
      // An optional preference never blocks startup.
    }
  }

  static const String storageKey = 'appearance.preferences';
  final KeyValueStore _store;
  Future<void> _pending = Future<void>.value();
  bool _disposed = false;
  UiStyle _style = UiStyle.classic;
  UiStyle get style => _style;

  /// Which [BackendFactory] built this session's services (About section).
  final String backendLabel;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  /// Save one record before publishing the change. A failed write leaves
  /// the visible theme unchanged; queued saves cannot overtake one another.
  Future<void> applyAppearance({
    required UiStyle style,
    required ThemeMode themeMode,
  }) {
    final operation = _pending.then((_) async {
      if (style == _style && themeMode == _themeMode) return;
      await _store.setString(
        storageKey,
        jsonEncode({'style': style.name, 'mode': themeMode.name}),
      );
      _style = style;
      _themeMode = themeMode;
      if (!_disposed) notifyListeners();
    });
    // Callers still receive errors; a failed save must not poison the queue.
    _pending = operation.catchError((Object error) {});
    return operation;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
