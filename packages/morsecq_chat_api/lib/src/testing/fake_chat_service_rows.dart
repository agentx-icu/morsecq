part of 'fake_chat_service.dart';

/// Row bookkeeping shared by the service and its test hooks: which
/// conversations are listed, and how a message or status change updates
/// them.
extension _FakeConversationRows on FakeChatService {
  /// Every row, plus one for each friend that has none yet (the backend
  /// lists all friends), minus deleted ones until their next message (a
  /// draft or pin does not bring one back). Empty without a session, like
  /// the backend's lists.
  List<Conversation> _listedConversations() {
    if (!_sessionUp) return const <Conversation>[];
    final Map<String, Conversation> rows = <String, Conversation>{
      for (final MapEntry<String, Conversation> e in _conversations.entries)
        if (!_hidden.contains(e.key)) e.key: e.value,
    };
    for (final Friend friend in _friends.values) {
      final String id = FakeChatService.c2cConversationId(friend.publicKey);
      if (rows.containsKey(id) || _hidden.contains(id)) continue;
      rows[id] = Conversation(
        id: id,
        kind: ConversationKind.c2c,
        title: friend.displayName,
      );
    }
    return List<Conversation>.unmodifiable(rows.values);
  }

  void _updateConversation(
    String id,
    Conversation Function(Conversation) change,
  ) {
    final Conversation? existing = _conversations[id] ?? _materialize(id);
    if (existing == null) {
      throw ChatException('conversation_not_found', 'No conversation $id');
    }
    _conversations[id] = change(existing);
    _publishConversations();
  }

  /// Builds the conversation row for a known friend / group that has no row
  /// yet (first message, first draft). Returns null for unknown peers.
  Conversation? _materialize(String id) {
    final String peer = id.substring(id.indexOf('_') + 1);
    if (_isSelfConversation(id)) return _selfConversation();
    if (id.startsWith('c2c_')) {
      final Friend? friend = _friends[peer];
      if (friend == null) return null;
      return Conversation(
        id: id,
        kind: ConversationKind.c2c,
        title: friend.displayName,
      );
    }
    if (id.startsWith('group_')) {
      final Group? group = _groups[peer];
      if (group == null) return null;
      return Conversation(
        id: id,
        kind: ConversationKind.group,
        title: group.name,
      );
    }
    return null;
  }

  void _append(
    Conversation conversation,
    ChatMessage message, {
    required int unreadDelta,
  }) {
    _hidden.remove(message.conversationId);
    _messages.putIfAbsent(message.conversationId, () => <ChatMessage>[]);
    _messages[message.conversationId]!.add(message);
    _conversations[conversation.id] = _copyConversation(
      conversation,
      lastMessage: message,
      unreadCount: conversation.unreadCount + unreadDelta,
    );
    _publishConversations();
    _messageEvents.add(message);
  }

  void _setStatus(String messageId, MessageStatus status) {
    for (final List<ChatMessage> list in _messages.values) {
      final int index = list.indexWhere((m) => m.id == messageId);
      if (index < 0) continue;
      final ChatMessage updated = list[index].copyWith(status: status);
      list[index] = updated;
      final Conversation? conversation = _conversations[updated.conversationId];
      if (conversation != null && conversation.lastMessage?.id == messageId) {
        _conversations[conversation.id] = _copyConversation(
          conversation,
          lastMessage: updated,
        );
        _publishConversations();
      }
      _messageEvents.add(updated);
      return;
    }
  }
}
