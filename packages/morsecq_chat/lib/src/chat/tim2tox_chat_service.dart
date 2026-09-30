import 'dart:async';
import 'dart:convert';

import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:tim2tox_dart/models/chat_message.dart' as t2t;
import 'package:tim2tox_dart/service/ffi_chat_service.dart';

import '../adapters/key_value_store.dart';
import '../adapters/prefs_adapter.dart';
import '../engine/chat_engine.dart';
import '../logging/chat_logger.dart';
import '../util/value_stream.dart';
import 'conversation_meta_store.dart';
import 'group_bindings.dart';
import 'message_mapper.dart';

part 'chat_service_conversations.dart';
part 'chat_service_friends.dart';
part 'chat_service_groups.dart';

/// [ChatService] over one live `FfiChatService` (Tim2Tox), following the
/// [ChatEngine]'s session: bound while the identity is connected, detached
/// while it is not.
///
/// Data model: Tim2Tox owns friends, requests, history, the offline queue and
/// group membership; this class owns conversation metadata (pinned, drafts,
/// hidden) and the derivation of the conversation list from all of it.
///
/// Before `IdentityService.connect()` (and after `disconnect()`) every getter
/// and stream works (lists are empty, streams replay), and every mutation
/// throws [ChatException] `not_connected`. Once connected, a send to a friend
/// who is offline on the Tox network is queued by Tim2Tox and surfaces as a
/// `pending` row; it drains when the friend comes back.
class Tim2ToxChatService implements ChatService {
  Tim2ToxChatService({
    required ChatEngine engine,
    required IdentityService identity,
    required KeyValueStore store,
    ChatLogger logger = const SilentChatLogger(),
    Duration pollInterval = const Duration(seconds: 3),
  })  : _engine = engine,
        _identity = identity,
        _store = store,
        _logger = logger,
        _pollInterval = pollInterval {
    _friendsPart = _FriendsPart(this);
    _groupsPart = _GroupsPart(this);
    _conversationsPart = _ConversationsPart(this);
    _sessionSub = _engine.sessionChanges.listen(_bindSession);
  }

  /// Tox single-message budget after Tim2Tox's fragment header. Longer texts
  /// are fragmented by Tim2Tox and arrive as separate messages, which the UI
  /// must avoid (plan §5.2).
  static const int toxMessageBudget = 1322;

  final ChatEngine _engine;
  final IdentityService _identity;
  final KeyValueStore _store;
  final ChatLogger _logger;
  final Duration _pollInterval;

  late final _FriendsPart _friendsPart;
  late final _GroupsPart _groupsPart;
  late final _ConversationsPart _conversationsPart;

  FfiChatService? _service;
  StreamSubscription<FfiChatService?>? _sessionSub;
  final List<StreamSubscription<Object?>> _serviceSubs = [];
  Timer? _poll;
  bool _polling = false;
  bool _disposed = false;

  final StreamController<ChatMessage> _messageEvents =
      StreamController<ChatMessage>.broadcast();

  // ---- session binding ------------------------------------------------------

  String get _accountPrefix {
    final toxId = _identity.current?.toxId ?? '';
    return toxId.length >= 16 ? toxId.substring(0, 16).toUpperCase() : toxId;
  }

  ConversationMetaStore get _meta =>
      ConversationMetaStore(_store, accountPrefix: _accountPrefix);

  Tim2ToxPreferencesAdapter get _prefs =>
      Tim2ToxPreferencesAdapter(_store, accountPrefix: _accountPrefix);

  String get _selfKey {
    final svc = _service;
    final full = svc?.getSelfToxId() ?? _identity.current?.toxId ?? '';
    return ConversationIds.normalizeKey(full);
  }

  MessageMapper get _mapper => MessageMapper(
        selfKey: _selfKey,
        selfName: _identity.current?.displayName ?? '',
        nameOf: _friendsPart.nameOf,
      );

  FfiChatService _requireService() {
    final svc = _service;
    if (svc == null) {
      throw const ChatException(
        'not_connected',
        'Chat is not connected (call IdentityService.connect first)',
      );
    }
    return svc;
  }

  void _bindSession(FfiChatService? svc) {
    _unbindSession();
    _service = svc;
    if (svc == null) {
      _friendsPart.reset();
      _groupsPart.reset();
      _conversationsPart.reset();
      return;
    }
    _serviceSubs.addAll([
      svc.messages.listen(_onEngineMessage),
      svc.nicknameUpdated.listen((_) => _friendsPart.refresh(svc)),
      svc.pendingGroupInvitesChanged.listen((_) => _groupsPart.refreshInvites(svc)),
      svc.groupJoinFailures.listen(_groupsPart.onJoinFailure),
    ]);
    _poll = Timer.periodic(_pollInterval, (_) => _tick());
    unawaited(_tick());
  }

  void _unbindSession() {
    _poll?.cancel();
    _poll = null;
    for (final s in _serviceSubs) {
      unawaited(s.cancel());
    }
    _serviceSubs.clear();
    _service = null;
  }

  /// One refresh round: presence, requests, groups, invites, conversations.
  /// Serialised: a slow FFI round never overlaps the next.
  Future<void> _tick() async {
    final svc = _service;
    if (svc == null || _polling || _disposed) return;
    _polling = true;
    try {
      await _friendsPart.refresh(svc);
      await _friendsPart.refreshRequests(svc);
      await _groupsPart.refresh(svc);
      await _groupsPart.refreshInvites(svc);
      _conversationsPart.rebuild(svc);
    } catch (e, st) {
      _logger.error('[Chat] refresh tick failed', e, st);
    } finally {
      _polling = false;
    }
  }

  void _onEngineMessage(t2t.ChatMessage m) {
    final svc = _service;
    if (svc == null) return;
    var conversationId = MessageMapper.conversationOf(m);
    if (conversationId == null) {
      // Our own C2C row: Tim2Tox stamps the login alias, not the peer.
      final peer = m.msgID == null ? null : svc.c2cPeerOfSelfRow(m.msgID!);
      if (peer == null) return;
      conversationId = ConversationIds.c2c(peer);
    }
    if (_meta.hidden.contains(conversationId)) {
      unawaited(_meta.unhide(conversationId));
    }
    _messageEvents.add(_mapper.map(m, conversationId: conversationId));
    _conversationsPart.rebuild(svc);
  }

  // ---- Friends (delegated) -------------------------------------------------

  @override
  List<Friend> get friends => _friendsPart.friends.value;

  @override
  Stream<List<Friend>> get friendChanges => _friendsPart.friends.stream;

  @override
  List<FriendRequest> get friendRequests => _friendsPart.requests.value;

  @override
  Stream<List<FriendRequest>> get friendRequestChanges =>
      _friendsPart.requests.stream;

  @override
  Future<void> addFriend(String toxId, {String message = 'morsecq CQ'}) =>
      _friendsPart.addFriend(_requireService(), toxId, message);

  @override
  Future<void> acceptFriendRequest(String publicKey) =>
      _friendsPart.accept(_requireService(), publicKey);

  @override
  Future<void> rejectFriendRequest(String publicKey) =>
      _friendsPart.reject(_requireService(), publicKey);

  @override
  Future<void> removeFriend(String publicKey) =>
      _friendsPart.remove(_requireService(), publicKey);

  // ---- Conversations (delegated) -------------------------------------------

  @override
  List<Conversation> get conversations => _conversationsPart.conversations.value;

  @override
  Stream<List<Conversation>> get conversationChanges =>
      _conversationsPart.conversations.stream;

  @override
  Future<void> markRead(String conversationId) =>
      _conversationsPart.markRead(_requireService(), conversationId);

  @override
  Future<void> setPinned(String conversationId, bool pinned) =>
      _conversationsPart.setPinned(conversationId, pinned);

  @override
  Future<void> setDraft(String conversationId, String draft) =>
      _conversationsPart.setDraft(conversationId, draft);

  @override
  Future<void> deleteConversation(String conversationId) =>
      _conversationsPart.delete(_requireService(), conversationId);

  // ---- Messages -------------------------------------------------------------

  @override
  Stream<ChatMessage> get messageEvents => _messageEvents.stream;

  @override
  int get maxMessageBytes => toxMessageBudget;

  @override
  Future<List<ChatMessage>> loadHistory(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    final svc = _requireService();
    final peer = ConversationIds.peerOf(conversationId);
    final rows = List<t2t.ChatMessage>.of(svc.getHistory(peer));
    if (rows.length < limit + 1 && await svc.hasArchivedHistory(peer)) {
      final archived = await svc.getArchivedHistory(peer);
      final seen = rows.map((r) => r.msgID).toSet();
      rows.addAll(archived.where((r) => !seen.contains(r.msgID)));
    }
    t2t.sortChatMessagesChronologically(rows);
    var page = before == null
        ? rows
        : rows.where((r) => r.timestamp.isBefore(before)).toList();
    if (page.length > limit) page = page.sublist(page.length - limit);
    final mapper = _mapper;
    return [for (final r in page) mapper.map(r, conversationId: conversationId)];
  }

  @override
  Future<ChatMessage> sendText(String conversationId, String text) async {
    final svc = _requireService();
    final bytes = utf8.encode(text).length;
    if (bytes > toxMessageBudget) {
      throw ChatException(
        'message_too_long',
        '$bytes bytes exceeds the $toxMessageBudget-byte Tox message budget',
      );
    }
    if (text.trim().isEmpty) {
      throw const ChatException('empty_message', 'Message is empty');
    }
    final peer = ConversationIds.peerOf(conversationId);
    final t2t.ChatMessage row;
    try {
      row = ConversationIds.isGroup(conversationId)
          ? await svc.sendGroupTextWithResult(peer, text)
          : await svc.sendTextWithResult(peer, text);
    } on ArgumentError catch (e) {
      throw ChatException('invalid_message', e.message?.toString() ?? '$e');
    } on StateError catch (e) {
      throw ChatException('send_failed', e.message);
    }
    if (_meta.hidden.contains(conversationId)) {
      await _meta.unhide(conversationId);
    }
    _conversationsPart.rebuild(svc);
    return _mapper.map(row, conversationId: conversationId);
  }

  @override
  Future<void> clearHistory(String conversationId) async {
    final svc = _requireService();
    final peer = ConversationIds.peerOf(conversationId);
    if (ConversationIds.isGroup(conversationId)) {
      await svc.clearGroupHistory(peer);
    } else {
      await svc.clearC2CHistory(peer);
    }
    _conversationsPart.rebuild(svc);
  }

  // ---- Groups (delegated) --------------------------------------------------

  @override
  List<Group> get groups => _groupsPart.groups.value;

  @override
  Stream<List<Group>> get groupChanges => _groupsPart.groups.stream;

  @override
  List<GroupInvite> get groupInvites => _groupsPart.invites.value;

  @override
  Stream<List<GroupInvite>> get groupInviteChanges => _groupsPart.invites.stream;

  @override
  Future<Group> createGroup(String name, {GroupKind kind = GroupKind.group}) =>
      _groupsPart.create(_requireService(), name, kind);

  @override
  Future<void> joinGroup(String chatId, {String? password}) =>
      _groupsPart.join(_requireService(), chatId, password);

  @override
  Future<void> inviteToGroup(String groupId, String friendPublicKey) =>
      _groupsPart.invite(_requireService(), groupId, friendPublicKey);

  @override
  Future<void> acceptGroupInvite(String inviteId, {String? password}) =>
      _groupsPart.acceptInvite(_requireService(), inviteId, password);

  @override
  Future<void> rejectGroupInvite(String inviteId) =>
      _groupsPart.rejectInvite(_requireService(), inviteId);

  @override
  Future<List<GroupMember>> groupMembers(String groupId) =>
      _groupsPart.members(_requireService(), groupId);

  @override
  Future<void> leaveGroup(String groupId) =>
      _groupsPart.leave(_requireService(), groupId);

  // ---- lifecycle --------------------------------------------------------------

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _sessionSub?.cancel();
    _unbindSession();
    await _messageEvents.close();
    await _friendsPart.close();
    await _groupsPart.close();
    await _conversationsPart.close();
  }
}
