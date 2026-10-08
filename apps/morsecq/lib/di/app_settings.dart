import 'dart:convert';

import 'package:flutter/material.dart';

import '../i18n/key_value_store.dart';
import '../ui/appearance/ui_style.dart';

/// App-wide user preferences that are stored on this device. Training and
/// playback defaults belong to the learn UI; this only carries what the shell
/// itself needs.
class AppSettings extends ChangeNotifier {
  AppSettings({KeyValueStore? store})
    : _store = store ?? InMemoryKeyValueStore() {
    // Preserve the theme used before style and mode shared one record.
    _themeMode = ThemeMode.values.firstWhere(
      (value) => value.name == _store.getString('app.theme'),
      orElse: () => ThemeMode.system,
    );
    final saved = _store.getString(storageKey);
    if (saved == null) return;
    try {
      final decoded = jsonDecode(saved);
      if (decoded is! Map<String, dynamic>) return;
      _style = UiStyle.values.firstWhere(
        (value) => value.name == decoded['style'],
        orElse: () => kDefaultUiStyle,
      );
      _themeMode = ThemeMode.values.firstWhere(
        (value) => value.name == decoded['mode'],
        orElse: () => _themeMode,
      );
    } on FormatException {
      // An optional preference never blocks startup.
    }
  }

  static const String storageKey = 'appearance.preferences';

  final KeyValueStore _store;
  Future<void> _pending = Future<void>.value();
  bool _disposed = false;
  UiStyle _style = kDefaultUiStyle;
  UiStyle get style => _style;

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

  /// Background and quit barriers wait for all accepted appearance requests.
  /// Failed requests already leave the visible and stored appearance unchanged
  /// and are reported through [applyAppearance] to the caller.
  Future<void> flush() async {
    Future<void> pending;
    do {
      pending = _pending;
      await pending;
    } while (!identical(pending, _pending));
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
