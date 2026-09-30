import 'package:flutter/material.dart';

import 'placeholder_page.dart';

/// Profile, account, progress and settings.
class MePage extends StatelessWidget {
  const MePage({super.key});

  static const String title = 'Me';
  static const String description =
      'Your callsign, Tox identity, progress and settings.';

  @override
  Widget build(BuildContext context) => const PlaceholderPage(
    title: title,
    description: description,
    icon: Icons.person_outline,
  );
}
