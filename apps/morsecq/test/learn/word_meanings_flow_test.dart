import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/receive/round_result_view.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

void main() {
  testWidgets('word meaning appears only after submitting the answer', (
    tester,
  ) async {
    final training = await TestTraining.create();
    addTearDown(training.controller.dispose);
    final session = ReceiveSession(
      kind: ReceiveDrillKind.words,
      generator: WordDrill(words: const <String>['THE'], wordCount: 1),
      chars: MorseAlphabet.kochOrder,
      timing: const MorseTiming(wpm: 20, farnsworthWpm: 8),
      charBudget: 3,
      random: Random(1),
      now: () => kTestNow,
    );
    await tester.pumpWidget(
      l10nApp(
        home: ReceiveDrillScreen(
          controller: training.controller,
          playback: FakeLearnPlaybackFactory(),
          session: session,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('round-meanings')), findsNothing);
    expect(find.textContaining('specific person or thing'), findsNothing);

    await tester.enterText(find.byType(TextField), 'THE');
    await tester.tap(find.widgetWithText(FilledButton, en.learnSubmit));
    await tester.pumpAndSettle();

    expect(find.byType(RoundResultView), findsOneWidget);
    expect(
      find.text('THE — indicates a specific person or thing'),
      findsOneWidget,
    );
  });
}
