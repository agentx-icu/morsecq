import 'dart:async';
import 'dart:convert';

import '../chat_service.dart';
import '../models.dart';
import 'replay_stream.dart';

/// In-memory [ChatService] for widget tests and UI development without a
/// Tox node.
///
/// Behaviour mirrors the Tox transport where it matters to the UI:
/// * ids are deterministic (`msg_1`, `tox_1`, `inv_1`, ...);
/// * [sendText] to an **offline** friend returns [MessageStatus.pending] and
///   the row flips to `sent` (via [messageEvents]) when the friend comes
///   online through [setFriendOnline] — Tox has no server to store it;
/// * [addFriend] adds the friend immediately, offline, like `tox_friend_add`;
/// * a `c2c_<pk>` / `group_<id>` conversation that is not in
///   [conversations] yet is created on first send / draft, so the UI can open
///   a chat straight from the contact list.
///
/// Test hooks are the `receive*` / `set*` / `addFake*` methods at the bottom.
final class FakeChatService implements ChatService {
  FakeChatService({
    String? selfPublicKey,
    DateTime Function()? clock,
    this.maxMessageBytes = 1322,
  })  : selfPublicKey = selfPublicKey ?? 'F' * 64,
        _clock = clock ?? DateTime.now;

  /// Our own 64-hex public key; `addFriend(<own id>)` throws `own_id`.
  final String selfPublicKey;

  @override
  final int maxMessageBytes;

  final DateTime Function() _clock;
  int _seq = 0;

  final Map<String, Friend> _friends = <String, Friend>{};
  final List<FriendRequest> _friendRequests = <FriendRequest>[];
  final Map<String, Conversation> _conversations = <String, Conversation>{};
  final Map<String, List<ChatMessage>> _messages =
      <String, List<ChatMessage>>{};
  final Map<String, Group> _groups = <String, Group>{};
  final Map<String, List<GroupMember>> _members =
      <String, List<GroupMember>>{};
  final List<GroupInvite> _groupInvites = <GroupInvite>[];

  /// Tox IDs handed to [addFriend], oldest first (for assertions).
  final List<String> outgoingFriendRequests = <String>[];

  final ReplaySubject<List<Friend>> _friendChanges =
      ReplaySubject<List<Friend>>(const <Friend>[]);
  final ReplaySubject<List<FriendRequest>> _friendRequestChanges =
      ReplaySubject<List<FriendRequest>>(const <FriendRequest>[]);
  final ReplaySubject<List<Conversation>> _conversationChanges =
      ReplaySubject<List<Conversation>>(const <Conversation>[]);
  final ReplaySubject<List<Group>> _groupChanges =
      ReplaySubject<List<Group>>(const <Group>[]);
  final ReplaySubject<List<GroupInvite>> _groupInviteChanges =
      ReplaySubject<List<GroupInvite>>(const <GroupInvite>[]);
  final StreamController<ChatMessage> _messageEvents =
      StreamController<ChatMessage>.broadcast();

  bool _disposed = false;

  String _nextId(String prefix) => '${prefix}_${++_seq}';

  // ---- Friends -------------------------------------------------------------

  @override
  List<Friend> get friends => List<Friend>.unmodifiable(_friends.values);

  @override
  Stream<List<Friend>> get friendChanges => _friendChanges.stream;

  @override
  List<FriendRequest> get friendRequests =>
      List<FriendRequest>.unmodifiable(_friendRequests);

  @override
  Stream<List<FriendRequest>> get friendRequestChanges =>
      _friendRequestChanges.stream;

  @override
  Future<void> addFriend(String toxId, {String message = 'morsecq CQ'}) async {
    final String id = toxId.trim().toUpperCase();
    if (!isValidToxId(id)) {
      throw const ChatException(
        'invalid_tox_id',
        'Tox ID must be 76 hex chars',
      );
    }
    final String pk = id.substring(0, 64);
    if (pk == selfPublicKey.toUpperCase()) {
      throw const ChatException('own_id', 'That is your own Tox ID');
    }
    if (_friends.containsKey(pk)) {
      throw const ChatException('already_friend', 'Already a friend');
    }
    outgoingFriendRequests.add(id);
    _friends[pk] = Friend(publicKey: pk, displayName: _shortKey(pk));
    _publishFriends();
  }

  @override
  Future<void> acceptFriendRequest(String publicKey) async {
    final FriendRequest? request = _takeFriendRequest(publicKey);
    if (request == null) {
      throw const ChatException('request_not_found', 'No such friend request');
    }
    _friends[publicKey] = Friend(
      publicKey: publicKey,
      displayName: _shortKey(publicKey),
    );
    _publishFriends();
  }

  @override
  Future<void> rejectFriendRequest(String publicKey) async {
    if (_takeFriendRequest(publicKey) == null) {
      throw const ChatException('request_not_found', 'No such friend request');
    }
  }

  @override
  Future<void> removeFriend(String publicKey) async {
    if (_friends.remove(publicKey) == null) {
      throw const ChatException('friend_not_found', 'No such friend');
    }
    _publishFriends();
    await deleteConversation(c2cConversationId(publicKey));
  }

  FriendRequest? _takeFriendRequest(String publicKey) {
    final int index =
        _friendRequests.indexWhere((r) => r.publicKey == publicKey);
    if (index < 0) return null;
    final FriendRequest request = _friendRequests.removeAt(index);
    _friendRequestChanges.add(friendRequests);
    return request;
  }

  void _publishFriends() => _friendChanges.add(friends);

  // ---- Conversations -------------------------------------------------------

  @override
  List<Conversation> get conversations =>
      List<Conversation>.unmodifiable(_conversations.values);

  @override
  Stream<List<Conversation>> get conversationChanges =>
      _conversationChanges.stream;

  @override
  Future<void> markRead(String conversationId) async {
    _updateConversation(conversationId, (c) => _copy(c, unreadCount: 0));
  }

  @override
  Future<void> setPinned(String conversationId, bool pinned) async {
    _updateConversation(conversationId, (c) => _copy(c, pinned: pinned));
  }

  @override
  Future<void> setDraft(String conversationId, String draft) async {
    _updateConversation(conversationId, (c) => _copy(c, draft: draft));
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    _messages.remove(conversationId);
    if (_conversations.remove(conversationId) != null) {
      _publishConversations();
    }
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

  void _publishConversations() => _conversationChanges.add(conversations);

  // ---- Messages ------------------------------------------------------------

  @override
  Future<List<ChatMessage>> loadHistory(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    final List<ChatMessage> all =
        _messages[conversationId] ?? const <ChatMessage>[];
    final List<ChatMessage> eligible = before == null
        ? all
        : all.where((m) => m.timestamp.isBefore(before)).toList();
    final int start = eligible.length > limit ? eligible.length - limit : 0;
    return List<ChatMessage>.unmodifiable(eligible.sublist(start));
  }

  @override
  Stream<ChatMessage> get messageEvents => _messageEvents.stream;

  @override
  Future<ChatMessage> sendText(String conversationId, String text) async {
    if (utf8.encode(text).length > maxMessageBytes) {
      throw ChatException(
        'message_too_long',
        'Message exceeds $maxMessageBytes bytes',
      );
    }
    final Conversation? conversation =
        _conversations[conversationId] ?? _materialize(conversationId);
    if (conversation == null) {
      throw ChatException(
        'conversation_not_found',
        'No conversation $conversationId',
      );
    }
    final bool peerOnline = conversation.kind == ConversationKind.group ||
        (_friends[conversation.peerId]?.online ?? false);
    final ChatMessage message = ChatMessage(
      id: _nextId('msg'),
      conversationId: conversationId,
      senderId: selfPublicKey,
      text: text,
      timestamp: _clock(),
      status: peerOnline ? MessageStatus.sent : MessageStatus.pending,
      isMine: true,
    );
    _append(conversation, message, unreadDelta: 0);
    return message;
  }

  @override
  Future<void> clearHistory(String conversationId) async {
    _messages.remove(conversationId);
    final Conversation? existing = _conversations[conversationId];
    if (existing != null) {
      _conversations[conversationId] = Conversation(
        id: existing.id,
        kind: existing.kind,
        title: existing.title,
        pinned: existing.pinned,
        draft: existing.draft,
      );
      _publishConversations();
    }
  }

  void _append(
    Conversation conversation,
    ChatMessage message, {
    required int unreadDelta,
  }) {
    _messages.putIfAbsent(message.conversationId, () => <ChatMessage>[]);
    _messages[message.conversationId]!.add(message);
    _conversations[conversation.id] = _copy(
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
      final Conversation? conversation =
          _conversations[updated.conversationId];
      if (conversation != null && conversation.lastMessage?.id == messageId) {
        _conversations[conversation.id] =
            _copy(conversation, lastMessage: updated);
        _publishConversations();
      }
      _messageEvents.add(updated);
      return;
    }
  }

  // ---- Groups --------------------------------------------------------------

  @override
  List<Group> get groups => List<Group>.unmodifiable(_groups.values);

  @override
  Stream<List<Group>> get groupChanges => _groupChanges.stream;

  @override
  List<GroupInvite> get groupInvites =>
      List<GroupInvite>.unmodifiable(_groupInvites);

  @override
  Stream<List<GroupInvite>> get groupInviteChanges =>
      _groupInviteChanges.stream;

  @override
  Future<Group> createGroup(
    String name, {
    GroupKind kind = GroupKind.group,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ChatException('invalid_group_name', 'Group name is empty');
    }
    final String id = _nextId('tox');
    return _installGroup(Group(
      id: id,
      name: trimmed,
      kind: kind,
      chatId: kind == GroupKind.group ? fakeChatIdFor(id) : null,
      memberCount: 1,
    ));
  }

  @override
  Future<void> joinGroup(String chatId, {String? password}) async {
    final String id = chatId.trim().toUpperCase();
    if (!isValidChatId(id)) {
      throw const ChatException(
        'invalid_chat_id',
        'Chat id must be 64 hex chars',
      );
    }
    if (_groups.values.any((g) => g.chatId == id)) {
      throw const ChatException('already_member', 'Already in that group');
    }
    _installGroup(Group(
      id: _nextId('tox'),
      name: 'Group ${id.substring(0, 8)}',
      kind: GroupKind.group,
      chatId: id,
      memberCount: 1,
    ));
  }

  @override
  Future<void> inviteToGroup(String groupId, String friendPublicKey) async {
    _requireGroup(groupId);
    if (!_friends.containsKey(friendPublicKey)) {
      throw const ChatException('friend_not_found', 'No such friend');
    }
  }

  @override
  Future<void> acceptGroupInvite(String inviteId, {String? password}) async {
    final GroupInvite invite = _takeInvite(inviteId);
    final String id = _nextId('tox');
    _installGroup(Group(
      id: id,
      name: invite.groupName,
      kind: invite.kind,
      chatId: invite.kind == GroupKind.group ? fakeChatIdFor(id) : null,
      memberCount: 2,
    ));
  }

  @override
  Future<void> rejectGroupInvite(String inviteId) async {
    _takeInvite(inviteId);
  }

  @override
  Future<List<GroupMember>> groupMembers(String groupId) async {
    _requireGroup(groupId);
    return List<GroupMember>.unmodifiable(
      _members[groupId] ?? <GroupMember>[_selfMember()],
    );
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    _requireGroup(groupId);
    _groups.remove(groupId);
    _members.remove(groupId);
    _groupChanges.add(groups);
    await deleteConversation(groupConversationId(groupId));
  }

  GroupMember _selfMember() =>
      GroupMember(publicKey: selfPublicKey, displayName: 'Me', isSelf: true);

  Group _installGroup(Group group) {
    _groups[group.id] = group;
    _members[group.id] = <GroupMember>[_selfMember()];
    _groupChanges.add(groups);
    final String cid = groupConversationId(group.id);
    _conversations[cid] = Conversation(
      id: cid,
      kind: ConversationKind.group,
      title: group.name,
    );
    _publishConversations();
    return group;
  }

  Group _requireGroup(String groupId) {
    final Group? group = _groups[groupId];
    if (group == null) {
      throw ChatException('group_not_found', 'No group $groupId');
    }
    return group;
  }

  GroupInvite _takeInvite(String inviteId) {
    final int index = _groupInvites.indexWhere((i) => i.inviteId == inviteId);
    if (index < 0) {
      throw const ChatException('invite_not_found', 'No such group invite');
    }
    final GroupInvite invite = _groupInvites.removeAt(index);
    _groupInviteChanges.add(groupInvites);
    return invite;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await Future.wait(<Future<void>>[
      _friendChanges.close(),
      _friendRequestChanges.close(),
      _conversationChanges.close(),
      _groupChanges.close(),
      _groupInviteChanges.close(),
      _messageEvents.close(),
    ]);
  }

  // ---- Test hooks ----------------------------------------------------------

  /// Adds (or replaces) a friend without going through a request.
  void addFakeFriend(Friend friend) {
    _friends[friend.publicKey] = friend;
    _publishFriends();
    final Conversation? existing =
        _conversations[c2cConversationId(friend.publicKey)];
    if (existing != null && existing.title != friend.displayName) {
      _conversations[existing.id] = _copy(existing, title: friend.displayName);
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
        (_messages[c2cConversationId(publicKey)] ?? const <ChatMessage>[])
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
    _friendRequests.add(FriendRequest(
      publicKey: publicKey,
      message: message,
      receivedAt: _clock(),
    ));
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

  // ---- Helpers -------------------------------------------------------------

  static String c2cConversationId(String publicKey) => 'c2c_$publicKey';

  static String groupConversationId(String groupId) => 'group_$groupId';

  static final RegExp _hex76 = RegExp(r'^[0-9A-Fa-f]{76}$');
  static final RegExp _hex64 = RegExp(r'^[0-9A-Fa-f]{64}$');

  static bool isValidToxId(String value) => _hex76.hasMatch(value);

  static bool isValidChatId(String value) => _hex64.hasMatch(value);

  /// Deterministic 64-hex chat id for a fake NGC group.
  static String fakeChatIdFor(String groupId) {
    final String hex = groupId.codeUnits
        .map((c) => c.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
    return (hex * (64 ~/ hex.length + 1)).substring(0, 64);
  }

  static String _shortKey(String publicKey) =>
      publicKey.length > 8 ? publicKey.substring(0, 8) : publicKey;

  static Conversation _copy(
    Conversation c, {
    String? title,
    ChatMessage? lastMessage,
    int? unreadCount,
    bool? pinned,
    String? draft,
  }) =>
      Conversation(
        id: c.id,
        kind: c.kind,
        title: title ?? c.title,
        lastMessage: lastMessage ?? c.lastMessage,
        unreadCount: unreadCount ?? c.unreadCount,
        pinned: pinned ?? c.pinned,
        draft: draft ?? c.draft,
      );
}
