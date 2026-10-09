import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/mistakes/mistake_notebook_screen.dart';
import 'package:morsecq/ui/learn/comprehension/listening_comprehension_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

MistakeNotebook _book() => MistakeNotebook().recordExercise(
  exerciseId: 'first',
  attempts: [
    MistakeAttempt(
      target: 'NAME JOHN',
      answer: 'NAME JON',
      source: ExerciseSource.focus,
      drillKind: 'qso',
      at: kTestNow,
      characterWpm: 25,
      effectiveWpm: 15,
    ),
  ],
);

void main() {
  testWidgets(
    'notebook keeps failures across screens and opens original retry',
    (tester) async {
      final t = await TestTraining.create(
        progress: TrainerProgress(mistakeNotebook: _book()),
      );
      addTearDown(t.controller.dispose);
      await tester.pumpWidget(
        l10nApp(
          home: MistakeNotebookScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('NAME JOHN'), findsOneWidget);
      expect(find.text('NAME JON'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('mistakes-retry')).first);
      await tester.pumpAndSettle();
      final receive = tester.widget<ReceiveDrillScreen>(
        find.byType(ReceiveDrillScreen),
      );
      expect(receive.session.currentDrill.text, 'NAME JOHN');
      expect(receive.session.timing.wpm, 25);
      expect(receive.session.timing.farnsworthWpm, 15);
      expect(receive.session.charBudget, 8);
    },
  );

  testWidgets('pending and recovered filters show independent-day progress', (
    tester,
  ) async {
    var book = _book();
    final entry = book.entries.single;
    for (var i = 0; i < 2; i++) {
      book = book.recordExercise(
        exerciseId: 'pass-$i',
        retryEntryId: entry.id,
        attempts: [
          MistakeAttempt(
            target: entry.target,
            answer: entry.target,
            source: ExerciseSource.review,
            drillKind: 'qso',
            at: kTestNow.add(Duration(days: i + 1)),
            characterWpm: 25,
            effectiveWpm: 15,
          ),
        ],
      );
    }
    final t = await TestTraining.create(
      progress: TrainerProgress(mistakeNotebook: book),
    );
    addTearDown(t.controller.dispose);
    await tester.pumpWidget(
      l10nApp(
        home: MistakeNotebookScreen(
          controller: t.controller,
          playback: FakeLearnPlaybackFactory(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('NAME JOHN'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('mistakes-filter-recovered')));
    await tester.pumpAndSettle();
    expect(find.text('NAME JOHN'), findsWidgets);
    expect(
      find.byKey(const ValueKey('mistakes-recovered-status')),
      findsOneWidget,
    );
  });

  testWidgets('Chinese notebook fits a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final t = await TestTraining.create(
      progress: TrainerProgress(mistakeNotebook: _book()),
    );
    addTearDown(t.controller.dispose);
    await tester.pumpWidget(
      l10nApp(
        locale: const Locale('zh'),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: MistakeNotebookScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(
      find.byKey(const ValueKey('mistakes-retry')).first,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('semantic notebook retries ask the saved information fields', (
    tester,
  ) async {
    final exercise = ListeningExercise(
      mode: ListeningMode.story,
      spokenText: 'ANNA WALKS TO THE PARK AT NOON',
      questions: [
        ListeningQuestion(field: ListeningField.person, answer: 'ANNA'),
        ListeningQuestion(
          field: ListeningField.time,
          answer: 'NOON',
          alternatives: ['12'],
        ),
      ],
    );
    final book = MistakeNotebook().recordExercise(
      exerciseId: 'semantic-failure',
      attempts: [
        MistakeAttempt.listening(
          exercise: exercise,
          answers: {ListeningField.person: 'ANA', ListeningField.time: ''},
          at: kTestNow,
          characterWpm: 25,
          effectiveWpm: 15,
        ),
      ],
    );
    final t = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 42, mistakeNotebook: book),
    );
    addTearDown(t.controller.dispose);
    await tester.pumpWidget(
      l10nApp(
        home: MistakeNotebookScreen(
          controller: t.controller,
          playback: FakeLearnPlaybackFactory(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('mistakes-retry')).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mistakes-retry')).first);
    await tester.pumpAndSettle();
    expect(find.byType(ReceiveDrillScreen), findsNothing);
    expect(find.byType(ListeningComprehensionScreen), findsOneWidget);
  });
}
