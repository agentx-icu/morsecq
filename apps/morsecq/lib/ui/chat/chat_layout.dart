import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'chat_strings.dart';

/// At or above this width the chat and groups pages show the list and the
/// open conversation side by side; below it the conversation is pushed as a
/// route. Wider than the shell's 600 rail breakpoint on purpose: a 7" tablet
/// in portrait gets the rail but not two panes.
const double kMasterDetailMinWidth = 900;

bool isMasterDetailWidth(double width) => width >= kMasterDetailMinWidth;

bool isMasterDetail(BuildContext context) =>
    isMasterDetailWidth(MediaQuery.sizeOf(context).width);

/// Width of the list pane in master-detail mode.
const double kMasterPaneWidth = 360;

/// Touch-first platforms get swipe actions and QR scanning; desktop gets
/// right-click menus and a "needs a camera" hint instead.
bool get isTouchPlatform =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Two-pane layout: [master] on the left at a fixed width, [detail] filling
/// the rest (or a neutral prompt when nothing is selected).
class MasterDetail extends StatelessWidget {
  const MasterDetail({
    super.key,
    required this.master,
    required this.detail,
    this.emptyDetailText = ChatStrings.selectConversation,
  });

  final Widget master;
  final Widget? detail;
  final String emptyDetailText;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(width: kMasterPaneWidth, child: master),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child:
              detail ??
              Center(
                child: Text(
                  emptyDetailText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
        ),
      ],
    );
  }
}

/// Shows [message] in a snack bar if the [context] is still mounted.
void showSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
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
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text(ChatStrings.cancel),
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

/// `HH:mm` for today, `MM-dd` otherwise, `yyyy-MM-dd` for other years.
String formatMessageTime(DateTime time, {DateTime? now}) {
  final DateTime local = time.toLocal();
  final DateTime today = (now ?? DateTime.now()).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  if (local.year == today.year &&
      local.month == today.month &&
      local.day == today.day) {
    return '${two(local.hour)}:${two(local.minute)}';
  }
  if (local.year == today.year) {
    return '${two(local.month)}-${two(local.day)}';
  }
  return '${local.year}-${two(local.month)}-${two(local.day)}';
}
