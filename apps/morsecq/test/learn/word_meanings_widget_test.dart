import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/ui/learn/receive/round_result_view.dart';

import 'helpers/l10n.dart';

ReceiveRound _round(String text) => ReceiveRound(
  index: 0,
  drill: Drill.fromText(text),
  answer: text,
  score: SessionScore.evaluate(text, text, at: DateTime(2026, 10, 8)),
);

void main() {
  testWidgets('word round explains THE in Simplified Chinese', (tester) async {
    await tester.pumpWidget(
      l10nApp(
        locale: const Locale('zh'),
        home: Scaffold(
          body: RoundResultView(
            round: _round('THE'),
            kind: ReceiveDrillKind.words,
          ),
        ),
      ),
    );
    expect(find.text('THE — 这／那；特指的人或事物'), findsOneWidget);
  });

  testWidgets('word round resolves Traditional Chinese UI locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      l10nApp(
        locale: const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
        ),
        home: Scaffold(
          body: RoundResultView(
            round: _round('RADIO HEAR'),
            kind: ReceiveDrillKind.words,
          ),
        ),
      ),
    );
    expect(find.text('RADIO — 無線電；收音機'), findsOneWidget);
    expect(find.text('HEAR — 聽見'), findsOneWidget);
  });

  testWidgets('word meanings do not change CW shorthand results', (
    tester,
  ) async {
    await tester.pumpWidget(
      l10nApp(
        locale: const Locale('zh'),
        home: Scaffold(
          body: RoundResultView(
            round: _round('CQ DE K'),
            kind: ReceiveDrillKind.abbreviations,
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('round-meanings')), findsOneWidget);
    expect(find.textContaining('CQ — '), findsOneWidget);
    expect(find.textContaining('DE — '), findsOneWidget);
    expect(find.textContaining('K — '), findsOneWidget);
  });

  testWidgets('random letter groups do not gain word hints', (tester) async {
    await tester.pumpWidget(
      l10nApp(
        home: Scaffold(
          body: RoundResultView(
            round: _round('THE'),
            kind: ReceiveDrillKind.groups,
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('round-meanings')), findsNothing);
  });
}
