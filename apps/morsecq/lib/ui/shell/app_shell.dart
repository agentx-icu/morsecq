import 'package:flutter/material.dart';
import '../../i18n/l10n_extension.dart';
import '../pages/learn_page.dart';
import '../pages/offline_me_page.dart';
import '../pages/reference_page.dart';
import '../responsive.dart';

class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });
  final String Function(S) label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

const kShellDestinations = [
  ShellDestination(
    label: LearnPage.title,
    icon: Icons.school_outlined,
    selectedIcon: Icons.school,
    page: LearnPage(),
  ),
  ShellDestination(
    label: ReferencePage.title,
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    page: ReferencePage(),
  ),
  ShellDestination(
    label: OfflineMePage.title,
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    page: OfflineMePage(),
  ),
];

/// Responsive root: bottom [NavigationBar] on compact widths, side
/// [NavigationRail] otherwise. See `responsive.dart` for the breakpoint.
///
/// Responsive navigation for the local learning profile.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  /// Keeps the page stack mounted when the layout class flips. Rotating a
  /// phone to landscape (or unfolding a foldable) crosses the 600 px
  /// breakpoint, which moves the body from `Scaffold.body` into the rail's
  /// `Row`; without a global key every tab's state (active exercise, scroll
  /// positions, reference/translator input) was thrown away on rotation.
  final GlobalKey _bodyKey = GlobalKey(debugLabel: 'shell-body');

  void _select(int index) {
    if (index < 0 || index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  /// Bottom-bar labels stay on one line: clamped like the AppBar title, and
  /// further down when a translation is still wider than its slot.
  double _barLabelScale(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final ThemeData theme = Theme.of(context);
    final double slot =
        (media.size.width - media.padding.horizontal) /
        kShellDestinations.length;
    return fitLabelsTextScale(
      context,
      labels: [for (final d in kShellDestinations) d.label(context.s)],
      style:
          (theme.navigationBarTheme.labelTextStyle?.resolve(const {
                    WidgetState.selected,
                  }) ??
                  theme.textTheme.labelMedium)
              ?.copyWith(fontWeight: FontWeight.w600),
      width: slot - 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final layout = layoutClassOf(context);
    final body = KeyedSubtree(
      key: _bodyKey,
      child: IndexedStack(
        index: _selectedIndex,
        children: [
          for (final (i, d) in kShellDestinations.indexed)
            TickerMode(enabled: i == _selectedIndex, child: d.page),
        ],
      ),
    );

    switch (layout) {
      case LayoutClass.compact:
        return Scaffold(
          // Sideways insets (a phone in landscape below the 600 px
          // breakpoint, a notched tablet) are the pages' to keep clear of.
          body: SafeArea(top: false, bottom: false, child: body),
          bottomNavigationBar: MediaQuery.withClampedTextScaling(
            maxScaleFactor: _barLabelScale(context),
            child: NavigationBar(
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
                      // Capped so a long language at large text wraps the
                      // label instead of widening the rail over the page.
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 96),
                        child: Text(d.label(s), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              // The rail already keeps clear of a leading notch; the pages
              // keep clear of the trailing one and must not inset again.
              // Read below the Scaffold (a Builder): the shell's own context
              // still has the keyboard inset the Scaffold body has consumed.
              Expanded(
                child: Builder(
                  builder: (inner) => MediaQuery.removePadding(
                    context: inner,
                    removeLeft: Directionality.of(inner) == TextDirection.ltr,
                    removeRight: Directionality.of(inner) == TextDirection.rtl,
                    child: SafeArea(top: false, bottom: false, child: body),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
