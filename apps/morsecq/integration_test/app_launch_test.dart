import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morsecq/main.dart' as app;
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/reference/translator_screen.dart';
import 'package:morsecq/ui/stats/stats_screen.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'support/scene_walk.dart';
import 'support/shot_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('installation opens learning, drills, statistics and reference', (
    tester,
  ) async {
    await app.main();
    await settle(tester, extra: const Duration(milliseconds: 500));
    expect(find.byType(AppShell), findsOneWidget);
    final context = tester.element(find.byType(AppShell));
    final s = S.of(context);
    expect(find.text(s.learnContinueLesson), findsOneWidget);
    await tapText(tester, s.learnContinueLesson);
    expect(find.byType(ReceiveDrillScreen), findsOneWidget);
    await popIfCan(tester);
    await tapTooltip(tester, s.learnStatistics);
    expect(find.byType(StatsScreen), findsOneWidget);
    await popIfCan(tester);
    await selectTab(tester, ShellTab.reference);
    await tapTooltip(tester, s.referenceTranslatorTitle);
    expect(find.byType(TranslatorScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
