import 'dart:convert';

import 'package:morsecq_chat_api/morsecq_chat_api.dart' as api;
import 'package:tim2tox_dart/models/chat_message.dart' as t2t;
import 'package:tim2tox_dart/utils/conversation_id_utils.dart';

/// Conversation-id helpers shared by the chat service parts.
///
/// The contract uses `c2c_<publicKey>` / `group_<groupId>`; Tim2Tox keys its
/// history by the bare, normalised id (64-hex key or `tox_<n>`).
class ConversationIds {
  ConversationIds._();

  static const c2cPrefix = 'c2c_';
  static const groupPrefix = 'group_';

  static String c2c(String publicKey) => '$c2cPrefix${normalizeKey(publicKey)}';
  static String group(String groupId) => '$groupPrefix$groupId';

  static bool isGroup(String conversationId) =>
      conversationId.startsWith(groupPrefix);

  /// Bare peer key / group id — what Tim2Tox wants.
  static String peerOf(String conversationId) =>
      ConversationIdUtils.normalize(conversationId);

  /// 76-hex Tox address → 64-hex public key, upper-cased and trimmed.
  static String normalizeKey(String id) =>
      ConversationIdUtils.normalize(id).toUpperCase();

  static final RegExp toxAddress = RegExp(r'^[0-9A-Fa-f]{76}$');
  static final RegExp publicKey = RegExp(r'^[0-9A-Fa-f]{64}$');

  /// Short human label for a bare key (`A1B2C3D4…`).
  static String shortKey(String key) =>
      key.length > 8 ? '${key.substring(0, 8).toUpperCase()}…' : key;
}

/// Maps Tim2Tox rows to contract [api.ChatMessage]s.
class MessageMapper {
  const MessageMapper({
    required this.selfKey,
    required this.selfName,
    required this.nameOf,
    this.isQueued,
  });

  /// Our 64-hex public key (upper-case). Empty before login.
  final String selfKey;
  final String selfName;

  /// Display name for a peer key, or null when unknown.
  final String? Function(String publicKey) nameOf;

  /// Checks the durable outbox when history's transient pending flag was lost.
  final bool Function(t2t.ChatMessage message, String conversationId)? isQueued;

  /// [conversationId] is required for our own C2C rows: Tim2Tox stamps them
  /// with the login alias and no peer, so the caller must know the target.
  api.ChatMessage map(t2t.ChatMessage m, {required String conversationId}) {
    final isMine = m.isSelf;
    final sender = isMine
        ? selfKey
        : ConversationIds.normalizeKey(m.fromUserId);
    final text = m.contentKind == t2t.ChatMessageContentKind.action
        ? '/me ${m.text}'
        : m.text;
    return api.ChatMessage(
      // Legacy rows without a msgID: include the sender so two peers'
      // identical texts at the same instant never share an id (paging,
      // bookmarks and jumps key on it).
      id:
          m.msgID ??
          '${m.timestamp.microsecondsSinceEpoch}_${sender}_${_digest(text)}',
      conversationId: conversationId,
      senderId: sender,
      senderName: isMine ? selfName : nameOf(sender),
      text: text,
      timestamp: m.timestamp,
      // A cancelled or failed row keeps that state even while its queue item
      // lingers (Tim2Tox emits the row before the durable removal);
      // otherwise the durable queue says pending.
      status:
          isMine &&
              !m.isCancelled &&
              !m.isFailed &&
              (isQueued?.call(m, conversationId) ?? false)
          ? api.MessageStatus.pending
          : statusOf(m),
      isMine: isMine,
    );
  }

  /// Our rows: cancelled (`isCancelled`), failed (a queued send whose
  /// drain failed: `isFailed`), still queued (`isPending`), else sent.
  static api.MessageStatus statusOf(t2t.ChatMessage m) {
    if (!m.isSelf) return api.MessageStatus.received;
    if (m.isCancelled) return api.MessageStatus.cancelled;
    if (m.isFailed) return api.MessageStatus.failed;
    return m.isPending ? api.MessageStatus.pending : api.MessageStatus.sent;
  }

  /// The contract conversation id of a row when it can be derived from the
  /// row alone (inbound C2C, any group row). Null for our own C2C rows.
  static String? conversationOf(t2t.ChatMessage m) {
    final gid = m.groupId;
    if (gid != null && gid.isNotEmpty) return ConversationIds.group(gid);
    if (m.isSelf) return null;
    return ConversationIds.c2c(m.fromUserId);
  }

  /// FNV-1a 64 over the UTF-8 body: stable across runs and platforms,
  /// unlike `String.hashCode`, and wide enough that distinct bodies with
  /// the same sender and timestamp do not collide in practice.
  static String _digest(String text) {
    var hash = BigInt.parse('cbf29ce484222325', radix: 16);
    final prime = BigInt.parse('100000001b3', radix: 16);
    final mask = (BigInt.one << 64) - BigInt.one;
    for (final byte in utf8.encode(text)) {
      hash = ((hash ^ BigInt.from(byte)) * prime) & mask;
    }
    return hash.toRadixString(36);
  }
}
