import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/pages/offline_me_page.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('Me opens an appearance chooser with four styles', (
    tester,
  ) async {
    await pumpApp(tester);
    final s = lookupS(const Locale('en'));
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(OfflineMePage.title(s)),
      ),
    );
    await settle(tester);
    expect(find.text('Appearance'), findsOneWidget);
    await tapVisible(tester, find.text('Appearance'));
    for (final name in [
      'Minimal White',
      'Brass Handbook',
      'Night Radio',
      'Fresh Cartoon',
    ]) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('Modern Calm'), findsNothing);
    expect(find.text('Paper Handbook'), findsNothing);
    expect(find.text('Apply style'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
