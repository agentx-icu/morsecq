import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_plan.dart';
import 'helpers/test_controller.dart';

void main() {
  final good = SessionSummary(
    id: 'recent-recovery',
    at: kTestNow,
    totalChars: 20,
    correctChars: 20,
    source: ExerciseSource.focus,
    characterWpm: 20,
    effectiveWpm: 8,
    assistance: const {},
    perChar: const {
      'K': CharStats(attempts: 10, correct: 10),
      'M': CharStats(attempts: 10, correct: 10),
    },
  );
  for (final oldConfusions in [false, true]) {
    test(
      'recent recovery removes lifetime ${oldConfusions ? "confusions" : "weakness"} from daily focus',
      () async {
        final confusion = ConfusionMatrix();
        if (oldConfusions) confusion.record('K', 'M', times: 100);
        final t = await TestTraining.create(
          progress: TrainerProgress(
            firstLessonDoneAt: kTestNow,
            history: [good],
            confusion: confusion,
            charStats: oldConfusions
                ? const {
                    'K': CharStats(attempts: 1010, correct: 910),
                    'M': CharStats(attempts: 10, correct: 10),
                  }
                : const {
                    'K': CharStats(attempts: 110, correct: 10),
                    'M': CharStats(attempts: 110, correct: 10),
                  },
          ),
        );
        addTearDown(t.controller.dispose);
        expect(t.controller.learnerStage, LearnerStage.copying);
        expect(t.controller.masteryOf('K'), CharMastery.mastered);
        expect(t.controller.masteryOf('M'), CharMastery.mastered);
        final inputs = t.controller.planInputs(seed: 1);
        final focus = DailyPlanBuilder.focusPool(inputs);
        final plan = DailyPlanBuilder.build(inputs);
        expect(
          focus,
          isEmpty,
          reason:
              'both current symbols are 10/10 at the current speed; '
              'plan focus remains $focus / ${plan.steps.map((s) => '${s.kind.name}:${s.reason.name}').join(', ')}',
        );
      },
    );
  }
  test(
    'a current independent weakness still receives a contrast step',
    () async {
      final pairs = ConfusionMatrix()..record('M', 'K', times: 8);
      final t = await TestTraining.create(
        progress: TrainerProgress(
          firstLessonDoneAt: kTestNow,
          confusion: pairs,
          history: [
            SessionSummary(
              id: 'current-weak',
              at: kTestNow,
              totalChars: 20,
              correctChars: 18,
              source: ExerciseSource.focus,
              characterWpm: 20,
              effectiveWpm: 8,
              assistance: const {},
              perChar: const {
                'K': CharStats(attempts: 10, correct: 10),
                'M': CharStats(attempts: 10, correct: 8),
              },
            ),
          ],
        ),
      );
      addTearDown(t.controller.dispose);
      final plan = await t.controller.ensureTodayPlan();
      final focus = plan.steps.firstWhere(
        (step) => step.kind == PlanStepKind.focus,
      );
      expect(focus.pool, contains('M'));
      expect(focus.reason, PlanReason.confusions);
      expect(t.controller.progress.confusion.count('M', 'K'), 8);
    },
  );
  test(
    'stray answers cannot inflate the sample floor used for plan focus',
    () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(
          firstLessonDoneAt: kTestNow,
          history: [
            SessionSummary(
              id: 'under-sampled',
              at: kTestNow,
              totalChars: 9,
              correctChars: 9,
              insertions: 3,
              source: ExerciseSource.focus,
              characterWpm: 20,
              effectiveWpm: 8,
              assistance: const {},
              perChar: const {'K': CharStats(attempts: 9, correct: 9)},
            ),
          ],
        ),
      );
      addTearDown(t.controller.dispose);
      expect(DailyPlanBuilder.focusPool(t.controller.planInputs()), isEmpty);
      expect(t.controller.masteryOf('K'), CharMastery.practicing);
    },
  );
}
