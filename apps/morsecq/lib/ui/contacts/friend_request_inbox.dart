import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../../i18n/chat_error_messages.dart';
import '../../i18n/l10n_extension.dart';
import '../chat/chat_layout.dart';
import 'tox_id.dart';

/// Pending inbound friend requests with accept / reject. Renders nothing
/// when the inbox is empty and [showWhenEmpty] is false.
class FriendRequestInbox extends StatelessWidget {
  const FriendRequestInbox({
    super.key,
    required this.service,
    this.showWhenEmpty = false,
  });

  final ChatService service;
  final bool showWhenEmpty;

  Future<void> _run(BuildContext context, Future<void> Function() op) async {
    final S s = context.s;
    try {
      await op();
    } on Object catch (e) {
      if (context.mounted) showSnack(context, describeChatError(s, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final S s = context.s;
    return StreamBuilder<List<FriendRequest>>(
      stream: service.friendRequestChanges,
      initialData: service.friendRequests,
      builder: (context, snapshot) {
        final List<FriendRequest> requests =
            snapshot.data ?? const <FriendRequest>[];
        if (requests.isEmpty && !showWhenEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                s.chatFriendRequestsCount(requests.length),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            if (requests.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(s.chatNoRequests),
              ),
            for (final FriendRequest r in requests)
              ListTile(
                key: ValueKey<String>('req_${r.publicKey}'),
                leading: const CircleAvatar(child: Icon(Icons.person_add_alt)),
                title: Text(shortKey(r.publicKey, length: 16)),
                subtitle: Text(
                  r.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: s.chatReject,
                      icon: Icon(Icons.close, color: theme.colorScheme.error),
                      onPressed: () => unawaited(
                        _run(
                          context,
                          () => service.rejectFriendRequest(r.publicKey),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: s.chatAccept,
                      icon: const Icon(Icons.check),
                      onPressed: () => unawaited(
                        _run(
                          context,
                          () => service.acceptFriendRequest(r.publicKey),
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
