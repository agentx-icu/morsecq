import 'package:flutter/material.dart';

import 'placeholder_page.dart';

/// Group nets: many operators on one shared Morse channel.
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  static const String title = 'Groups';
  static const String description =
      'Group nets — many operators keying on one shared channel.';

  @override
  Widget build(BuildContext context) => const PlaceholderPage(
    title: title,
    description: description,
    icon: Icons.groups_outlined,
  );
}
