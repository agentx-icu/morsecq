import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'chat_strings.dart';

/// Delivery glyph for our own messages. Pending gets a tooltip explaining
/// that Tox has no server: nothing is lost, it waits for the peer.
class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon(this.status, {super.key, this.size = 14});

  final MessageStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final (IconData icon, Color color, String tip) = switch (status) {
      MessageStatus.pending => (
        Icons.schedule,
        scheme.onSurfaceVariant,
        '${ChatStrings.statusPending}\n${ChatStrings.statusPendingDetail}',
      ),
      MessageStatus.sending => (
        Icons.more_horiz,
        scheme.onSurfaceVariant,
        ChatStrings.statusSending,
      ),
      MessageStatus.sent => (
        Icons.check,
        scheme.primary,
        ChatStrings.statusSent,
      ),
      MessageStatus.failed => (
        Icons.error_outline,
        scheme.error,
        ChatStrings.statusFailed,
      ),
      MessageStatus.received => (Icons.check, Colors.transparent, ''),
    };
    if (status == MessageStatus.received) return const SizedBox.shrink();
    return Tooltip(
      message: tip,
      child: Icon(icon, size: size, color: color, semanticLabel: tip),
    );
  }
}
