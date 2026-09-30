import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../startup/startup_controller.dart';
import 'account_strings.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final (label, color, icon) = switch (status) {
      ConnectionStatus.online => (
        AccountStrings.connectionOnline,
        scheme.primary,
        Icons.cloud_done_outlined,
      ),
      ConnectionStatus.connecting => (
        AccountStrings.connectionConnecting,
        scheme.tertiary,
        Icons.cloud_sync_outlined,
      ),
      ConnectionStatus.offline => (
        AccountStrings.connectionOffline,
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
        message: offline ? AccountStrings.connectionTapToReconnect : label,
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
