import 'package:flutter/foundation.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

/// What the conversation screen needs to open: the id, a title for the app
/// bar and the kind. Built from a [Conversation], a [Friend] (before any
/// message exists) or a [Group].
@immutable
final class ConversationTarget {
  const ConversationTarget({
    required this.id,
    required this.title,
    required this.kind,
  });

  ConversationTarget.fromConversation(Conversation c)
    : this(id: c.id, title: c.title, kind: c.kind);

  ConversationTarget.fromFriend(Friend f)
    : this(
        id: 'c2c_${f.publicKey}',
        title: f.displayName,
        kind: ConversationKind.c2c,
      );

  ConversationTarget.fromGroup(Group g)
    : this(id: 'group_${g.id}', title: g.name, kind: ConversationKind.group);

  final String id;
  final String title;
  final ConversationKind kind;

  /// Peer public key for c2c, group id for groups.
  String get peerId => id.substring(id.indexOf('_') + 1);

  @override
  bool operator ==(Object other) =>
      other is ConversationTarget && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
