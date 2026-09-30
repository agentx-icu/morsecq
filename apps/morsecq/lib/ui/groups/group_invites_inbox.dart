import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../chat/chat_layout.dart';
import '../chat/chat_scope.dart';
import '../chat/chat_strings.dart';
import '../contacts/tox_id.dart';

/// Pending group invites with accept / reject; hidden when empty.
class GroupInvitesInbox extends StatelessWidget {
  const GroupInvitesInbox({super.key, required this.service});

  final ChatService service;

  Future<void> _run(BuildContext context, Future<void> Function() op) async {
    try {
      await op();
    } on Object catch (e) {
      if (context.mounted) showSnack(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return StreamBuilder<List<GroupInvite>>(
      stream: service.groupInviteChanges,
      initialData: service.groupInvites,
      builder: (context, snapshot) {
        final List<GroupInvite> invites =
            snapshot.data ?? const <GroupInvite>[];
        if (invites.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '${ChatStrings.groupInvites} (${invites.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            for (final GroupInvite i in invites)
              ListTile(
                key: ValueKey<String>('invite_${i.inviteId}'),
                leading: const CircleAvatar(child: Icon(Icons.group_add)),
                title: Text(i.groupName),
                subtitle: Text(
                  '${ChatStrings.invitedBy} ${shortKey(i.fromPublicKey, length: 12)}'
                  '${i.kind == GroupKind.conference ? ' · ${ChatStrings.conferenceBadge}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: ChatStrings.reject,
                      icon: Icon(Icons.close, color: theme.colorScheme.error),
                      onPressed: () => unawaited(
                        _run(
                          context,
                          () => service.rejectGroupInvite(i.inviteId),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: ChatStrings.accept,
                      icon: const Icon(Icons.check),
                      onPressed: () => unawaited(
                        _run(
                          context,
                          () => service.acceptGroupInvite(i.inviteId),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
          ],
        );
      },
    );
  }
}
