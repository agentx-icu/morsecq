import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/contacts/add_friend_sheet.dart';
import 'package:morsecq/ui/contacts/contacts_page.dart';
import 'package:morsecq/ui/contacts/tox_id.dart';

import 'test_support.dart';

void main() {
  group('validateToxId', () {
    test('accepts 76 hex chars, tolerates whitespace and tox: prefix', () {
      expect(validateToxId(kPeerToxId), isNull);
      expect(validateToxId(' tox:${kPeerToxId.toLowerCase()} '), isNull);
      expect(validateToxIdInput(s, kPeerToxId), isNull);
    });

    test('rejects wrong length, non-hex and own id', () {
      expect(validateToxId(''), ToxIdError.invalid);
      expect(validateToxId('${'A' * 75}G'), ToxIdError.invalid);
      expect(validateToxId('A' * 75), ToxIdError.invalid);
      expect(validateToxId('A' * 77), ToxIdError.invalid);
      expect(validateToxId(kSelfToxId, ownToxId: kSelfToxId), ToxIdError.own);
    });

    test('the form validator renders the codes in the given locale', () {
      expect(validateToxIdInput(s, 'A' * 75), s.chatToxIdInvalid);
      expect(
        validateToxIdInput(s, kSelfToxId, ownToxId: kSelfToxId),
        s.chatToxIdOwn,
      );
    });
  });

  testWidgets('invalid id shows the error and does not call the service', (
    tester,
  ) async {
    final ChatHarness h = await pumpChat(
      tester,
      (h) => Scaffold(body: AddFriendForm(service: h.service)),
    );
    await tester.enterText(find.byType(TextFormField).first, 'not-a-tox-id');
    await tester.pump();
    expect(find.text(s.chatToxIdInvalid), findsOneWidget);
    await tester.tap(find.text(s.chatSendRequest));
    await tester.pumpAndSettle();
    expect(h.service.outgoingFriendRequests, isEmpty);
  });

  testWidgets('valid id sends the request through the service', (tester) async {
    final ChatHarness h = await pumpChat(
      tester,
      (h) => Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showAddFriendSheet(
                context,
                service: h.service,
                canScan: false,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    // Desktop: no scan button (a disabled one carried a tooltip that tripped
    // a semantics assertion while the sheet dismissed); the hint explains.
    expect(find.text(s.chatScanQrDesktopHint), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsNothing);
    // The greeting defaults to the localized "morsecq CQ".
    expect(find.text(s.chatDefaultRequestMessage), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      kPeerToxId.toLowerCase(),
    );
    await tester.pump();
    expect(find.text(s.chatToxIdInvalid), findsNothing);
    await tester.tap(find.text(s.chatSendRequest));
    await tester.pumpAndSettle();
    expect(h.service.outgoingFriendRequests, [kPeerToxId]);
    expect(h.service.friends.single.publicKey, kPeerToxId.substring(0, 64));
    expect(find.byType(AddFriendForm), findsNothing); // sheet closed
  });

  testWidgets('adding yourself is refused by the backend and surfaced', (
    tester,
  ) async {
    final ChatHarness h = await pumpChat(
      tester,
      (h) => Scaffold(body: AddFriendForm(service: h.service)),
    );
    await tester.enterText(find.byType(TextFormField).first, kSelfToxId);
    await tester.tap(find.text(s.chatSendRequest));
    await tester.pumpAndSettle();
    expect(find.text(s.chatToxIdOwn), findsOneWidget);
    expect(h.service.friends, isEmpty);
  });

  testWidgets('contacts page lists friends with requests and accepts one', (
    tester,
  ) async {
    final ChatHarness h = await pumpChat(tester, (h) {
      h.addAnn(online: true, withMessage: false);
      h.service.receiveFriendRequest('D' * 64, message: 'CQ DE DAN');
      return ContactsPage(
        service: h.service,
        identity: h.identity,
        onOpenConversation: (_) {},
        canScan: false,
      );
    });
    expect(find.text('Ann'), findsOneWidget);
    expect(find.text(s.connectionOnline), findsOneWidget);
    expect(find.text(s.chatFriendsCount(1)), findsOneWidget);
    expect(find.text('CQ DE DAN'), findsOneWidget);
    await tester.tap(find.byTooltip(s.chatAccept));
    await tester.pumpAndSettle();
    expect(h.service.friendRequests, isEmpty);
    expect(h.service.friends, hasLength(2));
    expect(find.text('CQ DE DAN'), findsNothing);

    // My Tox ID sheet renders the identity's id.
    await tester.tap(find.byTooltip(s.chatMyToxId));
    await tester.pumpAndSettle();
    expect(find.text(kSelfToxId), findsOneWidget);
  });
}
