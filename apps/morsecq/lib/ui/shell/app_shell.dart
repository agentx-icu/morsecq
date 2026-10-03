import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../../i18n/l10n_extension.dart';
import '../../notifications/connection_banner_policy.dart';
import '../../notifications/notification_center.dart';
import '../../notifications/notification_payload.dart';
import '../chat/conversation_route.dart';
import '../chat/conversation_target.dart';
import '../pages/chat_page.dart';
import '../pages/groups_page.dart';
import '../pages/learn_page.dart';
import '../pages/me_page.dart';
import '../pages/reference_page.dart';
import '../responsive.dart';

/// One top-level destination. Kept as data so the bar and the rail render the
/// same list and cannot drift apart. The label is resolved against the
/// current locale at build time, so a language switch relabels the bar.
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String Function(S s) label;
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
  StreamSubscription<NotificationTapTarget>? _taps;
  NotificationCenter? _center;

  /// Notification-opened conversations whose routes are pushed but may not
  /// have built yet (so they are not [NotificationCenter.activeConversation]
  /// yet): reserved synchronously, each released once its route has had a
  /// frame (from then on the screen reports itself) or has gone.
  final Set<String> _opening = <String>{};

  /// Bumped per routing tap, so an older tap's pop loop stops.
  int _tapGeneration = 0;

  /// Keeps the page stack mounted when the layout class flips. Rotating a
  /// phone to landscape (or unfolding a foldable) crosses the 600 px
  /// breakpoint, which moves the body from `Scaffold.body` into the rail's
  /// `Row`; without a global key every tab's state (open chat pane, scroll
  /// positions, reference/translator input) was thrown away on rotation.
  final GlobalKey _bodyKey = GlobalKey(debugLabel: 'shell-body');

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    // Notification taps (and cold-start payloads) open the conversation.
    // NotificationCenter is null in tests and where notifications are off.
    final center = _center = context.read<NotificationCenter?>();
    _openRequests = center?.openConversationRequests.listen(_openConversation);
    // Friend requests and group invites land on the area that answers them.
    _taps = center?.tapTargets.listen(_onTap);
  }

  @override
  void dispose() {
    _openRequests?.cancel();
    _taps?.cancel();
    super.dispose();
  }

  void _onTap(NotificationTapTarget target) {
    final Type? page = switch (target) {
      FriendRequestTarget() => ChatPage, // contacts badge on the Chat bar
      GroupInviteTarget() => GroupsPage, // invites head the group list
      OpenConversationTarget() => null, // see openConversationRequests
    };
    if (page == null || !mounted) return;
    final int generation = ++_tapGeneration;
    unawaited(
      _popToShell(generation).then((bool atShell) {
        if (!atShell || !mounted || generation != _tapGeneration) return;
        _select(
          kShellDestinations.indexWhere((d) => d.page.runtimeType == page),
        );
      }),
    );
  }

  /// Pops the routes above the shell one at a time through `maybePop`, so a
  /// route that refuses (a [PopScope] such as the drill leave guard, which
  /// asks first) keeps its say instead of being torn down by `popUntil`.
  /// Resolves to whether the shell's route is on top again.
  Future<bool> _popToShell(int generation) async {
    final NavigatorState navigator = Navigator.of(context);
    while (mounted && generation == _tapGeneration) {
      // A route pushed this frame (a conversation tap just before) has no
      // scope yet and asserts in maybePop: let it build first.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || generation != _tapGeneration) return false;
      final Route<dynamic>? top = _topRoute(navigator);
      if (top == null || top.isFirst) return true;
      await navigator.maybePop();
      // Not popped: it refused, and may be asking the user (a dialog now on
      // top, not built yet - never maybePop that one). Stop here.
      if (top.isActive) return false;
    }
    return false;
  }

  static Route<dynamic>? _topRoute(NavigatorState navigator) {
    Route<dynamic>? top;
    navigator.popUntil((Route<dynamic> route) {
      top = route; // never pops: the predicate accepts the top route
      return true;
    });
    return top;
  }

  void _openConversation(String conversationId) {
    // Already on screen (a pushed route on top, or the selected tab's
    // detail pane), or pushed and about to build: a second copy would only
    // stack a duplicate route.
    if (!mounted ||
        _opening.contains(conversationId) ||
        _center?.activeConversation == conversationId) {
      return;
    }
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
    _opening.add(conversationId);
    void release() => _opening.remove(conversationId);
    unawaited(pushConversation(context, target).whenComplete(release));
    WidgetsBinding.instance.addPostFrameCallback((_) => release());
  }

  /// Body plus the "offline for a while" strip; the policy decides when the
  /// strip shows so it never flaps on short reconnects.
  Widget _withBanner(Widget body) {
    final policy = context.read<ConnectionBannerPolicy>();
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: policy.offlineBannerVisible,
          builder: (context, visible, _) =>
              visible ? const _OfflineBanner() : const SizedBox.shrink(),
        ),
        Expanded(child: body),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final layout = layoutClassOf(context);
    final body = KeyedSubtree(
      key: _bodyKey,
      child: _withBanner(
        IndexedStack(
          index: _selectedIndex,
          // Hidden tabs keep their state but stop animating; a conversation
          // left open on another tab reads this to stay silent.
          children: [
            for (final (i, d) in kShellDestinations.indexed)
              TickerMode(enabled: i == _selectedIndex, child: d.page),
          ],
        ),
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
                  label: d.label(s),
                ),
            ],
          ),
        );
      case LayoutClass.expanded:
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                // A phone in landscape is ~320-430 px tall: five labelled
                // destinations overflow there at large text scales.
                scrollable: true,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _select,
                destinations: [
                  for (final d in kShellDestinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label(s)),
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
                  context.s.shellOfflineBanner,
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
