import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';

void main() {
  test('defaults: space = straight, ctrl left/right = dit/dah', () {
    final b = KeyboardKeyBinding.defaults;
    expect(b.actionFor(LogicalKeyboardKey.space), KeyerAction.straight);
    expect(b.actionFor(LogicalKeyboardKey.controlLeft), KeyerAction.dit);
    expect(b.actionFor(LogicalKeyboardKey.controlRight), KeyerAction.dah);
    expect(b.actionFor(LogicalKeyboardKey.keyA), isNull);
  });

  test('swapped exchanges dit and dah only', () {
    final b = KeyboardKeyBinding.defaults.swapped();
    expect(b.actionFor(LogicalKeyboardKey.controlLeft), KeyerAction.dah);
    expect(b.actionFor(LogicalKeyboardKey.controlRight), KeyerAction.dit);
    expect(b.actionFor(LogicalKeyboardKey.space), KeyerAction.straight);
  });

  test('copyWith replaces one set and keeps the others', () {
    final b = KeyboardKeyBinding.defaults.copyWith(
      dit: <LogicalKeyboardKey>{LogicalKeyboardKey.keyZ},
    );
    expect(b.actionFor(LogicalKeyboardKey.keyZ), KeyerAction.dit);
    expect(b.actionFor(LogicalKeyboardKey.controlLeft), isNull);
    expect(b.actionFor(LogicalKeyboardKey.controlRight), KeyerAction.dah);
  });

  test('actionForEvent ignores repeats', () {
    final b = KeyboardKeyBinding.defaults;
    const down = KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.space,
      logicalKey: LogicalKeyboardKey.space,
      timeStamp: Duration.zero,
    );
    const repeat = KeyRepeatEvent(
      physicalKey: PhysicalKeyboardKey.space,
      logicalKey: LogicalKeyboardKey.space,
      timeStamp: Duration.zero,
    );
    const up = KeyUpEvent(
      physicalKey: PhysicalKeyboardKey.space,
      logicalKey: LogicalKeyboardKey.space,
      timeStamp: Duration.zero,
    );
    expect(b.actionForEvent(down), KeyerAction.straight);
    expect(b.actionForEvent(repeat), isNull);
    expect(b.actionForEvent(up), KeyerAction.straight);
  });

  test('sets are unmodifiable', () {
    expect(
      () => KeyboardKeyBinding.defaults.dit.add(LogicalKeyboardKey.keyA),
      throwsUnsupportedError,
    );
  });
}
