import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';
import 'package:morsecq/ui/learn/placement/placement_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

final class _SoloudOutput implements SoloudApi {
  bool refuseOutput = false;
  int? failFadeAt;
  int audibleMarks = 0;
  int startedVoices = 0;
  int refusedResumes = 0;
  int refusedStarts = 0;
  @override
  bool isInitialized = false;
  @override
  Future<void> init() async => isInitialized = true;
  @override
  Future<SidetoneSource> loadSineWaveform() async => const SidetoneSource(1);
  @override
  void setWaveformFrequency(SidetoneSource source, double hz) {}
  @override
  SidetoneVoice playLooping(SidetoneSource source, {required double volume}) {
    if (refuseOutput) {
      refusedStarts++;
      throw StateError('OS refused audio output');
    }
    return SidetoneVoice(++startedVoices);
  }

  @override
  void resumeVoice(SidetoneVoice voice) {
    if (refuseOutput) {
      refusedResumes++;
      throw StateError('OS refused audio output');
    }
  }

  @override
  void fadeVolume(SidetoneVoice voice, double to, Duration over) {
    if (to > 0 && ++audibleMarks == failFadeAt) {
      throw StateError('output lost during a later mark');
    }
  }

  @override
  void setVolume(SidetoneVoice voice, double volume) {}
  @override
  Future<void> stop(SidetoneVoice voice) async {}
  @override
  Future<void> disposeSource(SidetoneSource source) async {}
  @override
  Future<void> deinit() async => isInitialized = false;
}

final class _SidetonePlayback implements LearnPlaybackFactory {
  _SidetonePlayback(this.api, {this.refuseAfterPrepare = false});
  final _SoloudOutput api;
  final bool refuseAfterPrepare;
  final clock = FakeClock();
  SidetoneSink? tone;
  int creates = 0;
  int disposes = 0;
  @override
  Future<LearnPlayback> create(TrainingSettings settings) async {
    creates++;
    final sink = SidetoneSink(api: api);
    await sink.prepare();
    tone = sink;
    if (refuseAfterPrepare && creates == 1) api.refuseOutput = true;
    return LearnPlayback(
      sink: CompositeSink([sink]),
      sidetone: sink,
      clock: clock,
      flash: null,
      dispose: () async {
        disposes++;
        await sink.dispose();
      },
    );
  }
}

final class _FailOnceStore implements TrainerStore {
  final inner = InMemoryTrainerStore();
  bool fail = true;
  @override
  Future<TrainerProgress?> load() => inner.load();
  @override
  Future<void> save(TrainerProgress progress) async {
    if (fail) {
      fail = false;
      throw StateError('disk unavailable');
    }
    await inner.save(progress);
  }

  @override
  Future<void> clear() => inner.clear();
}

void main() {
  testWidgets(
    'audit: placement offers a persistence retry after stopping early',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = _FailOnceStore();
      final controller = TrainingController(
        progressStore: store,
        settingsStore: InMemoryTrainingSettingsStore(),
        now: () => kTestNow,
      );
      addTearDown(controller.dispose);
      await controller.load();
      final assessment = PlacementAssessment(
        course: controller.course,
        seed: 5,
      );
      await tester.pumpWidget(
        l10nApp(
          home: PlacementScreen(
            controller: controller,
            playback: FakeLearnPlaybackFactory(),
            seed: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('placement-start')));
      await tester.pump();
      await tester.enterText(
        find.byType(TextField),
        assessment.tiers.first.rounds.first,
      );
      await tester.tap(find.byKey(const ValueKey('placement-submit')));
      await tester.pump();
      await tester.tap(find.text(en.placementStop));
      await tester.pumpAndSettle();
      expect(store.inner.saveCount, 0);
      expect(controller.progress.history, hasLength(1));
      expect(find.text(en.learnProgressSaveFailed), findsOneWidget);
      await tester.tap(find.text(en.actionRetry));
      await tester.pumpAndSettle();
      expect(store.inner.saveCount, 1);
      expect((await store.load())!.history, hasLength(1));
    },
  );

  testWidgets(
    'audit: unheard receive cannot earn independent receive evidence',
    (tester) async {
      final training = await TestTraining.create(settings: kShortSettings);
      addTearDown(training.controller.dispose);
      final session = training.controller.startLessonSession();
      final api = _SoloudOutput();
      final playback = _SidetonePlayback(api, refuseAfterPrepare: true);
      await tester.pumpWidget(
        l10nApp(
          home: ReceiveDrillScreen(
            controller: training.controller,
            playback: playback,
            session: session,
          ),
        ),
      );
      await tester.pumpAndSettle();
      playback.clock.advance(
        MorseEncoder.totalDuration(session.currentTimeline) +
            const Duration(milliseconds: 1),
      );
      await tester.pumpAndSettle();
      expect(api.refusedResumes, greaterThan(0));
      expect(api.refusedStarts, greaterThan(0));
      expect(api.audibleMarks, 0);
      expect(find.text(en.comprehensionAudioFailed), findsOneWidget);
      final submit = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, en.learnSubmit),
      );
      expect(submit.onPressed, isNull);
      expect(
        training.controller.progress.charStats,
        isEmpty,
        reason: 'zero perceivable output must not claim independent reception',
      );
      expect(training.controller.progress.srs.cards, isEmpty);
      expect(session.roundCount, 0);
      api.refuseOutput = false;
      await tester.tap(find.text(en.actionRetry));
      playback.clock.advance(const Duration(minutes: 2));
      await tester.pumpAndSettle();
      expect(find.text(en.comprehensionAudioFailed), findsNothing);
      await tester.enterText(find.byType(TextField), session.currentDrill.text);
      await tester.tap(find.widgetWithText(FilledButton, en.learnSubmit));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, en.learnFinish));
      await tester.pumpAndSettle();
      expect(training.controller.progress.charStats, isNotEmpty);
      expect(training.progressStore.saveCount, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(playback.creates, 1, reason: 'retry reuses one prepared bundle');
      expect(playback.disposes, 1);
      expect(playback.clock.pendingTimers, 0);
      expect(playback.tone!.isOn, isFalse);
    },
  );

  testWidgets('audit: later receive sidetone rejection is a handled failure', (
    tester,
  ) async {
    final training = await TestTraining.create(settings: kShortSettings);
    addTearDown(training.controller.dispose);
    final session = training.controller.startLessonSession();
    final api = _SoloudOutput()..failFadeAt = 2;
    final playback = _SidetonePlayback(api);
    await tester.pumpWidget(
      l10nApp(
        home: ReceiveDrillScreen(
          controller: training.controller,
          playback: playback,
          session: session,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.audibleMarks, 1);
    expect(
      () => playback.clock.advance(const Duration(minutes: 2)),
      returnsNormally,
      reason: 'later timer callback errors must be converted into retry UI',
    );
    await tester.pumpAndSettle();
    expect(playback.clock.pendingTimers, 0);
    expect(find.text(en.comprehensionAudioFailed), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'audit: placement silences the round when a phone backgrounds',
    (tester) async {
      final training = await TestTraining.create();
      addTearDown(training.controller.dispose);
      final playback = FakeLearnPlaybackFactory();
      await tester.pumpWidget(
        l10nApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: PlacementScreen(
            controller: training.controller,
            playback: playback,
            seed: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('placement-start')));
      await tester.pump();
      expect(playback.sink.isOn, isTrue);
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
      expect(
        playback.sink.isOn,
        isFalse,
        reason: 'a placement round should be silent while the phone is hidden',
      );
      expect(playback.clock.pendingTimers, 0);
      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
      expect(playback.sink.isOn, isFalse, reason: 'return never auto-plays');
      await tester.tap(find.text(en.learnReplay));
      await tester.pump();
      expect(playback.sink.isOn, isTrue);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'audit: first lesson failed worked sound never reveals completion',
    (tester) async {
      final training = await TestTraining.create();
      addTearDown(training.controller.dispose);
      final api = _SoloudOutput();
      final playback = _SidetonePlayback(api, refuseAfterPrepare: true);
      await tester.pumpWidget(
        l10nApp(
          home: FirstLessonScreen(
            controller: training.controller,
            playback: playback,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final key in [
        'first-lesson-heard',
        'first-lesson-continue-worked',
      ]) {
        await tester.ensureVisible(find.byKey(ValueKey(key)));
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const ValueKey('worked-K')));
      playback.clock.advance(const Duration(minutes: 2));
      await tester.pumpAndSettle();
      expect(api.audibleMarks, 0);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('worked-reveal-K'))).data,
        '',
      );
      expect(training.controller.progress.history, isEmpty);
      expect(training.controller.progress.charStats, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(playback.disposes, 1);
    },
  );

  for (final kind in ReceiveDrillKind.values) {
    testWidgets('audit: ${kind.name} completes, records once and reopens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final training = await TestTraining.create(
        settings: kShortSettings,
        progress: TrainerProgress(currentLesson: 42),
      );
      addTearDown(training.controller.dispose);
      final controller = training.controller;
      if (kind != ReceiveDrillKind.review) {
        expect(controller.availableReceiveKinds, contains(kind));
      }
      final session = controller.startReceiveSession(kind);
      final playback = FakeLearnPlaybackFactory();
      await tester.pumpWidget(
        l10nApp(
          home: ReceiveDrillScreen(
            controller: controller,
            playback: playback,
            session: session,
          ),
        ),
      );
      await tester.pumpAndSettle();
      while (!session.isComplete) {
        playback.clock.advance(
          MorseEncoder.totalDuration(session.currentTimeline) +
              const Duration(milliseconds: 1),
        );
        await tester.pump();
        expect(
          MorseText.usesOnly(
            session.currentDrill.text,
            controller.learnedChars.toSet(),
          ),
          isTrue,
        );
        await tester.enterText(
          find.byType(TextField),
          session.currentDrill.text,
        );
        await tester.tap(find.text(en.learnSubmit));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text(session.isComplete ? en.learnFinish : en.learnNext),
        );
        await tester.tap(
          find.text(session.isComplete ? en.learnFinish : en.learnNext),
        );
        await tester.pumpAndSettle();
      }
      expect(find.text(en.learnAccuracyPercent(100)), findsOneWidget);
      expect(controller.progress.history, hasLength(1));
      expect(controller.progress.history.single.drillKind, kind.name);
      expect(controller.progress.history.single.assistance, isEmpty);
      expect(
        controller.currentLesson,
        42,
        reason: 'practice/review is never a challenge',
      );
      expect(controller.progress.charStats, isNotEmpty);
      expect(controller.progress.srs.cards, isNotEmpty);
      await controller.recordReceiveSession(session);
      expect(
        training.progressStore.saveCount,
        1,
        reason: 'same completion is idempotent',
      );
      final reopened = TrainerProgress.fromJson(controller.progress.toJson());
      final restart = await TestTraining.create(
        progress: reopened,
        settings: kShortSettings,
      );
      addTearDown(restart.controller.dispose);
      expect(restart.controller.progress.history.single.id, session.id);
      expect(
        restart.controller.progress.charStats,
        controller.progress.charStats,
      );
      expect(
        restart.controller.progress.srs.cards.keys.toSet(),
        controller.progress.srs.cards.keys.toSet(),
      );
      expect(
        restart.controller.startReceiveSession(kind).id,
        isNot(session.id),
      );
    });
  }
}
