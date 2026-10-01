import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/account/connection_chip.dart';
import 'package:morsecq/ui/chat/conversation_screen.dart';
import 'package:morsecq/ui/chat/self_badge.dart';
import 'package:morsecq/ui/contacts/contacts_page.dart';
import 'package:morsecq/ui/pages/chat_page.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'test_app.dart';

final S en = lookupS(const Locale('en'));

/// While the node is not online, the connection chip used to float over the
/// shell's top-right corner — exactly where every page's app-bar action
/// lives — and swallowed taps meant for it (the Chat page's Contacts button
/// could not be opened while "Connecting…", or at all while offline). The
/// chip now sits in its own strip above the shell.
void main() {
  for (final (String label, Size size) in <(String, Size)>[
    ('phone', kPhoneSize),
    ('desktop', kDesktopSize),
  ]) {
    testWidgets('$label: Contacts opens while still connecting', (
      tester,
    ) async {
      final identity = seededIdentityService(
        connectDelay: const Duration(seconds: 30),
      );
      await pumpApp(tester, identity: identity, size: size);
      expect(identity.connectionStatus, ConnectionStatus.connecting);
      expect(find.text(en.connectionConnecting), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is NavigationBar || w is NavigationRail,
          ),
          matching: find.byIcon(Icons.chat_bubble_outline),
        ),
      );
      await settle(tester);
      expect(find.byType(ChatPage), findsOneWidget);

      final Finder contacts = find.byTooltip(en.chatContacts);
      expect(
        contacts.hitTestable(),
        findsOneWidget,
        reason: 'nothing may cover the app-bar action',
      );
      await tester.tap(contacts);
      await settle(tester);
      expect(find.byType(ContactsPage), findsOneWidget);

      await tester.pump(const Duration(seconds: 31));
      await settle(tester);
    });
  }

  testWidgets('desktop: the detail pane menu is reachable while connecting', (
    tester,
  ) async {
    final identity = seededIdentityService(
      connectDelay: const Duration(seconds: 30),
    );
    await pumpApp(tester, identity: identity, size: kDesktopSize);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byIcon(Icons.chat_bubble_outline),
      ),
    );
    await settle(tester);
    // The note-to-self row is always there; it opens in the detail pane.
    await tester.tap(find.byType(SelfAvatar));
    await settle(tester);
    expect(find.byType(ConversationScreen), findsOneWidget);
    final Finder menu = find.descendant(
      of: find.byType(ConversationScreen),
      matching: find.byType(PopupMenuButton<String>),
    );
    expect(menu.hitTestable(), findsOneWidget);
    await tester.tap(menu);
    await settle(tester);
    expect(find.text(en.chatClearHistory), findsOneWidget);
    await tester.pump(const Duration(seconds: 31));
    await settle(tester);
  });

  testWidgets('the shell keeps its state when the node comes online', (
    tester,
  ) async {
    final identity = seededIdentityService(
      connectDelay: const Duration(seconds: 2),
    );
    await pumpApp(tester, identity: identity);
    final Finder groupsTab = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.groups_outlined),
    );
    await tester.tap(groupsTab);
    await settle(tester);
    final State shellState = tester.state(find.byType(AppShell));
    expect(find.byType(ConnectionChip), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    expect(identity.connectionStatus, ConnectionStatus.online);
    expect(find.byType(ConnectionChip), findsNothing);
    expect(
      identical(tester.state(find.byType(AppShell)), shellState),
      isTrue,
      reason: 'the shell must not be remounted',
    );
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
    // Online: the shell gets the full top inset back (no strip).
    expect(tester.getTopLeft(find.byType(AppShell)).dy, 0);
  });

  testWidgets('the chip strip does not overlap the shell', (tester) async {
    final identity = seededIdentityService(
      connectDelay: const Duration(seconds: 30),
    );
    await pumpApp(tester, identity: identity);
    final Rect chip = tester.getRect(find.byType(ConnectionChip));
    final Rect appBar = tester.getRect(find.byType(AppBar).first);
    expect(chip.overlaps(appBar), isFalse);
    await tester.pump(const Duration(seconds: 31));
    await settle(tester);
  });
}
