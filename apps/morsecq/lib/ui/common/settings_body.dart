import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key, required this.children, this.maxWidth = 640});
  final List<Widget> children;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}

Future<void> copyToClipboard(
  BuildContext context,
  String text, {
  required String confirmation,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  await Clipboard.setData(ClipboardData(text: text));
  messenger?.showSnackBar(SnackBar(content: Text(confirmation)));
}
