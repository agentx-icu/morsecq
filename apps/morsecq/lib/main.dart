import 'package:flutter/material.dart';

import 'ui/shell/app_shell.dart';
import 'ui/theme.dart';

void main() {
  runApp(const MorsecqApp());
}

/// Root widget: Material 3, light/dark following the system setting, and the
/// responsive [AppShell] as home.
class MorsecqApp extends StatelessWidget {
  const MorsecqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'morsecq',
      debugShowCheckedModeBanner: false,
      theme: MorsecqTheme.light(),
      darkTheme: MorsecqTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
