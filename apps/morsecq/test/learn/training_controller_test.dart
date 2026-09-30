import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_settings.dart';

import 'helpers/test_controller.dart';

void main() {
  test('loads defaults when nothing is stored', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    expect(c.isLoaded, isTrue);
    expect(c.loadError, isNull);
    expect(c.currentLesson, 1);
    expect(c.lessonCount, 42);
    expect(c.learnedChars, <String>['K', 'M']);
    expect(c.newestChar, 'M');
    expect(c.streak, 0);
    expect(c.charsToday, 0);
    expect(c.dueChars, <String>['K', 'M']);
    expect(c.settings, TrainingSettings.defaults);
  });

  test('clamps an out-of-range stored lesson', () async {
    final t = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 999),
    );
    expect(t.controller.currentLesson, 42);
  });

  test('lesson session drills only the learned set', () async {
    final t = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 3),
    );
    final session = t.controller.startLessonSession();
    expect(session.kind, ReceiveDrillKind.groups);
    expect(session.countsTowardLesson, isTrue);
    expect(session.lesson, 3);
    expect(session.chars, <String>['K', 'M', 'R', 'S']);
    expect(session.currentDrill.chars, everyElement(isIn(session.chars)));
    expect(session.currentDrill.charCount, 5);
    expect(session.charBudget, 50);
  });

  test('seeded random makes sessions replayable', () async {
    final a = await TestTraining.create(seed: 7);
    final b = await TestTraining.create(seed: 7);
    expect(
      a.controller.startLessonSession().currentDrill.text,
      b.controller.startLessonSession().currentDrill.text,
    );
  });

  test('a perfect lesson session advances the lesson and saves', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    final session = c.startLessonSession();
    while (!session.isComplete) {
      session.submit(session.currentDrill.text);
    }
    final outcome = await c.recordReceiveSession(session);
    expect(outcome.passed, isTrue);
    expect(outcome.advanced, isTrue);
    expect(outcome.lesson, 2);
    expect(c.currentLesson, 2);
    expect(c.learnedChars, <String>['K', 'M', 'R']);
    expect(c.newestChar, 'R');
    expect(c.streak, 1);
    expect(c.charsToday, 50);
    expect(t.progressStore.saveCount, 1);
    final saved = await t.progressStore.load();
    expect(saved!.currentLesson, 2);
    expect(saved.history.single.drillKind, 'groups');
    // Both drilled symbols were copied cleanly, so SRS promoted them out of
    // box 0; only the symbol the new lesson unlocked is still "due" (new).
    expect(c.dueChars, <String>['R']);
  });

  test('a failed lesson session records stats but stays put', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    final session = c.startLessonSession();
    while (!session.isComplete) {
      // Answer the wrong symbol every time.
      final wrong = session.currentDrill.text
          .split('')
          .map((ch) => ch == 'K' ? 'M' : (ch == 'M' ? 'K' : ch))
          .join();
      session.submit(wrong);
    }
    final outcome = await c.recordReceiveSession(session);
    expect(outcome.passed, isFalse);
    expect(outcome.advanced, isFalse);
    expect(c.currentLesson, 1);
    // The aligner may salvage a few matches from a fully swapped copy by
    // shifting, so assert the shape rather than an exact zero.
    expect(c.progress.overallAccuracy, lessThan(0.9));
    expect(
      c.progress.confusion.count('K', 'M') +
          c.progress.confusion.count('M', 'K'),
      greaterThan(0),
    );
    // Which of K / M takes the blame is an aligner tie-break; what matters
    // is that both were tracked and the session went into history.
    expect(c.progress.charStats.keys, containsAll(<String>['K', 'M']));
    expect(c.progress.sessionCount, 1);
    expect(c.progress.srs.boxOf('K'), isNotNull);
  });

  test('review sessions never advance the lesson', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    final session = c.startReviewSession();
    expect(session.kind, ReceiveDrillKind.review);
    expect(session.countsTowardLesson, isFalse);
    while (!session.isComplete) {
      session.submit(session.currentDrill.text);
    }
    final outcome = await c.recordReceiveSession(session);
    expect(outcome.passed, isTrue);
    expect(outcome.advanced, isFalse);
    expect(c.currentLesson, 1);
  });

  test('review pool is the due set, falling back to all learned', () async {
    final t = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 5),
    );
    final c = t.controller;
    // Nothing tracked yet: everything is "new", so all six are due.
    expect(c.dueChars.length, 6);
    var session = c.startReviewSession();
    expect(session.chars.toSet(), c.learnedChars.toSet());

    // Clear the whole set; nothing is due tomorrow except demoted symbols.
    session = c.startLessonSession();
    while (!session.isComplete) {
      session.submit(session.currentDrill.text);
    }
    await c.recordReceiveSession(session);
    // The pass unlocked lesson 6, so only its new symbol is "due" (untracked);
    // a single due symbol is too thin to drill, so the pool falls back.
    expect(c.currentLesson, 6);
    expect(c.dueChars, <String>['P']);
    session = c.startReviewSession();
    expect(session.chars.toSet(), c.learnedChars.toSet());
  });

  test('streak counts consecutive days and resets after a gap', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    Future<void> practise() async {
      final s = c.startLessonSession();
      while (!s.isComplete) {
        s.submit(s.currentDrill.text);
      }
      await c.recordReceiveSession(s);
    }

    await practise();
    expect(c.streak, 1);
    t.clock.advance(const Duration(days: 1));
    await practise();
    expect(c.streak, 2);
    t.clock.advance(const Duration(days: 2));
    expect(c.streak, 0, reason: 'a skipped day breaks the streak');
    await practise();
    expect(c.streak, 1);
  });

  test(
    'send sessions credit history and streak but not receive stats',
    () async {
      final t = await TestTraining.create();
      final c = t.controller;
      final session = c.startSendSession();
      expect(session.target, isNotEmpty);
      expect(session.target.split(''), everyElement(isIn(<String>['K', 'M'])));
      // Key nothing at all: an empty attempt.
      final score = await c.recordSendSession(session);
      expect(score.drillKind, 'send');
      expect(c.progress.history.single.drillKind, 'send');
      expect(c.streak, 1);
      expect(c.charsToday, session.target.length);
      expect(c.progress.charStats, isEmpty);
      expect(c.progress.srs.cards, isEmpty);
      expect(t.progressStore.saveCount, 1);
    },
  );

  test('updateSettings persists and notifies once per change', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    var notifications = 0;
    c.addListener(() => notifications++);
    const next = TrainingSettings(keyerMode: KeyerMode.straight);
    await c.updateSettings(next);
    await c.updateSettings(next);
    expect(notifications, 1);
    expect(t.settingsStore.saveCount, 1);
    expect(await t.settingsStore.load(), next);
  });

  test('available drill kinds grow with the learned set', () async {
    final early = await TestTraining.create();
    expect(early.controller.availableReceiveKinds, <ReceiveDrillKind>[
      ReceiveDrillKind.groups,
    ]);
    final late = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 42),
    );
    expect(
      late.controller.availableReceiveKinds,
      containsAll(<ReceiveDrillKind>[
        ReceiveDrillKind.words,
        ReceiveDrillKind.callsigns,
        ReceiveDrillKind.qso,
      ]),
    );
  });

  test('daily goal fraction tracks characters practised today', () async {
    final t = await TestTraining.create(
      progress: TrainerProgress(dailyGoalChars: 100),
    );
    final c = t.controller;
    expect(c.dailyGoalFraction, 0);
    final s = c.startLessonSession();
    while (!s.isComplete) {
      s.submit(s.currentDrill.text);
    }
    await c.recordReceiveSession(s);
    expect(c.dailyGoalFraction, 0.5);
    expect(c.dailyGoalMet, isFalse);
    await c.setDailyGoal(50);
    expect(c.dailyGoalMet, isTrue);
  });
}
