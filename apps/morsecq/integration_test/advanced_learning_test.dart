import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/ui/learn/comprehension/listening_comprehension_screen.dart';
import 'package:morsecq/ui/learn/goals/goal_route_screen.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';
import 'package:morsecq/ui/learn/mistakes/mistake_notebook_screen.dart';

import 'support/native_advanced_playback.dart';
import 'support/shot_harness.dart';

Future<void> waitUntil(
  WidgetTester tester,
  bool Function() ready,
  String label,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (!ready() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await tester.pump();
  }
  expect(ready(), isTrue, reason: label);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native advanced practice, notebook and goal survive reopening', (
    tester,
  ) async {
    final scratch = await Directory.systemTemp.createTemp('morsecq_advanced_');
    addTearDown(() => scratch.delete(recursive: true));
    final store = LocalLearningStore(root: () async => scratch.path);
    final controller = await store.openController();
    final playback = NativeAdvancedPlayback();
    await ShotHarness(binding).prepareWindow(tester);
    await controller.commitProgress(
      (p) => p.copyWith(currentLesson: 42, courseCompleted: true),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: LearnHome(controller: controller, playback: playback),
      ),
    );
    await settle(tester);

    Future<void> open(String key) async {
      final entry = find.byKey(ValueKey(key));
      await tester.ensureVisible(entry);
      await tester.tap(entry);
      await settle(tester);
    }

    await open('learn-goal-route');
    expect(find.byType(GoalRouteScreen), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('goal-selector')));
    await settle(tester);
    await tester.tap(find.text(lookupS(const Locale('en')).goalsContest).last);
    await settle(tester);
    expect(controller.progress.learningGoal, LearningGoal.contest);
    await tester.pageBack();
    await settle(tester);

    await open('learn-comprehension');
    final play = find.byKey(const ValueKey('comprehension-play'));
    expect(tester.widget<OutlinedButton>(play).onPressed, isNotNull);
    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const ValueKey('comprehension-target')), findsNothing);
    await tester.tap(play);
    final submit = find.byKey(const ValueKey('comprehension-submit'));
    await waitUntil(
      tester,
      () => submit.evaluate().isNotEmpty,
      'complete the recorded native timeline before grading',
    );
    expect(playback.marks, greaterThan(0));
    expect(submit, findsOneWidget);
    await tester.ensureVisible(submit);
    await tester.tap(submit); // An omitted word must persist as a mistake.
    await settle(tester);
    expect(controller.progress.listeningAttempts.single.correct, 0);
    expect(controller.progress.mistakeNotebook.pending.length, 1);
    expect(controller.progress.charStats, isEmpty);
    await tester.pageBack();
    await settle(tester);
    await open('learn-mistakes');
    expect(find.byType(MistakeNotebookScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('mistakes-retry')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await controller.flush();
    controller.dispose();
    final reopened = await store.openController();
    expect(reopened.progress.learningGoal, LearningGoal.contest);
    expect(reopened.progress.listeningAttempts.length, 1);
    expect(
      reopened.progress.mistakeNotebook.pending.single.listeningContext,
      isNotNull,
    );
    reopened.dispose();
  });

  testWidgets('native device head copy completes or blocks unavailable audio', (
    tester,
  ) async {
    final scratch = await Directory.systemTemp.createTemp('morsecq_audio_');
    addTearDown(() => scratch.delete(recursive: true));
    final controller = await LocalLearningStore(
      root: () async => scratch.path,
    ).openController();
    addTearDown(controller.dispose);
    await controller.commitProgress((p) => p.copyWith(currentLesson: 42));
    await ShotHarness(binding).prepareWindow(tester);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: ListeningComprehensionScreen(
          controller: controller,
          playback: const DevicePlaybackFactory(),
        ),
      ),
    );
    final play = find.byKey(const ValueKey('comprehension-play'));
    final submit = find.byKey(const ValueKey('comprehension-submit'));
    final failure = find.text(
      lookupS(const Locale('en')).comprehensionAudioFailed,
    );
    bool failed() => failure.evaluate().isNotEmpty;
    bool ready() =>
        play.evaluate().isNotEmpty &&
        tester.widget<OutlinedButton>(play).onPressed != null;
    await waitUntil(tester, () => ready() || failed(), 'native audio setup');
    if (!failed()) {
      await tester.ensureVisible(play);
      await tester.tap(play);
      await waitUntil(
        tester,
        () => submit.evaluate().isNotEmpty || failed(),
        'native audio completion or a visible output failure',
      );
    }
    if (failed()) {
      debugPrint('[native] no audio output: assessment correctly blocked');
      expect(tester.widget<OutlinedButton>(play).onPressed, isNull);
      expect(submit, findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(const ValueKey('comprehension-target')), findsNothing);
      expect(controller.progress.listeningAttempts, isEmpty);
      expect(controller.progress.mistakeNotebook.entries, isEmpty);
    } else {
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await waitUntil(
        tester,
        () => controller.progress.listeningAttempts.length == 1,
        'persist the completed native audio attempt',
      );
      expect(controller.progress.listeningAttempts.single.correct, 0);
    }
    expect(controller.progress.charStats, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await controller.flush();
  });
}
