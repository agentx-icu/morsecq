import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../reference/reference.dart';

/// Shell destination hosting the Morse handbook. The translator is reached
/// from the handbook's app bar so both share one playback settings object,
/// which lives here for the lifetime of the shell.
class ReferencePage extends StatefulWidget {
  const ReferencePage({super.key});

  static const String title = 'Reference';
  static const String description =
      'Alphabet, prosigns, Q-codes, abbreviations and a two-way translator.';

  @override
  State<ReferencePage> createState() => _ReferencePageState();
}

class _ReferencePageState extends State<ReferencePage> {
  final ReferencePlaybackSettings _settings = ReferencePlaybackSettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReferencePlaybackSettings>.value(
      value: _settings,
      child: ReferenceScreen(settings: _settings),
    );
  }
}
