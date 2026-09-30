import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../i18n/l10n_extension.dart';
import '../../startup/startup_controller.dart';

/// Small status chip: visible while connecting or offline, gone once online.
/// Tapping an offline chip retries `connect()`.
class ConnectionChip extends StatelessWidget {
  const ConnectionChip({super.key, this.alwaysVisible = false});

  /// Show the chip even when online (Me page uses this).
  final bool alwaysVisible;

  @override
  Widget build(BuildContext context) {
    final identity = context.read<IdentityService>();
    return StreamBuilder<ConnectionStatus>(
      stream: identity.connectionChanges,
      initialData: identity.connectionStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectionStatus.offline;
        if (status == ConnectionStatus.online && !alwaysVisible) {
          return const SizedBox.shrink();
        }
        return _StatusChip(status: status);
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    // Shared `connection*` keys: the chat list uses the same words.
    final (label, color, icon) = switch (status) {
      ConnectionStatus.online => (
        s.connectionOnline,
        scheme.primary,
        Icons.cloud_done_outlined,
      ),
      ConnectionStatus.connecting => (
        s.connectionConnecting,
        scheme.tertiary,
        Icons.cloud_sync_outlined,
      ),
      ConnectionStatus.offline => (
        s.connectionOffline,
        scheme.error,
        Icons.cloud_off_outlined,
      ),
    };
    final offline = status == ConnectionStatus.offline;
    // The gate overlays this chip outside any Scaffold, so bring our own
    // Material ancestor; inside a card it is transparent and harmless.
    return Material(
      type: MaterialType.transparency,
      child: Tooltip(
        message: offline ? s.accountConnectionTapToReconnect : label,
        child: ActionChip(
          avatar: Icon(icon, size: 18, color: color),
          label: Text(label),
          labelStyle: TextStyle(color: color, fontSize: 12),
          visualDensity: VisualDensity.compact,
          onPressed: offline
              ? () => context.read<StartupController>().reconnect().ignore()
              : null,
        ),
      ),
    );
  }
}
