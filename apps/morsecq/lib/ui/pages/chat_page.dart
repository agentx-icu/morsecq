import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../chat/chat_layout.dart';
import '../chat/chat_scope.dart';
import '../chat/chat_strings.dart';
import '../chat/conversation_list.dart';
import '../chat/conversation_screen.dart';
import '../chat/conversation_target.dart';
import '../contacts/contacts_page.dart';
import 'placeholder_page.dart';

/// One-to-one Morse conversations over Tox.
///
/// Phone: the list fills the page and opening a conversation pushes a route.
/// Tablet / desktop (width ≥ [kMasterDetailMinWidth]): list + open
/// conversation side by side. Contacts (friends, requests, add friend, my
/// Tox ID) live behind the app-bar people icon.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  static const String title = ChatStrings.chatTitle;
  static const String description =
      'Serverless one-to-one Morse conversations over Tox P2P.';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ConversationTarget? _selected;

  void _open(BuildContext context, ConversationTarget target) {
    if (isMasterDetail(context)) {
      setState(() => _selected = target);
      return;
    }
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ConversationScreen(target: target),
        ),
      ),
    );
  }

  Future<void> _openContacts(BuildContext context, ChatService service) {
    final NavigatorState navigator = Navigator.of(context);
    return ContactsPage.open(
      context,
      service: service,
      identity: maybeIdentityService(context),
      onOpenConversation: (target) {
        navigator.pop();
        if (mounted) _open(context, target);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChatService? service = maybeChatService(context);
    if (service == null) {
      return const PlaceholderPage(
        title: ChatPage.title,
        description: ChatPage.description,
        icon: Icons.chat_bubble_outline,
      );
    }
    final bool twoPane = isMasterDetail(context);
    if (!twoPane && _selected != null) {
      // Window shrank below the breakpoint: forget the inline selection so
      // the list is not stuck showing a pane that no longer exists.
      _selected = null;
    }

    final Widget list = Scaffold(
      appBar: AppBar(
        title: const Text(ChatPage.title),
        actions: [
          _RequestsBadge(
            service: service,
            onPressed: () => unawaited(_openContacts(context, service)),
          ),
        ],
      ),
      body: ConversationList(
        service: service,
        selectedId: _selected?.id,
        emptyText: ChatPage.description,
        onOpen: (c) => _open(context, ConversationTarget.fromConversation(c)),
      ),
    );

    if (!twoPane) return list;
    final ConversationTarget? selected = _selected;
    return MasterDetail(
      master: list,
      detail: selected == null
          ? null
          : ConversationScreen(
              key: ValueKey<String>('detail_${selected.id}'),
              target: selected,
              embedded: true,
              onClosed: () => setState(() => _selected = null),
            ),
    );
  }
}

/// Contacts button with a badge for pending friend requests.
class _RequestsBadge extends StatelessWidget {
  const _RequestsBadge({required this.service, required this.onPressed});

  final ChatService service;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendRequest>>(
      stream: service.friendRequestChanges,
      initialData: service.friendRequests,
      builder: (context, snapshot) {
        final int count = snapshot.data?.length ?? 0;
        return IconButton(
          tooltip: ChatStrings.contacts,
          onPressed: onPressed,
          icon: Badge.count(
            count: count,
            isLabelVisible: count > 0,
            child: const Icon(Icons.people_outline),
          ),
        );
      },
    );
  }
}
