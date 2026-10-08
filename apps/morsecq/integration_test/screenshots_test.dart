import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'support/scene_walk.dart';
import 'support/seed_data.dart';
import 'support/shot_harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final shots = ShotHarness(binding);

  for (final locale in shotLocales()) {
    testWidgets('screenshots offline [$locale]', (tester) async {
      final S s = lookupS(parseShotLocale(locale));
      final scratch = await Directory.systemTemp.createTemp('morsecq_shots_');
      addTearDown(() => scratch.delete(recursive: true));
      // The local learning profile, seeded with the same week of training.
      final guest = LocalLearningStore(
        root: () async => '${scratch.path}/offline',
      );
      await seedTrainingProgress(
        await guest.directory(),
        anchor: seedAnchor(DateTime.now()),
      );
      await tester.pumpWidget(
        shots.wrap(
          MorsecqApp(
            key: ValueKey<String>('offline-$locale'),
            learningStore: guest,
            localeStore: InMemoryKeyValueStore({
              LocaleController.storageKey: locale,
            }),
          ),
        ),
      );
      await shots.prepareWindow(tester);
      await walkOffline(tester, shots, s, locale);
      final mine = shots.captured.where((n) => n.contains('/$locale/'));
      expect(mine.length, kOfflineScenes.length, reason: 'all scenes');
    });
  }
}
