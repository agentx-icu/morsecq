import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/training/send_practice_start.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/settings/training_settings_screen.dart';
import 'package:morsecq/ui/listen/listen_screen.dart';
import 'package:morsecq/ui/pages/offline_me_page.dart';
import 'package:morsecq/ui/pages/reference_page.dart';
import 'package:morsecq/ui/reference/morse_pattern_text.dart';
import 'package:morsecq/ui/reference/text_to_morse_view.dart';
import 'package:morsecq/ui/reference/translator_screen.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq/ui/stats/stats_screen.dart';
import 'shot_harness.dart';
import 'pedagogy_walk.dart';

const kScenes = [
  'learn_home',
  'stats',
  'training_settings',
  'receive_drill',
  'send_practice',
  'first_lesson',
  'receive_summary',
  'guided_send',
  'reference',
  'translator',
  'listen',
  'me',
];
const kOfflineScenes = kScenes;

enum ShellTab { learn, reference, me }

Finder _navHost() =>
    find.byWidgetPredicate((w) => w is NavigationRail || w is NavigationBar);

/// Taps a shell destination by its icon (rail labels are hidden on desktop,
/// and the bar label text also appears as the page's app-bar title).
Future<void> selectTab(WidgetTester tester, ShellTab tab) async {
  final d = kShellDestinations[tab.index];
  var finder = find.descendant(of: _navHost(), matching: find.byIcon(d.icon));
  if (finder.evaluate().isEmpty) {
    finder = find.descendant(
      of: _navHost(),
      matching: find.byIcon(d.selectedIcon),
    );
  }
  await tapHittable(tester, finder, 'destination ${tab.name}');
}

/// Taps [finder] after asserting it resolves to exactly one widget that a
/// pointer can actually reach (not covered by a SnackBar, a sheet or an
/// offstage route), then settles. `tester.tap` alone only warns on a miss.
Future<void> tapHittable(
  WidgetTester tester,
  Finder finder,
  String what,
) async {
  expect(finder, findsOneWidget, reason: what);
  await tester.ensureVisible(finder);
  await tester.pump();
  expect(finder.hitTestable(), findsOneWidget, reason: '$what is hittable');
  await tester.tap(finder);
  await settle(tester);
}

/// Asserts the screen a scene is about to capture is on stage.
void expectScreen(Type screen) {
  expect(find.byType(screen), findsOneWidget, reason: '$screen on screen');
}

Future<void> popIfCan(WidgetTester tester) async {
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  if (nav.canPop()) {
    nav.pop();
    await settle(tester);
  }
}

Future<void> tapTooltip(WidgetTester tester, String tooltip) =>
    tapHittable(tester, find.byTooltip(tooltip), 'tooltip "$tooltip"');

Future<void> tapText(WidgetTester tester, String text) =>
    tapHittable(tester, find.text(text), 'text "$text"');

Future<void> dumpStartupState(WidgetTester tester) async {}
Future<void> walkLearn(
  WidgetTester tester,
  ShotHarness shots,
  S s,
  String locale,
) async {
  // Learn
  expectScreen(LearnHome);
  expect(find.text(s.learnContinueLesson), findsOneWidget);
  await shots.capture(tester, locale, 'learn_home');
  await tapTooltip(tester, s.learnStatistics);
  await settle(tester, extra: const Duration(milliseconds: 300));
  expectScreen(StatsScreen);
  await shots.capture(tester, locale, 'stats');
  await popIfCan(tester);
  await tapTooltip(tester, s.learnSettings);
  expectScreen(TrainingSettingsScreen);
  await shots.capture(tester, locale, 'training_settings');
  await popIfCan(tester);
  await tapText(tester, s.learnContinueLesson);
  await settle(tester, extra: const Duration(milliseconds: 1200));
  expectScreen(ReceiveDrillScreen);
  // Without an audio device (CI runners) the drill falls back to the
  // full-screen flash; capture between flashes.
  await shots.capture(
    tester,
    locale,
    'receive_drill',
    until: () {
      return tester
          .widgetList<FlashOverlay>(find.byType(FlashOverlay))
          .every((w) => !w.isOn.value);
    },
  );
  await popIfCan(tester);
  // Free sending and the guided first-use surface are distinct scenes.
  final home = tester.widget<LearnHome>(find.byType(LearnHome));
  unawaited(
    Navigator.of(tester.element(find.byType(LearnHome))).push(
      MaterialPageRoute<Object?>(
        builder: (_) => SendPracticeScreen(
          controller: home.controller,
          playback: home.playback,
          session: home.controller.startFreeSendSession(),
        ),
      ),
    ),
  );
  await settle(tester, extra: const Duration(milliseconds: 400));
  expectScreen(SendPracticeScreen);
  await shots.capture(tester, locale, 'send_practice');
  await popIfCan(tester);
  await capturePedagogy(tester, shots, locale);
}

/// Reference: the handbook, the translator and Listen.
Future<void> walkReference(
  WidgetTester tester,
  ShotHarness shots,
  S s,
  String locale,
) async {
  // Reference
  await selectTab(tester, ShellTab.reference);
  expectScreen(ReferencePage);
  await shots.capture(tester, locale, 'reference');
  await tapTooltip(tester, s.referenceTranslatorTitle);
  expectScreen(TranslatorScreen);
  const plain = 'CQ CQ DE MORSECQ K';
  await tester.enterText(find.byKey(TextToMorseView.inputKey), plain);
  await settle(tester);
  final pattern = MorseEncoder.toPattern(plain);
  expect(
    find.byWidgetPredicate(
      (w) => w is MorsePatternText && w.pattern == pattern,
    ),
    findsOneWidget,
    reason: 'translator output for "$plain"',
  );
  await shots.capture(tester, locale, 'translator');
  await popIfCan(tester);
  await tapTooltip(tester, s.listenTitle);
  expectScreen(ListenScreen);
  await shots.capture(tester, locale, 'listen');
  await popIfCan(tester);
}

/// The account-free application opens directly on Learn with three
/// destinations and local preferences on Me.
Future<void> walkOffline(
  WidgetTester tester,
  ShotHarness shots,
  S s,
  String locale,
) async {
  await settle(tester, extra: const Duration(milliseconds: 500));
  await shots.applyTheme(tester);
  if (find.byType(AppShell).evaluate().isEmpty) {
    await dumpStartupState(tester);
  }
  expect(find.byType(AppShell), findsOneWidget);
  await walkLearn(tester, shots, s, locale);
  await walkReference(tester, shots, s, locale);
  await selectTab(tester, ShellTab.me);
  expectScreen(OfflineMePage);
  await shots.capture(tester, locale, 'me');
}
