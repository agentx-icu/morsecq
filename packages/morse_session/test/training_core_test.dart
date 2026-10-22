import 'package:test/test.dart';

import 'helpers/test_core.dart';

void main() {
  test('close disposes the core and a later dispose is a no-op', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    var notified = 0;
    c.addListener(() => notified++);
    await c.setDailyGoal(10);
    expect(notified, 1);

    await c.close();
    expect(c.isDisposed, isTrue);
    c.dispose();
    expect(c.isDisposed, isTrue);
    expect(c.setDailyGoal(20), throwsStateError);
    expect(notified, 1);
  });

  test('dispose before close refuses further writes', () async {
    final t = await TestTraining.create();
    final c = t.controller;
    c.dispose();
    c.dispose();
    expect(c.isDisposed, isTrue);
    expect(c.markFirstLessonDone(), throwsStateError);
  });
}
