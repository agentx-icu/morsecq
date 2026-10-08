// Drives the real UI from scene to scene and captures each one.
//
// Layout-aware: on a phone the shell has a bottom NavigationBar and
// conversations open as pushed routes; on desktop/tablet a NavigationRail
// and an inline detail pane. Every navigation goes through the same widgets
// a user taps, found by localized text/tooltip or by the app's stable keys.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/startup/startup_controller.dart';
import 'package:morsecq/startup/startup_gate.dart';
import 'package:morsecq/ui/account/backup_wizard_page.dart';
import 'package:morsecq/ui/account/create_identity_page.dart';
import 'package:morsecq/ui/account/welcome_page.dart';
import 'package:morsecq/ui/chat/conversation_list.dart';
import 'package:morsecq/ui/chat/conversation_screen.dart';
import 'package:morsecq/ui/chat/message_bubble.dart';
import 'package:morsecq/ui/contacts/contacts_page.dart';
import 'package:morsecq/ui/groups/group_list.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/learn_home_widgets.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/settings/training_settings_screen.dart';
import 'package:morsecq/ui/listen/listen_screen.dart';
import 'package:morsecq/ui/pages/me_page.dart';
import 'package:morsecq/ui/pages/offline_me_page.dart';
import 'package:morsecq/ui/pages/reference_page.dart';
import 'package:morsecq/ui/reference/morse_pattern_text.dart';
import 'package:morsecq/ui/reference/text_to_morse_view.dart';
import 'package:morsecq/ui/reference/translator_screen.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq/ui/stats/stats_screen.dart';
import 'package:provider/provider.dart';

import 'seed_data.dart';
import 'shot_harness.dart';

/// Every scene the offline App Store build's run produces (`ios`, `ipad`),
/// in capture order. `tool/screenshots/capture.sh` checks the same list.
const List<String> kOfflineScenes = <String>[
  'learn_home',
  'stats',
  'training_settings',
  'receive_drill',
  'send_practice',
  'reference',
  'translator',
  'listen',
  'me',
];

/// Every scene the chat build's run must produce, in capture order.
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

/// Asserts a chat bubble carrying [text] is on screen (by message, so it
/// holds in training mode where the text itself is hidden). Only lines in
/// the viewport are built, so check the newest line: the conversation opens
/// scrolled to the bottom.
void expectBubble(String text) {
  expect(
    find.byWidgetPredicate((w) => w is MessageBubble && w.message.text == text),
    findsOneWidget,
    reason: 'bubble "$text"',
  );
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

Future<void> tapTooltip(WidgetTester tester, String tooltip) =>
    tapHittable(tester, find.byTooltip(tooltip), 'tooltip "$tooltip"');

Future<void> tapText(WidgetTester tester, String text) =>
    tapHittable(tester, find.text(text), 'text "$text"');

/// Welcome → create identity (name typed) → mandatory backup wizard.
Future<void> walkOnboarding(
  WidgetTester tester,
  ShotHarness shots,
  S s,
  SeedCopy copy,
) async {
  await settle(tester, extra: const Duration(milliseconds: 300));
  await shots.applyTheme(tester);
  expectScreen(WelcomePage);
  expect(find.text(s.accountCreateIdentity), findsOneWidget);
  await shots.capture(tester, copy.locale, 'welcome');

  await tapText(tester, s.accountCreateIdentity);
  expectScreen(CreateIdentityPage);
  await tester.enterText(find.byType(TextField).first, copy.heroName);
  await settle(tester);
  expect(find.text(copy.heroName), findsOneWidget);
  await shots.capture(tester, copy.locale, 'create_identity');

  await tapText(tester, s.accountCreateButton);
  expectScreen(BackupWizardPage);
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

  final copy = seed.copy;

  await walkLearn(tester, shots, s, locale);

  // Chat
  await selectTab(tester, ShellTab.chat);
  expectScreen(ConversationList);
  final qso = find.byKey(ValueKey<String>(seed.qsoConversationId));
  expect(qso, findsOneWidget, reason: 'seeded QSO in the list');
  expect(
    find.byKey(ValueKey<String>(seed.unreadConversationId)),
    findsOneWidget,
    reason: 'seeded unread conversation in the list',
  );
  await shots.capture(tester, locale, 'chat_list');
  await tapHittable(tester, qso, 'QSO conversation tile');
  await settle(tester, extra: const Duration(milliseconds: 300));
  expectScreen(ConversationScreen);
  expectBubble(copy.qso.last.text);
  await shots.capture(tester, locale, 'conversation');
  await popIfCan(tester);
  await tapTooltip(tester, s.chatContacts);
  expectScreen(ContactsPage);
  for (var i = 0; i < copy.friends.length; i++) {
    expect(
      find.byKey(ValueKey<String>('friend_${seedKey(i + 1)}')),
      findsOneWidget,
      reason: 'friend ${copy.friends[i].name}',
    );
  }
  expect(find.text(copy.requestMessage), findsOneWidget);
  await shots.capture(tester, locale, 'contacts');
  await popIfCan(tester);

  // Groups
  await selectTab(tester, ShellTab.groups);
  expectScreen(GroupList);
  final group = find.byKey(ValueKey<String>('group_${seed.groupId}'));
  expect(group, findsOneWidget, reason: 'seeded group in the list');
  await shots.capture(tester, locale, 'groups');
  await tapHittable(tester, group, 'group tile');
  await settle(tester, extra: const Duration(milliseconds: 300));
  expectScreen(ConversationScreen);
  expectBubble(copy.net.last.text);
  await shots.capture(tester, locale, 'group_conversation');
  await popIfCan(tester);

  await walkReference(tester, shots, s, locale);

  // Me
  await selectTab(tester, ShellTab.me);
  expectScreen(MePage);
  expect(find.text(copy.heroName), findsWidgets);
  await shots.capture(tester, locale, 'me');
}

/// Learn: home, statistics, training settings, a receive drill and send
/// practice. Shared by the chat and the offline walks.
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
  await shots.capture(tester, locale, 'receive_drill', until: () {
    return tester
        .widgetList<FlashOverlay>(find.byType(FlashOverlay))
        .every((w) => !w.isOn.value);
  });
  await popIfCan(tester);
  // The quick action, not today's plan step: in Chinese both read 发报练习,
  // and the 6.9" iPhone shows the plan too.
  await tapHittable(
    tester,
    find.descendant(
      of: find.byType(QuickActions),
      matching: find.text(s.learnSendPractice),
    ),
    'send practice quick action',
  );
  await settle(tester, extra: const Duration(milliseconds: 400));
  expectScreen(SendPracticeScreen);
  await shots.capture(tester, locale, 'send_practice');
  await popIfCan(tester);
}

/// Reference: the handbook, the translator and Listen. Shared by the chat
/// and the offline walks.
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
    find.byWidgetPredicate((w) => w is MorsePatternText && w.pattern == pattern),
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

/// The offline App Store build (`AppFeatures(chat: false)`): it opens
/// straight on Learn (no onboarding), has three destinations and the
/// offline Me page.
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
  expect(find.byType(WelcomePage), findsNothing);
  await walkLearn(tester, shots, s, locale);
  await walkReference(tester, shots, s, locale);
  await selectTab(tester, ShellTab.me);
  expectScreen(OfflineMePage);
  await shots.capture(tester, locale, 'me');
}
