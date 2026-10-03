import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/ui/learn/receive/drill_picker_sheet.dart';

import 'helpers/l10n.dart';

const List<ReceiveDrillKind> _all = <ReceiveDrillKind>[
  ReceiveDrillKind.groups,
  ReceiveDrillKind.characters,
  ReceiveDrillKind.words,
  ReceiveDrillKind.abbreviations,
  ReceiveDrillKind.numbers,
  ReceiveDrillKind.callsigns,
  ReceiveDrillKind.confusables,
  ReceiveDrillKind.qso,
  ReceiveDrillKind.contest,
];

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('every drill has a distinct label and hint in both locales', (
    tester,
  ) async {
    for (final locale in S.supportedLocales) {
      final s = lookupS(locale);
      final labels = ReceiveDrillKind.values.map((k) => drillLabel(s, k));
      expect(labels.toSet(), hasLength(ReceiveDrillKind.values.length));
      final hints = ReceiveDrillKind.values.map((k) => drillDescription(s, k));
      expect(hints.toSet(), hasLength(ReceiveDrillKind.values.length));
    }
  });

  testWidgets('the sheet scrolls on a small phone and returns the pick', (
    tester,
  ) async {
    await _setSize(tester, const Size(360, 640));
    ReceiveDrillKind? picked;
    await tester.pumpWidget(
      l10nApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async =>
                    picked = await showDrillPickerSheet(context, _all),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(en.learnChooseDrill), findsOneWidget);

    final last = find.byKey(DrillPickerList.tileKey(ReceiveDrillKind.contest));
    await tester.scrollUntilVisible(
      last,
      100,
      scrollable: find.descendant(
        of: find.byType(DrillPickerList),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(last);
    await tester.pumpAndSettle();
    expect(find.text(en.learnDrillContestHint), findsOneWidget);
    await tester.tap(last);
    await tester.pumpAndSettle();
    expect(picked, ReceiveDrillKind.contest);
  });
}
