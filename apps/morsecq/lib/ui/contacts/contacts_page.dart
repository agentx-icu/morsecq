import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../chat/chat_layout.dart';
import '../chat/chat_scope.dart';
import '../chat/chat_strings.dart';
import '../chat/conversation_target.dart';
import 'add_friend_sheet.dart';
import 'friend_request_inbox.dart';
import 'my_tox_id_sheet.dart';

/// Friends (with online dots), the request inbox, "add friend" and "my Tox
/// ID". Tapping a friend hands a [ConversationTarget] to [onOpenConversation]
/// so the chat page decides between push and master-detail selection.
class ContactsPage extends StatelessWidget {
  const ContactsPage({
    super.key,
    required this.service,
    required this.identity,
    required this.onOpenConversation,
    this.canScan,
  });

  final ChatService service;
  final IdentityService? identity;
  final ValueChanged<ConversationTarget> onOpenConversation;

  /// Test override for the QR-scan affordance; defaults to the platform.
  final bool? canScan;

  static Future<void> open(
    BuildContext context, {
    required ChatService service,
    required IdentityService? identity,
    required ValueChanged<ConversationTarget> onOpenConversation,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ContactsPage(
        service: service,
        identity: identity,
        onOpenConversation: onOpenConversation,
      ),
    ),
  );

  Future<void> _addFriend(BuildContext context) async {
    final bool sent = await showAddFriendSheet(
      context,
      service: service,
      ownToxId: identity?.current?.toxId,
      canScan: canScan,
    );
    if (sent && context.mounted) showSnack(context, ChatStrings.requestSent);
  }

  Future<void> _removeFriend(BuildContext context, Friend f) async {
    final bool ok = await confirm(
      context,
      title: ChatStrings.removeFriendTitle,
      body: ChatStrings.removeFriendBody,
      confirmLabel: ChatStrings.remove,
    );
    if (!ok) return;
    try {
      await service.removeFriend(f.publicKey);
    } on Object catch (e) {
      if (context.mounted) showSnack(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ChatStrings.contacts),
        actions: [
          IconButton(
            tooltip: ChatStrings.myToxId,
            icon: const Icon(Icons.qr_code_2),
            onPressed: () =>
                unawaited(showMyToxIdSheet(context, identity?.current)),
          ),
          IconButton(
            tooltip: ChatStrings.addFriend,
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => unawaited(_addFriend(context)),
          ),
        ],
      ),
      body: StreamBuilder<List<Friend>>(
        stream: service.friendChanges,
        initialData: service.friends,
        builder: (context, snapshot) {
          final List<Friend> friends =
              List<Friend>.of(snapshot.data ?? const <Friend>[])..sort((a, b) {
                if (a.online != b.online) return a.online ? -1 : 1;
                return a.displayName.toLowerCase().compareTo(
                  b.displayName.toLowerCase(),
                );
              });
          return ListView(
            children: [
              FriendRequestInbox(service: service),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  '${ChatStrings.friends} (${friends.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (friends.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    ChatStrings.noFriends,
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final Friend f in friends)
                _FriendTile(
                  key: ValueKey<String>('friend_${f.publicKey}'),
                  friend: f,
                  onTap: () =>
                      onOpenConversation(ConversationTarget.fromFriend(f)),
                  onRemove: () => unawaited(_removeFriend(context, f)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    super.key,
    required this.friend,
    required this.onTap,
    required this.onRemove,
  });

  final Friend friend;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Text(
              friend.displayName.isEmpty
                  ? '?'
                  : friend.displayName.substring(0, 1).toUpperCase(),
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: friend.online ? Colors.green : scheme.outlineVariant,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(friend.displayName),
      subtitle: Text(
        friend.statusMessage.isNotEmpty
            ? friend.statusMessage
            : (friend.online ? ChatStrings.online : ChatStrings.offline),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (_) => onRemove(),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'remove', child: Text(ChatStrings.removeFriend)),
        ],
      ),
    );
  }
}
