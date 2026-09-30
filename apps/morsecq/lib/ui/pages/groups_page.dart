import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../chat/chat_layout.dart';
import '../chat/chat_scope.dart';
import '../chat/chat_strings.dart';
import '../chat/conversation_screen.dart';
import '../chat/conversation_target.dart';
import '../groups/create_group_sheet.dart';
import '../groups/group_list.dart';
import '../groups/join_group_sheet.dart';
import 'placeholder_page.dart';

/// Group nets: many operators on one shared Morse channel.
///
/// Same master-detail rule as the chat page; group conversations reuse
/// [ConversationScreen], which shows the conference note and the member /
/// leave actions for groups.
class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  static const String title = ChatStrings.groupsTitle;
  static const String description =
      'Group nets — many operators keying on one shared channel.';

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  Group? _selected;

  void _open(BuildContext context, Group group) {
    if (isMasterDetail(context)) {
      setState(() => _selected = group);
      return;
    }
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              ConversationScreen(target: ConversationTarget.fromGroup(group)),
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context, ChatService service) async {
    final Group? group = await showCreateGroupSheet(context, service: service);
    if (group != null && context.mounted) _open(context, group);
  }

  Future<void> _join(BuildContext context, ChatService service) async {
    final bool joined = await showJoinGroupSheet(context, service: service);
    if (joined && context.mounted) {
      showSnack(context, ChatStrings.joinRequested);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatService? service = maybeChatService(context);
    if (service == null) {
      return const PlaceholderPage(
        title: GroupsPage.title,
        description: GroupsPage.description,
        icon: Icons.groups_outlined,
      );
    }
    final bool twoPane = isMasterDetail(context);
    if (!twoPane && _selected != null) _selected = null;

    final Widget list = Scaffold(
      appBar: AppBar(
        title: const Text(GroupsPage.title),
        actions: [
          IconButton(
            tooltip: ChatStrings.joinGroup,
            icon: const Icon(Icons.login),
            onPressed: () => unawaited(_join(context, service)),
          ),
          IconButton(
            tooltip: ChatStrings.createGroup,
            icon: const Icon(Icons.group_add_outlined),
            onPressed: () => unawaited(_create(context, service)),
          ),
        ],
      ),
      body: StreamBuilder<List<Group>>(
        stream: service.groupChanges,
        initialData: service.groups,
        builder: (context, snapshot) {
          final List<Group> groups = snapshot.data ?? const <Group>[];
          final Group? selected = _selected;
          if (selected != null && !groups.any((g) => g.id == selected.id)) {
            // Left (or was removed from) the open group: drop the pane.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selected?.id == selected.id) {
                setState(() => _selected = null);
              }
            });
          }
          return Column(
            children: [
              if (groups.isEmpty && service.groupInvites.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Text(
                    GroupsPage.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Expanded(
                child: GroupList(
                  service: service,
                  selectedId: _selected?.id,
                  onOpen: (g) => _open(context, g),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (!twoPane) return list;
    final Group? selected = _selected;
    return MasterDetail(
      master: list,
      detail: selected == null
          ? null
          : ConversationScreen(
              key: ValueKey<String>('detail_group_${selected.id}'),
              target: ConversationTarget.fromGroup(selected),
              embedded: true,
              onClosed: () => setState(() => _selected = null),
            ),
    );
  }
}
