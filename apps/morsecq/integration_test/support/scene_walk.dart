// Drives the real UI from scene to scene and captures each one.
//
// Layout-aware: on a phone the shell has a bottom NavigationBar and
// conversations open as pushed routes; on desktop/tablet a NavigationRail
// and an inline detail pane. Every navigation goes through the same widgets
// a user taps, found by localized text/tooltip or by the app's stable keys.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/startup/startup_controller.dart';
import 'package:morsecq/startup/startup_gate.dart';
import 'package:morsecq/ui/reference/text_to_morse_view.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:provider/provider.dart';

import 'seed_data.dart';
import 'shot_harness.dart';

/// Every scene the screenshot run must produce, in capture order.
/// `tool/screenshots/capture.sh` checks the same list.
const List<String> kScenes = <String>[
  'welcome',
  'create_identity',
  'backup_wizard',
  'learn_home',
  'stats',
  'training_settings',
  'receive_drill',
  'send_practice',
  'chat_list',
  'conversation',
  'contacts',
  'groups',
  'group_conversation',
  'reference',
  'translator',
  'listen',
  'me',
];

/// Index into [kShellDestinations].
enum ShellTab { learn, chat, groups, reference, me }

Finder _navHost() => find.byWidgetPredicate(
  (w) => w is NavigationRail || w is NavigationBar,
);

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
  expect(finder, findsOneWidget, reason: 'destination ${tab.name}');
  await tester.tap(finder);
  await settle(tester);
}

/// Pops the top route of the root navigator when there is one (a pushed
/// conversation on a phone); a no-op for an inline desktop pane.
Future<void> popIfCan(WidgetTester tester) async {
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  if (nav.canPop()) {
    nav.pop();
    await settle(tester);
  }
}

/// Prints the startup phase/error and every visible string, for the log of
/// a run that did not reach the shell.
Future<void> dumpStartupState(WidgetTester tester) async {
  final gate = find.byType(StartupGate);
  if (gate.evaluate().isNotEmpty) {
    final controller = tester.element(gate).read<StartupController>();
    debugPrint('[shot] startup phase=${controller.phase} '
        'error=${controller.error} connection=${controller.connectionError}');
  }
  final texts = find.byType(Text).evaluate().map((e) {
    final t = e.widget as Text;
    return t.data ?? t.textSpan?.toPlainText() ?? '';
  }).where((t) => t.isNotEmpty);
  debugPrint('[shot] visible text: ${texts.join(' | ')}');
}

Future<void> tapTooltip(WidgetTester tester, String tooltip) async {
  final finder = find.byTooltip(tooltip);
  expect(finder, findsOneWidget, reason: 'tooltip "$tooltip"');
  await tester.tap(finder);
  await settle(tester);
}

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  expect(finder, findsOneWidget, reason: 'text "$text"');
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await settle(tester);
}

/// Welcome → create identity (name typed) → mandatory backup wizard.
Future<void> walkOnboarding(
  WidgetTester tester,
  ShotHarness shots,
  S s,
  SeedCopy copy,
) async {
  await settle(tester, extra: const Duration(milliseconds: 300));
  await shots.applyTheme(tester);
  expect(find.text(s.accountCreateIdentity), findsOneWidget);
  await shots.capture(tester, copy.locale, 'welcome');

  await tapText(tester, s.accountCreateIdentity);
  await tester.enterText(find.byType(TextField).first, copy.heroName);
  await settle(tester);
  await shots.capture(tester, copy.locale, 'create_identity');

  await tapText(tester, s.accountCreateButton);
  expect(find.text(s.accountBackupContinue), findsOneWidget);
  await shots.capture(tester, copy.locale, 'backup_wizard');
}

/// Every shell scene, from the seeded identity.
Future<void> walkShell(
  WidgetTester tester,
  ShotHarness shots,
  S s,
  SeededBackend seed,
) async {
  final locale = seed.copy.locale;
  await settle(tester, extra: const Duration(milliseconds: 500));
  await shots.applyTheme(tester);
  if (find.byType(AppShell).evaluate().isEmpty) {
    await dumpStartupState(tester);
  }
  expect(find.byType(AppShell), findsOneWidget);

  // Learn
  expect(find.text(s.learnContinueLesson), findsOneWidget);
  await shots.capture(tester, locale, 'learn_home');
  await tapTooltip(tester, s.learnStatistics);
  await settle(tester, extra: const Duration(milliseconds: 300));
  await shots.capture(tester, locale, 'stats');
  await popIfCan(tester);
  await tapTooltip(tester, s.learnSettings);
  await shots.capture(tester, locale, 'training_settings');
  await popIfCan(tester);
  await tapText(tester, s.learnContinueLesson);
  await settle(tester, extra: const Duration(milliseconds: 1200));
  await shots.capture(tester, locale, 'receive_drill');
  await popIfCan(tester);
  await tapText(tester, s.learnSendPractice);
  await settle(tester, extra: const Duration(milliseconds: 400));
  await shots.capture(tester, locale, 'send_practice');
  await popIfCan(tester);

  // Chat
  await selectTab(tester, ShellTab.chat);
  await shots.capture(tester, locale, 'chat_list');
  final qso = find.byKey(ValueKey<String>(seed.qsoConversationId));
  expect(qso, findsOneWidget);
  await tester.tap(qso);
  await settle(tester, extra: const Duration(milliseconds: 300));
  await shots.capture(tester, locale, 'conversation');
  await popIfCan(tester);
  await tapTooltip(tester, s.chatContacts);
  await shots.capture(tester, locale, 'contacts');
  await popIfCan(tester);

  // Groups
  await selectTab(tester, ShellTab.groups);
  await shots.capture(tester, locale, 'groups');
  final group = find.byKey(ValueKey<String>('group_${seed.groupId}'));
  expect(group, findsOneWidget);
  await tester.tap(group);
  await settle(tester, extra: const Duration(milliseconds: 300));
  await shots.capture(tester, locale, 'group_conversation');
  await popIfCan(tester);

  // Reference
  await selectTab(tester, ShellTab.reference);
  await shots.capture(tester, locale, 'reference');
  await tapTooltip(tester, s.referenceTranslatorTitle);
  await tester.enterText(
    find.byKey(TextToMorseView.inputKey),
    'CQ CQ DE MORSECQ K',
  );
  await settle(tester);
  await shots.capture(tester, locale, 'translator');
  await popIfCan(tester);
  await tapTooltip(tester, s.listenTitle);
  await shots.capture(tester, locale, 'listen');
  await popIfCan(tester);

  // Me
  await selectTab(tester, ShellTab.me);
  await shots.capture(tester, locale, 'me');
}
