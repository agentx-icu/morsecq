import 'package:flutter/material.dart';

/// App-wide user preferences that are not tied to an identity. Training and
/// playback defaults belong to the learn UI; this only carries what the shell
/// itself needs.
class AppSettings extends ChangeNotifier {
  AppSettings({
    required this.backendLabel,
    ThemeMode themeMode = ThemeMode.system,
  }) : _themeMode = themeMode;

  /// Which [BackendFactory] built this session's services (About section).
  final String backendLabel;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    if (value == _themeMode) return;
    _themeMode = value;
    notifyListeners();
  }
}
