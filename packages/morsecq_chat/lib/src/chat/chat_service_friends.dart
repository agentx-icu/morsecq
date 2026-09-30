part of 'tim2tox_chat_service.dart';

/// Friends and friend requests: Tim2Tox has no push for presence or new
/// requests, so both are polled on the service tick (toxee's UIKit polls the
/// same two calls every few seconds).
class _FriendsPart {
  _FriendsPart(this._owner);

  final Tim2ToxChatService _owner;

  final ValueStream<List<Friend>> friends = ValueStream(const []);
  final ValueStream<List<FriendRequest>> requests = ValueStream(const []);

  /// First time each pending request was observed (Tox does not timestamp
  /// friend requests).
  final Map<String, DateTime> _requestSeen = {};
  final Map<String, String> _names = {};
  final Set<String> _online = {};

  String? nameOf(String publicKey) => _names[publicKey];

  bool isOnline(String publicKey) => _online.contains(publicKey);

  void reset() {
    _online.clear();
    friends.add(const []);
    requests.add(const []);
  }

  Future<void> refresh(FfiChatService svc) async {
    final raw = await svc.getFriendList();
    if (!_owner._isCurrent(svc)) return;
    final cameOnline = <String>[];
    final next = <Friend>[];
    final onlineNow = <String>{};
    for (final f in raw) {
      final key = ConversationIds.normalizeKey(f.userId);
      if (key.isEmpty) continue;
      final name = f.nickName.isNotEmpty ? f.nickName : ConversationIds.shortKey(key);
      _names[key] = name;
      if (f.online) {
        onlineNow.add(key);
        if (!_online.contains(key)) cameOnline.add(key);
      }
      next.add(Friend(
        publicKey: key,
        displayName: name,
        statusMessage: f.status,
        online: f.online,
      ));
    }
    _online
      ..clear()
      ..addAll(onlineNow);
    next.sort((a, b) {
      if (a.online != b.online) return a.online ? -1 : 1;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    if (!listEqualsBy(friends.value, next, _sameFriend)) friends.force(next);
    for (final key in cameOnline) {
      if (!_owner._isCurrent(svc)) return;
      await _owner._groupsPart.flushQueuedInvites(svc, key);
    }
  }

  static bool _sameFriend(Friend a, Friend b) =>
      a.publicKey == b.publicKey &&
      a.displayName == b.displayName &&
      a.statusMessage == b.statusMessage &&
      a.online == b.online;

  Future<void> refreshRequests(FfiChatService svc) async {
    final apps = await svc.getFriendApplications();
    if (!_owner._isCurrent(svc)) return;
    final next = <FriendRequest>[];
    final live = <String>{};
    for (final a in apps) {
      final key = ConversationIds.normalizeKey(a.userId);
      if (key.isEmpty || live.contains(key)) continue;
      live.add(key);
      final seen = _requestSeen.putIfAbsent(key, DateTime.now);
      next.add(FriendRequest(publicKey: key, message: a.wording, receivedAt: seen));
    }
    _requestSeen.removeWhere((k, _) => !live.contains(k));
    next.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    if (!listEqualsBy(requests.value, next, _sameRequest)) requests.force(next);
  }

  static bool _sameRequest(FriendRequest a, FriendRequest b) =>
      a.publicKey == b.publicKey && a.message == b.message;

  Future<void> addFriend(FfiChatService svc, String toxId, String message) async {
    final id = toxId.trim().toUpperCase();
    if (!ConversationIds.toxAddress.hasMatch(id)) {
      throw const ChatException(
        'invalid_tox_id',
        'A Tox ID is 76 hexadecimal characters',
      );
    }
    final key = ConversationIds.normalizeKey(id);
    if (key == _owner._selfKey) {
      throw const ChatException('own_id', 'That is your own Tox ID');
    }
    if (friends.value.any((f) => f.publicKey == key)) {
      throw const ChatException('already_friend', 'Already in your friend list');
    }
    final result = await svc.addFriend(id, requestMessage: message);
    if (!result.isSuccess) {
      final code = result.resultCode;
      // V2TIM 30515: the peer is already a friend; 30539: request pending.
      if (code == 30515) {
        throw const ChatException('already_friend', 'Already in your friend list');
      }
      throw ChatException(
        'add_friend_failed',
        result.resultInfo.isEmpty ? 'Friend request failed ($code)' : result.resultInfo,
      );
    }
    _owner._ensureCurrent(svc);
    await refresh(svc);
    _owner._ensureCurrent(svc);
    _owner._conversationsPart.rebuild(svc);
  }

  Future<void> accept(FfiChatService svc, String publicKey) async {
    final key = ConversationIds.normalizeKey(publicKey);
    try {
      await svc.acceptFriendRequest(key);
    } on StateError catch (e) {
      throw ChatException('accept_failed', e.message);
    }
    _owner._ensureCurrent(svc);
    _requestSeen.remove(key);
    await refreshRequests(svc);
    await refresh(svc);
    _owner._ensureCurrent(svc);
    _owner._conversationsPart.rebuild(svc);
  }

  Future<void> reject(FfiChatService svc, String publicKey) async {
    final key = ConversationIds.normalizeKey(publicKey);
    await svc.refuseFriendApplication(key);
    _owner._ensureCurrent(svc);
    _requestSeen.remove(key);
    await refreshRequests(svc);
  }

  Future<void> remove(FfiChatService svc, String publicKey) async {
    final key = ConversationIds.normalizeKey(publicKey);
    await svc.removeFriend(key);
    _owner._ensureCurrent(svc);
    _names.remove(key);
    _online.remove(key);
    await _owner._forgetMeta(svc, ConversationIds.c2c(key));
    await refresh(svc);
    _owner._ensureCurrent(svc);
    _owner._conversationsPart.rebuild(svc);
  }

  Future<void> close() =>
      Future.wait([friends.close(), requests.close()]);
}
