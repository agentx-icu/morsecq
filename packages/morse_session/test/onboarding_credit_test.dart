import 'package:test/test.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'helpers/test_core.dart';

void main() {
  test(
    'two-choice tutorials are activity, never independent recognition',
    () async {
      final t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      for (var i = 0; i < 5; i++) {
        final session = t.controller.startOnboardingSession();
        while (!session.isComplete) {
          session.submit(session.currentDrill.text);
        }
        final outcome = await t.controller.recordReceiveSession(session);
        expect(outcome.credit.activity, isTrue);
        expect(outcome.credit.receiveStats, isFalse);
      }
      await t.controller.markFirstLessonDone();
      expect(t.controller.learnerStage, LearnerStage.recognition);
      expect(t.controller.progress.charStats, isEmpty);
    },
  );
}
