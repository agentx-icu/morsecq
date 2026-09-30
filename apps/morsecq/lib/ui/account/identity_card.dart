import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'account_strings.dart';
import 'account_widgets.dart';
import 'connection_chip.dart';
import 'tox_id_qr_dialog.dart';

/// Header card on the Me page: avatar initial, name, status message,
/// connection chip, and the Tox ID with copy + QR actions.
class IdentityCard extends StatelessWidget {
  const IdentityCard({super.key, required this.identity});

  final Identity identity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = identity.displayName.isEmpty
        ? '?'
        : identity.displayName.characters.first.toUpperCase();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Text(initial, style: theme.textTheme.headlineSmall),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        identity.displayName,
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (identity.statusMessage.isNotEmpty)
                        Text(
                          identity.statusMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const ConnectionChip(alwaysVisible: true),
                          if (identity.hasPassword) ...[
                            const SizedBox(width: 6),
                            Tooltip(
                              message: AccountStrings.password,
                              child: Icon(
                                Icons.lock_outline,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AccountStrings.toxId,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    groupToxId(identity.toxId),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: AccountStrings.copy,
                  icon: const Icon(Icons.copy),
                  onPressed: () => copyToClipboard(context, identity.toxId),
                ),
                IconButton(
                  tooltip: AccountStrings.showQr,
                  icon: const Icon(Icons.qr_code_2),
                  onPressed: () => showToxIdQrDialog(context, identity.toxId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
