part of 'tim2tox_chat_service.dart';

/// Derives the conversation list from Tim2Tox state (history ids, friends,
/// groups, unread counters, last messages) plus our own metadata (pinned,
/// drafts, hidden). Rebuilt on every tick and after every mutation; only
/// published when something changed.
class _ConversationsPart {
  _ConversationsPart(this._owner);

  final Tim2ToxChatService _owner;

  final ValueStream<List<Conversation>> conversations = ValueStream(const []);

  void reset() => conversations.add(const []);

  void rebuild(FfiChatService svc) {
    final meta = _owner._meta;
    final hidden = meta.hidden;
    final pinned = meta.pinned;
    final quit = svc.quitGroups;
    final groupIds = svc.knownGroups;
    final friendById = {for (final f in _owner._friendsPart.friends.value) f.publicKey: f};
    final groupById = {for (final g in _owner._groupsPart.groups.value) g.id: g};

    final ids = <String>{
      for (final id in svc.getConversationIds())
        if (groupIds.contains(id)) ConversationIds.group(id) else if (!quit.contains(id)) ConversationIds.c2c(id),
      for (final f in friendById.keys) ConversationIds.c2c(f),
      for (final g in groupIds) ConversationIds.group(g),
    }..removeAll(hidden);

    final mapper = _owner._mapper;
    final next = <Conversation>[];
    for (final id in ids) {
      final peer = ConversationIds.peerOf(id);
      final isGroup = ConversationIds.isGroup(id);
      if (!isGroup && !ConversationIds.publicKey.hasMatch(peer)) {
        continue; // foreign history key (e.g. an IRC channel), not a peer
      }
      final last = _lastMessage(svc, peer);
      final title = isGroup
          ? (groupById[peer]?.name ?? svc.sharedGroupName(peer) ?? peer)
          : (friendById[peer]?.displayName ??
              _owner._friendsPart.nameOf(peer) ??
              ConversationIds.shortKey(peer));
      next.add(Conversation(
        id: id,
        kind: isGroup ? ConversationKind.group : ConversationKind.c2c,
        title: title,
        lastMessage: last == null ? null : mapper.map(last, conversationId: id),
        unreadCount: svc.getUnreadOf(peer),
        pinned: pinned.contains(id),
        draft: meta.draft(id),
      ));
    }
    next.sort(_compare);
    if (!listEqualsBy(conversations.value, next, _same)) conversations.force(next);
  }

  static t2t.ChatMessage? _lastMessage(FfiChatService svc, String peer) {
    final cached = svc.lastMessages[peer];
    if (cached != null) return cached;
    final history = svc.getHistory(peer);
    if (history.isEmpty) return null;
    t2t.ChatMessage newest = history.first;
    for (final m in history) {
      if (!m.timestamp.isBefore(newest.timestamp)) newest = m;
    }
    return newest;
  }

  static int _compare(Conversation a, Conversation b) {
    if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
    final ta = a.lastMessage?.timestamp;
    final tb = b.lastMessage?.timestamp;
    if (ta != null && tb != null && ta != tb) return tb.compareTo(ta);
    if (ta == null && tb != null) return 1;
    if (ta != null && tb == null) return -1;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  static bool _same(Conversation a, Conversation b) =>
      a.id == b.id &&
      a.title == b.title &&
      a.unreadCount == b.unreadCount &&
      a.pinned == b.pinned &&
      a.draft == b.draft &&
      a.lastMessage?.id == b.lastMessage?.id &&
      a.lastMessage?.status == b.lastMessage?.status &&
      a.lastMessage?.text == b.lastMessage?.text;

  Future<void> markRead(FfiChatService svc, String conversationId) async {
    await svc.markConversationRead(ConversationIds.peerOf(conversationId));
    rebuild(svc);
  }

  Future<void> setPinned(String conversationId, bool pinned) async {
    await _owner._meta.setPinned(conversationId, pinned);
    final svc = _owner._service;
    if (svc != null) rebuild(svc);
  }

  Future<void> setDraft(String conversationId, String draft) async {
    await _owner._meta.setDraft(conversationId, draft);
    final svc = _owner._service;
    if (svc != null) rebuild(svc);
  }

  /// Clears the history and hides the conversation until the next message
  /// (a friend or group stays; deleting the relationship is a separate call).
  Future<void> delete(FfiChatService svc, String conversationId) async {
    final peer = ConversationIds.peerOf(conversationId);
    if (ConversationIds.isGroup(conversationId)) {
      await svc.clearGroupHistory(peer);
    } else {
      await svc.clearC2CHistory(peer);
    }
    await _owner._meta.setPinned(conversationId, false);
    await _owner._meta.setDraft(conversationId, '');
    await _owner._meta.hide(conversationId);
    rebuild(svc);
  }

  Future<void> close() => conversations.close();
}
