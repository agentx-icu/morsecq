import 'package:flutter/material.dart';

/// Keeps the current training action usable on short screens and at large
/// text sizes while the other content scrolls independently.
class LearnFooter extends StatelessWidget {
  const LearnFooter({super.key, required this.child});

  final Widget child;

  /// The scaffold's bottom bar sits behind the keyboard. On a very short
  /// screen, or when enlarged instructions fill a compact window, scroll the
  /// actions with the exercise.
  static bool belongsInBody(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final enlargedText = MediaQuery.textScalerOf(context).scale(16) > 32;
    return MediaQuery.viewInsetsOf(context).bottom > 0 ||
        height < 400 ||
        (height <= 640 && enlargedText);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
