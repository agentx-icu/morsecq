import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

Future<void> _trials(WidgetTester tester) async {
  for (final key in [
    'first-lesson-heard',
    'first-lesson-continue-worked',
    'first-lesson-continue-trials',
  ]) {
    await tester.ensureVisible(find.byKey(ValueKey(key)));
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
  }
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _perfect(TrainingController c) async {
  final s = c.startGuidedSession();
  while (!s.isComplete) {
    s.submit(s.currentDrill.text);
  }
  await c.recordReceiveSession(s);
}

void main() {
  test(
    'choice tutorials repeated perfectly cannot prove independent mastery',
    () async {
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      for (var i = 0; i < 5; i++) {
        final session = t.controller.startOnboardingSession();
        while (!session.isComplete) {
          session.submit(session.currentDrill.text);
        }
        final outcome = await t.controller.recordReceiveSession(session);
        expect(outcome.credit.receiveStats, isFalse);
      }
      await t.controller.markFirstLessonDone();
      expect(t.controller.learnerStage, LearnerStage.recognition);
    },
  );
  testWidgets(
    'intro primary is clickable on first phone frame without scrolling',
    (tester) async {
      _phone(tester);
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      await tester.pumpWidget(
        l10nApp(
          locale: const Locale('zh'),
          home: LearnHome(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('start-here')).hitTestable(),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('start-here')));
      await tester.pumpAndSettle();
      expect(find.byType(FirstLessonScreen), findsOneWidget);
    },
  );
  testWidgets(
    'zero correct intro suggests practice without claiming K/M mastery',
    (tester) async {
      _phone(tester);
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      final trials = t.controller.startOnboardingSession();
      await tester.pumpWidget(
        l10nApp(
          locale: const Locale('zh'),
          home: FirstLessonScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
            trialSession: trials,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _trials(tester);
      for (var i = 0; i < 6; i++) {
        final wrong = trials.currentDrill.text == 'K' ? 'M' : 'K';
        await tester.ensureVisible(find.byKey(ValueKey('trial-$wrong')));
        await tester.tap(find.byKey(ValueKey('trial-$wrong')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('trial-next')));
        await tester.tap(find.byKey(const ValueKey('trial-next')));
        await tester.pumpAndSettle();
      }
      expect(find.textContaining('你已经能分辨'), findsNothing);
      expect(find.byKey(const ValueKey('next-contrast')), findsOneWidget);
      expect(t.controller.progress.firstLessonDone, isTrue);
      expect(t.controller.currentLesson, 1);
    },
  );
  testWidgets('beginner pace applies to playback and recorded session timing', (
    tester,
  ) async {
    _phone(tester);
    final t = await TestTraining.create();
    addTearDown(t.controller.dispose);
    final trials = t.controller.startOnboardingSession();
    await tester.pumpWidget(
      l10nApp(
        home: FirstLessonScreen(
          controller: t.controller,
          playback: FakeLearnPlaybackFactory(),
          trialSession: trials,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _trials(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('beginner-pace')));
    await tester.tap(find.byKey(const ValueKey('beginner-pace')));
    await tester.pumpAndSettle();
    expect(trials.timing.farnsworthWpm, 6);
    for (var i = 0; i < 6; i++) {
      final target = trials.currentDrill.text;
      await tester.ensureVisible(find.byKey(ValueKey('trial-$target')));
      await tester.tap(find.byKey(ValueKey('trial-$target')));
      await tester.pumpAndSettle();
      final pace = tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('beginner-pace')),
      );
      expect(
        pace.onChanged,
        isNull,
        reason: 'answered sessions must retain one comparable speed',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('trial-next')));
      await tester.tap(find.byKey(const ValueKey('trial-next')));
      await tester.pumpAndSettle();
    }
    expect(t.controller.progress.history.single.effectiveWpm, 6);
  });
  test(
    'independent guided success advances from single to three to five symbols',
    () async {
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      expect(t.controller.startGuidedSession().currentDrill.charCount, 1);
      await _perfect(t.controller);
      final short = t.controller.startGuidedSession();
      expect(short.currentDrill.charCount, 3);
      expect(short.charBudget, 15);
      await _perfect(t.controller);
      final groups = t.controller.startGuidedSession();
      expect(groups.currentDrill.charCount, 5);
      expect(groups.charBudget, 20);
      expect(t.controller.currentLesson, 1);
    },
  );
  test(
    'mastery is recent and same-speed instead of the lifetime total',
    () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(
          firstLessonDoneAt: kTestNow,
          charStats: const {
            'K': CharStats(attempts: 100, correct: 0),
            'M': CharStats(attempts: 100, correct: 0),
          },
        ),
      );
      addTearDown(t.controller.dispose);
      for (var i = 0; i < 10; i++) {
        await _perfect(t.controller);
      }
      expect(t.controller.masteryOf('K'), CharMastery.mastered);
      expect(t.controller.masteryOf('M'), CharMastery.mastered);
      final trainer = t.controller.trainerSettings;
      await t.controller.updateSettings(
        t.controller.settings.copyWith(
          trainer: trainer.copyWith(farnsworthWpm: 6),
        ),
      );
      expect(t.controller.masteryOf('K'), isNot(CharMastery.mastered));
    },
  );
}
