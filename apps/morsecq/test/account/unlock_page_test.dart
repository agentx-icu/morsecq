import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/account/account_strings.dart';
import 'package:morsecq/ui/account/restore_backup_page.dart';
import 'package:morsecq/ui/account/unlock_page.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'test_app.dart';

void main() {
  testWidgets('wrong password shows an error and stays locked', (tester) async {
    final identity = seededIdentityService(password: 'secret');
    await pumpApp(tester, identity: identity);
    expect(find.byType(UnlockPage), findsOneWidget);
    expect(buttonEnabled(tester, AccountStrings.unlockButton), isFalse);

    await tester.enterText(find.byType(TextField), 'nope');
    await settle(tester);
    expect(buttonEnabled(tester, AccountStrings.unlockButton), isTrue);
    await tester.tap(find.text(AccountStrings.unlockButton));
    await settle(tester);

    expect(find.text(AccountStrings.wrongPassword), findsOneWidget);
    expect(find.byType(UnlockPage), findsOneWidget);
    expect(identity.current, isNull);
    expect(await identity.inspect(), IdentityState.locked);
  });

  testWidgets('correct password unlocks into the shell', (tester) async {
    final identity = seededIdentityService(password: 'secret');
    await pumpApp(tester, identity: identity);
    await tester.enterText(find.byType(TextField), 'secret');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.byType(AppShell), findsOneWidget);
    expect(identity.current?.displayName, 'Ann');
    expect(identity.connectionStatus, ConnectionStatus.online);
  });

  testWidgets('show/hide toggles obscuring', (tester) async {
    await pumpApp(tester, identity: seededIdentityService(password: 'x'));
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, true);
    await tester.tap(find.byTooltip(AccountStrings.showPassword));
    await settle(tester);
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, false);
  });

  testWidgets('"restore from backup instead" opens the restore page', (
    tester,
  ) async {
    await pumpApp(tester, identity: seededIdentityService(password: 'x'));
    await tester.tap(find.text(AccountStrings.unlockRestoreInstead));
    await settle(tester);
    expect(find.byType(RestoreBackupPage), findsOneWidget);
  });
}
