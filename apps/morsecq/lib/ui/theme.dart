import 'package:flutter/material.dart';

/// Telegraph-brass amber: the colour of a polished straight key.
const Color kMorsecqSeedColor = Color(0xFFB8860B);

/// App-wide Material 3 themes derived from [kMorsecqSeedColor].
abstract final class MorsecqTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kMorsecqSeedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
      ),
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: scheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
      ),
    );
  }
}
