import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/learn/learn_glossary.dart';
import 'package:morsecq/ui/learn/settings/training_settings_entry.dart';
import 'package:morsecq/ui/learn/settings/training_settings_screen.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';

void main() {
  group('TrainingSettingsEntry', () {
    late Completer<TrainingController> opening;
    late int opens;
    late TrainingControllerHost host;

    // Created inside each test body: a Completer made in setUp would
    // schedule its callbacks outside the test's fake-async zone.
    void setUpHost() {
      opens = 0;
      opening = Completer<TrainingController>();
      host = TrainingControllerHost(
        LocalLearningStore(),
        factory: () {
          opens++;
          return opening.future;
        },
      );
      addTearDown(host.dispose);
    }

    Future<void> pump(WidgetTester tester) async {
      setUpHost();
      await tester.pumpWidget(
        Provider<TrainingControllerHost>.value(
          value: host,
          child: l10nApp(
            home: TrainingSettingsEntry(playback: FakeLearnPlaybackFactory()),
          ),
        ),
      );
      await tester.pump();
    }

    TrainingController controller() => TrainingController(
      progressStore: InMemoryTrainerStore(),
      settingsStore: InMemoryTrainingSettingsStore(
        const TrainingSettings(planMinutes: 25),
      ),
    );

    testWidgets('waits for the shared controller, then edits it', (
      tester,
    ) async {
      await pump(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(en.learnSettings), findsOneWidget);
      final c = controller();
      await c.load();
      opening.complete(c);
      await tester.pumpAndSettle();
      final screen = tester.widget<TrainingSettingsScreen>(
        find.byType(TrainingSettingsScreen),
      );
      expect(screen.controller, same(c));
      expect(opens, 1);
    });

    testWidgets('unavailable storage can be retried in place', (tester) async {
      await pump(tester);
      opening.completeError(StateError('locked'));
      await tester.pumpAndSettle();
      expect(find.text(en.learnStorageUnavailable), findsOneWidget);
      expect(find.byType(TrainingSettingsScreen), findsNothing);

      opening = Completer<TrainingController>();
      await tester.tap(find.byKey(const ValueKey('training-settings-retry')));
      await tester.pump();
      expect(opens, 2, reason: 'a failed open is not cached');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final c = controller();
      await c.load();
      opening.complete(c);
      await tester.pumpAndSettle();
      expect(find.byType(TrainingSettingsScreen), findsOneWidget);
    });
  });

  testWidgets('the glossary explains every term and closes', (tester) async {
    await tester.pumpWidget(
      l10nApp(
        home: Scaffold(appBar: AppBar(actions: const [LearnGlossaryButton()])),
      ),
    );
    await tester.tap(find.byTooltip(en.learnGlossaryTitle));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('learn-glossary')), findsOneWidget);
    for (final text in [
      en.glossaryKoch,
      en.glossaryWpm,
      en.glossaryFarnsworth,
      en.glossaryQso,
      en.glossaryRst,
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    await tester.tap(find.text(en.learnDone));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('learn-glossary')), findsNothing);
  });

  group('TrainingSettings value semantics', () {
    test('equality covers every field, including the plan length', () {
      const base = TrainingSettings();
      expect(const TrainingSettings(), base);
      expect(const TrainingSettings().hashCode, base.hashCode);
      for (final other in [
        base.copyWith(planMinutes: base.planMinutes + 5),
        base.copyWith(soundEnabled: !base.soundEnabled),
        base.copyWith(flashEnabled: !base.flashEnabled),
        base.copyWith(hapticEnabled: !base.hapticEnabled),
        base.copyWith(keyerMode: KeyerMode.straight),
        base.copyWith(trainer: base.trainer.copyWith(toneHz: 650)),
      ]) {
        expect(other, isNot(base), reason: '$other');
      }
    });

    test('a JSON round trip keeps every field', () {
      final custom = const TrainingSettings().copyWith(
        planMinutes: DailyPlanBuilder.budgets.last,
        soundEnabled: false,
        flashEnabled: true,
        hapticEnabled: true,
        keyerMode: KeyerMode.iambicA,
        trainer: const TrainerSettings(characterWpm: 25, farnsworthWpm: 12),
      );
      final back = TrainingSettings.fromJson(custom.toJson());
      expect(back, custom);
      expect(back.hashCode, custom.hashCode);
      expect(custom.toString(), contains('iambicA'));
    });

    test('a plan length the planner cannot build falls back', () {
      final json = const TrainingSettings().toJson()..['planMinutes'] = 25;
      expect(
        TrainingSettings.fromJson(json).planMinutes,
        TrainingSettings.defaults.planMinutes,
      );
    });
  });
}
