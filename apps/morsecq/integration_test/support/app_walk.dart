// Shared driving helpers for the real-app walks (reference_walk, me_walk,
// learn_walk). Each walk launches the full MorsecqApp the way main() does --
// a JSON settings file, the local learning store and the platform
// background-task bridge -- but over a scratch directory, so a file never
// depends on what an earlier file (or the user's installed app) left behind.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morsecq/di/app_preferences.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/keying/key_profiles.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/lifecycle/background_task_api.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'shot_harness.dart';

/// One isolated installation: `<scratch>/settings.json` plays the app
/// support settings file, `<scratch>/morsecq/guest` the learning profile.
class IsolatedApp {
  IsolatedApp._(this.binding, this.scratch);

  static Future<IsolatedApp> create(
    IntegrationTestWidgetsFlutterBinding binding,
    String prefix,
  ) async {
    // The live binding leaves the platform keyboard in charge, and
    // `enterText` then targets a stale input client once a field has been
    // refocused. Simulate the keyboard as widget tests do.
    if (!binding.testTextInput.isRegistered) {
      binding.testTextInput.register();
      addTearDown(binding.testTextInput.unregister);
    }
    final scratch = await Directory.systemTemp.createTemp(prefix);
    addTearDown(() async {
      if (scratch.existsSync()) await scratch.delete(recursive: true);
    });
    return IsolatedApp._(binding, scratch);
  }

  final IntegrationTestWidgetsFlutterBinding binding;
  final Directory scratch;

  String get learningDir => p.join(scratch.path, 'morsecq', 'guest');
  File get settingsFile => File(p.join(scratch.path, 'settings.json'));
  LocalLearningStore get learningStore =>
      LocalLearningStore(root: () async => learningDir);

  /// Starts the app like main() and waits for the loaded Learn home.
  Future<TrainingController> launch(
    WidgetTester tester, {
    required String key,
  }) async {
    await ShotHarness(binding).prepareWindow(tester);
    await tester.pumpWidget(
      MorsecqApp(
        key: ValueKey<String>(key),
        learningStore: learningStore,
        localeStore: await JsonFileKeyValueStore.open(settingsFile),
        backgroundTasks: BackgroundTaskApi.forPlatform(),
      ),
    );
    await settle(tester, extra: const Duration(milliseconds: 300));
    await waitFor(
      tester,
      () =>
          find.byType(LearnHome).evaluate().isNotEmpty &&
          tester.widget<LearnHome>(find.byType(LearnHome)).controller.isLoaded,
      'Learn home loaded after launch "$key"',
    );
    expect(find.byType(AppShell), findsOneWidget);
    return tester.widget<LearnHome>(find.byType(LearnHome)).controller;
  }

  /// An orderly quit: every store the app owns is flushed (what the
  /// lifecycle barrier does before the OS suspends the process), then the
  /// widget tree goes away.
  Future<void> quit(WidgetTester tester) async {
    final context = tester.element(find.byType(AppShell));
    final prefs = context.read<AppPreferences>();
    final locale = context.read<LocaleController>();
    final keys = context.read<KeyProfiles?>();
    final host = context.read<TrainingControllerHost>();
    await tester.runAsync(
      () => Future.wait<void>([
        prefs.flush(),
        locale.flush(),
        if (keys != null) keys.flush(),
        host.flush(),
      ]).timeout(const Duration(seconds: 30)),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }
}

/// Strings of the locale the app currently shows.
S appStrings(WidgetTester tester) =>
    S.of(tester.element(find.byType(AppShell)));

/// Pumps real frames until [ready] holds or [timeout] elapses, then asserts
/// it. File writes, plugin calls and audio timelines finish on their own
/// clock; this waits for the observable result instead of a fixed sleep.
Future<void> waitFor(
  WidgetTester tester,
  bool Function() ready,
  String label, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!ready() && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  expect(ready(), isTrue, reason: label);
}

/// Waits until [finder] resolves to at least one widget.
Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder,
  String label, {
  Duration timeout = const Duration(seconds: 20),
}) => waitFor(
  tester,
  () => finder.evaluate().isNotEmpty,
  label,
  timeout: timeout,
);

/// Leaves the current page through its app-bar back button, the way a
/// user would (never `Navigator.pop`, which also "works" on a page whose
/// back button is missing or covered).
Future<void> goBack(WidgetTester tester) async {
  final back = find.byType(BackButton);
  expect(back, findsOneWidget, reason: 'one back button on stage');
  expect(back.hitTestable(), findsOneWidget, reason: 'back is hittable');
  await tester.tap(back);
  await settle(tester);
}

/// Types [text] into the field [finder] and checks it arrived. On a device
/// the platform's own text-input connection can echo its previous editing
/// state back right after `enterText` (seen on the iOS simulator when a
/// field is refocused), reverting the field; type again until it sticks.
Future<void> typeInto(WidgetTester tester, Finder finder, String text) async {
  await tester.ensureVisible(finder);
  final editable = find.descendant(
    of: finder,
    matching: find.byType(EditableText),
  );
  String current() => tester.widget<EditableText>(editable).controller.text;
  for (var attempt = 0; attempt < 4; attempt++) {
    await tester.enterText(finder, text);
    await settle(tester);
    if (current() == text) return;
    await tester.pump(const Duration(milliseconds: 200));
  }
  expect(current(), text, reason: 'typed text reached the field');
}

/// Hides the soft keyboard (phones) so it no longer shrinks the page.
Future<void> dismissKeyboard(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await settle(tester);
}

/// Scrolls the nearest scrollable of [finder] until [finder] is laid out
/// and visible: lazy lists do not build rows below the fold, so
/// `ensureVisible` alone cannot reach them on a small phone.
Future<void> revealIn(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double delta = 200,
}) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: find
          .descendant(of: scrollable, matching: find.byType(Scrollable))
          .first,
      maxScrolls: 80,
    );
  }
  await tester.ensureVisible(finder);
  await settle(tester);
}

/// Taps the first hittable match of [finder] (several matches are fine,
/// e.g. a label that is also a page title elsewhere in the stack).
Future<void> tapFirstHittable(
  WidgetTester tester,
  Finder finder,
  String what,
) async {
  expect(finder, findsWidgets, reason: what);
  await tester.ensureVisible(finder.first);
  await tester.pump();
  final hittable = finder.hitTestable();
  expect(hittable, findsWidgets, reason: '$what is hittable');
  await tester.tap(hittable.first);
  await settle(tester);
}

/// The text a [SelectableText] or [Text] under [finder] shows.
String shownText(WidgetTester tester, Finder finder) {
  final widget = tester.widget(finder);
  return switch (widget) {
    SelectableText(:final data) => data ?? '',
    Text(:final data) => data ?? '',
    _ => throw StateError('$widget shows no plain text'),
  };
}
