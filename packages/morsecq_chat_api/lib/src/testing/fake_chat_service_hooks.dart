part of 'fake_chat_service.dart';

/// Test-only hooks that drive the fake from the outside: inbound messages,
/// friend requests, group invites, online toggles. Kept as an extension in
/// a part file so the service itself stays under the 500-line gate; being
/// part of the same library it may touch the private state directly.
extension FakeChatServiceTestHooks on FakeChatService {
  /// Adds (or replaces) a friend without going through a request.
  void addFakeFriend(Friend friend) {
    _friends[friend.publicKey] = friend;
    _publishFriends();
    final Conversation? existing =
        _conversations[FakeChatService.c2cConversationId(friend.publicKey)];
    if (existing != null && existing.title != friend.displayName) {
      _conversations[existing.id] = _copyConversation(
        existing,
        title: friend.displayName,
      );
      _publishConversations();
    }
  }

  /// Toggles a friend's connection; coming online flushes pending messages
  /// to `sent`, exactly what the Tox transport does.
  void setFriendOnline(String publicKey, bool online) {
    final Friend? friend = _friends[publicKey];
    if (friend == null) return;
    _friends[publicKey] = friend.copyWith(online: online);
    _publishFriends();
    if (!online) return;
    final List<ChatMessage> pending =
        (_messages[FakeChatService.c2cConversationId(publicKey)] ??
                const <ChatMessage>[])
            .where((m) => m.isMine && m.status == MessageStatus.pending)
            .toList();
    for (final ChatMessage m in pending) {
      _setStatus(m.id, MessageStatus.sent);
    }
  }

  /// Marks one of our messages as failed (emits a status event).
  void failMessage(String messageId) =>
      _setStatus(messageId, MessageStatus.failed);

  /// Delivers an inbound message; bumps the conversation's unread count.
  ChatMessage receiveMessage(
    String conversationId,
    String text, {
    String? senderId,
    String? senderName,
    DateTime? timestamp,
  }) {
    final Conversation? conversation =
        _conversations[conversationId] ?? _materialize(conversationId);
    if (conversation == null) {
      throw ChatException(
        'conversation_not_found',
        'No conversation $conversationId',
      );
    }
    final String sender = senderId ?? conversation.peerId;
    final ChatMessage message = ChatMessage(
      id: _nextId('msg'),
      conversationId: conversationId,
      senderId: sender,
      senderName: senderName ?? _friends[sender]?.displayName,
      text: text,
      timestamp: timestamp ?? _clock(),
      status: MessageStatus.received,
      isMine: false,
    );
    _append(conversation, message, unreadDelta: 1);
    return message;
  }

  void receiveFriendRequest(String publicKey, {String message = 'CQ CQ'}) {
    _friendRequests.add(
      FriendRequest(
        publicKey: publicKey,
        message: message,
        receivedAt: _clock(),
      ),
    );
    _friendRequestChanges.add(friendRequests);
  }

  GroupInvite receiveGroupInvite({
    required String fromPublicKey,
    required String groupName,
    GroupKind kind = GroupKind.group,
  }) {
    final GroupInvite invite = GroupInvite(
      inviteId: _nextId('inv'),
      fromPublicKey: fromPublicKey,
      groupName: groupName,
      kind: kind,
    );
    _groupInvites.add(invite);
    _groupInviteChanges.add(groupInvites);
    return invite;
  }

  /// Installs a group (and its conversation) as if we were already a member.
  Group addFakeGroup(Group group, {List<GroupMember>? members}) {
    _installGroup(group);
    if (members != null) {
      _members[group.id] = List<GroupMember>.of(members);
      _groups[group.id] = Group(
        id: group.id,
        name: group.name,
        kind: group.kind,
        chatId: group.chatId,
        memberCount: members.length,
        topic: group.topic,
      );
      _groupChanges.add(groups);
    }
    return _groups[group.id]!;
  }
}

String _shortKey(String publicKey) =>
    publicKey.length > 8 ? publicKey.substring(0, 8) : publicKey;

Conversation _copyConversation(
  Conversation c, {
  String? title,
  ChatMessage? lastMessage,
  int? unreadCount,
  bool? pinned,
  String? draft,
}) => Conversation(
  id: c.id,
  kind: c.kind,
  title: title ?? c.title,
  lastMessage: lastMessage ?? c.lastMessage,
  unreadCount: unreadCount ?? c.unreadCount,
  pinned: pinned ?? c.pinned,
  draft: draft ?? c.draft,
);

String _fakeChatIdFor(String groupId) {
  final String hex = groupId.codeUnits
      .map((c) => c.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
  return (hex * (64 ~/ hex.length + 1)).substring(0, 64);
}
