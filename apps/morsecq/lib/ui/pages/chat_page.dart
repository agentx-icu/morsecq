import 'package:flutter/material.dart';

import 'placeholder_page.dart';

/// One-to-one Morse conversations over Tox.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static const String title = 'Chat';
  static const String description =
      'Serverless one-to-one Morse conversations over Tox P2P.';

  @override
  Widget build(BuildContext context) => const PlaceholderPage(
    title: title,
    description: description,
    icon: Icons.chat_bubble_outline,
  );
}
