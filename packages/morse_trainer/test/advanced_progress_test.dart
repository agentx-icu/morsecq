import 'package:test/test.dart';
import 'package:morse_trainer/morse_trainer.dart';

void main() {
  test(
    'old progress gains safe defaults and chosen goal survives all copies',
    () {
      final old = TrainerProgress.fromJson({'currentLesson': 3});
      expect(old.learningGoal, LearningGoal.firstQso);
      expect(old.listeningAttempts, isEmpty);
      expect(old.mistakeNotebook.entries, isEmpty);
      final selected = old.copyWith(learningGoal: LearningGoal.conversation);
      expect(
        TrainerProgress.fromJson(selected.withLesson(4).toJson()).learningGoal,
        LearningGoal.conversation,
      );
    },
  );
  test(
    'listening credit is idempotent, survives reload and never unlocks or alters SRS',
    () {
      final at = DateTime(2026, 10, 9);
      final attempt = ListeningAttempt(
        id: 'listen_1',
        at: at,
        mode: ListeningMode.qso,
        correct: 3,
        total: 3,
        characterWpm: 20,
        effectiveWpm: 13,
      );
      final old = TrainerProgress(currentLesson: 2);
      final next = old.recordListening(attempt);
      expect(next.currentLesson, 2);
      expect(next.charStats, isEmpty);
      expect(next.srs.cards, isEmpty);
      expect(next.lifetimeSessions, 1);
      expect(next.lifetimeChars, 0);
      final restored = TrainerProgress.fromJson(
        next.toJson(),
      ).recordListening(attempt);
      expect(restored.listeningAttempts.length, 1);
      expect(restored.lifetimeSessions, 1);
    },
  );
  test(
    'late listening evidence cannot move the most recent activity backwards',
    () {
      final latest = DateTime(2026, 10, 9);
      final old = TrainerProgress(streakDays: 5, lastPracticeDay: latest);
      final attempt = ListeningAttempt(
        id: 'backdated',
        at: DateTime(2026, 9, 1),
        mode: ListeningMode.words,
        correct: 1,
        total: 1,
        characterWpm: 20,
        effectiveWpm: 13,
      );
      final next = old.recordListening(attempt);
      expect(next.lastPracticeDay, latest);
      expect(next.streakDays, 5);
      expect(next.listeningAttempts.single.at, attempt.at);
    },
  );
}
