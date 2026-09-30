import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../chat/chat_strings.dart';

/// Bottom sheet listing a group's members with online dots.
Future<void> showGroupMembersSheet(
  BuildContext context, {
  required ChatService service,
  required Group group,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      builder: (context, scroll) => _MembersBody(
        future: service.groupMembers(group.id),
        group: group,
        scroll: scroll,
      ),
    ),
  );
}

class _MembersBody extends StatelessWidget {
  const _MembersBody({
    required this.future,
    required this.group,
    required this.scroll,
  });

  final Future<List<GroupMember>> future;
  final Group group;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FutureBuilder<List<GroupMember>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final List<GroupMember>? members = snapshot.data;
        if (members == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          controller: scroll,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                '${ChatStrings.members} · ${members.length}',
                style: theme.textTheme.titleMedium,
              ),
            ),
            for (final GroupMember m in members)
              ListTile(
                leading: _OnlineDot(online: m.online),
                title: Text(
                  m.isSelf
                      ? '${m.displayName} (${ChatStrings.you})'
                      : m.displayName,
                ),
                subtitle: Text(
                  m.publicKey.length > 16
                      ? '${m.publicKey.substring(0, 16)}…'
                      : m.publicKey,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 6,
      backgroundColor: online ? Colors.green : scheme.outlineVariant,
    );
  }
}
