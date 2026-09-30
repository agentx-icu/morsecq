import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/account/account_strings.dart';
import 'package:morsecq/ui/account/backup_file_gateway.dart';
import 'package:morsecq/ui/account/change_password_page.dart';
import 'package:morsecq/ui/account/delete_identity_dialog.dart';
import 'package:morsecq/ui/account/edit_profile_page.dart';
import 'package:morsecq/ui/account/identity_card.dart';
import 'package:morsecq/ui/account/welcome_page.dart';
import 'package:morsecq/ui/pages/me_page.dart';
import 'package:morsecq_chat_api/testing.dart';

import 'test_app.dart';

Future<void> _openMe(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(MePage.title),
    ),
  );
  await settle(tester);
  expect(find.byType(IdentityCard), findsOneWidget);
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await settle(tester);
}

void main() {
  late FakeIdentityService identity;
  late FakeBackupFileGateway files;

  setUp(() {
    identity = seededIdentityService();
    files = FakeBackupFileGateway();
  });

  testWidgets('identity card shows name, status and copies the Tox ID', (
    tester,
  ) async {
    final clipboard = ClipboardSpy(tester);
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openMe(tester);

    expect(find.text('Ann'), findsOneWidget);
    expect(find.text('QRV on 40m'), findsOneWidget);
    expect(find.text(AccountStrings.connectionOnline), findsOneWidget);

    await tester.tap(find.byTooltip(AccountStrings.copy));
    await settle(tester);
    expect(clipboard.copied, [identity.current!.toxId]);
    expect(find.text(AccountStrings.copied), findsOneWidget);
  });

  testWidgets('export backup saves through the gateway', (tester) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openMe(tester);
    await _scrollTo(tester, find.text(AccountStrings.exportBackup));
    await tester.tap(find.text(AccountStrings.exportBackup));
    await settle(tester);
    expect(files.saved, hasLength(1));
    expect(find.text(AccountStrings.backupSaved), findsOneWidget);
  });

  testWidgets('edit profile updates the card', (tester) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openMe(tester);
    await tester.tap(find.text(AccountStrings.editProfile));
    await settle(tester);
    expect(find.byType(EditProfilePage), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, AccountStrings.displayName),
      'Bob',
    );
    await tester.tap(find.text(AccountStrings.save));
    await settle(tester);
    expect(find.byType(EditProfilePage), findsNothing);
    expect(identity.current?.displayName, 'Bob');
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('set password then the tile reads "Change password"', (
    tester,
  ) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openMe(tester);
    await tester.tap(find.text(AccountStrings.setPassword));
    await settle(tester);
    expect(find.byType(ChangePasswordPage), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, AccountStrings.newPassword),
      'longer password 1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, AccountStrings.confirmPassword),
      'longer password 1',
    );
    await tester.tap(find.text(AccountStrings.save));
    await settle(tester);
    expect(identity.storedPassword, 'longer password 1');
    expect(find.text(AccountStrings.changePassword), findsOneWidget);
  });

  testWidgets('training defaults tile navigates to /settings/training', (
    tester,
  ) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openMe(tester);
    await _scrollTo(tester, find.text(AccountStrings.trainingDefaults));
    await tester.tap(find.text(AccountStrings.trainingDefaults));
    await settle(tester);
    expect(
      find.text(AccountStrings.trainingDefaultsPlaceholder),
      findsOneWidget,
    );
  });

  testWidgets('delete requires typing DELETE; cancel keeps the identity', (
    tester,
  ) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openMe(tester);
    await _scrollTo(tester, find.text(AccountStrings.deleteIdentity));
    await tester.tap(find.text(AccountStrings.deleteIdentity));
    await settle(tester);
    expect(find.byType(DeleteIdentityDialog), findsOneWidget);
    expect(buttonEnabled(tester, AccountStrings.deleteButton), isFalse);

    await tester.enterText(
      find.descendant(
        of: find.byType(DeleteIdentityDialog),
        matching: find.byType(TextField),
      ),
      'delete',
    );
    await settle(tester);
    expect(buttonEnabled(tester, AccountStrings.deleteButton), isFalse);

    await tester.tap(find.text(AccountStrings.cancel));
    await settle(tester);
    expect(find.byType(DeleteIdentityDialog), findsNothing);
    expect(identity.hasStoredProfile, isTrue);
  });

  testWidgets('typed confirmation deletes and returns to onboarding', (
    tester,
  ) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openMe(tester);
    await _scrollTo(tester, find.text(AccountStrings.deleteIdentity));
    await tester.tap(find.text(AccountStrings.deleteIdentity));
    await settle(tester);
    await tester.enterText(
      find.descendant(
        of: find.byType(DeleteIdentityDialog),
        matching: find.byType(TextField),
      ),
      AccountStrings.deleteConfirmWord,
    );
    await settle(tester);
    expect(buttonEnabled(tester, AccountStrings.deleteButton), isTrue);
    await tester.tap(find.text(AccountStrings.deleteButton));
    await settle(tester);

    expect(identity.hasStoredProfile, isFalse);
    expect(identity.current, isNull);
    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.byType(IdentityCard), findsNothing);
  });
}
