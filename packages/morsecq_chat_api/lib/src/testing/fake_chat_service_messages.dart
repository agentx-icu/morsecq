part of 'fake_chat_service.dart';

/// Search, deep jumps, retry and cancel for [FakeChatService]. A mixin in a
/// part file keeps the service under the 500-line gate while still
/// implementing the [ChatService] members; the abstract members below are
/// the service's own private state.
mixin _FakeMessageManagement implements ChatService {
  Map<String, List<ChatMessage>> get _messages;
  Map<String, Conversation> get _conversations;
  Map<String, Friend> get _friends;
  void _setStatus(String messageId, MessageStatus status);

  @override
  Future<MessageSearchPage> searchMessages(
    String conversationId,
    MessageSearchQuery query, {
    MessageSearchCursor? cursor,
    int limit = 20,
  }) async => MessageOrder.page(
    _messages[conversationId] ?? const <ChatMessage>[],
    query,
    cursor: cursor,
    limit: limit,
  );

  @override
  Future<List<ChatMessage>> loadAround(
    String conversationId,
    String messageId, {
    int before = 25,
    int after = 25,
  }) async => MessageOrder.around(
    _messages[conversationId] ?? const <ChatMessage>[],
    messageId,
    before: before,
    after: after,
  );

  @override
  bool get supportsSendControl => true;

  ChatMessage? _ownRow(String conversationId, String messageId) {
    for (final m in _messages[conversationId] ?? const <ChatMessage>[]) {
      if (m.id == messageId) return m;
    }
    return null;
  }

  @override
  Future<MessageActionResult> retryMessage(
    String conversationId,
    String messageId,
  ) async {
    final m = _ownRow(conversationId, messageId);
    if (m == null || !m.isMine || conversationId == selfConversationId) {
      return MessageActionResult.unavailable;
    }
    if (m.status == MessageStatus.cancelled) {
      return MessageActionResult.unavailable;
    }
    if (m.status != MessageStatus.failed) {
      return MessageActionResult.stateChanged;
    }
    final conversation = _conversations[conversationId];
    final deliverable =
        conversation?.kind == ConversationKind.group ||
        (_friends[conversation?.peerId]?.online ?? false);
    _setStatus(messageId, MessageStatus.pending);
    if (deliverable) _setStatus(messageId, MessageStatus.sent);
    return MessageActionResult.success;
  }

  @override
  Future<MessageActionResult> cancelPendingMessage(
    String conversationId,
    String messageId,
  ) async {
    final m = _ownRow(conversationId, messageId);
    if (m == null || !m.isMine || conversationId == selfConversationId) {
      return MessageActionResult.unavailable;
    }
    if (m.status != MessageStatus.pending) {
      return MessageActionResult.stateChanged;
    }
    _setStatus(messageId, MessageStatus.cancelled);
    return MessageActionResult.success;
  }
}
