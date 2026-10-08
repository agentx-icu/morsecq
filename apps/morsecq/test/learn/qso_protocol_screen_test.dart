import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/qso/qso_protocol_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_setup_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

void main() {
  Future<TestTraining> pumpQuiz(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final t = await TestTraining.create();
    addTearDown(t.controller.dispose);
    await tester.pumpWidget(
      l10nApp(home: QsoProtocolScreen(controller: t.controller)),
    );
    return t;
  }

  Future<void> answer(WidgetTester tester, QsoProtocolConcept choice) async {
    await tester.tap(
      find.byKey(ValueKey('qso-protocol-answer-${choice.name}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('qso-protocol-next')));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'four first answers record independent understanding, activity only',
    (tester) async {
      final t = await pumpQuiz(tester);
      for (final c in QsoProtocolConcept.values) {
        await answer(tester, c);
      }
      expect(find.text(en.learnQsoProtocolPass), findsOneWidget);
      final row = t.controller.progress.history.single;
      expect(row.sourceRef, QsoProtocolAttempt.passedSourceRef);
      expect(row.source, ExerciseSource.qso);
      expect(row.isKnownUnassisted, isTrue);
      expect(t.controller.progress.charStats, isEmpty);
      expect(t.controller.currentLesson, 1);
    },
  );

  testWidgets(
    'wrong answers show feedback and retry creates a separate attempt',
    (tester) async {
      final t = await pumpQuiz(tester);
      await answer(tester, QsoProtocolConcept.bestRegards);
      for (final c in QsoProtocolConcept.values.skip(1)) {
        await answer(tester, c);
      }
      expect(find.text(en.learnQsoProtocolPractice), findsOneWidget);
      expect(
        t.controller.progress.history.single.sourceRef,
        'protocol:3/4:firstTry=false',
      );
      await tester.tap(find.text(en.learnQsoProtocolRetry));
      await tester.pumpAndSettle();
      for (final c in QsoProtocolConcept.values) {
        await answer(tester, c);
      }
      expect(t.controller.progress.history, hasLength(2));
      expect(
        t.controller.progress.history.last.sourceRef,
        QsoProtocolAttempt.passedSourceRef,
      );
      expect(
        t.controller.progress.history.first.id,
        isNot(t.controller.progress.history.last.id),
      );
    },
  );

  testWidgets(
    'introduced characters offer consolidation and full exploration stays explicit',
    (tester) async {
      tester.view.physicalSize = const Size(390, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 42),
      );
      addTearDown(t.controller.dispose);
      await tester.pumpWidget(
        l10nApp(
          home: QsoSetupScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('qso-practise-symbols')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('qso-practise-protocol')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('qso-practise-exchange')),
        findsOneWidget,
      );
      expect(find.text(en.learnQsoExplorePending), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('qso-practise-protocol')));
      await tester.pumpAndSettle();
      expect(find.text(en.learnQsoProtocolQuestion('CQ')), findsOneWidget);
    },
  );
}
