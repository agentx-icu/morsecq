// Native first-day journey with temporary offline profiles and the device's
// real LearnPlaybackFactory. Automated answers verify behavior, not learning.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morsecq/di/app_features.dart';
import 'package:morsecq/di/fake_backend_factory.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/training/guest_profile.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/account/backup_file_gateway.dart';

import 'support/pedagogy_walk.dart';
import 'support/shot_harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  for (final locale in ['en', 'zh']) {
    testWidgets(
      'first day native intro, graded practice and guided sending [$locale]',
      (tester) async {
        final scratch = await Directory.systemTemp.createTemp(
          'morsecq_first_day_',
        );
        addTearDown(() => scratch.delete(recursive: true));
        await ShotHarness(binding).prepareWindow(tester);
        await tester.pumpWidget(
          MorsecqApp(
            key: ValueKey('first-day-$locale'),
            features: const AppFeatures(chat: false),
            backend: FakeBackendFactory(),
            backupFiles: FakeBackupFileGateway(),
            guestStore: GuestStore(root: () async => scratch.path),
            localeStore: InMemoryKeyValueStore({
              LocaleController.storageKey: locale,
            }),
          ),
        );
        await settle(tester, extra: const Duration(seconds: 1));
        final home = tester.widget<LearnHome>(find.byType(LearnHome));
        final c = home.controller;
        expect(
          find.byKey(const ValueKey('start-here')).hitTestable(),
          findsOneWidget,
        );
        debugPrint('[native] $locale home loaded');
        await tapKey(tester, 'start-here');
        await completeFirstLesson(tester);
        debugPrint('[native] $locale intro completed');
        expect(c.progress.firstLessonDone, isTrue);
        expect(c.progress.history.length, 1);
        expect(c.currentLesson, 1);
        await tapKey(tester, 'next-guided');
        expect(
          tester
              .widget<ReceiveDrillScreen>(find.byType(ReceiveDrillScreen))
              .session
              .currentDrill
              .text
              .length,
          1,
        );
        await completeReceive(tester);
        expect(c.currentLesson, 1);
        debugPrint('[native] $locale single completed');
        await tapKey(tester, 'guided-next');
        expect(
          tester
              .widget<ReceiveDrillScreen>(find.byType(ReceiveDrillScreen))
              .session
              .currentDrill
              .text
              .length,
          3,
        );
        await completeReceive(tester);
        expect(c.currentLesson, 1);
        debugPrint('[native] $locale short completed');
        await tapKey(tester, 'receive-done');
        await c.updateSettings(
          c.settings.copyWith(keyerMode: KeyerMode.straight),
        );
        await settle(tester);
        await tapKey(tester, 'more-practice');
        await tapKey(tester, 'guided-send');
        expect(find.byType(SendPracticeScreen), findsOneWidget);
        await keyGuidedK(tester);
        expect(GuidedSending.nextStage(c.progress.history), GuidedSendStage.m);
        await tester.pumpWidget(const SizedBox.shrink());
        await settle(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
