import 'dart:async';
import 'dart:convert';

import '../chat_service.dart';
import '../models.dart';
import 'replay_stream.dart';

part 'fake_chat_service_hooks.dart';

/// In-memory [ChatService] for widget tests and UI development without a
/// Tox node. Mirrors the Tox transport where the UI can tell: deterministic
/// ids (`msg_1`, `tox_1`, `inv_1`); [sendText] to an offline friend is
/// [MessageStatus.pending] until `setFriendOnline` flips it to `sent` (Tox has
/// no server); [addFriend] adds the friend immediately, offline, like
/// `tox_friend_add`; a `c2c_<pk>` / `group_<id>` conversation not yet in
/// [conversations] is created on first send / draft. Test hooks live in the
/// [FakeChatServiceTestHooks] extension (`fake_chat_service_hooks.dart`).
final class FakeChatService implements ChatService {
  FakeChatService({
    String? selfPublicKey,
    DateTime Function()? clock,
    this.maxMessageBytes = 1322,
  }) : selfPublicKey = selfPublicKey ?? 'F' * 64,
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
  final Map<String, List<GroupMember>> _members = <String, List<GroupMember>>{};
  final List<GroupInvite> _groupInvites = <GroupInvite>[];

  /// Tox IDs handed to [addFriend], oldest first (for assertions).
  final List<String> outgoingFriendRequests = <String>[];

  final ReplaySubject<List<Friend>> _friendChanges =
      ReplaySubject<List<Friend>>(const <Friend>[]);
  final ReplaySubject<List<FriendRequest>> _friendRequestChanges =
      ReplaySubject<List<FriendRequest>>(const <FriendRequest>[]);
  final ReplaySubject<List<Conversation>> _conversationChanges =
      ReplaySubject<List<Conversation>>(const <Conversation>[]);
  final ReplaySubject<List<Group>> _groupChanges = ReplaySubject<List<Group>>(
    const <Group>[],
  );
  final ReplaySubject<List<GroupInvite>> _groupInviteChanges =
      ReplaySubject<List<GroupInvite>>(const <GroupInvite>[]);
  final StreamController<ChatMessage> _messageEvents =
      StreamController<ChatMessage>.broadcast();

  bool _disposed = false;

  List<ReplaySubject<Object>> get _subjects => <ReplaySubject<Object>>[
    _friendChanges,
    _friendRequestChanges,
    _conversationChanges,
    _groupChanges,
    _groupInviteChanges,
  ];

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
    final int index = _friendRequests.indexWhere(
      (r) => r.publicKey == publicKey,
    );
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
    _updateConversation(
      conversationId,
      (c) => _copyConversation(c, unreadCount: 0),
    );
  }

  @override
  Future<void> setPinned(String conversationId, bool pinned) async {
    _updateConversation(
      conversationId,
      (c) => _copyConversation(c, pinned: pinned),
    );
  }

  @override
  Future<void> setDraft(String conversationId, String draft) async {
    _updateConversation(
      conversationId,
      (c) => _copyConversation(c, draft: draft),
    );
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
    final bool peerOnline =
        conversation.kind == ConversationKind.group ||
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
    return _installGroup(
      Group(
        id: id,
        name: trimmed,
        kind: kind,
        chatId: kind == GroupKind.group ? fakeChatIdFor(id) : null,
        memberCount: 1,
      ),
    );
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
    _installGroup(
      Group(
        id: _nextId('tox'),
        name: 'Group ${id.substring(0, 8)}',
        kind: GroupKind.group,
        chatId: id,
        memberCount: 1,
      ),
    );
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
    _installGroup(
      Group(
        id: id,
        name: invite.groupName,
        kind: invite.kind,
        chatId: invite.kind == GroupKind.group ? fakeChatIdFor(id) : null,
        memberCount: 2,
      ),
    );
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
      for (final ReplaySubject<Object> s in _subjects) s.close(),
      _messageEvents.close(),
    ]);
  }

  static String c2cConversationId(String publicKey) => 'c2c_$publicKey';

  static String groupConversationId(String groupId) => 'group_$groupId';

  static bool isValidToxId(String value) =>
      RegExp(r'^[0-9A-Fa-f]{76}$').hasMatch(value);

  static bool isValidChatId(String value) =>
      RegExp(r'^[0-9A-Fa-f]{64}$').hasMatch(value);

  /// Deterministic 64-hex chat id for a fake NGC group.
  static String fakeChatIdFor(String groupId) => _fakeChatIdFor(groupId);
}
