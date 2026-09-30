import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/chat/chat_layout.dart';
import 'package:morsecq/ui/chat/chat_strings.dart';
import 'package:morsecq/ui/chat/conversation_list.dart';
import 'package:morsecq/ui/chat/conversation_screen.dart';
import 'package:morsecq/ui/pages/chat_page.dart';
import 'package:morsecq/ui/pages/groups_page.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'test_support.dart';

void main() {
  test('master-detail breakpoint is 900 logical pixels', () {
    expect(isMasterDetailWidth(899), isFalse);
    expect(isMasterDetailWidth(900), isTrue);
    expect(isMasterDetailWidth(kMasterDetailMinWidth), isTrue);
  });

  testWidgets('1280 px: list and conversation side by side', (tester) async {
    await pumpChat(tester, (h) {
      h.addAnn();
      return const ChatPage();
    }, size: kDesktop);
    expect(find.byType(MasterDetail), findsOneWidget);
    expect(find.text(ChatStrings.selectConversation), findsOneWidget);
    expect(find.byType(ConversationScreen), findsNothing);

    await tester.tap(find.text('Ann').first);
    await tester.pumpAndSettle();

    // Both panes are on screen and no route was pushed.
    expect(find.byType(ConversationList), findsOneWidget);
    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    expect(find.text(ChatStrings.selectConversation), findsNothing);
    // The list keeps the open row highlighted.
    final ListTile tile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text('Ann').first,
        matching: find.byType(ListTile),
      ),
    );
    expect(tile.selected, isTrue);
  });

  testWidgets('390 px: tapping pushes the conversation as a route', (
    tester,
  ) async {
    await pumpChat(tester, (h) {
      h.addAnn();
      return const ChatPage();
    }, size: kPhone);
    expect(find.byType(MasterDetail), findsNothing);
    await tester.tap(find.text('Ann'));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(find.byType(ConversationList), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationList), findsOneWidget);
  });

  testWidgets('contacts opens from the app bar and starts a chat inline', (
    tester,
  ) async {
    await pumpChat(tester, (h) {
      h.addAnn(withMessage: false);
      h.service.receiveFriendRequest('D' * 64);
      return const ChatPage();
    }, size: kDesktop);
    expect(find.text(ChatPage.description), findsOneWidget); // empty state
    expect(find.text('1'), findsOneWidget); // requests badge
    await tester.tap(find.byTooltip(ChatStrings.contacts));
    await tester.pumpAndSettle();
    expect(find.text('${ChatStrings.friendRequests} (1)'), findsOneWidget);
    await tester.tap(find.text('Ann'));
    await tester.pumpAndSettle();
    // Back on the chat page, Ann is open in the detail pane.
    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(find.byType(MasterDetail), findsOneWidget);
  });

  testWidgets('groups page uses the same two-pane rule', (tester) async {
    await pumpChat(tester, (h) {
      h.service.addFakeGroup(
        const Group(id: 'tox_1', name: 'Net', kind: GroupKind.group),
      );
      return const GroupsPage();
    }, size: kDesktop);
    expect(find.byType(MasterDetail), findsOneWidget);
    await tester.tap(find.text('Net').first);
    await tester.pumpAndSettle();
    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('without providers the pages fall back to the placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ChatPage()));
    expect(find.text(ChatPage.description), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(home: GroupsPage()));
    expect(find.text(GroupsPage.description), findsOneWidget);
  });
}
