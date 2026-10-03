import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/account/backup_actions.dart';
import 'package:morsecq/ui/account/backup_file_gateway.dart';
import 'package:morsecq/ui/account/backup_wizard_page.dart';

import 'test_app.dart';

final S en = lookupS(const Locale('en'));

/// iPadOS shows the backup share sheet as a popover; it must be anchored to
/// the tapped button, not float in the middle of the screen.
void main() {
  testWidgets('wizard share passes the save button rect as share origin', (
    tester,
  ) async {
    final files = FakeBackupFileGateway();
    await pumpApp(
      tester,
      identity: freshIdentityService(),
      backupFiles: files,
      size: const Size(1024, 1366), // iPad portrait (regular width)
    );
    await tapVisible(tester, find.text(en.accountCreateIdentity));
    await tester.enterText(
      find.widgetWithText(TextField, en.accountDisplayName),
      'Ann',
    );
    await tapVisible(tester, find.text(en.accountCreateButton));
    expect(find.byType(BackupWizardPage), findsOneWidget);

    final button = find.byKey(BackupWizardPage.saveButtonKey);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    // Measured before the tap: the "saved" row shifts the layout afterwards.
    final buttonRect = tester.getRect(button);
    await tapVisible(tester, button);

    expect(files.saved, hasLength(1));
    expect(files.shareOrigins.single, buttonRect);
  });

  testWidgets('shareOriginOf is null for a widget without a laid-out box', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    // A zero-size box cannot anchor a popover; let the plugin centre it.
    expect(shareOriginOf(captured), isNull);
  });
}
