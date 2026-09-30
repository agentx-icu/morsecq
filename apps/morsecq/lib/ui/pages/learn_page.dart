import 'package:flutter/material.dart';

import 'placeholder_page.dart';

/// Morse training: lessons, keying drills, copy practice.
class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  static const String title = 'Learn';
  static const String description =
      'Koch-method lessons, keying drills and copy practice.';

  @override
  Widget build(BuildContext context) => const PlaceholderPage(
    title: title,
    description: description,
    icon: Icons.school_outlined,
  );
}
