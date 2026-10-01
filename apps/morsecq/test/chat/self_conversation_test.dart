import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/chat/conversation_screen.dart';
import 'package:morsecq/ui/chat/conversation_target.dart';
import 'package:morsecq/ui/chat/message_bubble.dart';
import 'package:morsecq/ui/chat/self_badge.dart';
import 'package:morsecq/ui/contacts/contacts_page.dart';
import 'package:morsecq/ui/pages/chat_page.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'test_support.dart';

/// The default "me" contact: the note-to-self conversation. Every scenario
/// runs at phone and desktop width (mobile parity).
final StubIdentityService _zoe = StubIdentityService(
  identity: Identity(toxId: kSelfToxId, displayName: 'Zoe'),
);

ChatHarness _harness() => ChatHarness(
  service: FakeChatService(
    identity: _zoe,
    clock: () => DateTime(2026, 10, 1, 9),
  ),
);

final Finder _selfTile = find.byKey(const ValueKey<String>('contacts_self'));

Future<void> _send(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.byTooltip(s.chatSend));
  await tester.pumpAndSettle();
}

void main() {
  for (final (String label, Size size) in <(String, Size)>[
    ('phone', kPhone),
    ('desktop', kDesktop),
  ]) {
    group('at $label width', () {
      testWidgets('Contacts lists "me" first, with the own name', (
        tester,
      ) async {
        ConversationTarget? opened;
        await pumpChat(
          tester,
          (h) {
            h.addAnn(withMessage: false);
            return ContactsPage(
              service: h.service,
              identity: _zoe,
              onOpenConversation: (t) => opened = t,
              canScan: false,
            );
          },
          size: size,
          harness: _harness(),
        );
        expect(_selfTile, findsOneWidget);
        expect(
          find.descendant(of: _selfTile, matching: find.text('Zoe')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: _selfTile, matching: find.byType(SelfBadge)),
          findsOneWidget,
        );
        expect(find.text(s.chatSelfContactSubtitle), findsOneWidget);
        // Above the friends; not a friend (no remove menu, not counted).
        expect(
          tester.getTopLeft(_selfTile).dy,
          lessThan(tester.getTopLeft(find.text('Ann')).dy),
        );
        expect(
          find.descendant(
            of: _selfTile,
            matching: find.byType(PopupMenuButton<String>),
          ),
          findsNothing,
        );
        expect(find.text(s.chatFriendsCount(1)), findsOneWidget);

        await tester.tap(_selfTile);
        expect(opened?.id, 'c2c_$kSelfKey');
        expect(opened?.isSelf, isTrue);
        expect(opened?.title, 'Zoe');
      });

      testWidgets('notes to self are delivered at once and stay local', (
        tester,
      ) async {
        final ChatHarness h = await pumpChat(
          tester,
          (h) => ConversationScreen(
            target: ConversationTarget.self(id: 'c2c_$kSelfKey', title: 'Zoe'),
          ),
          size: size,
          harness: _harness(),
        );
        expect(find.text(s.chatSelfLocalOnly), findsOneWidget);
        expect(find.text(s.connectionOffline), findsNothing);
        expect(find.text(s.connectionOnline), findsNothing);

        await _send(tester, 'CQ TEST');
        expect(find.byType(MessageBubble), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsNothing, reason: 'no queue');
        final Conversation self = h.service.conversations.singleWhere(
          (c) => c.isSelf,
        );
        expect(self.lastMessage?.text, 'CQ TEST');
        expect(self.lastMessage?.status, MessageStatus.sent);
      });

      testWidgets('the conversation list shows it with the "me" badge', (
        tester,
      ) async {
        await pumpChat(
          tester,
          (h) => const ChatPage(),
          size: size,
          harness: _harness(),
        );
        expect(find.text('Zoe'), findsOneWidget);
        expect(find.byType(SelfBadge), findsOneWidget);
        expect(find.byType(SelfAvatar), findsOneWidget);
        expect(find.text(ChatPage.description(s)), findsNothing);
      });
    });
  }

  testWidgets('no identity, no "me" contact', (tester) async {
    await pumpChat(
      tester,
      (h) => ContactsPage(
        service: h.service, // the default harness fake has no identity
        identity: null,
        onOpenConversation: (_) {},
        canScan: false,
      ),
    );
    expect(_selfTile, findsNothing);
  });

  testWidgets('a nameless profile falls back to "Me"', (tester) async {
    final StubIdentityService nameless = StubIdentityService(
      identity: Identity(toxId: kSelfToxId, displayName: ''),
    );
    await pumpChat(
      tester,
      (h) => ContactsPage(
        service: h.service,
        identity: nameless,
        onOpenConversation: (_) {},
        canScan: false,
      ),
      harness: ChatHarness(service: FakeChatService(identity: nameless)),
    );
    expect(
      find.descendant(of: _selfTile, matching: find.text(s.chatSelfMe)),
      findsNWidgets(2), // the title fallback and the badge
    );
  });
}
