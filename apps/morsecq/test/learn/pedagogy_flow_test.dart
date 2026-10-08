// Behaviour tests for the 2026-10-08 pedagogy review (A1–A5 and the
// first-day flow): only a lesson challenge advances the course, challenges
// cover the new symbol, the last lesson completes the course, verdicts
// follow what was committed, and the first lesson works end to end.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_plan.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/drill_session_guard.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_setup_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/settings/training_settings_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

Future<ReceiveOutcome> _answerAll(
  TrainingController c,
  ReceiveSession session, {
  String Function(String target)? answer,
}) async {
  while (!session.isComplete) {
    final target = session.currentDrill.text;
    session.submit(answer == null ? target : answer(target));
  }
  return c.recordReceiveSession(session);
}

/// Fixed round texts, in order, so a session's scoring can be checked.
final class _ScriptedDrill implements DrillGenerator {
  _ScriptedDrill(this.texts);

  final List<String> texts;
  int _i = 0;

  @override
  String get kind => 'groups';

  @override
  Drill generate(Random random) =>
      Drill.fromText(texts[_i++ % texts.length], kind: kind);
}

/// A playback whose only modality is the screen flash.
final class _FlashOnlyFactory implements LearnPlaybackFactory {
  final FakeClock clock = FakeClock();
  late final RecordingSink sink = RecordingSink(clock: clock);
  final ValueNotifier<bool> flash = ValueNotifier<bool>(false);
  final List<TrainingSettings> created = <TrainingSettings>[];

  @override
  Future<LearnPlayback> create(TrainingSettings settings) async {
    created.add(settings);
    return LearnPlayback(
      sink: sink,
      clock: clock,
      flash: flash,
      dispose: () async {},
    );
  }
}

void _setPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('A1: only a lesson challenge advances the course', () {
    test('perfect numbers-only practice at lesson 23 stays at 23', () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 23),
      );
      final c = t.controller;
      final session = c.startReceiveSession(ReceiveDrillKind.numbers);
      expect(session.countsTowardLesson, isFalse);
      expect(session.source, ExerciseSource.focus);
      final outcome = await _answerAll(c, session);
      expect(outcome.score.isPerfect, isTrue);
      expect(outcome.score.totalChars, greaterThanOrEqualTo(50));
      expect(outcome.challenge, isFalse);
      expect(outcome.passed, isFalse);
      expect(outcome.advanced, isFalse);
      expect(c.currentLesson, 23);
      expect(verdictOf(outcome, session), ReceiveVerdict.practice);
      // Practice still feeds statistics and reviews.
      expect(outcome.credit.receiveStats, isTrue);
      expect(c.progress.charStats.keys, containsAll(<String>['0', '5']));
    });

    test('free groups practice never counts toward the lesson', () async {
      final t = await TestTraining.create();
      final groups = t.controller.startReceiveSession(ReceiveDrillKind.groups);
      expect(groups.countsTowardLesson, isFalse);
      expect(groups.source, ExerciseSource.focus);
      final guided = t.controller.startGuidedSession();
      expect(guided.countsTowardLesson, isFalse);
      expect(guided.kind, ReceiveDrillKind.characters);
      expect(guided.charBudget, GuidedLevel.single.chars);
      expect(guided.currentDrill.charCount, 1);
    });

    test('radio conditions stay activity-only', () async {
      final t = await TestTraining.create();
      final radio = t.controller.startReceiveSession(
        ReceiveDrillKind.groups,
        preset: RadioPreset.radio,
      );
      expect(radio.source, ExerciseSource.conditions);
      expect(radio.countsTowardLesson, isFalse);
    });
  });

  group('A2: the challenge covers and judges the new symbol', () {
    test('a perfect challenge at lesson 23 contains / and advances', () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 23),
      );
      final c = t.controller;
      final session = c.startLessonSession();
      expect(session.countsTowardLesson, isTrue);
      expect(session.source, ExerciseSource.course);
      expect(session.timeBudget, isNull);
      final outcome = await _answerAll(c, session);
      expect(outcome.score.charStats['/']!.attempts, greaterThanOrEqualTo(10));
      expect(outcome.challenge, isTrue);
      expect(outcome.lessonVerdict, LessonVerdict.passed);
      expect(outcome.passed, isTrue);
      expect(outcome.advanced, isTrue);
      expect(c.currentLesson, 24);
      expect(verdictOf(outcome, session), ReceiveVerdict.unlocked);
    });

    test('a challenge that always misses the new symbol does not pass', () async {
      final t = await TestTraining.create();
      final c = t.controller;
      final session = c.startLessonSession();
      final outcome = await _answerAll(
        c,
        session,
        answer: (target) => target.replaceAll('M', 'K'),
      );
      expect(outcome.challenge, isTrue);
      expect(outcome.passed, isFalse);
      expect(c.currentLesson, 1);
      expect(verdictOf(outcome, session).isFailedChallenge, isTrue);
    });

    test('a replayed challenge is practice with help', () async {
      final t = await TestTraining.create();
      final c = t.controller;
      final session = c.startLessonSession()..markReplay();
      final outcome = await _answerAll(c, session);
      expect(outcome.score.isPerfect, isTrue);
      expect(outcome.challenge, isFalse, reason: 'no unlock credit');
      expect(outcome.passed, isFalse);
      expect(c.currentLesson, 1);
      expect(verdictOf(outcome, session), ReceiveVerdict.assisted);
    });

    test('the time cap applies to practice, never to a challenge', () async {
      final t = await TestTraining.create(
        settings: const TrainingSettings(
          trainer: TrainerSettings(sessionLengthSeconds: 60),
        ),
      );
      expect(t.controller.startLessonSession().timeBudget, isNull);
      expect(
        t.controller.startReceiveSession(ReceiveDrillKind.groups).timeBudget,
        const Duration(seconds: 60),
      );
    });
  });

  group('A3: course completion', () {
    test('passing the last lesson completes the course', () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 42),
      );
      final c = t.controller;
      expect(c.isCourseComplete, isFalse);
      expect(c.allCharsUnlocked, isTrue);
      final session = c.startLessonSession();
      final outcome = await _answerAll(c, session);
      expect(outcome.advanced, isFalse);
      expect(outcome.passed, isTrue);
      expect(outcome.courseCompleted, isTrue);
      expect(c.isCourseComplete, isTrue);
      expect(c.learnerStage, LearnerStage.coursePassed);
      expect(verdictOf(outcome, session), ReceiveVerdict.courseComplete);
      final saved = await t.progressStore.load();
      expect(saved!.courseCompleted, isTrue);
      // Sticky across a lesson jump.
      await c.setLesson(10);
      expect(c.isCourseComplete, isTrue);
    });
  });

  group('first lesson and plan wiring', () {
    test('the onboarding session binds the pending intro step', () async {
      final t = await TestTraining.create();
      final c = t.controller;
      expect(c.learnerStage, LearnerStage.firstUse);
      final plan = await c.ensureTodayPlan();
      expect(plan.steps.first.kind, PlanStepKind.intro);
      final session = c.startOnboardingSession();
      expect(session.planStepId, plan.steps.first.id);
      expect(session.chars, <String>['K', 'M']);
      expect(session.charBudget, 6);
      expect(session.currentDrill.charCount, 1);
      // Replays are allowed: an assisted run still completes the step.
      session.markReplay();
      await _answerAll(c, session);
      await c.markFirstLessonDone();
      expect(c.todayPlan!.steps.first.isDone, isTrue);
      expect(c.progress.firstLessonDone, isTrue);
      expect(c.learnerStage, LearnerStage.recognition);
      t.clock.advance(const Duration(days: 1));
      final next = await c.ensureTodayPlan();
      expect(next.steps.map((s) => s.kind), isNot(contains(PlanStepKind.intro)));
      expect(next.steps.first.kind, PlanStepKind.recognition);
    });

    test('a recognition plan step is single-symbol practice', () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 5),
      );
      final c = t.controller;
      final plan = await c.ensureTodayPlan();
      final step = plan.steps.firstWhere(
        (s) => s.kind == PlanStepKind.recognition,
      );
      final session = await c.startPlanReceiveStep(step);
      expect(session.kind, ReceiveDrillKind.characters);
      expect(session.source, ExerciseSource.focus);
      expect(session.countsTowardLesson, isFalse);
      expect(session.currentDrill.charCount, 1);
      expect(plan.steps.last.optional, isTrue);
    });

    test('speed advice is withheld while a new symbol is unmastered', () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 5),
      );
      expect(t.controller.learnerStage, LearnerStage.recognition);
      expect(t.controller.pendingSpeedAdvice, isNull);
    });
  });

  group('A5: QSO readiness', () {
    test('follows symbols and practice, never a lesson number', () async {
      final at30 = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 30),
      );
      final r = at30.controller.qsoReadiness;
      expect(r.level, QsoReadinessLevel.symbols);
      expect(r.missing, contains('<SK>'));
      expect(
        at30.controller.availableReceiveKinds,
        contains(ReceiveDrillKind.qso),
        reason: 'QSO lines that fit the learned set are offered',
      );
      final qso = at30.controller.startReceiveSession(ReceiveDrillKind.qso);
      expect(qso.currentDrill.chars, everyElement(isIn(qso.chars)));
      final full = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 42),
      );
      expect(full.controller.qsoReadiness.level, QsoReadinessLevel.consolidate);
    });
  });

  group('screens', () {
    testWidgets('the first lesson runs end to end and records the trials', (
      tester,
    ) async {
      _setPhone(tester);
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      final playback = FakeLearnPlaybackFactory();
      final trials = t.controller.startOnboardingSession();
      await tester.pumpWidget(
        l10nApp(
          home: FirstLessonScreen(
            controller: t.controller,
            playback: playback,
            trialSession: trials,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.firstLessonHearTitle), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('first-lesson-play')));
      await tester.pump();
      expect(playback.sink.events, isNotEmpty);
      // Nothing heard: the recovery card appears and switching on the flash
      // rebuilds the playback from the new settings.
      await tester.tap(find.byKey(const ValueKey('first-lesson-not-heard')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('no-sound-card')), findsOneWidget);
      final created = playback.created.length;
      await tester.tap(find.byKey(const ValueKey('no-sound-flash')));
      await tester.pumpAndSettle();
      expect(t.controller.settings.flashEnabled, isTrue);
      expect(playback.created.length, created + 1);
      await tester.tap(find.byKey(const ValueKey('first-lesson-heard')));
      await tester.pumpAndSettle();
      expect(find.text(en.firstLessonSoundsTitle), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sound-K')));
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('first-lesson-continue-worked')),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.firstLessonWorkedTitle), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('first-lesson-continue-trials')),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.firstLessonTrialsTitle), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        final target = trials.currentDrill.text;
        await tester.ensureVisible(find.byKey(ValueKey<String>('trial-$target')));
        await tester.tap(find.byKey(ValueKey<String>('trial-$target')));
        await tester.pumpAndSettle();
        expect(find.text(en.firstLessonTrialCorrect(target)), findsOneWidget);
        await tester.ensureVisible(find.byKey(const ValueKey('trial-next')));
        await tester.tap(find.byKey(const ValueKey('trial-next')));
        await tester.pumpAndSettle();
      }
      expect(find.text(en.firstLessonNextTitle), findsOneWidget);
      expect(find.text(en.firstLessonNextBody(6, 6)), findsOneWidget);
      expect(find.byKey(const ValueKey('next-guided')), findsOneWidget);
      expect(t.controller.progress.firstLessonDone, isTrue);
      expect(t.controller.progress.history, hasLength(1));
      expect(t.controller.progress.history.single.source, ExerciseSource.focus);
      expect(t.controller.learnerStage, isNot(LearnerStage.firstUse));
    });

    testWidgets('free practice ends with the practice verdict and a way on', (
      tester,
    ) async {
      _setPhone(tester);
      final t = await TestTraining.create(settings: kShortSettings);
      addTearDown(t.controller.dispose);
      final session = t.controller.startReceiveSession(ReceiveDrillKind.groups);
      await tester.pumpWidget(
        l10nApp(
          home: ReceiveDrillScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
            session: session,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.learnPracticeTitle), findsOneWidget);
      await tester.enterText(find.byType(TextField), session.currentDrill.text);
      await tester.tap(find.text(en.learnSubmit));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.learnFinish));
      await tester.pumpAndSettle();
      expect(find.text(en.learnVerdictPractice), findsOneWidget);
      expect(find.text(en.learnVerdictPracticeHint), findsOneWidget);
      expect(find.byKey(const ValueKey('take-challenge')), findsOneWidget);
      expect(find.byKey(const ValueKey('receive-done')), findsOneWidget);
      expect(t.controller.currentLesson, 1);
    });

    testWidgets('a challenge screen is titled as one', (tester) async {
      _setPhone(tester);
      final t = await TestTraining.create(settings: kShortSettings);
      addTearDown(t.controller.dispose);
      await tester.pumpWidget(
        l10nApp(
          home: ReceiveDrillScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
            session: t.controller.startLessonSession(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.learnChallengeTitle(1)), findsOneWidget);
    });

    testWidgets('the new-learner card leads with the first lesson', (
      tester,
    ) async {
      _setPhone(tester);
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      await tester.pumpWidget(
        l10nApp(
          home: LearnHome(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('start-here')), findsOneWidget);
      expect(find.text(en.learnGoalFirstUse), findsOneWidget);
      expect(find.text(en.learnCharsIntroducedMastered(2, 0)), findsOneWidget);
      expect(find.byKey(const ValueKey('guided-practice')), findsOneWidget);
      expect(find.text(en.learnQsoSymbolsToGo(36)), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('start-here')));
      await tester.tap(find.byKey(const ValueKey('start-here')));
      await tester.pumpAndSettle();
      expect(find.byType(FirstLessonScreen), findsOneWidget);
    });

    testWidgets('chips play their symbol and the newest has a demo row', (
      tester,
    ) async {
      _setPhone(tester);
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 3),
      );
      addTearDown(t.controller.dispose);
      final playback = FakeLearnPlaybackFactory();
      await tester.pumpWidget(
        l10nApp(home: LearnHome(controller: t.controller, playback: playback)),
      );
      await tester.pumpAndSettle();
      expect(playback.created, isEmpty, reason: 'lazy: no audio on open');
      await tester.tap(find.byKey(const ValueKey('hear-newest')));
      await tester.pumpAndSettle();
      expect(playback.created, hasLength(1));
      final marks = MorseEncoder.encode(
        'S',
        t.controller.trainerSettings.toTiming(),
      ).where((e) => e.on).length;
      playback.clock.advance(const Duration(seconds: 5));
      await tester.pump();
      expect(playback.sink.events.where((e) => e.on).length, marks);
      expect(find.byKey(const ValueKey('compare-newest')), findsOneWidget);
    });

    testWidgets('training settings offer the beginner pace', (tester) async {
      _setPhone(tester);
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      await tester.pumpWidget(
        l10nApp(
          home: TrainingSettingsScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('preset-beginner')));
      await tester.pumpAndSettle();
      expect(t.controller.trainerSettings.farnsworthWpm, 6);
      expect(t.controller.trainerSettings.characterWpm, 20);
      await tester.tap(find.byKey(const ValueKey('preset-standard')));
      await tester.pumpAndSettle();
      expect(t.controller.trainerSettings.farnsworthWpm, 8);
    });

    testWidgets('send practice shows first-use guidance until dismissed', (
      tester,
    ) async {
      _setPhone(tester);
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      await tester.pumpWidget(
        l10nApp(
          home: SendPracticeScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('send-first-use')), findsOneWidget);
      expect(find.text(en.sendFirstUsePaddles), findsOneWidget);
      await tester.tap(find.text(en.sendFirstUseDismiss));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('send-first-use')), findsNothing);
    });

    testWidgets('QSO setup explains readiness and labels exploring', (
      tester,
    ) async {
      _setPhone(tester);
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 10),
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
      expect(find.byKey(const ValueKey('qso-readiness-symbols')), findsOneWidget);
      expect(find.text(en.learnQsoNotReadyTitle), findsOneWidget);
      expect(find.byKey(const ValueKey('qso-missing-?')), findsOneWidget);
      expect(find.byKey(const ValueKey('qso-explore-label')), findsOneWidget);
      expect(find.text(en.learnQsoHowTitle), findsOneWidget);
    });
  });

  group("A2': session scoring", () {
    test('a symbol missed in one round stays missed in the session score', () async {
      final t = await TestTraining.create();
      final c = t.controller;
      // Joined and re-aligned these ten rounds would read as a perfect copy.
      final session = ReceiveSession(
        kind: ReceiveDrillKind.groups,
        generator: _ScriptedDrill(const <String>['KKKKM', 'MKKKK']),
        chars: const <String>['K', 'M'],
        timing: const MorseTiming(wpm: 20),
        charBudget: 50,
        lesson: 1,
        countsTowardLesson: true,
        source: ExerciseSource.course,
        random: Random(1),
        now: () => kTestNow,
      );
      var i = 0;
      while (!session.isComplete) {
        session.submit((i++).isEven ? 'KKKKMM' : 'KKKK');
      }
      final score = session.finish();
      expect(score.totalChars, 50);
      expect(score.charStats['M'], const CharStats(attempts: 10, correct: 5));
      expect(score.strictAccuracy, lessThan(0.9));
      final outcome = await c.recordReceiveSession(session);
      expect(outcome.passed, isFalse);
      expect(c.currentLesson, 1);
      expect(verdictOf(outcome, session), ReceiveVerdict.belowAccuracy);
    });
  });

  group('first lesson on a phone', () {
    testWidgets(
      'backgrounding stops playback; an answered trial arms the leave guard',
      (tester) async {
        _setPhone(tester);
        final t = await TestTraining.create();
        addTearDown(t.controller.dispose);
        final playback = FakeLearnPlaybackFactory();
        final trials = t.controller.startOnboardingSession();
        await tester.pumpWidget(
          l10nApp(
            home: FirstLessonScreen(
              controller: t.controller,
              playback: playback,
              trialSession: trials,
            ),
          ),
        );
        await tester.pumpAndSettle();
        DrillLeaveGuard guard() =>
            tester.widget<DrillLeaveGuard>(find.byType(DrillLeaveGuard));
        expect(guard().guard, isFalse);
        await tester.tap(find.byKey(const ValueKey('first-lesson-play')));
        await tester.pump();
        expect(playback.sink.isOn, isTrue);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        expect(playback.sink.isOn, isFalse);
        final before = playback.sink.events.length;
        playback.clock.advance(const Duration(seconds: 10));
        await tester.pump();
        expect(playback.sink.events.length, before);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
        // Straight to the trials: one answer makes leaving ask first.
        await tester.tap(find.byKey(const ValueKey('first-lesson-heard')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('first-lesson-continue-worked')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('first-lesson-continue-trials')));
        await tester.pumpAndSettle();
        final target = trials.currentDrill.text;
        await tester.ensureVisible(find.byKey(ValueKey<String>('trial-$target')));
        await tester.tap(find.byKey(ValueKey<String>('trial-$target')));
        await tester.pumpAndSettle();
        expect(guard().guard, isTrue);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  });

  group('previews', () {
    testWidgets('flash-only previews render the flash and follow settings', (
      tester,
    ) async {
      _setPhone(tester);
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 3),
        settings: const TrainingSettings(soundEnabled: false, flashEnabled: true),
      );
      addTearDown(t.controller.dispose);
      final playback = _FlashOnlyFactory();
      await tester.pumpWidget(
        l10nApp(home: LearnHome(controller: t.controller, playback: playback)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlashOverlay), findsNothing, reason: 'nothing built yet');
      await tester.tap(find.byKey(const ValueKey('hear-newest')));
      await tester.pumpAndSettle();
      expect(playback.created, hasLength(1));
      expect(find.byType(FlashOverlay), findsOneWidget);
      playback.flash.value = true;
      await tester.pump();
      expect(find.byType(FlashOverlay), findsOneWidget);
      // A settings change rebuilds the bundle on the next tap.
      await t.controller.updateSettings(
        t.controller.settings.copyWith(hapticEnabled: true),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hear-newest')));
      await tester.pumpAndSettle();
      expect(playback.created, hasLength(2));
      expect(playback.created.last.hapticEnabled, isTrue);
    });
  });
}
