import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/privacy_consent.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:path/path.dart' as p;

Map<String, String> _legalStrings(S s) => {
  'accountSectionPrivacy': s.accountSectionPrivacy,
  'accountPersonalInfoList': s.accountPersonalInfoList,
  'accountThirdPartyShareList': s.accountThirdPartyShareList,
  'accountPermissionList': s.accountPermissionList,
  'technicalSupportText': s.technicalSupportText,
  'privacyConsentTitle': s.privacyConsentTitle,
  'privacyConsentSummary': s.privacyConsentSummary,
  'privacyConsentAccept': s.privacyConsentAccept,
  'privacyConsentDecline': s.privacyConsentDecline,
  'privacyConsentSaving': s.privacyConsentSaving,
  'privacyConsentSaveFailed': s.privacyConsentSaveFailed,
  'privacyConsentStorageFailed': s.privacyConsentStorageFailed,
  'listenMicPurposeTitle': s.listenMicPurposeTitle,
  'listenMicPurposeBody': s.listenMicPurposeBody,
  'listenMicPurposeContinue': s.listenMicPurposeContinue,
  'privacyPolicyText': s.privacyPolicyText,
  'termsOfUseText': s.termsOfUseText,
  'personalInfoListText': s.personalInfoListText,
  'thirdPartyShareText': s.thirdPartyShareText,
  'permissionListText': s.permissionListText,
};

void main() {
  const diagnosticsHeadings = {
    'de': 'Diagnoseprotokoll',
    'en': 'Diagnostic logs',
    'es': 'Registros de diagnóstico',
    'fr': 'Journaux de diagnostic',
    'ja': '診断ログ',
    'ko': '진단 로그',
    'pt': 'Registros de diagnóstico',
    'ru': 'Журналы диагностики',
    'zh': '诊断日志',
    'zh_Hant': '診斷記錄',
  };
  for (final locale in S.supportedLocales) {
    test('the policy discloses local diagnostics in $locale', () {
      final s = lookupS(locale);
      expect(
        s.privacyPolicyText,
        contains(diagnosticsHeadings[locale.toString()]!),
      );
      expect(s.privacyPolicyText, contains(s.diagnosticsCopy));
    });
    if (locale.languageCode == 'en') continue;
    test('legal and permission strings are localized for $locale', () {
      final localized = _legalStrings(lookupS(locale));
      final english = _legalStrings(lookupS(const Locale('en')));
      for (final MapEntry(:key, :value) in english.entries) {
        expect(localized[key], isNot(value), reason: '$key in $locale');
      }
    });
  }

  test('the English policy describes the scope of local deletion', () {
    final s = lookupS(const Locale('en'));
    for (final text in [s.privacyPolicyText, s.personalInfoListText]) {
      expect(text, contains('Me > Clear learning data'));
      expect(text, contains('App preferences are kept.'));
    }
    expect(s.privacyPolicyText, contains('release builds on Android'));
  });

  test(
    'clearing learning data preserves app preferences and consent',
    () async {
      final support = await Directory.systemTemp.createTemp('morsecq_clear_');
      addTearDown(() => support.delete(recursive: true));
      final profile = p.join(support.path, 'morsecq', 'guest');
      final training = Directory(p.join(profile, 'training'));
      final media = Directory(p.join(profile, 'media'));
      await training.create(recursive: true);
      await media.create(recursive: true);
      await File(p.join(training.path, 'progress.json')).writeAsString('{}');
      await File(p.join(media.path, 'recording.wav')).writeAsBytes([1, 2, 3]);
      final settingsFile = File(p.join(support.path, 'settings.json'));
      final preferences = await JsonFileKeyValueStore.open(settingsFile);
      await preferences.setString(LocaleController.storageKey, 'fr');
      final consentFile = File(
        p.join(support.path, 'no_backup', 'privacy.json'),
      );
      final consent = PrivacyConsent(
        store: await JsonFileKeyValueStore.open(consentFile),
      );
      addTearDown(consent.dispose);
      await consent.accept();

      await LocalLearningStore(root: () async => profile).clear();

      expect(await training.exists(), isFalse);
      expect(await media.exists(), isFalse);
      final stored = await JsonFileKeyValueStore.open(settingsFile);
      expect(stored.getString(LocaleController.storageKey), 'fr');
      expect(
        (await JsonFileKeyValueStore.open(
          consentFile,
        )).getString(PrivacyConsent.storageKey),
        PrivacyConsent.currentVersion,
      );
    },
  );
}
