import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/startup/startup_controller.dart';
import 'package:morsecq/startup/startup_screens.dart';
import 'package:morsecq/ui/account/account_strings.dart';
import 'package:morsecq/ui/account/connection_chip.dart';
import 'package:morsecq/ui/account/unlock_page.dart';
import 'package:morsecq/ui/account/welcome_page.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'test_app.dart';

void main() {
  testWidgets('IdentityState.none routes to the welcome page', (tester) async {
    await pumpApp(tester, identity: freshIdentityService());
    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
    expect(find.text(AccountStrings.createIdentity), findsOneWidget);
    expect(find.text(AccountStrings.restoreFromBackup), findsOneWidget);
  });

  testWidgets('IdentityState.locked routes to the unlock page', (tester) async {
    await pumpApp(tester, identity: seededIdentityService(password: 'pw'));
    expect(find.byType(UnlockPage), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('IdentityState.ready opens, shows the shell and connects', (
    tester,
  ) async {
    final identity = seededIdentityService();
    await pumpApp(tester, identity: identity);
    expect(find.byType(AppShell), findsOneWidget);
    expect(identity.current, isNotNull);
    expect(identity.connectionStatus, ConnectionStatus.online);
    // Online → the overlay chip is hidden; the shell is unobstructed.
    expect(find.text(AccountStrings.connectionConnecting), findsNothing);
    expect(find.text(AccountStrings.connectionOffline), findsNothing);
  });

  testWidgets('connection does not block the shell; chip shows meanwhile', (
    tester,
  ) async {
    final identity = seededIdentityService(
      connectDelay: const Duration(seconds: 2),
    );
    await pumpApp(tester, identity: identity);
    expect(find.byType(AppShell), findsOneWidget);
    expect(identity.connectionStatus, ConnectionStatus.connecting);
    expect(find.byType(ConnectionChip), findsWidgets);
    expect(find.text(AccountStrings.connectionConnecting), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    expect(identity.connectionStatus, ConnectionStatus.online);
    expect(find.text(AccountStrings.connectionConnecting), findsNothing);
  });

  testWidgets('inspect failure shows the retry screen; retry recovers', (
    tester,
  ) async {
    final identity = seededIdentityService()
      ..inspectError = StateError('disk unreadable');
    await pumpApp(tester, identity: identity);
    expect(find.byType(StartupErrorPage), findsOneWidget);
    expect(find.textContaining('disk unreadable'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);

    await tester.tap(find.text(AccountStrings.retry));
    await settle(tester);
    expect(find.byType(AppShell), findsOneWidget);
  });

  test('StartupController.describeError prefers ChatException messages', () {
    expect(
      StartupController.describeError(
        const ChatException('wrong_password', 'Wrong password.'),
      ),
      'Wrong password.',
    );
    expect(StartupController.describeError(StateError('x')), contains('x'));
  });

  testWidgets('deleting the identity returns to onboarding', (tester) async {
    final identity = seededIdentityService();
    await pumpApp(tester, identity: identity);
    expect(find.byType(AppShell), findsOneWidget);
    await identity.deleteIdentity();
    await settle(tester);
    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
