import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq/ui/learn/comprehension/listening_comprehension_screen.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';
import 'package:morsecq/training/training_settings.dart';

import '../helpers/fake_playback.dart';
import '../helpers/l10n.dart';
import '../helpers/test_controller.dart';

Future<(TestTraining, FakeLearnPlaybackFactory)> open(
  WidgetTester tester, {
  ListeningMode mode = ListeningMode.words,
  int seed = 1,
  TrainerProgress? progress,
}) async {
  final training = await TestTraining.create(
    progress: progress ?? TrainerProgress(currentLesson: 40),
    seed: seed,
  );
  final playback = FakeLearnPlaybackFactory();
  addTearDown(training.controller.dispose);
  await tester.pumpWidget(
    l10nApp(
      home: ListeningComprehensionScreen(
        controller: training.controller,
        playback: playback,
        initialMode: mode,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (training, playback);
}

Future<void> listen(
  WidgetTester tester,
  FakeLearnPlaybackFactory playback,
) async {
  await tester.tap(find.byKey(const ValueKey('comprehension-play')));
  await tester.pump();
  playback.clock.advance(const Duration(minutes: 5));
  await tester.pumpAndSettle();
}

final class _RetryPlaybackFactory implements LearnPlaybackFactory {
  final fake = FakeLearnPlaybackFactory();
  var fail = true;
  @override
  Future<LearnPlayback> create(TrainingSettings settings) async {
    if (fail) {
      fail = false;
      throw StateError('audio device unavailable');
    }
    return fake.create(settings);
  }
}

final class _BrokenSink implements MorseSink {
  @override
  Future<void> prepare() async {}
  @override
  Future<void> dispose() async {}
  @override
  void on() => throw StateError('device lost output');
  @override
  void off() {}
}

final class _BrokenPlaybackFactory implements LearnPlaybackFactory {
  final fake = FakeLearnPlaybackFactory();
  var creates = 0;
  @override
  Future<LearnPlayback> create(TrainingSettings settings) async {
    if (creates++ > 0) return fake.create(settings);
    return LearnPlayback(
      sink: _BrokenSink(),
      clock: fake.clock,
      flash: null,
      dispose: () async {},
    );
  }
}

void main() {
  testWidgets(
    'target remains hidden until playback completes and answer is submitted',
    (tester) async {
      final (training, playback) = await open(tester);
      // The text is not exposed by any answer widget before listening.
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(const ValueKey('comprehension-target')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('comprehension-play')));
      await tester.pump();
      expect(playback.sink.events, isNotEmpty);
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(const ValueKey('comprehension-reveal')), findsNothing);
      playback.clock.advance(const Duration(minutes: 5));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byKey(const ValueKey('comprehension-target')), findsNothing);
      await tester.enterText(find.byType(TextField), 'WRONG');
      await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('comprehension-target')),
        findsOneWidget,
      );
      expect(training.controller.progress.listeningAttempts, hasLength(1));
      expect(
        training.controller.progress.listeningAttempts.single.assisted,
        isFalse,
      );
      expect(training.controller.progress.srs.cards, isEmpty);
      expect(training.controller.progress.history, isEmpty);
    },
  );

  testWidgets('replay and reveal are explicit assisted attempts', (
    tester,
  ) async {
    final (training, playback) = await open(tester, mode: ListeningMode.qso);
    await listen(tester, playback);
    await listen(tester, playback);
    await tester.ensureVisible(
      find.byKey(const ValueKey('comprehension-reveal')),
    );
    await tester.tap(find.byKey(const ValueKey('comprehension-reveal')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('comprehension-target')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('comprehension-submit')),
    );
    await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
    await tester.pumpAndSettle();
    expect(
      training.controller.progress.listeningAttempts.single.assisted,
      isTrue,
    );
    expect(training.controller.progress.listeningAttempts.single.total, 4);
  });

  testWidgets('unlearned preview is marked assisted and fits a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final (training, playback) = await open(
      tester,
      mode: ListeningMode.story,
      progress: TrainerProgress(currentLesson: 1),
    );
    expect(find.byKey(const ValueKey('comprehension-preview')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('comprehension-play')),
    );
    await listen(tester, playback);
    await tester.ensureVisible(
      find.byKey(const ValueKey('comprehension-submit')),
    );
    await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
    await tester.pumpAndSettle();
    expect(
      training.controller.progress.listeningAttempts.single.assisted,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('backgrounding cancels playback without exposing answers', (
    tester,
  ) async {
    final (_, playback) = await open(tester, mode: ListeningMode.story);
    await tester.tap(find.byKey(const ValueKey('comprehension-play')));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    playback.clock.advance(const Duration(minutes: 5));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(playback.sink.events.last.on, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await listen(tester, playback);
    expect(find.byType(TextField), findsNWidgets(4));
    await tester.pumpWidget(l10nApp(home: const SizedBox()));
    await tester.pumpAndSettle();
    expect(playback.disposeCalls, 1);
  });
  testWidgets('notebook retry keeps exact questions and original speed', (
    tester,
  ) async {
    final training = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 40),
    );
    addTearDown(training.controller.dispose);
    final playback = FakeLearnPlaybackFactory();
    final exercise = ListeningExercise.generate(
      mode: ListeningMode.pota,
      seed: 42,
    );
    await tester.pumpWidget(
      l10nApp(
        home: ListeningComprehensionScreen(
          controller: training.controller,
          playback: playback,
          exercise: exercise,
          retryEntryId: 'mistake/1',
          practiceTiming: const MorseTiming(wpm: 25, farnsworthWpm: 18),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(playback.created.single.trainer.characterWpm, 25);
    expect(playback.created.single.trainer.farnsworthWpm, 18);
    expect(find.byKey(const ValueKey('comprehension-speed')), findsNothing);
    await listen(tester, playback);
    for (final question in exercise.questions) {
      await tester.enterText(
        find.byKey(ValueKey('comprehension-answer-${question.field.name}')),
        question.answer,
      );
    }
    await tester.ensureVisible(
      find.byKey(const ValueKey('comprehension-submit')),
    );
    await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
    await tester.pumpAndSettle();
    final saved = training.controller.progress.listeningAttempts.single;
    expect(saved.retryEntryId, 'mistake/1');
    expect(saved.exercise!.spokenText, exercise.spokenText);
    expect(saved.correct, 4);
    expect(saved.assisted, isFalse);
  });
  testWidgets('audio setup failure keeps answers hidden and supports retry', (
    tester,
  ) async {
    final training = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 40),
    );
    addTearDown(training.controller.dispose);
    final playback = _RetryPlaybackFactory();
    await tester.pumpWidget(
      l10nApp(
        home: ListeningComprehensionScreen(
          controller: training.controller,
          playback: playback,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(en.comprehensionAudioFailed), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(training.controller.progress.listeningAttempts, isEmpty);
    await tester.ensureVisible(find.text(en.actionRetry));
    await tester.tap(find.text(en.actionRetry));
    await tester.pumpAndSettle();
    expect(find.text(en.comprehensionAudioFailed), findsNothing);
    await listen(tester, playback.fake);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets(
    'daily plan uses its frozen seed and speed before external practice timing',
    (tester) async {
      const frozen = PlanSettings(
        characterWpm: 20,
        effectiveWpm: 13,
        toneHz: 650,
        groupSize: 5,
      );
      final step = PlanStep(
        id: 'plan/listen',
        kind: PlanStepKind.comprehension,
        pool: ['qso'],
        minutes: 1,
        charBudget: 1,
        lesson: 40,
        reason: PlanReason.goalListening,
        seed: 42,
        settings: frozen,
        state: PlanStepState.active,
      );
      final plan = DailyPlan(
        id: 'plan',
        date: DailyPlan.dateKey(kTestNow),
        profileKey: '',
        seed: 1,
        budgetMinutes: 10,
        settings: frozen,
        steps: [step],
      );
      final training = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 40, dailyPlan: plan),
      );
      addTearDown(training.controller.dispose);
      final playback = FakeLearnPlaybackFactory();
      final expected = ListeningExercise.generate(
        mode: ListeningMode.qso,
        seed: 42,
        allowedChars: training.controller.learnedChars,
      );
      await tester.pumpWidget(
        l10nApp(
          home: ListeningComprehensionScreen(
            controller: training.controller,
            playback: playback,
            initialMode: ListeningMode.qso,
            planStepId: step.id,
            practiceTiming: const MorseTiming(wpm: 25, farnsworthWpm: 18),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(playback.created.single.trainer.characterWpm, 20);
      expect(playback.created.single.trainer.farnsworthWpm, 13);
      expect(playback.created.single.trainer.toneHz, 650);
      await listen(tester, playback);
      for (final question in expected.questions) {
        await tester.enterText(
          find.byKey(ValueKey('comprehension-answer-${question.field.name}')),
          question.answer,
        );
      }
      await tester.ensureVisible(
        find.byKey(const ValueKey('comprehension-submit')),
      );
      await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
      await tester.pumpAndSettle();
      final saved = training.controller.progress.listeningAttempts.single;
      expect(saved.exercise!.spokenText, expected.spokenText);
      expect(saved.effectiveWpm, 13);
      expect(saved.planStepId, step.id);
      expect(saved.correct, 4);
      expect(
        training.controller.progress.dailyPlan!.stepById(step.id)!.isDone,
        isTrue,
      );
    },
  );
  testWidgets(
    'semantic results remain readable with large text on a small display',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final training = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 40),
      );
      addTearDown(training.controller.dispose);
      final playback = FakeLearnPlaybackFactory();
      await tester.pumpWidget(
        l10nApp(
          locale: const Locale('de'),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: ListeningComprehensionScreen(
              controller: training.controller,
              playback: playback,
              initialMode: ListeningMode.qso,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('comprehension-play')),
      );
      await listen(tester, playback);
      await tester.ensureVisible(
        find.byKey(const ValueKey('comprehension-submit')),
      );
      await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'lost audio output stops the attempt and allows a fresh playback',
    (tester) async {
      final training = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 40),
      );
      addTearDown(training.controller.dispose);
      final playback = _BrokenPlaybackFactory();
      await tester.pumpWidget(
        l10nApp(
          home: ListeningComprehensionScreen(
            controller: training.controller,
            playback: playback,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('comprehension-play')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(en.comprehensionAudioFailed), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.ensureVisible(find.text(en.actionRetry));
      await tester.tap(find.text(en.actionRetry));
      await tester.pumpAndSettle();
      // Stream cancellation uses the real event queue, outside FakeClock.
      await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.text(en.comprehensionAudioFailed), findsNothing);
      expect(playback.creates, 2);
      await tester.ensureVisible(
        find.byKey(const ValueKey('comprehension-play')),
      );
      await listen(tester, playback.fake);
      expect(playback.fake.sink.events, isNotEmpty);
      await tester.enterText(find.byType(TextField), 'WRONG');
      await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
      await tester.pumpAndSettle();
      expect(
        training.controller.progress.listeningAttempts.single.assisted,
        isTrue,
      );
    },
  );
  testWidgets('an oversized pasted answer remains safely submittable', (
    tester,
  ) async {
    final (training, playback) = await open(tester);
    await listen(tester, playback);
    await tester.enterText(find.byType(TextField), 'X' * 900);
    await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(training.controller.progress.listeningAttempts.single.correct, 0);
    expect(
      training
          .controller
          .progress
          .listeningAttempts
          .single
          .answers
          .values
          .single
          .length,
      lessThanOrEqualTo(800),
    );
  });
}
