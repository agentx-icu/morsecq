// The Me destination end to end on the device: training defaults (shared
// with Learn), a new key profile, appearance and language, the About copy
// action, then a relaunch that must restore every choice, and finally the
// confirmed clear (cancel first) which empties learning but keeps the
// device preferences.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morsecq/di/app_settings.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/keying/key_profiles.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/appearance/appearance_page.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/keying/key_setup_page.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/settings/training_settings_screen.dart';
import 'package:morsecq/ui/pages/offline_me_page.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:provider/provider.dart';

import 'support/app_walk.dart';
import 'support/scene_walk.dart';

const _profileName = 'Paddle 1';
const _german = Locale('de');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('me settings persist across a relaunch and clearing', (
    tester,
  ) async {
    final app = await IsolatedApp.create(binding, 'morsecq_me_');
    final c = await app.launch(tester, key: 'me');
    await tester.runAsync(() async {
      await c.setDailyGoal(88);
      await c.markFirstLessonDone();
    });
    var s = appStrings(tester);
    await selectTab(tester, ShellTab.me);
    expect(find.byType(OfflineMePage), findsOneWidget);

    await _trainingDefaults(tester, s, c);
    await _keyProfile(tester, s, c);
    await _appearance(tester, s);
    await _language(tester, s);
    s = appStrings(tester);
    expect(s.localeName, _german.languageCode);
    await tapFirstHittable(
      tester,
      find.text(s.accountAboutSource),
      'copy source URL',
    );
    // Queued behind the appearance confirmation.
    await waitForWidget(
      tester,
      find.text(s.accountAboutSourceCopied),
      'source URL copied',
    );

    await app.quit(tester);
    final again = await app.launch(tester, key: 'me-again');
    _expectPreferences(tester);
    expect(again.progress.dailyGoalChars, 88);
    expect(again.progress.firstLessonDone, isTrue);
    expect(again.settings.trainer.characterWpm, 20);
    expect(again.settings.trainer.farnsworthWpm, 6);
    expect(again.settings.keyerMode, KeyerMode.iambicA);
    expect(
      Theme.of(tester.element(find.byType(LearnHome))).brightness,
      Brightness.dark,
    );

    await _clear(tester, appStrings(tester), again);
    expect(tester.takeException(), isNull);
    await app.quit(tester);
  });
}

/// Me -> Training defaults edits the same controller Learn uses.
Future<void> _trainingDefaults(
  WidgetTester tester,
  S s,
  TrainingController c,
) async {
  await tapHittable(
    tester,
    find.byKey(const ValueKey('offline-training-defaults')),
    'training defaults',
  );
  await waitForWidget(
    tester,
    find.byType(TrainingSettingsScreen),
    'training settings page',
  );
  await tapHittable(
    tester,
    find.byKey(const ValueKey('preset-beginner')),
    'beginner preset',
  );
  await waitFor(
    tester,
    () =>
        c.settings.trainer.characterWpm == 20 &&
        c.settings.trainer.farnsworthWpm == 6,
    'beginner preset saved',
  );
  await revealIn(
    tester,
    find.text(s.learnKeyerStraight),
    find.byType(TrainingSettingsScreen),
  );
  await tapFirstHittable(
    tester,
    find.text(s.learnKeyerStraight),
    'straight keyer',
  );
  await waitFor(
    tester,
    () => c.settings.keyerMode == KeyerMode.straight,
    'keyer mode saved',
  );
  await goBack(tester);

  // The Learn gear opens the same values.
  await selectTab(tester, ShellTab.learn);
  await tapTooltip(tester, s.learnSettings);
  final beginner = tester.widget<ChoiceChip>(
    find.byKey(const ValueKey('preset-beginner')),
  );
  expect(beginner.selected, isTrue, reason: 'Learn sees the Me change');
  await goBack(tester);
  await selectTab(tester, ShellTab.me);
}

/// A new key profile becomes the active one and carries its keyer mode
/// into Learn.
Future<void> _keyProfile(WidgetTester tester, S s, TrainingController c) async {
  await tapHittable(
    tester,
    find.byKey(const ValueKey('offline-keys')),
    'keys and keyers',
  );
  expect(find.byType(KeySetupPage), findsOneWidget);
  await tapHittable(tester, find.byKey(const Key('keys-new')), 'new profile');
  expect(find.byType(KeyProfileEditorPage), findsOneWidget);
  await typeInto(tester, find.byKey(const Key('keys-name')), _profileName);
  await dismissKeyboard(tester);
  final iambicA = find.byKey(const Key('keys-mode-iambicA'));
  await revealIn(tester, iambicA, find.byType(KeyProfileEditorPage));
  await tapHittable(tester, iambicA, 'iambic A');
  // The editor is a lazy list: on a short phone Save is not built yet.
  final save = find.byKey(const Key('keys-save'));
  await revealIn(tester, save, find.byType(KeyProfileEditorPage));
  await tapHittable(tester, save, 'save');
  await waitForWidget(tester, find.byType(KeySetupPage), 'back on the list');
  expect(find.byType(KeyProfileEditorPage), findsNothing);
  expect(find.text(_profileName), findsOneWidget);
  final profiles = tester
      .element(find.byType(KeySetupPage))
      .read<KeyProfiles>();
  expect(profiles.active.name, _profileName);
  await waitFor(
    tester,
    () => c.settings.keyerMode == KeyerMode.iambicA,
    'Learn follows the saved profile',
  );
  await goBack(tester);
}

Future<void> _appearance(WidgetTester tester, S s) async {
  await tapFirstHittable(
    tester,
    find.descendant(
      of: find.byType(OfflineMePage),
      matching: find.text(s.appearanceTitle),
    ),
    'appearance',
  );
  expect(find.byType(AppearancePage), findsOneWidget);
  final apply = find.byKey(const ValueKey('appearance-apply'));
  expect(
    tester.widget<FilledButton>(apply).onPressed,
    isNull,
    reason: 'nothing to apply yet',
  );
  await tapHittable(
    tester,
    find.byKey(const ValueKey('style-paper')),
    'paper style',
  );
  await tapHittable(
    tester,
    find.byKey(const ValueKey('mode-dark')),
    'dark mode',
  );
  await tapHittable(tester, apply, 'apply');
  await waitForWidget(
    tester,
    find.text(s.appearanceApplied),
    'appearance applied',
  );
  final settings = tester
      .element(find.byType(AppShell, skipOffstage: false))
      .read<AppSettings>();
  expect(settings.style, UiStyle.paper);
  expect(settings.themeMode, ThemeMode.dark);
  expect(
    Theme.of(tester.element(find.byType(AppearancePage))).brightness,
    Brightness.dark,
  );
  await goBack(tester);
}

Future<void> _language(WidgetTester tester, S s) async {
  await tapFirstHittable(tester, find.text(s.languageTitle), 'language');
  final option = find.text(localeDisplayName(s, _german));
  await tester.scrollUntilVisible(
    option,
    100,
    scrollable: find
        .descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tapHittable(tester, option, 'Deutsch');
  await waitFor(
    tester,
    () => find.byType(AlertDialog).evaluate().isEmpty,
    'the dialog closes after saving',
  );
  final de = lookupS(_german);
  expect(find.text(de.navMe), findsWidgets);
  expect(
    tester.element(find.byType(AppShell)).read<LocaleController>().locale,
    _german,
  );
}

void _expectPreferences(WidgetTester tester) {
  final context = tester.element(find.byType(AppShell));
  expect(context.read<LocaleController>().locale, _german);
  expect(find.text(lookupS(_german).navLearn), findsWidgets);
  final appearance = context.read<AppSettings>();
  expect(appearance.style, UiStyle.paper);
  expect(appearance.themeMode, ThemeMode.dark);
  final keys = context.read<KeyProfiles?>()!;
  expect(keys.active.name, _profileName);
}

/// Cancelling keeps everything; confirming retires the controller and
/// reloads empty learning while device preferences stay.
Future<void> _clear(WidgetTester tester, S s, TrainingController c) async {
  await selectTab(tester, ShellTab.me);
  final clear = find.byKey(const ValueKey('offline-clear'));
  await tapHittable(tester, clear, 'clear learning data');
  await tapText(tester, s.actionCancel);
  expect(c.isDisposed, isFalse);
  expect(c.progress.dailyGoalChars, 88);

  await tapHittable(tester, clear, 'clear learning data');
  await tapText(tester, s.guestClearConfirm);
  await waitForWidget(tester, find.text(s.offlineCleared), 'cleared');
  expect(c.isDisposed, isTrue);

  await selectTab(tester, ShellTab.learn);
  await waitFor(tester, () {
    final home = tester.widget<LearnHome>(find.byType(LearnHome));
    return !identical(home.controller, c) && home.controller.isLoaded;
  }, 'fresh learning controller');
  final fresh = tester.widget<LearnHome>(find.byType(LearnHome)).controller;
  expect(fresh.progress.dailyGoalChars, TrainerProgress().dailyGoalChars);
  expect(fresh.progress.firstLessonDone, isFalse);
  expect(fresh.progress.history, isEmpty);
  expect(fresh.settings.trainer, const TrainingSettings().trainer);
  expect(
    find.byKey(const ValueKey('start-here')),
    findsOneWidget,
    reason: 'a cleared profile starts from the first lesson again',
  );
  _expectPreferences(tester);
}
