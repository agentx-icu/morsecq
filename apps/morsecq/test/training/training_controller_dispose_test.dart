import 'package:flutter_test/flutter_test.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';

void main() {
  test('close then dispose runs the core and the notifier once', () async {
    final c = TrainingController(
      progressStore: InMemoryTrainerStore(),
      settingsStore: InMemoryTrainingSettingsStore(),
    );
    await c.load();
    var notified = 0;
    c.addListener(() => notified++);
    await c.setDailyGoal(10);
    expect(notified, 1);

    await c.close();
    expect(c.isDisposed, isTrue);
    // A second dispose must neither re-run the core teardown nor trip the
    // ChangeNotifier "disposed twice" assertion.
    c.dispose();
    expect(c.isDisposed, isTrue);
    expect(c.setDailyGoal(20), throwsStateError);
  });
}
