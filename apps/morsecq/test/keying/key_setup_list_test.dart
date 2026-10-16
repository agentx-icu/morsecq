import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/keying/key_profile.dart';
import 'package:morsecq/keying/key_profiles.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/keying/key_setup_page.dart';
import 'package:provider/provider.dart';

import '../learn/helpers/l10n.dart';

/// Profiles, the shared Learn controller and its host, as AppScope wires
/// them (both the plain and the nullable host lookups).
final class _Scope {
  _Scope._(this.profiles, this.controller, this.host);

  static Future<_Scope> create() async {
    final profiles = KeyProfiles(InMemoryKeyValueStore());
    final controller = TrainingController(
      progressStore: InMemoryTrainerStore(),
      settingsStore: InMemoryTrainingSettingsStore(),
    );
    await controller.load();
    final host = TrainingControllerHost(
      LocalLearningStore(),
      factory: () async => controller,
    );
    addTearDown(host.dispose);
    return _Scope._(profiles, controller, host);
  }

  final KeyProfiles profiles;
  final TrainingController controller;
  final TrainingControllerHost host;

  Widget wrap(Widget home) => MultiProvider(
    providers: [
      ChangeNotifierProvider<KeyProfiles>.value(value: profiles),
      Provider<TrainingControllerHost>.value(value: host),
      Provider<TrainingControllerHost?>.value(value: host),
    ],
    child: l10nApp(home: home),
  );
}

final KeyProfile _straight = KeyProfile.defaults.copyWith(
  id: 'p-straight',
  name: 'Straight',
  keyerMode: KeyerMode.straight,
);

void _size(WidgetTester tester) {
  tester.view.physicalSize = const Size(600, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('choosing a profile makes it active and Learn follows it', (
    tester,
  ) async {
    _size(tester);
    final scope = await _Scope.create();
    await scope.profiles.save(_straight);
    await scope.profiles.save(
      KeyProfile.defaults.copyWith(id: 'p-unnamed', name: ''),
    );
    await scope.profiles.useDefaults();
    await tester.pumpWidget(scope.wrap(const KeySetupPage()));
    await tester.pumpAndSettle();

    expect(find.text(en.keysStandardProfile), findsOneWidget);
    expect(find.text('Straight'), findsOneWidget);
    expect(find.text(en.keysUnnamed), findsOneWidget);
    expect(find.text(en.keysLimitations), findsOneWidget);

    await tester.tap(find.byKey(const Key('keys-profile-p-straight')));
    await tester.pumpAndSettle();
    expect(scope.profiles.active.id, 'p-straight');
    expect(scope.controller.settings.keyerMode, KeyerMode.straight);

    await tester.tap(find.byKey(const Key('keys-profile-default')));
    await tester.pumpAndSettle();
    expect(scope.profiles.active.id, KeyProfile.defaults.id);
    expect(scope.controller.settings.keyerMode, KeyProfile.defaults.keyerMode);
  });

  group('editor', () {
    Future<_Scope> openEditor(WidgetTester tester, KeyProfile profile) async {
      _size(tester);
      final scope = await _Scope.create();
      await tester.pumpWidget(
        scope.wrap(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => KeyProfileEditorPage(
                      profile: profile,
                      testSink: RecordingSink(clock: FakeClock()),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return scope;
    }

    testWidgets('every switch is saved, and Learn takes the mode', (
      tester,
    ) async {
      final scope = await openEditor(
        tester,
        KeyProfile.defaults.copyWith(id: 'p-new'),
      );
      expect(find.byTooltip(en.actionDelete), findsNothing, reason: 'unsaved');
      await tester.enterText(find.byKey(const Key('keys-name')), '  Vail  ');
      for (final key in ['keys-adapter', 'keys-sidetone', 'keys-swap']) {
        await tester.ensureVisible(find.byKey(Key(key)));
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('keys-mode-iambicA')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('keys-save')));
      await tester.tap(find.byKey(const Key('keys-save')));
      await tester.pumpAndSettle();

      expect(find.byType(KeyProfileEditorPage), findsNothing);
      final saved = scope.profiles.active;
      expect(saved.id, 'p-new');
      expect(saved.name, 'Vail', reason: 'the name is trimmed');
      expect(saved.adapterKeyer, !KeyProfile.defaults.adapterKeyer);
      expect(saved.appSidetone, !KeyProfile.defaults.appSidetone);
      expect(saved.swapPaddles, !KeyProfile.defaults.swapPaddles);
      expect(saved.keyerMode, KeyerMode.iambicA);
      expect(scope.controller.settings.keyerMode, KeyerMode.iambicA);
    });

    testWidgets('a key reserved by the app is refused while capturing', (
      tester,
    ) async {
      await openEditor(tester, KeyProfile.defaults.copyWith(id: 'p-new'));
      final reserved = KeyProfile.reservedKeys.first;
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('keys-capture-dit')),
          matching: find.text(en.keysSet),
        ),
      );
      await tester.pump();
      expect(find.text(en.keysPressKey), findsOneWidget);
      await tester.sendKeyDownEvent(reserved);
      await tester.sendKeyUpEvent(reserved);
      await tester.pump();
      expect(find.byKey(const Key('keys-error')), findsOneWidget);
      expect(find.text(en.keysReserved(keyLabels({reserved}))), findsOneWidget);
    });

    testWidgets('a paddle mode without paddle keys cannot be saved', (
      tester,
    ) async {
      final scope = await openEditor(
        tester,
        KeyProfile.defaults.copyWith(
          id: 'p-bad',
          dit: <LogicalKeyboardKey>{},
          dah: <LogicalKeyboardKey>{},
        ),
      );
      await tester.ensureVisible(find.byKey(const Key('keys-save')));
      await tester.tap(find.byKey(const Key('keys-save')));
      await tester.pumpAndSettle();
      expect(find.byType(KeyProfileEditorPage), findsOneWidget);
      expect(find.text(en.keysMissing), findsOneWidget);
      expect(scope.profiles.saved, isEmpty);
    });

    testWidgets('deleting the active profile hands Learn the standard mode', (
      tester,
    ) async {
      final scope = await openEditor(tester, _straight);
      await scope.profiles.save(_straight);
      await scope.controller.updateSettings(
        scope.controller.settings.copyWith(keyerMode: KeyerMode.straight),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(en.actionDelete));
      await tester.pumpAndSettle();
      expect(find.byType(KeyProfileEditorPage), findsNothing);
      expect(scope.profiles.saved, isEmpty);
      expect(scope.profiles.active.id, KeyProfile.defaults.id);
      expect(
        scope.controller.settings.keyerMode,
        KeyProfile.defaults.keyerMode,
        reason: 'every keying surface runs the active profile\'s mode',
      );
    });

    testWidgets('deleting an inactive profile leaves Learn alone', (
      tester,
    ) async {
      final scope = await openEditor(tester, _straight);
      await scope.profiles.save(_straight);
      await scope.profiles.useDefaults();
      await scope.controller.updateSettings(
        scope.controller.settings.copyWith(keyerMode: KeyerMode.iambicA),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(en.actionDelete));
      await tester.pumpAndSettle();
      expect(scope.profiles.saved, isEmpty);
      expect(
        scope.controller.settings.keyerMode,
        KeyerMode.iambicA,
        reason: 'the active profile did not change',
      );
    });
  });
}
