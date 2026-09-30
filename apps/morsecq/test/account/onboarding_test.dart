import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/account/account_strings.dart';
import 'package:morsecq/ui/account/backup_file_gateway.dart';
import 'package:morsecq/ui/account/backup_wizard_page.dart';
import 'package:morsecq/ui/account/create_identity_page.dart';
import 'package:morsecq/ui/account/restore_backup_page.dart';
import 'package:morsecq/ui/account/tox_id_qr_dialog.dart';
import 'package:morsecq/ui/account/welcome_page.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq_chat_api/testing.dart';

import 'test_app.dart';

Future<void> _openCreatePage(WidgetTester tester) async {
  await tapVisible(tester, find.text(AccountStrings.createIdentity));
  expect(find.byType(CreateIdentityPage), findsOneWidget);
}

Future<void> _createNamed(WidgetTester tester, String name) async {
  await tester.enterText(
    find.widgetWithText(TextField, AccountStrings.displayName),
    name,
  );
  await tapVisible(tester, find.text(AccountStrings.createButton));
}

void main() {
  late FakeIdentityService identity;
  late FakeBackupFileGateway files;

  setUp(() {
    identity = freshIdentityService();
    files = FakeBackupFileGateway();
  });

  testWidgets('create → backup wizard; continue needs the checkbox', (
    tester,
  ) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openCreatePage(tester);
    await _createNamed(tester, 'Ann');

    expect(identity.current?.displayName, 'Ann');
    expect(identity.current?.hasPassword, isFalse);
    expect(find.byType(BackupWizardPage), findsOneWidget);
    expect(find.byType(CreateIdentityPage), findsNothing);
    expect(find.byType(AppShell), findsNothing);
    // Mandatory: no back arrow.
    expect(find.byType(BackButton), findsNothing);
    expect(buttonEnabled(tester, AccountStrings.backupContinue), isFalse);

    // Saving works but is not enough on its own.
    // Label is "Save" on desktop and "Share" on mobile; find by key.
    await tapVisible(tester, find.byKey(BackupWizardPage.saveButtonKey));
    expect(files.saved, hasLength(1));
    expect(files.savedNames.single, startsWith('morsecq-Ann-'));
    expect(files.savedNames.single, endsWith('.mcqbackup'));
    expect(buttonEnabled(tester, AccountStrings.backupContinue), isFalse);

    await tapVisible(tester, find.byType(Checkbox));
    expect(buttonEnabled(tester, AccountStrings.backupContinue), isTrue);

    await tapVisible(tester, find.text(AccountStrings.backupContinue));
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(BackupWizardPage), findsNothing);
  });

  testWidgets('wizard shows the Tox ID QR dialog', (tester) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openCreatePage(tester);
    await _createNamed(tester, 'Ann');
    await tapVisible(tester, find.text(AccountStrings.showQr));
    expect(find.byType(ToxIdQrDialog), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('empty name is rejected before creating anything', (
    tester,
  ) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openCreatePage(tester);
    await tapVisible(tester, find.text(AccountStrings.createButton));
    expect(find.text(AccountStrings.displayNameRequired), findsOneWidget);
    expect(identity.hasStoredProfile, isFalse);
    expect(find.byType(CreateIdentityPage), findsOneWidget);
  });

  testWidgets('password must be confirmed; then identity is encrypted', (
    tester,
  ) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _openCreatePage(tester);
    await tester.enterText(
      find.widgetWithText(TextField, AccountStrings.displayName),
      'Ann',
    );
    await tester.enterText(
      find.widgetWithText(TextField, AccountStrings.passwordOptional),
      'correct horse',
    );
    await settle(tester);
    expect(find.text(AccountStrings.strengthStrong), findsNothing);
    expect(find.text(AccountStrings.strengthFair), findsOneWidget);
    expect(find.text(AccountStrings.confirmPassword), findsOneWidget);

    await tapVisible(tester, find.text(AccountStrings.createButton));
    expect(find.text(AccountStrings.passwordsDoNotMatch), findsOneWidget);
    expect(identity.hasStoredProfile, isFalse);

    await tester.enterText(
      find.widgetWithText(TextField, AccountStrings.confirmPassword),
      'correct horse',
    );
    await tapVisible(tester, find.text(AccountStrings.createButton));
    expect(identity.current?.hasPassword, isTrue);
    expect(identity.storedPassword, 'correct horse');
    expect(find.byType(BackupWizardPage), findsOneWidget);
  });

  testWidgets('restore from backup skips the wizard and opens the shell', (
    tester,
  ) async {
    final source = FakeIdentityService.withProfile(
      identity: testIdentity(),
      connectDelay: Duration.zero,
    );
    addTearDown(source.dispose);
    await source.open();
    await source.changePassword(newPassword: 'pw');
    files.pickResult = await source.exportBackup();

    await pumpApp(tester, identity: identity, backupFiles: files);
    await tapVisible(tester, find.text(AccountStrings.restoreFromBackup));
    expect(find.byType(RestoreBackupPage), findsOneWidget);

    // No file yet.
    await tapVisible(tester, find.text(AccountStrings.restoreButton));
    expect(find.text(AccountStrings.restoreNoFile), findsOneWidget);

    await tapVisible(tester, find.text(AccountStrings.restoreChooseFile));
    expect(find.textContaining(AccountStrings.restoreFileChosen), findsOne);

    // Wrong password is reported inline.
    await tapVisible(tester, find.text(AccountStrings.restoreButton));
    expect(find.text(AccountStrings.wrongPassword), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, AccountStrings.passwordOptional),
      'pw',
    );
    await tapVisible(tester, find.text(AccountStrings.restoreButton));
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(BackupWizardPage), findsNothing);
    expect(identity.current?.toxId, testIdentity().toxId);
  });

  testWidgets('welcome page explains the no-server model', (tester) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.text(AccountStrings.welcomePointNoServer), findsOneWidget);
    expect(find.text(AccountStrings.welcomePointBackup), findsOneWidget);
  });
}
