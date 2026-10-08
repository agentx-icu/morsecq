import 'package:morse_trainer/morse_trainer.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.now();
  final course = KochCourse();
  const good = <String, CharStats>{
    'K': CharStats(attempts: 10, correct: 10),
    'M': CharStats(attempts: 10, correct: 10),
  };
  SessionSummary row({
    DateTime? at,
    Set<Assistance>? assistance,
    bool completed = true,
  }) => SessionSummary(
    at: at ?? now,
    totalChars: 20,
    correctChars: 20,
    source: ExerciseSource.focus,
    drillKind: 'characters',
    characterWpm: 20,
    effectiveWpm: 8,
    perChar: good,
    assistance: assistance ?? <Assistance>{},
    completed: completed,
  );
  TrainerProgress progress(
    List<SessionSummary> history, {
    bool oldMistakes = false,
  }) => TrainerProgress(
    firstLessonDoneAt: now,
    charStats: oldMistakes
        ? const <String, CharStats>{
            'K': CharStats(attempts: 110, correct: 10),
            'M': CharStats(attempts: 110, correct: 10),
          }
        : good,
    history: history,
  );

  test('recent independent success replaces lifetime beginner mistakes', () {
    expect(
      LearnerStages.of(progress([row()], oldMistakes: true), course),
      LearnerStage.copying,
    );
  });
  test(
    'unlocked or lifetime counters without recent evidence are not mastery',
    () {
      expect(LearnerStages.of(progress([]), course), LearnerStage.recognition);
    },
  );
  test('expired evidence cannot prove current mastery', () {
    expect(
      LearnerStages.of(
        progress([row(at: now.subtract(const Duration(days: 15)))]),
        course,
      ),
      LearnerStage.recognition,
    );
  });
  test('assisted evidence cannot prove mastery', () {
    expect(
      LearnerStages.of(
        progress([
          row(assistance: {Assistance.replay}),
        ]),
        course,
      ),
      LearnerStage.recognition,
    );
  });
  test('unfinished evidence cannot prove mastery', () {
    expect(
      LearnerStages.of(progress([row(completed: false)]), course),
      LearnerStage.recognition,
    );
  });
  test('latest five use append order when timestamps tie', () {
    final wrong = SessionSummary(
      at: now,
      totalChars: 10,
      correctChars: 0,
      source: ExerciseSource.focus,
      characterWpm: 20,
      effectiveWpm: 8,
      assistance: const {},
      perChar: const {'K': CharStats(attempts: 10, correct: 0)},
    );
    final evidence = RecentPractice.forSymbol(
      [wrong, ...List.generate(5, (_) => row())],
      'K',
      now: now,
    );
    expect(evidence.stats, const CharStats(attempts: 50, correct: 50));
  });
  test('insertions penalize strict accuracy without filling sample quota', () {
    final padded = SessionSummary(
      at: now,
      totalChars: 9,
      correctChars: 9,
      source: ExerciseSource.focus,
      characterWpm: 20,
      effectiveWpm: 8,
      assistance: const {},
      insertions: 1,
      perChar: const {'K': CharStats(attempts: 9, correct: 9)},
    );
    final evidence = RecentPractice.forSymbol([padded], 'K', now: now);
    expect(evidence.strictAccuracy, .9);
    expect(
      LearnerStages.masteryOf(evidence.stats, insertions: evidence.insertions),
      CharMastery.practicing,
    );
  });
  test('recent evidence excludes a different pace and unknown help', () {
    final other = SessionSummary(
      at: now,
      totalChars: 20,
      correctChars: 20,
      source: ExerciseSource.focus,
      characterWpm: 20,
      effectiveWpm: 6,
      assistance: const {},
      perChar: good,
    );
    expect(
      RecentPractice.forSymbol(
        [other],
        'K',
        now: now,
        characterWpm: 20,
        effectiveWpm: 8,
      ).stats.attempts,
      0,
    );
    final unknown = SessionSummary(
      at: now,
      totalChars: 20,
      correctChars: 20,
      source: ExerciseSource.focus,
      characterWpm: 20,
      effectiveWpm: 8,
      perChar: good,
    );
    expect(
      RecentPractice.forSymbol([unknown], 'K', now: now).stats.attempts,
      0,
    );
  });
}
