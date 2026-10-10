import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/telegraph_sessions.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_practice_screen.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_recall_screen.dart';
import 'package:morsecq/ui/telegraph/telegraph_interpret_sheet.dart';
import 'package:morsecq/ui/telegraph/telegraph_labels.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

/// One finished digit-copying attempt in [book]: 8 digits, [correct] right.
SessionSummary _digits(TelegraphCodebook book, int correct, int i) =>
    SessionSummary(
      at: kTestNow.subtract(Duration(hours: i + 1)),
      totalChars: 8,
      correctChars: correct,
      drillKind: 'numbers',
      lesson: 20,
      id: 'tg-${book.name}-$i',
      source: ExerciseSource.focus,
      sourceRef: TelegraphCurriculum.sourceRef(book),
    );

Future<TestTraining> _pump(
  WidgetTester tester, {
  TrainerProgress? progress,
}) async {
  tester.view.physicalSize = const Size(430, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final t = await TestTraining.create(
    progress: progress ?? TrainerProgress(currentLesson: 20),
  );
  addTearDown(t.controller.dispose);
  await tester.pumpWidget(
    l10nApp(
      home: TelegraphPracticeScreen(
        controller: t.controller,
        playback: FakeLearnPlaybackFactory(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return t;
}

String _sampleLine(TelegraphCodebook book) => [
  for (final c in TelegraphCurriculum.introductoryFor(book).take(5))
    '$c ${ChineseTelegraphCode.codeOf(c, codebook: book)}',
].join('   ');

void main() {
  group('TelegraphPracticeScreen', () {
    testWidgets('the sample follows the chosen codebook', (tester) async {
      await _pump(tester);
      expect(find.text(en.telegraphTitle), findsOneWidget);
      expect(
        find.text(_sampleLine(TelegraphCodebook.mainland)),
        findsOneWidget,
      );
      // The two books spell 0948 differently (国 / 國).
      expect(
        _sampleLine(TelegraphCodebook.mainland),
        isNot(_sampleLine(TelegraphCodebook.taiwan)),
      );
      await tester.tap(find.byKey(const ValueKey('codebook-taiwan')));
      await tester.pumpAndSettle();
      expect(find.text(_sampleLine(TelegraphCodebook.taiwan)), findsOneWidget);
      expect(find.text(_sampleLine(TelegraphCodebook.mainland)), findsNothing);
      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      expect(chips.where((c) => c.selected), hasLength(1));
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('codebook-taiwan')))
            .selected,
        isTrue,
      );
    });

    testWidgets('digit and recall results are kept per codebook', (
      tester,
    ) async {
      final t = await TestTraining.create(
        progress: TrainerProgress(
          currentLesson: 20,
          history: [
            _digits(TelegraphCodebook.taiwan, 6, 1),
            _digits(TelegraphCodebook.taiwan, 8, 0),
          ],
        ),
      );
      await t.controller.recordTelegraphRecall(TelegraphCodebook.mainland, [
        ('中', true, false),
        ('国', false, false),
      ]);
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        l10nApp(
          home: TelegraphPracticeScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mainland: recall answered, no digit attempts in this book.
      expect(find.textContaining(en.telegraphRecallResults(2, 50)), findsOne);
      expect(
        find.textContaining(en.telegraphDigitsResults(2, 88)),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('codebook-taiwan')));
      await tester.pumpAndSettle();
      // Taiwan: 14 of 16 digits right over two attempts; no recall yet.
      expect(find.textContaining(en.telegraphDigitsResults(2, 88)), findsOne);
      expect(
        find.textContaining(en.telegraphRecallResults(2, 50)),
        findsNothing,
      );
    });

    testWidgets('digit copying opens a drill in the chosen codebook', (
      tester,
    ) async {
      final t = await _pump(tester);
      await tester.tap(find.byKey(const ValueKey('codebook-taiwan')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('telegraph-digits')));
      await tester.pumpAndSettle();
      final drill = tester.widget<ReceiveDrillScreen>(
        find.byType(ReceiveDrillScreen),
      );
      expect(drill.title, en.telegraphDigitsTitle);
      expect(
        drill.session.sourceRef,
        TelegraphCurriculum.sourceRef(TelegraphCodebook.taiwan),
      );
      expect(drill.session.source, ExerciseSource.focus);
      expect(
        drill.session.countsTowardLesson,
        isFalse,
        reason: 'telegraph digits never advance the Koch course',
      );
      final lesson = t.controller.currentLesson;
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(TelegraphPracticeScreen), findsOneWidget);
      expect(t.controller.currentLesson, lesson);
    });

    testWidgets('recall opens in the chosen codebook and reloads results', (
      tester,
    ) async {
      final t = await _pump(tester);
      await tester.tap(find.byKey(const Key('telegraph-recall')));
      await tester.pumpAndSettle();
      final recall = tester.widget<TelegraphRecallScreen>(
        find.byType(TelegraphRecallScreen),
      );
      expect(recall.codebook, TelegraphCodebook.mainland);
      // An answer recorded while the recall screen was open shows up on
      // return.
      await t.controller.recordTelegraphRecall(TelegraphCodebook.mainland, [
        ('人', true, false),
      ]);
      expect(
        find.textContaining(en.telegraphRecallResults(1, 100)),
        findsNothing,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.textContaining(en.telegraphRecallResults(1, 100)), findsOne);
    });
  });

  group('TelegraphInterpretation', () {
    Future<void> pumpSheet(WidgetTester tester, String text) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        l10nApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    unawaited(showTelegraphInterpretation(context, text)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Finder subtitleOf(int i, String text) => find.descendant(
      of: find.byKey(ValueKey('telegraph-token-$i')),
      matching: find.text(text),
    );

    testWidgets('reads every token in order with its kind', (tester) async {
      await pumpSheet(tester, '0022 0948  CQ 123 9999');
      expect(find.text(en.telegraphInterpretTitle), findsOneWidget);
      for (final (i, source) in ['0022', '0948', 'CQ', '123', '9999'].indexed) {
        expect(subtitleOf(i, source), findsOneWidget, reason: 'token $i');
      }
      expect(find.byKey(const ValueKey('telegraph-token-5')), findsNothing);
      expect(subtitleOf(0, '中'), findsOneWidget);
      expect(subtitleOf(1, '国'), findsOneWidget);
      expect(subtitleOf(2, en.telegraphNotCode), findsOneWidget);
      expect(subtitleOf(3, en.telegraphMalformed), findsOneWidget);
      expect(subtitleOf(4, en.telegraphUnresolved), findsOneWidget);
    });

    testWidgets('switching the codebook re-reads the same message', (
      tester,
    ) async {
      await pumpSheet(tester, '0948 8888');
      expect(subtitleOf(0, '国'), findsOneWidget);
      expect(subtitleOf(1, en.telegraphUnresolved), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('codebook-taiwan')));
      await tester.pumpAndSettle();
      expect(subtitleOf(0, '國'), findsOneWidget);
      expect(subtitleOf(0, '国'), findsNothing);
      // 8888 exists only in the Taiwan book.
      expect(subtitleOf(1, en.telegraphUnresolved), findsNothing);
      expect(
        subtitleOf(
          1,
          ChineseTelegraphCode.charsOf(
            '8888',
            codebook: TelegraphCodebook.taiwan,
          ).join(' / '),
        ),
        findsOneWidget,
      );
    });

    testWidgets('an empty message lists no tokens', (tester) async {
      await pumpSheet(tester, '   ');
      expect(find.text(en.telegraphInterpretTitle), findsOneWidget);
      expect(find.byKey(const ValueKey('telegraph-token-0')), findsNothing);
    });
  });

  test('every codebook has a distinct label in English', () {
    final labels = {
      for (final b in TelegraphCodebook.values) codebookLabel(en, b),
    };
    expect(labels, hasLength(TelegraphCodebook.values.length));
    expect(labels, everyElement(isNotEmpty));
  });
}
