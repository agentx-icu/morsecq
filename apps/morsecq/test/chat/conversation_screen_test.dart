import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/chat/chat_strings.dart';
import 'package:morsecq/ui/chat/conversation_screen.dart';
import 'package:morsecq/ui/chat/conversation_target.dart';
import 'package:morsecq/ui/chat/message_bubble.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'test_support.dart';

ConversationTarget _ann() => ConversationTarget(
  id: 'c2c_$kPeerKey',
  title: 'Ann',
  kind: ConversationKind.c2c,
);

Future<void> _send(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.byTooltip(ChatStrings.send));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sending to an offline peer appends a pending bubble', (
    tester,
  ) async {
    final ChatHarness h = await pumpChat(tester, (h) {
      h.addAnn(withMessage: false);
      return ConversationScreen(target: _ann());
    });
    expect(find.text(ChatStrings.noMessages), findsOneWidget);
    expect(find.text(ChatStrings.offline), findsOneWidget);

    await _send(tester, 'CQ');
    expect(find.byType(MessageBubble), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.text('-.-. --.-'), findsOneWidget);
    expect(
      h.service.conversations.single.lastMessage?.status,
      MessageStatus.pending,
    );

    // Peer comes online: the status event flips the glyph to sent.
    h.service.setFriendOnline(kPeerKey, true);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.schedule), findsNothing);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text(ChatStrings.online), findsOneWidget);
  });

  testWidgets('sending to an online peer appends a sent bubble', (
    tester,
  ) async {
    await pumpChat(tester, (h) {
      h.addAnn(online: true, withMessage: false);
      return ConversationScreen(target: _ann());
    });
    await _send(tester, 'K');
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsNothing);
    // Draft field is cleared and the byte counter is back to the budget.
    expect(find.text('1322 ${ChatStrings.bytesLeft}'), findsOneWidget);
  });

  testWidgets('training mode hides inbound text until revealed', (
    tester,
  ) async {
    final ChatHarness h = await pumpChat(tester, (h) {
      h.addAnn();
      return ConversationScreen(target: _ann());
    });
    expect(find.text('CQ CQ DE ANN'), findsOneWidget);

    await tester.tap(find.byTooltip(ChatStrings.trainingMode));
    await tester.pumpAndSettle();
    expect(h.settings.trainingMode, isTrue);
    expect(find.text('CQ CQ DE ANN'), findsNothing);
    expect(find.text(ChatStrings.hiddenText), findsOneWidget);
    // The pattern layer stays visible so the listener can follow along.
    expect(
      find.text('-.-. --.- / -.-. --.- / -.. . / .- -. -.'),
      findsOneWidget,
    );

    await tester.tap(find.text(ChatStrings.reveal));
    await tester.pumpAndSettle();
    expect(find.text('CQ CQ DE ANN'), findsOneWidget);

    // A new inbound message is hidden again; revealed state is per message.
    h.service.receiveMessage('c2c_$kPeerKey', 'R');
    await tester.pumpAndSettle();
    expect(find.text(ChatStrings.hiddenText), findsOneWidget);
    expect(find.text('CQ CQ DE ANN'), findsOneWidget);
  });

  testWidgets('play toggles the controller and highlights marks', (
    tester,
  ) async {
    final ChatHarness h = await pumpChat(tester, (h) {
      h.addAnn();
      return ConversationScreen(target: _ann());
    });
    await tester.tap(find.byTooltip(ChatStrings.play));
    await tester.pumpAndSettle();
    expect(h.playback.playingId, 'msg_1');
    expect(find.byTooltip(ChatStrings.stop), findsOneWidget);
    await tester.tap(find.byTooltip(ChatStrings.stop));
    await tester.pumpAndSettle();
    expect(h.playback.playingId, isNull);
  });

  testWidgets('opening marks the conversation read and restores the draft', (
    tester,
  ) async {
    final ChatHarness h = ChatHarness();
    h.addAnn();
    await h.service.setDraft('c2c_$kPeerKey', 'CQ DE');
    expect(h.service.conversations.single.unreadCount, 1);
    await pumpChat(
      tester,
      (_) => ConversationScreen(target: _ann()),
      harness: h,
    );
    expect(h.service.conversations.single.unreadCount, 0);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'CQ DE',
    );
    expect(find.text('1317 ${ChatStrings.bytesLeft}'), findsOneWidget);
  });

  testWidgets('over-budget draft disables send and shows the error', (
    tester,
  ) async {
    final ChatHarness h = ChatHarness(
      service: FakeChatService(selfPublicKey: kSelfKey, maxMessageBytes: 3),
    );
    await pumpChat(tester, (h) {
      h.addAnn(withMessage: false);
      return ConversationScreen(target: _ann());
    }, harness: h);
    await tester.enterText(find.byType(TextField), 'ABCD');
    await tester.pump();
    expect(find.text(ChatStrings.tooLong), findsOneWidget);
    expect(find.text('-1 ${ChatStrings.bytesLeft}'), findsOneWidget);
    await tester.tap(find.byTooltip(ChatStrings.send));
    await tester.pumpAndSettle();
    expect(find.byType(MessageBubble), findsNothing);
  });

  testWidgets('switching to the straight key shows the pad and the hint', (
    tester,
  ) async {
    await pumpChat(tester, (h) {
      h.addAnn(withMessage: false);
      return ConversationScreen(target: _ann());
    });
    await tester.tap(find.byTooltip(ChatStrings.modeStraightKey));
    await tester.pumpAndSettle();
    expect(find.text('KEY'), findsOneWidget);
    expect(find.text(ChatStrings.keyHint), findsOneWidget);
    await tester.tap(find.byTooltip(ChatStrings.modePaddles));
    await tester.pumpAndSettle();
    expect(find.text('DIT'), findsOneWidget);
    expect(find.text('DAH'), findsOneWidget);
    await tester.tap(find.byTooltip(ChatStrings.modeKeyboard));
    await tester.pumpAndSettle();
    expect(find.text('DIT'), findsNothing);
  });
}
