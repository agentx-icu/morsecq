import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/legal/legal_pages.dart';

import '../learn/helpers/l10n.dart';

final S en = lookupS(const Locale('en'));

void main() {
  testWidgets(
    'the privacy policy page is readable in-app without a web action',
    (tester) async {
      await tester.pumpWidget(l10nApp(home: const PrivacyPolicyPage()));
      await tester.pumpAndSettle();

      expect(find.text(en.aboutPrivacyPolicy), findsOneWidget);
      expect(find.textContaining('account-free, offline'), findsOneWidget);
      expect(find.textContaining('RECORD_AUDIO'), findsOneWidget);

      expect(find.byType(TextButton), findsNothing);
      expect(find.byIcon(Icons.open_in_new), findsNothing);
    },
  );

  testWidgets('the terms page is readable in-app without a web action', (
    tester,
  ) async {
    await tester.pumpWidget(l10nApp(home: const TermsOfUsePage()));
    await tester.pumpAndSettle();

    expect(find.text(en.aboutTermsOfUse), findsOneWidget);
    expect(find.textContaining('GPL-3.0'), findsOneWidget);

    expect(find.byType(TextButton), findsNothing);
    expect(find.byIcon(Icons.open_in_new), findsNothing);
  });

  testWidgets('the double-list and permission pages render their text', (
    tester,
  ) async {
    await tester.pumpWidget(l10nApp(home: const PersonalInfoListPage()));
    await tester.pumpAndSettle();
    expect(find.text(en.accountPersonalInfoList), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new), findsNothing);
    expect(
      find.textContaining('does not collect personal information'),
      findsOneWidget,
    );

    await tester.pumpWidget(l10nApp(home: const ThirdPartyShareListPage()));
    await tester.pumpAndSettle();
    expect(find.text(en.accountThirdPartyShareList), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new), findsNothing);
    expect(
      find.textContaining('does not share personal information'),
      findsOneWidget,
    );

    await tester.pumpWidget(l10nApp(home: const PermissionListPage()));
    await tester.pumpAndSettle();
    expect(find.text(en.accountPermissionList), findsOneWidget);
    expect(find.textContaining('RECORD_AUDIO'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new), findsNothing);
  });

  testWidgets('the Me privacy section opens the in-app pages', (tester) async {
    await tester.pumpWidget(
      l10nApp(
        home: Scaffold(body: ListView(children: const [LegalLinksSection()])),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('about-privacy')));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('about-terms')));
    await tester.pumpAndSettle();
    expect(find.byType(TermsOfUsePage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('account-permissions')));
    await tester.pumpAndSettle();
    expect(find.byType(PermissionListPage), findsOneWidget);
  });
}
