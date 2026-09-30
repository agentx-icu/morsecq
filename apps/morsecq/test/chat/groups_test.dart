import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/chat/chat_strings.dart';
import 'package:morsecq/ui/chat/conversation_screen.dart';
import 'package:morsecq/ui/chat/conversation_target.dart';
import 'package:morsecq/ui/pages/groups_page.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'test_support.dart';

void main() {
  testWidgets('create group flow: NGC by default, opens the conversation', (
    tester,
  ) async {
    final ChatHarness h = await pumpChat(
      tester,
      (_) => const GroupsPage(),
      size: kPhone,
    );
    expect(find.text(ChatStrings.noGroups), findsOneWidget);

    await tester.tap(find.byTooltip(ChatStrings.createGroup));
    await tester.pumpAndSettle();
    // Advanced toggle is collapsed by default.
    expect(find.text(ChatStrings.legacyConference), findsNothing);
    await tester.tap(find.text(ChatStrings.advanced));
    await tester.pumpAndSettle();
    expect(find.text(ChatStrings.legacyConference), findsOneWidget);

    await tester.tap(find.text(ChatStrings.create));
    await tester.pumpAndSettle();
    expect(find.text(ChatStrings.groupNameRequired), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Net 40m');
    await tester.tap(find.text(ChatStrings.create));
    await tester.pumpAndSettle();

    final Group g = h.service.groups.single;
    expect(g.name, 'Net 40m');
    expect(g.kind, GroupKind.group);
    expect(g.chatId, hasLength(64));
    // Phone: the group conversation was pushed.
    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(find.text(ChatStrings.conferenceNote), findsNothing);
    expect(find.text('1 ${ChatStrings.membersCount}'), findsOneWidget);
  });

  testWidgets('legacy conference shows the metadata note', (tester) async {
    await pumpChat(tester, (h) {
      final Group g = h.service.addFakeGroup(
        const Group(id: 'tox_9', name: 'Old net', kind: GroupKind.conference),
      );
      return ConversationScreen(target: ConversationTarget.fromGroup(g));
    });
    expect(find.text(ChatStrings.conferenceNote), findsOneWidget);
    expect(find.textContaining(ChatStrings.conferenceBadge), findsOneWidget);
  });

  testWidgets('join by chat id validates then joins', (tester) async {
    final ChatHarness h = await pumpChat(
      tester,
      (_) => const GroupsPage(),
      size: kPhone,
    );
    await tester.tap(find.byTooltip(ChatStrings.joinGroup));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'abc');
    await tester.pump();
    expect(find.text(ChatStrings.chatIdInvalid), findsOneWidget);
    await tester.tap(find.text(ChatStrings.join));
    await tester.pumpAndSettle();
    expect(h.service.groups, isEmpty);

    await tester.enterText(find.byType(TextFormField).first, 'c' * 64);
    await tester.pump();
    await tester.tap(find.text(ChatStrings.join));
    await tester.pumpAndSettle();
    expect(h.service.groups.single.chatId, 'C' * 64);
    expect(find.text(ChatStrings.joinRequested), findsOneWidget);
    expect(find.text('Group CCCCCCCC'), findsOneWidget);
  });

  testWidgets('invites inbox accepts an invite and lists the group', (
    tester,
  ) async {
    final ChatHarness h = await pumpChat(tester, (h) {
      h.service.receiveGroupInvite(fromPublicKey: kPeerKey, groupName: 'DX');
      return const GroupsPage();
    });
    expect(find.text('DX'), findsOneWidget);
    expect(find.textContaining(ChatStrings.invitedBy), findsOneWidget);
    await tester.tap(find.byTooltip(ChatStrings.accept));
    await tester.pumpAndSettle();
    expect(h.service.groupInvites, isEmpty);
    expect(h.service.groups.single.name, 'DX');
    expect(find.text('DX'), findsOneWidget);
    expect(find.textContaining(ChatStrings.invitedBy), findsNothing);
  });

  testWidgets('leave from the conversation menu pops and removes the group', (
    tester,
  ) async {
    final ChatHarness h = await pumpChat(tester, (h) {
      h.service.addFakeGroup(
        const Group(id: 'tox_1', name: 'Net', kind: GroupKind.group),
      );
      return const GroupsPage();
    }, size: kPhone);
    await tester.tap(find.text('Net'));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationScreen), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(ChatStrings.leaveGroup));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ChatStrings.leave));
    await tester.pumpAndSettle();

    expect(h.service.groups, isEmpty);
    expect(find.byType(ConversationScreen), findsNothing);
    expect(find.text(ChatStrings.noGroups), findsOneWidget);
  });

  testWidgets('group messages show the sender and send as sent', (
    tester,
  ) async {
    await pumpChat(tester, (h) {
      final Group g = h.service.addFakeGroup(
        const Group(id: 'tox_1', name: 'Net', kind: GroupKind.group),
      );
      h.service.receiveMessage(
        'group_${g.id}',
        'CQ NET',
        senderId: kPeerKey,
        senderName: 'Ann',
      );
      return ConversationScreen(target: ConversationTarget.fromGroup(g));
    });
    expect(find.text('Ann'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'K');
    await tester.pump();
    await tester.tap(find.byTooltip(ChatStrings.send));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
