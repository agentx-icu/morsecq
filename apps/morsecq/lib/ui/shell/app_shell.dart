import 'package:flutter/material.dart';

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

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final layout = layoutClassOf(context);
    final body = IndexedStack(
      index: _selectedIndex,
      children: [for (final d in kShellDestinations) d.page],
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
