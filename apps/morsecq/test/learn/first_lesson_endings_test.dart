import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/receive_session_start.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

/// The first lesson, opened from a launcher page that keeps what it returns.
final class _Lesson {
  _Lesson(this.t, this.playback, this.trials);

  final TestTraining t;
  final FakeLearnPlaybackFactory playback;
  final ReceiveSession trials;
  Object? popped = const _NotPopped();
}

final class _NotPopped {
  const _NotPopped();
}

Future<_Lesson> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final t = await TestTraining.create();
  addTearDown(t.controller.dispose);
  final lesson = _Lesson(
    t,
    FakeLearnPlaybackFactory(),
    t.controller.startOnboardingSession(),
  );
  await tester.pumpWidget(
    l10nApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            lesson.popped = await Navigator.of(context).push<Object?>(
              MaterialPageRoute<Object?>(
                builder: (_) => FirstLessonScreen(
                  controller: t.controller,
                  playback: lesson.playback,
                  trialSession: lesson.trials,
                ),
              ),
            );
          },
          child: const Text('launch'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('launch'));
  await tester.pumpAndSettle();
  return lesson;
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey<String>(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Lets every scheduled sound finish on the fake clock.
Future<void> _finishSound(WidgetTester tester, _Lesson l) async {
  l.playback.clock.advance(const Duration(seconds: 10));
  await tester.pump();
  await tester.pumpAndSettle();
}

int _toneCount(_Lesson l) => l.playback.sink.events.where((e) => e.on).length;

Future<void> _toTrials(WidgetTester tester) async {
  await _tapKey(tester, 'first-lesson-heard');
  await _tapKey(tester, 'first-lesson-continue-worked');
  await _tapKey(tester, 'first-lesson-continue-trials');
  expect(find.text(en.firstLessonTrialsTitle), findsOneWidget);
}

/// Answers the six trials, the first [wrong] of them with the other symbol.
Future<void> _toNext(WidgetTester tester, _Lesson l, {int wrong = 0}) async {
  await _toTrials(tester);
  for (var i = 0; i < 6; i++) {
    final target = l.trials.currentDrill.text;
    final answer = i < wrong ? (target == 'K' ? 'M' : 'K') : target;
    await _tapKey(tester, 'trial-$answer');
    await _tapKey(tester, 'trial-next');
  }
  expect(find.text(en.firstLessonNextTitle), findsOneWidget);
}

void main() {
  testWidgets('dit and dah tiles each sound one element', (tester) async {
    final l = await _open(tester);
    await _tapKey(tester, 'first-lesson-heard');
    for (final (label, kind) in [
      (en.firstLessonDit, MorseElementKind.dit),
      (en.firstLessonDah, MorseElementKind.dah),
    ]) {
      final before = l.playback.sink.events.length;
      await tester.tap(find.byKey(ValueKey<String>('sound-$label')));
      await tester.pump();
      await _finishSound(tester, l);
      final events = l.playback.sink.events.sublist(before);
      expect(events.where((e) => e.on), hasLength(1), reason: kind.name);
      final timing = l.t.controller.trainerSettings.toTiming();
      expect(
        events.last.at - events.first.at,
        kind == MorseElementKind.dah ? timing.dah : timing.dit,
        reason: '${kind.name} lasts its own length',
      );
    }
  });

  testWidgets('a worked example names its symbol only after it sounded', (
    tester,
  ) async {
    final l = await _open(tester);
    await _tapKey(tester, 'first-lesson-heard');
    await _tapKey(tester, 'first-lesson-continue-worked');
    expect(find.text(en.firstLessonWorkedReveal('K')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('worked-K')));
    await tester.pump();
    expect(
      find.text(en.firstLessonWorkedReveal('K')),
      findsNothing,
      reason: 'not while it is still playing',
    );
    await _finishSound(tester, l);
    expect(find.text(en.firstLessonWorkedReveal('K')), findsOneWidget);
    expect(find.text(en.firstLessonWorkedReveal('M')), findsNothing);
  });

  testWidgets('replaying a trial plays it again and is recorded', (
    tester,
  ) async {
    final l = await _open(tester);
    await _toTrials(tester);
    await _finishSound(tester, l);
    expect(l.trials.assistance, isNot(contains(Assistance.replay)));
    final tones = _toneCount(l);
    await _tapKey(tester, 'trial-replay');
    await _finishSound(tester, l);
    expect(_toneCount(l), greaterThan(tones));
    expect(l.trials.assistance, contains(Assistance.replay));
  });

  testWidgets('the beginner pace switches on and back off before answering', (
    tester,
  ) async {
    final l = await _open(tester);
    await _toTrials(tester);
    final pace = find.byKey(const ValueKey('beginner-pace'));
    await tester.ensureVisible(pace);
    await tester.tap(pace);
    await tester.pumpAndSettle();
    expect(
      l.t.controller.trainerSettings.farnsworthWpm,
      FirstLessonScreen.beginnerEffectiveWpm,
    );
    await tester.tap(pace);
    await tester.pumpAndSettle();
    expect(
      l.t.controller.trainerSettings.farnsworthWpm,
      TrainerSettings.defaults.farnsworthWpm,
    );
  });

  group('the closing step', () {
    testWidgets('after a mistake, compare plays K and M together', (
      tester,
    ) async {
      final l = await _open(tester);
      await _toNext(tester, l, wrong: 1);
      await _finishSound(tester, l);
      final before = l.playback.sink.events.length;
      await _tapKey(tester, 'next-contrast');
      await _finishSound(tester, l);
      final tones = l.playback.sink.events
          .sublist(before)
          .where((e) => e.on)
          .length;
      expect(tones, 5, reason: 'K (-.-) then M (--)');
    });

    testWidgets('a perfect run offers no comparison', (tester) async {
      final l = await _open(tester);
      await _toNext(tester, l);
      expect(find.byKey(const ValueKey('next-contrast')), findsNothing);
    });

    testWidgets('guided practice replaces the lesson and never unlocks', (
      tester,
    ) async {
      final l = await _open(tester);
      await _toNext(tester, l);
      await _tapKey(tester, 'next-guided');
      expect(find.byType(FirstLessonScreen), findsNothing);
      final drill = tester.widget<ReceiveDrillScreen>(
        find.byType(ReceiveDrillScreen),
      );
      expect(drill.session.countsTowardLesson, isFalse);
    });

    testWidgets('the challenge is the lesson 1 unlock path', (tester) async {
      final l = await _open(tester);
      await _toNext(tester, l);
      await _tapKey(tester, 'next-challenge');
      final drill = tester.widget<ReceiveDrillScreen>(
        find.byType(ReceiveDrillScreen),
      );
      expect(drill.session.countsTowardLesson, isTrue);
      expect(drill.session.lesson, 1);
      expect(l.t.controller.currentLesson, 1, reason: 'not unlocked yet');
    });

    testWidgets('send practice replaces the lesson', (tester) async {
      final l = await _open(tester);
      await _toNext(tester, l);
      await _tapKey(tester, 'next-send');
      expect(find.byType(SendPracticeScreen), findsOneWidget);
      expect(find.byType(FirstLessonScreen), findsNothing);
    });

    testWidgets('done returns to the launcher with the outcome', (
      tester,
    ) async {
      final l = await _open(tester);
      await _toNext(tester, l);
      await _tapKey(tester, 'first-lesson-done');
      expect(find.byType(FirstLessonScreen), findsNothing);
      expect(find.text('launch'), findsOneWidget);
      expect(l.popped, isNot(isA<_NotPopped>()));
      expect(l.t.controller.progress.firstLessonDone, isTrue);
    });
  });
}
