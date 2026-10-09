import 'package:flutter/material.dart';
import '../../i18n/l10n_extension.dart';

/// Shows [message] in a snack bar if the [context] is still mounted.
void showSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        // Large text on a small phone: at most half the screen, scrolling.
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height / 2,
          ),
          child: SingleChildScrollView(child: Text(message)),
        ),
      ),
    );
}

/// Standard yes/no confirmation. Returns true when [confirmLabel] was tapped.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (ctx) => ScrollingAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(ctx.s.actionCancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// An [AlertDialog] whose action buttons scroll with its title and content,
/// so a short window with the largest text still reaches every button (the
/// stock dialog keeps its action bar fixed and can leave no room for it).
class ScrollingAlertDialog extends StatelessWidget {
  const ScrollingAlertDialog({
    super.key,
    this.title,
    required this.content,
    required this.actions,
  });

  final Widget? title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: title,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        content,
        const SizedBox(height: 24),
        OverflowBar(
          alignment: MainAxisAlignment.end,
          spacing: 8,
          overflowAlignment: OverflowBarAlignment.end,
          overflowSpacing: 8,
          children: actions,
        ),
      ],
    ),
  );
}
