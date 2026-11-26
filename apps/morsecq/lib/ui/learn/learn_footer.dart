import 'package:flutter/material.dart';

/// Keeps the current training action usable on short screens and at large
/// text sizes while the other content scrolls independently.
class LearnFooter extends StatelessWidget {
  const LearnFooter({super.key, required this.child});

  final Widget child;

  /// The scaffold's bottom bar sits behind the keyboard. On a very short
  /// screen, an oversized bottom bar can also crowd out the exercise.
  static bool belongsInBody(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom > 0 ||
      MediaQuery.sizeOf(context).height < 400;

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
