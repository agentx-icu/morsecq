import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/app_features.dart';
import 'package:morsecq/di/app_services.dart';
import 'package:morsecq/di/fake_backend_factory.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/notifications/notification_center.dart';
import 'package:morsecq/notifications/testing/fake_badge_api.dart';
import 'package:morsecq/notifications/testing/fake_local_notifications_api.dart';
import 'package:morsecq/startup/startup_controller.dart';
import 'package:morsecq/training/guest_profile.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/ui/account/backup_file_gateway.dart';
import 'package:morsecq/ui/account/welcome_page.dart';
import 'package:morsecq/ui/moderation/terms_gate_page.dart';
import 'package:morsecq/ui/pages/offline_me_page.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq_chat_api/testing.dart';
import 'package:provider/provider.dart';

import '../account/test_app.dart';

final S s = lookupS(const Locale('en'));

/// The offline App Store build (`AppFeatures(chat: false)`).
void main() {
  late Directory root;
  late FakeIdentityService identity;
  late FakeLocalNotificationsApi notifications;

  setUp(() {
    root = Directory.systemTemp.createTempSync('morsecq_offline_');
    // A profile on disk must stay untouched: the offline build never
    // inspects, opens or connects an identity.
    identity = seededIdentityService();
    notifications = FakeLocalNotificationsApi();
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  Future<void> pumpOffline(WidgetTester tester) async {
    tester.view.physicalSize = kPhoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MorsecqApp(
        features: const AppFeatures(chat: false),
        backend: FakeBackendFactory(
          identityService: identity,
          label: kOfflineBackendLabel,
        ),
        backupFiles: FakeBackupFileGateway(),
        guestStore: GuestStore(root: () async => '${root.path}/learning'),
        // No accepted terms: the offline build has no gate to show.
        localeStore: InMemoryKeyValueStore(),
        notifications: NotificationApis(
          notifications: notifications,
          badge: FakeBadgeApi(),
        ),
      ),
    );
    await tester.runAsync(() async {
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await settle(tester);
  }

  Finder nav(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is NavigationBar || w is NavigationRail,
    ),
    matching: find.text(label),
  );

  testWidgets('opens straight on Learn with three destinations and no chat', (
    tester,
  ) async {
    await pumpOffline(tester);
    expect(find.byType(WelcomePage), findsNothing);
    expect(find.byType(TermsGatePage), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
    expect(nav(s.navLearn), findsOneWidget);
    expect(nav(s.navReference), findsOneWidget);
    expect(nav(s.navMe), findsOneWidget);
    expect(nav(s.navChat), findsNothing);
    expect(nav(s.navGroups), findsNothing);
    expect(find.text(s.guestBanner), findsNothing);
    expect(find.text(s.learnContinueLesson), findsOneWidget);
    expect(identity.current, isNull, reason: 'no identity opened');
    final controller = tester
        .element(find.byType(AppShell))
        .read<StartupController>();
    expect(controller.phase, StartupPhase.guest);
    expect(controller.guestMode.value, isTrue);
  });

  testWidgets('posts no notifications and builds no notification centre', (
    tester,
  ) async {
    await pumpOffline(tester);
    final BuildContext context = tester.element(find.byType(AppShell));
    expect(context.read<NotificationCenter?>(), isNull);
    expect(notifications.initialized, isFalse);
    expect(notifications.permissionRequests, 0);
    // The never-connected identity must not raise the "messaging offline"
    // banner after its threshold.
    await tester.pump(const Duration(minutes: 5));
    expect(find.text(s.shellOfflineBanner), findsNothing);
    expect(find.byIcon(Icons.cloud_off), findsNothing);
  });

  testWidgets('Me is the offline settings page without identity entries', (
    tester,
  ) async {
    await pumpOffline(tester);
    await tester.tap(nav(s.navMe));
    await settle(tester);
    expect(find.byType(OfflineMePage), findsOneWidget);
    expect(find.text(s.guestGetIdentity), findsNothing);
    expect(find.text(s.accountExportBackup), findsNothing);
    expect(find.byKey(const ValueKey('offline-keys')), findsOneWidget);
    expect(find.byKey(const ValueKey('about-privacy')), findsOneWidget);
  });

  testWidgets(
    'training changes reach disk when the app goes to the background',
    (tester) async {
      await pumpOffline(tester);
      final host = tester
          .element(find.byType(AppShell))
          .read<TrainingControllerHost?>()!;
      TrainingController? controller;
      unawaited(host.controller().then((c) => controller = c));
      Future<void> spin(bool Function() done) => tester.runAsync(() async {
        for (var i = 0; i < 100 && !done(); i++) {
          await tester.pump(const Duration(milliseconds: 20));
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });
      await spin(() => controller != null);
      unawaited(controller!.setDailyGoal(77));
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      bool persisted() => Directory('${root.path}/learning')
          .listSync(recursive: true)
          .whereType<File>()
          .any(
            (f) => RegExp(
              r'"dailyGoalChars":\s*77',
            ).hasMatch(f.readAsStringSync()),
          );
      await spin(persisted);
      expect(persisted(), isTrue, reason: 'the daily goal was persisted');
    },
  );
}
