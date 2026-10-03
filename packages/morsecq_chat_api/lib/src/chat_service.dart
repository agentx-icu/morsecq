import 'message_search.dart';
import 'models.dart';

/// Friends, conversations, C2C and group messaging.
///
/// All lists are exposed as broadcast streams that replay the current value
/// to new listeners (BehaviorSubject semantics), plus a synchronous getter.
/// Implementations must be safe to use before [IdentityService.connect];
/// sends while offline are queued (status [MessageStatus.pending]) and
/// flushed automatically when the peer comes online.
abstract interface class ChatService {
  // ---- Friends -------------------------------------------------------------

  List<Friend> get friends;
  Stream<List<Friend>> get friendChanges;

  List<FriendRequest> get friendRequests;
  Stream<List<FriendRequest>> get friendRequestChanges;

  /// Send a friend request to a 76-hex Tox ID. Throws `invalid_tox_id`,
  /// `already_friend`, `own_id`.
  Future<void> addFriend(String toxId, {String message = 'morsecq CQ'});

  Future<void> acceptFriendRequest(String publicKey);
  Future<void> rejectFriendRequest(String publicKey);
  Future<void> removeFriend(String publicKey);

  // ---- Conversations -------------------------------------------------------

  /// The note-to-self conversation (`c2c_<own public key>`) of the open
  /// identity, or null when none is open. Shown as "me" with the own display
  /// name: a drafts box, a practice partner, a place to keep notes. It is in
  /// [conversations] (with [Conversation.isSelf]) whenever the other
  /// conversations are, i.e. while chat is connected. [sendText] to it is
  /// local only — stored, never sent — and returns [MessageStatus.sent] at
  /// once. It cannot be deleted: [deleteConversation] refuses it (see there);
  /// [clearHistory] is the explicit way to empty it.
  String? get selfConversationId;

  List<Conversation> get conversations;
  Stream<List<Conversation>> get conversationChanges;

  Future<void> markRead(String conversationId);
  Future<void> setPinned(String conversationId, bool pinned);
  Future<void> setDraft(String conversationId, String draft);

  /// Clears the conversation's history and removes it from [conversations]
  /// until the next message. For [selfConversationId] it throws
  /// `ChatException('self_conversation', ...)` and changes nothing (history,
  /// draft and pin all stay).
  Future<void> deleteConversation(String conversationId);

  // ---- Messages ------------------------------------------------------------

  /// Persisted history for a conversation, oldest first. [before] pages
  /// backwards; null = latest page.
  Future<List<ChatMessage>> loadHistory(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  });

  /// Live message events: new inbound messages and status updates for our
  /// own messages (pending → sent / failed), for every conversation.
  Stream<ChatMessage> get messageEvents;

  /// Send plain text. Returns the local row immediately (status pending or
  /// sending). Throws `message_too_long` when [text] exceeds
  /// [maxMessageBytes] in UTF-8 — the UI shows the remaining budget so this
  /// should be rare.
  Future<ChatMessage> sendText(String conversationId, String text);

  /// Tox single-message budget after Tim2Tox's fragment header (1322 bytes).
  int get maxMessageBytes;

  Future<void> clearHistory(String conversationId);

  // ---- Message management (F07) ---------------------------------------------

  /// Searches the whole persisted history of [conversationId] (not only the
  /// rows a screen loaded), newest first by (timestamp, id). Pass the
  /// previous page's [MessageSearchPage.next] as [cursor] for the next page;
  /// pages never lose or repeat rows, even with equal timestamps.
  Future<MessageSearchPage> searchMessages(
    String conversationId,
    MessageSearchQuery query, {
    MessageSearchCursor? cursor,
    int limit = 20,
  });

  /// Up to [before] older and [after] newer rows around [messageId], oldest
  /// first, including the message itself; empty when it is not in the
  /// history (deleted, cleared). For jumping to a search result.
  Future<List<ChatMessage>> loadAround(
    String conversationId,
    String messageId, {
    int before = 25,
    int after = 25,
  });

  /// Whether [retryMessage] / [cancelPendingMessage] are backed by the
  /// transport. When false both return [MessageActionResult.unavailable]
  /// and the UI must not offer them.
  bool get supportsSendControl;

  /// Re-sends our [MessageStatus.failed] message under its stable local id
  /// (no second row); the row turns [MessageStatus.pending] and drains when
  /// the peer is reachable. Only confirmed failures qualify. A stable local
  /// id is not end-to-end exactly-once delivery.
  Future<MessageActionResult> retryMessage(
    String conversationId,
    String messageId,
  );

  /// Cancels our [MessageStatus.pending] message while it is still only
  /// queued locally. Returns [MessageActionResult.stateChanged] when the
  /// transport already claimed it (it may be delivered). The row is kept as
  /// [MessageStatus.cancelled] and emitted on [messageEvents].
  Future<MessageActionResult> cancelPendingMessage(
    String conversationId,
    String messageId,
  );

  // ---- Groups --------------------------------------------------------------

  List<Group> get groups;
  Stream<List<Group>> get groupChanges;

  List<GroupInvite> get groupInvites;
  Stream<List<GroupInvite>> get groupInviteChanges;

  Future<Group> createGroup(String name, {GroupKind kind = GroupKind.group});

  /// Join an NGC group by its 64-hex chat id (async on the Tox side; the
  /// group appears in [groups] once the DHT finds a peer).
  Future<void> joinGroup(String chatId, {String? password});

  Future<void> inviteToGroup(String groupId, String friendPublicKey);
  Future<void> acceptGroupInvite(String inviteId, {String? password});
  Future<void> rejectGroupInvite(String inviteId);
  Future<List<GroupMember>> groupMembers(String groupId);
  Future<void> leaveGroup(String groupId);

  /// Release streams and stop timers.
  Future<void> dispose();
}
