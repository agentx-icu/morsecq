import 'package:flutter/foundation.dart';

/// What a tapped notification asks the app to do. Encoded into the plugin's
/// string payload and parsed back on tap (also on cold start via
/// `LocalNotificationsApi.takeLaunchPayload`).
///
/// Wire format: `conv:<conversationId>`, `friend_req:<publicKey>`,
/// `group_invite:<inviteId>`. Conversation ids are the contract's
/// `c2c_<pk>` / `group_<id>`, kept verbatim so the orchestrator can hand
/// them straight to the chat UI.
@immutable
sealed class NotificationTapTarget {
  const NotificationTapTarget();

  static const String _conversation = 'conv:';
  static const String _friendRequest = 'friend_req:';
  static const String _groupInvite = 'group_invite:';

  /// Null for an empty or unrecognised payload.
  static NotificationTapTarget? parse(String payload) {
    final String trimmed = payload.trim();
    if (trimmed.startsWith(_conversation)) {
      final String id = trimmed.substring(_conversation.length);
      return id.isEmpty ? null : OpenConversationTarget(id);
    }
    if (trimmed.startsWith(_friendRequest)) {
      final String pk = trimmed.substring(_friendRequest.length);
      return pk.isEmpty ? null : FriendRequestTarget(pk);
    }
    if (trimmed.startsWith(_groupInvite)) {
      final String id = trimmed.substring(_groupInvite.length);
      return id.isEmpty ? null : GroupInviteTarget(id);
    }
    return null;
  }

  String encode();
}

final class OpenConversationTarget extends NotificationTapTarget {
  const OpenConversationTarget(this.conversationId);

  final String conversationId;

  @override
  String encode() => '${NotificationTapTarget._conversation}$conversationId';

  @override
  bool operator ==(Object other) =>
      other is OpenConversationTarget && other.conversationId == conversationId;

  @override
  int get hashCode => Object.hash(runtimeType, conversationId);

  @override
  String toString() => 'OpenConversationTarget($conversationId)';
}

final class FriendRequestTarget extends NotificationTapTarget {
  const FriendRequestTarget(this.publicKey);

  final String publicKey;

  @override
  String encode() => '${NotificationTapTarget._friendRequest}$publicKey';

  @override
  bool operator ==(Object other) =>
      other is FriendRequestTarget && other.publicKey == publicKey;

  @override
  int get hashCode => Object.hash(runtimeType, publicKey);

  @override
  String toString() => 'FriendRequestTarget($publicKey)';
}

final class GroupInviteTarget extends NotificationTapTarget {
  const GroupInviteTarget(this.inviteId);

  final String inviteId;

  @override
  String encode() => '${NotificationTapTarget._groupInvite}$inviteId';

  @override
  bool operator ==(Object other) =>
      other is GroupInviteTarget && other.inviteId == inviteId;

  @override
  int get hashCode => Object.hash(runtimeType, inviteId);

  @override
  String toString() => 'GroupInviteTarget($inviteId)';
}

/// Deterministic, non-negative 31-bit notification id for [key] (normally an
/// encoded [NotificationTapTarget]).
///
/// FNV-1a rather than `String.hashCode`: Dart does not promise that
/// `hashCode` is stable across processes, and we want to be able to cancel a
/// banner that an earlier run of the app posted (opening a conversation
/// after a cold start must still dismiss its notification).
int stableNotificationId(String key) {
  var hash = 0x811C9DC5;
  for (final int unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}
