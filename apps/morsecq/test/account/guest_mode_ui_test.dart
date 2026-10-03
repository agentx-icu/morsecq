import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/account/welcome_page.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'support/memory_guest_store.dart';
import 'test_app.dart';

final S en = lookupS(const Locale('en'));

void main() {
  testWidgets('try learning first opens Learn without any identity', (
    tester,
  ) async {
    final identity = freshIdentityService();
    final guest = MemoryGuestStore();
    await pumpApp(tester, identity: identity, guestStore: guest);
    expect(find.byType(WelcomePage), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('try-learning-first')));
    await settle(tester);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(LearnHome), findsOneWidget);
    expect(find.text(en.guestBanner), findsOneWidget);
    expect(guest.active, isTrue);
    expect(guest.controllersOpened, 1);
    // No identity, no connection attempt.
    expect(identity.current, isNull);
    expect(identity.connectionStatus, ConnectionStatus.offline);

    // Chat asks for an identity instead of showing a fake chat.
    await tester.tap(find.text(en.navChat).last);
    await settle(tester);
    expect(find.text(en.guestIdentityBody), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('guest-get-identity')));
    await settle(tester);
    expect(find.byType(WelcomePage), findsOneWidget);
    expect(guest.active, isFalse);
  });

  testWidgets('guest mode resumes on the next launch', (tester) async {
    final guest = MemoryGuestStore()..active = true;
    await pumpApp(tester, identity: freshIdentityService(), guestStore: guest);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text(en.guestBanner), findsOneWidget);
  });

  testWidgets('the guest Me page offers identity setup and clearing', (
    tester,
  ) async {
    final guest = MemoryGuestStore()
      ..active = true
      ..progress = true;
    await pumpApp(tester, identity: freshIdentityService(), guestStore: guest);
    await tester.tap(find.text(en.navMe).last);
    await settle(tester);
    expect(find.byKey(const ValueKey('guest-get-identity')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('guest-clear')));
    await settle(tester);
    await tester.tap(find.text(en.guestClearConfirm));
    await settle(tester);
    expect(guest.progress, isFalse);
    expect(find.text(en.guestCleared), findsOneWidget);
  });
}
