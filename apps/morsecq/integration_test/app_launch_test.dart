// Real launch + click-through smoke: runs the app's own `main()` on the real
// platform (desktop shell, notifications, settings file included) and walks
// the product the way a first-time user does. This is the top of the test
// pyramid; `test/` covers the same screens hermetically.
//
// Requires `--dart-define=MORSECQ_FAKE_BACKEND=true`: the in-memory backend
// keeps nothing on disk, so every launch starts at onboarding. With the Tox
// backend a real identity would be created on the device.
//
//   flutter test integration_test/app_launch_test.dart -d macos \
//       --dart-define=MORSECQ_FAKE_BACKEND=true
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morsecq/di/backend_factory.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart' as app;
import 'package:morsecq/ui/chat/conversation_screen.dart';
import 'package:morsecq/ui/chat/message_bubble.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/reference/morse_pattern_text.dart';
import 'package:morsecq/ui/reference/text_to_morse_view.dart';
import 'package:morsecq/ui/reference/translator_screen.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq/ui/stats/stats_screen.dart';

import 'support/scene_walk.dart';
import 'support/shot_harness.dart';

/// A syntactically valid Tox ID that is not the hero's own.
final String kFriendToxId = '${'AB' * 32}${'0' * 12}';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start: onboarding, five tabs, drill, chat, translator', (
    tester,
  ) async {
    expect(
      kForceFakeBackend,
      isTrue,
      reason: 'run with --dart-define=MORSECQ_FAKE_BACKEND=true',
    );
    await app.main();
    await settle(tester, extra: const Duration(milliseconds: 500));

    // Strings in whatever language the device's settings file selects.
    S s() => S.of(tester.element(find.byType(Scaffold).first));

    // Onboarding
    expect(find.text(s().accountCreateIdentity), findsOneWidget);
    await tapText(tester, s().accountCreateIdentity);
    await tester.enterText(find.byType(TextField).first, 'Ann');
    await tapText(tester, s().accountCreateButton);
    expect(find.text(s().accountBackupContinue), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile));
    await settle(tester);
    await tapText(tester, s().accountBackupContinue);
    expect(find.byType(AppShell), findsOneWidget);

    // Learn: home loaded, a lesson drill opens and closes.
    await settle(tester, extra: const Duration(milliseconds: 500));
    expect(find.text(s().learnContinueLesson), findsOneWidget);
    await tapText(tester, s().learnContinueLesson);
    await settle(tester, extra: const Duration(milliseconds: 800));
    expect(find.byType(ReceiveDrillScreen), findsOneWidget);
    await popIfCan(tester);
    await tapTooltip(tester, s().learnStatistics);
    expect(find.byType(StatsScreen), findsOneWidget);
    await popIfCan(tester);

    // Chat: add a friend by Tox ID, open the conversation, send a line.
    await selectTab(tester, ShellTab.chat);
    await tapTooltip(tester, s().chatContacts);
    await tapTooltip(tester, s().chatAddFriend);
    await tester.enterText(find.byType(TextField).first, kFriendToxId);
    await settle(tester);
    await tapText(tester, s().chatSendRequest);
    // The fake adds the friend immediately (offline); its row shows the
    // shortened key. Tap it to open the conversation.
    final friendRow = find.textContaining('ABAB');
    expect(friendRow, findsWidgets);
    await tester.tap(friendRow.first);
    await settle(tester);
    expect(find.byType(ConversationScreen), findsOneWidget);
    // The "request sent" SnackBar sits over the send button for 4 s; clear
    // it so the tap lands on the button and not on the toast.
    ScaffoldMessenger.of(
      tester.element(find.byType(ConversationScreen)),
    ).clearSnackBars();
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'CQ CQ DE ANN');
    await settle(tester);
    await tapTooltip(tester, s().chatSend);
    // Sent: one bubble with the text, and the composer is empty again.
    expect(find.byType(MessageBubble), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MessageBubble),
        matching: find.text('CQ CQ DE ANN'),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      isEmpty,
    );
    await popIfCan(tester);

    // Groups tab renders.
    await selectTab(tester, ShellTab.groups);
    expect(find.text(s().chatCreateGroup), findsNothing);
    expect(find.byTooltip(s().chatCreateGroup), findsOneWidget);

    // Reference: translator encodes SOS.
    await selectTab(tester, ShellTab.reference);
    await tapTooltip(tester, s().referenceTranslatorTitle);
    expect(find.byType(TranslatorScreen), findsOneWidget);
    await tester.enterText(find.byKey(TextToMorseView.inputKey), 'SOS');
    await settle(tester);
    expect(
      find.text(displayMorsePattern('... --- ...'), findRichText: true),
      findsOneWidget,
    );
    await popIfCan(tester);

    // Me: identity card and the backend label.
    await selectTab(tester, ShellTab.me);
    expect(find.text('Ann'), findsWidgets);
    expect(find.textContaining('fake'), findsOneWidget);
  });
}
