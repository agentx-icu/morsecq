import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morsecq/di/privacy_consent.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/legal/legal_pages.dart';
import 'package:morsecq/ui/legal/privacy_consent_gate.dart';
import 'package:morsecq/ui/pages/offline_me_page.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:path/path.dart' as p;

import 'support/app_walk.dart';
import 'support/scene_walk.dart';
import 'support/shot_harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first-run review and consent survive reopening both stores', (
    tester,
  ) async {
    final app = await IsolatedApp.create(binding, 'morsecq_consent_');
    final consentFile = File(p.join(app.scratch.path, 'privacy.json'));
    final restored = await JsonFileKeyValueStore.open(app.settingsFile);
    await restored.setString(LocaleController.storageKey, 'en');
    await restored.setString(
      PrivacyConsent.storageKey,
      PrivacyConsent.currentVersion,
    );
    final s = lookupS(const Locale('en'));
    Widget startup() => AndroidPrivacyStartup(
      openSettingsStore: () => JsonFileKeyValueStore.open(app.settingsFile),
      openConsentStore: () => JsonFileKeyValueStore.open(consentFile),
      learningStore: app.learningStore,
    );

    await ShotHarness(binding).prepareWindow(tester);
    await tester.pumpWidget(startup());
    final gate = find.byType(PrivacyConsentGate);
    await waitForWidget(tester, gate, 'consent is required on first launch');
    expect(find.byType(AppShell), findsNothing);
    expect(find.text(s.privacyConsentSummary), findsOneWidget);

    await tapText(tester, s.aboutPrivacyPolicy);
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
    expect(find.text(s.privacyPolicyText), findsOneWidget);
    await goBack(tester);

    await tapText(tester, s.aboutTermsOfUse);
    expect(find.byType(TermsOfUsePage), findsOneWidget);
    expect(find.text(s.termsOfUseText), findsOneWidget);
    await goBack(tester);
    expect(gate, findsOneWidget);
    expect(find.byType(AppShell), findsNothing);

    await tapText(tester, s.privacyConsentAccept);
    await waitForWidget(tester, find.byType(LearnHome), 'Learn after consent');
    expect(gate, findsNothing);
    final saved = await JsonFileKeyValueStore.open(consentFile);
    expect(
      saved.getString(PrivacyConsent.storageKey),
      PrivacyConsent.currentVersion,
    );

    await app.quit(tester);
    await tester.pumpWidget(startup());
    await waitForWidget(tester, find.byType(LearnHome), 'Learn after relaunch');
    expect(gate, findsNothing);
    expect(tester.takeException(), isNull);
    await app.quit(tester);
  });

  testWidgets('Me opens every privacy, permissions and support page', (
    tester,
  ) async {
    final app = await IsolatedApp.create(binding, 'morsecq_legal_');
    await app.launch(tester, key: 'legal');
    final s = appStrings(tester);
    await selectTab(tester, ShellTab.me);
    final me = find.byType(OfflineMePage);
    expect(find.text(s.accountSectionPrivacy), findsOneWidget);

    for (final (key, page, title, body) in [
      (
        'about-privacy',
        PrivacyPolicyPage,
        s.aboutPrivacyPolicy,
        s.privacyPolicyText,
      ),
      ('about-terms', TermsOfUsePage, s.aboutTermsOfUse, s.termsOfUseText),
      (
        'account-personal-info',
        PersonalInfoListPage,
        s.accountPersonalInfoList,
        s.personalInfoListText,
      ),
      (
        'account-third-party',
        ThirdPartyShareListPage,
        s.accountThirdPartyShareList,
        s.thirdPartyShareText,
      ),
      (
        'account-permissions',
        PermissionListPage,
        s.accountPermissionList,
        s.permissionListText,
      ),
      (
        'about-support',
        TechnicalSupportPage,
        s.aboutSupport,
        s.technicalSupportText,
      ),
    ]) {
      final entry = find.descendant(
        of: me,
        matching: find.byKey(ValueKey(key)),
      );
      await tapHittable(tester, entry, title);
      expect(find.byType(page), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      expect(find.text(body), findsOneWidget);
      await goBack(tester);
      expect(me, findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    await app.quit(tester);
  });
}
