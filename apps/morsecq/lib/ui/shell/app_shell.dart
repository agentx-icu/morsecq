import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../notifications/connection_banner_policy.dart';
import '../../notifications/notification_center.dart';
import '../chat/conversation_screen.dart';
import '../chat/conversation_target.dart';
import '../pages/chat_page.dart';
import '../pages/groups_page.dart';
import '../pages/learn_page.dart';
import '../pages/me_page.dart';
import '../pages/reference_page.dart';
import '../responsive.dart';

/// One top-level destination. Kept as data so the bar and the rail render the
/// same list and cannot drift apart.
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

const List<ShellDestination> kShellDestinations = [
  ShellDestination(
    label: LearnPage.title,
    icon: Icons.school_outlined,
    selectedIcon: Icons.school,
    page: LearnPage(),
  ),
  ShellDestination(
    label: ChatPage.title,
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
    page: ChatPage(),
  ),
  ShellDestination(
    label: GroupsPage.title,
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups,
    page: GroupsPage(),
  ),
  ShellDestination(
    label: ReferencePage.title,
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    page: ReferencePage(),
  ),
  ShellDestination(
    label: MePage.title,
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    page: MePage(),
  ),
];

/// Responsive root: bottom [NavigationBar] on compact widths, side
/// [NavigationRail] otherwise. See `responsive.dart` for the breakpoint.
///
/// Rendered only behind `StartupGate`: an identity is required before
/// training as well as chat (product decision, see
/// doc/plans/2026-09-30-morsecq-plan.zh-CN.md).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  StreamSubscription<String>? _openRequests;

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    // Notification taps (and cold-start payloads) open the conversation.
    // NotificationCenter is null in tests and where notifications are off.
    final center = context.read<NotificationCenter?>();
    _openRequests = center?.openConversationRequests.listen(_openConversation);
  }

  @override
  void dispose() {
    _openRequests?.cancel();
    super.dispose();
  }

  void _openConversation(String conversationId) {
    final chat = context.read<ChatService>();
    final existing = chat.conversations
        .where((c) => c.id == conversationId)
        .firstOrNull;
    final target = existing != null
        ? ConversationTarget.fromConversation(existing)
        : ConversationTarget(
            id: conversationId,
            title: conversationId,
            kind: conversationId.startsWith('group_')
                ? ConversationKind.group
                : ConversationKind.c2c,
          );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConversationScreen(target: target),
      ),
    );
  }

  /// Body plus the "offline for a while" strip; the policy decides when the
  /// strip shows so it never flaps on short reconnects.
  Widget _withBanner(Widget body) {
    final policy = context.read<ConnectionBannerPolicy>();
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: policy.offlineBannerVisible,
          builder: (context, visible, _) => visible
              ? const _OfflineBanner()
              : const SizedBox.shrink(),
        ),
        Expanded(child: body),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = layoutClassOf(context);
    final body = _withBanner(
      IndexedStack(
        index: _selectedIndex,
        children: [for (final d in kShellDestinations) d.page],
      ),
    );

    switch (layout) {
      case LayoutClass.compact:
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _select,
            destinations: [
              for (final d in kShellDestinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
            ],
          ),
        );
      case LayoutClass.expanded:
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _select,
                destinations: [
                  for (final d in kShellDestinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          ),
        );
    }
  }
}

/// Tox has no server: while we are offline nothing can arrive. Shown after the
/// [ConnectionBannerPolicy] threshold, on every platform, above the content.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.cloud_off, size: 18, color: scheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Offline: not connected to the Tox network. Messages will '
                  'be sent when you are back online.',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
