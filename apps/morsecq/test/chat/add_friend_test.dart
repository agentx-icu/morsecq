import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/chat/chat_strings.dart';
import 'package:morsecq/ui/contacts/add_friend_sheet.dart';
import 'package:morsecq/ui/contacts/contacts_page.dart';
import 'package:morsecq/ui/contacts/tox_id.dart';

import 'test_support.dart';

void main() {
  group('validateToxIdInput', () {
    test('accepts 76 hex chars, tolerates whitespace and tox: prefix', () {
      expect(validateToxIdInput(kPeerToxId), isNull);
      expect(validateToxIdInput(' tox:${kPeerToxId.toLowerCase()} '), isNull);
    });

    test('rejects wrong length, non-hex and own id', () {
      expect(validateToxIdInput(''), ChatStrings.toxIdInvalid);
      expect(validateToxIdInput('${'A' * 75}G'), ChatStrings.toxIdInvalid);
      expect(validateToxIdInput('A' * 75), ChatStrings.toxIdInvalid);
      expect(validateToxIdInput('A' * 77), ChatStrings.toxIdInvalid);
      expect(
        validateToxIdInput(kSelfToxId, ownToxId: kSelfToxId),
        ChatStrings.toxIdOwn,
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
    expect(find.text(ChatStrings.toxIdInvalid), findsOneWidget);
    await tester.tap(find.text(ChatStrings.sendRequest));
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
    // Desktop: the scan button is disabled and the hint is shown.
    expect(find.text(ChatStrings.scanQrDesktopHint), findsOneWidget);
    final IconButton scan = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.qr_code_scanner),
    );
    expect(scan.onPressed, isNull);

    await tester.enterText(
      find.byType(TextFormField).first,
      kPeerToxId.toLowerCase(),
    );
    await tester.pump();
    expect(find.text(ChatStrings.toxIdInvalid), findsNothing);
    await tester.tap(find.text(ChatStrings.sendRequest));
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
    await tester.tap(find.text(ChatStrings.sendRequest));
    await tester.pumpAndSettle();
    expect(find.text(ChatStrings.toxIdOwn), findsOneWidget);
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
    expect(find.text(ChatStrings.online), findsOneWidget);
    expect(find.text('CQ DE DAN'), findsOneWidget);
    await tester.tap(find.byTooltip(ChatStrings.accept));
    await tester.pumpAndSettle();
    expect(h.service.friendRequests, isEmpty);
    expect(h.service.friends, hasLength(2));
    expect(find.text('CQ DE DAN'), findsNothing);

    // My Tox ID sheet renders the identity's id.
    await tester.tap(find.byTooltip(ChatStrings.myToxId));
    await tester.pumpAndSettle();
    expect(find.text(kSelfToxId), findsOneWidget);
  });
}
