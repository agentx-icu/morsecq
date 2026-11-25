import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/privacy_consent.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/ui/learn/settings/training_settings_entry.dart';
import 'package:morsecq/ui/legal/legal_pages.dart';
import 'package:morsecq/ui/legal/privacy_consent_gate.dart';
import 'package:morsecq/ui/settings/settings_routes.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:provider/provider.dart';

import '../support/test_app.dart';

final S en = lookupS(const Locale('en'));

class _ScriptedStore implements KeyValueStore {
  final store = InMemoryKeyValueStore();
  final firstWrite = Completer<void>();
  int writes = 0;

  @override
  String? getString(String key) => store.getString(key);

  @override
  Future<void> remove(String key) => store.remove(key);

  @override
  Future<void> setString(String key, String value) async {
    if (++writes == 1) await firstWrite.future;
    await store.setString(key, value);
  }
}

Widget _harness(PrivacyConsent consent) =>
    ChangeNotifierProvider<PrivacyConsent>.value(
      value: consent,
      child: MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('en'),
        home: const PrivacyConsentGate(),
      ),
    );

void main() {
  group('requiresPrivacyConsent', () {
    test('only a release Android build gates', () {
      expect(
        requiresPrivacyConsent(
          releaseMode: true,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        requiresPrivacyConsent(
          releaseMode: false,
          platform: TargetPlatform.android,
        ),
        isFalse,
      );
      expect(
        requiresPrivacyConsent(releaseMode: true, platform: TargetPlatform.iOS),
        isFalse,
      );
      expect(
        requiresPrivacyConsent(
          releaseMode: true,
          platform: TargetPlatform.macOS,
        ),
        isFalse,
      );
    });
  });

  testWidgets('agreeing persists the acceptance', (tester) async {
    final store = InMemoryKeyValueStore();
    final consent = PrivacyConsent(store: store);
    addTearDown(consent.dispose);
    await tester.pumpWidget(_harness(consent));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyConsentGate), findsOneWidget);
    await tester.tap(find.text(en.privacyConsentAccept));
    await tester.pumpAndSettle();

    expect(consent.accepted, isTrue);
    expect(
      store.values[PrivacyConsent.storageKey],
      PrivacyConsent.currentVersion,
    );
  });

  testWidgets('consent save failure is visible and the user can retry', (
    tester,
  ) async {
    final store = _ScriptedStore();
    final consent = PrivacyConsent(store: store);
    addTearDown(consent.dispose);
    await tester.pumpWidget(_harness(consent));
    await tester.pumpAndSettle();

    final accept = find.byType(FilledButton);
    await tester.tap(accept);
    await tester.pump();
    expect(tester.widget<FilledButton>(accept).onPressed, isNull);
    expect(find.text(en.privacyConsentSaving), findsOneWidget);
    expect(store.writes, 1);
    store.firstWrite.completeError(const FileSystemException('write failed'));
    await tester.pumpAndSettle();
    expect(find.text(en.privacyConsentSaveFailed), findsOneWidget);
    expect(consent.accepted, isFalse);
    await tester.tap(accept);
    await tester.pumpAndSettle();
    expect(consent.accepted, isTrue);
    expect(store.writes, 2);
  });

  testWidgets('Android startup retries either unavailable persistent store', (
    tester,
  ) async {
    final root = Directory.systemTemp.createTempSync('morsecq_consent_retry_');
    addTearDown(() => root.deleteSync(recursive: true));
    final preferences = InMemoryKeyValueStore();
    final consent = InMemoryKeyValueStore();
    var settingsAttempts = 0;
    var consentAttempts = 0;
    await tester.pumpWidget(
      AndroidPrivacyStartup(
        openSettingsStore: () async {
          if (++settingsAttempts == 1) {
            throw const FileSystemException('settings unavailable');
          }
          return preferences;
        },
        openConsentStore: () async {
          if (++consentAttempts == 1) {
            throw const FileSystemException('consent unavailable');
          }
          return consent;
        },
        learningStore: LocalLearningStore(root: () async => root.path),
      ),
    );
    await settle(tester);

    for (var attempt = 0; attempt < 2; attempt++) {
      expect(find.text(en.privacyConsentStorageFailed), findsOneWidget);
      expect(find.text(en.privacyConsentAccept), findsNothing);
      expect(find.byType(AppShell), findsNothing);
      await tester.tap(find.text(en.actionRetry));
      await settle(tester);
    }

    expect(find.byType(PrivacyConsentGate), findsOneWidget);
    await tester.tap(find.text(en.privacyConsentAccept));
    await settle(tester);
    expect(find.byType(AppShell), findsOneWidget);
    expect(preferences.getString(PrivacyConsent.storageKey), isNull);
    expect(
      consent.getString(PrivacyConsent.storageKey),
      PrivacyConsent.currentVersion,
    );
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });

  testWidgets('restored preferences do not satisfy Android privacy consent', (
    tester,
  ) async {
    final root = Directory.systemTemp.createTempSync(
      'morsecq_consent_restore_',
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final restored = InMemoryKeyValueStore({
      LocaleController.storageKey: 'en',
      PrivacyConsent.storageKey: PrivacyConsent.currentVersion,
    });
    final consent = InMemoryKeyValueStore();
    Widget startup() => AndroidPrivacyStartup(
      openSettingsStore: () async => restored,
      openConsentStore: () async => consent,
      learningStore: LocalLearningStore(root: () async => root.path),
    );
    await tester.pumpWidget(startup());
    await settle(tester);
    expect(find.byType(PrivacyConsentGate), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);

    await tester.tap(find.text(en.privacyConsentAccept));
    await settle(tester);
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.pumpWidget(startup());
    await settle(tester);
    expect(find.byType(PrivacyConsentGate), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });

  testWidgets('a named initial route stays behind the consent gate', (
    tester,
  ) async {
    final root = Directory.systemTemp.createTempSync('morsecq_consent_');
    addTearDown(() => root.deleteSync(recursive: true));
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.defaultRouteNameTestValue = kTrainingSettingsRoute;
    addTearDown(dispatcher.clearDefaultRouteNameTestValue);
    final store = InMemoryKeyValueStore();
    await tester.pumpWidget(
      MorsecqApp(
        localeStore: store,
        consentStore: store,
        learningStore: LocalLearningStore(root: () async => root.path),
        privacyConsentRequired: true,
      ),
    );
    await settle(tester);
    expect(find.byType(PrivacyConsentGate), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
    expect(find.byType(TrainingSettingsEntry), findsNothing);

    await tester.tap(find.text(en.privacyConsentAccept));
    await settle(tester);
    expect(find.byType(AppShell), findsOneWidget);
    expect(
      store.getString(PrivacyConsent.storageKey),
      PrivacyConsent.currentVersion,
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigator.pushNamed<void>(kTrainingSettingsRoute));
    await settle(tester);
    expect(find.byType(TrainingSettingsEntry), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });

  testWidgets('declining exits the app', (tester) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final consent = PrivacyConsent(store: InMemoryKeyValueStore());
    addTearDown(consent.dispose);
    await tester.pumpWidget(_harness(consent));
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.privacyConsentDecline));
    await tester.pump();

    expect(calls, contains('SystemNavigator.pop'));
  });

  testWidgets('the policy opens from the gate for review', (tester) async {
    final consent = PrivacyConsent(store: InMemoryKeyValueStore());
    addTearDown(consent.dispose);
    await tester.pumpWidget(_harness(consent));
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.aboutPrivacyPolicy));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
  });
}
