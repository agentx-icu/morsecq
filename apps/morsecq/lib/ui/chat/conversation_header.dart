import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../../i18n/l10n_extension.dart';
import 'conversation_target.dart';

/// Title plus a live subtitle: online/offline for a friend, member count for
/// a group.
class ConversationTitle extends StatelessWidget {
  const ConversationTitle({
    super.key,
    required this.service,
    required this.target,
  });

  final ChatService service;
  final ConversationTarget target;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final S s = context.s;
    final Widget subtitle = target.kind == ConversationKind.c2c
        ? StreamBuilder<List<Friend>>(
            stream: service.friendChanges,
            initialData: service.friends,
            builder: (context, snapshot) {
              Friend? friend;
              for (final Friend f in snapshot.data ?? const <Friend>[]) {
                if (f.publicKey == target.peerId) friend = f;
              }
              final bool online = friend?.online ?? false;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: online
                        ? Colors.green
                        : scheme.outlineVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    online ? s.connectionOnline : s.connectionOffline,
                    style: text.labelSmall,
                  ),
                ],
              );
            },
          )
        : StreamBuilder<List<Group>>(
            stream: service.groupChanges,
            initialData: service.groups,
            builder: (context, snapshot) {
              Group? group;
              for (final Group g in snapshot.data ?? const <Group>[]) {
                if (g.id == target.peerId) group = g;
              }
              if (group == null) return const SizedBox.shrink();
              return Text(
                [
                  s.chatMemberCount(group.memberCount),
                  if (group.kind == GroupKind.conference) s.chatConferenceBadge,
                ].join(' · '),
                style: text.labelSmall,
              );
            },
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(target.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle,
      ],
    );
  }
}

class ConferenceNote extends StatelessWidget {
  const ConferenceNote({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: scheme.onTertiaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.s.chatConferenceNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
