import 'package:morsecq/training/training_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_io/testing.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/keying/key_profile.dart';
import 'package:morsecq/keying/key_profiles.dart';
import 'package:morsecq/ui/keying/key_setup_page.dart';
import 'package:morsecq/ui/keying/key_test_area.dart';
import 'package:provider/provider.dart';

import '../learn/helpers/l10n.dart';

void main() {
  late KeyProfiles profiles;
  late RecordingSink sink;

  setUp(() {
    profiles = KeyProfiles(InMemoryKeyValueStore());
    sink = RecordingSink(clock: FakeClock());
  });

  Future<void> pumpEditor(WidgetTester tester, KeyProfile profile) async {
    tester.view.physicalSize = const Size(600, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider<KeyProfiles>.value(
        value: profiles,
        child: l10nApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        KeyProfileEditorPage(profile: profile, testSink: sink),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> capture(
    WidgetTester tester,
    KeyerAction a,
    LogicalKeyboardKey key,
  ) async {
    await tester.tap(
      find.descendant(
        of: find.byKey(Key('keys-capture-${a.name}')),
        matching: find.text(en.keysSet),
      ),
    );
    await tester.pump();
    await tester.sendKeyDownEvent(key);
    await tester.sendKeyUpEvent(key);
    await tester.pump();
  }

  testWidgets('capture, conflict, reserved key, then save and activate', (
    tester,
  ) async {
    await pumpEditor(tester, KeyProfile.defaults.copyWith(id: 'p1'));
    await tester.enterText(find.byKey(const Key('keys-name')), 'Vail');
    await capture(tester, KeyerAction.dit, LogicalKeyboardKey.bracketLeft);
    // The straight key already uses Space: refused with a reason.
    await capture(tester, KeyerAction.dah, LogicalKeyboardKey.space);
    expect(
      find.text(en.keysConflict('Space', en.keysActionStraight)),
      findsOneWidget,
    );
    await capture(tester, KeyerAction.dah, LogicalKeyboardKey.tab);
    expect(find.textContaining('Tab'), findsWidgets);
    await capture(tester, KeyerAction.dah, LogicalKeyboardKey.bracketRight);
    await tester.tap(find.byKey(const Key('keys-save')));
    // The save's store write, then the pop.
    await tester.runAsync(() => profiles.flush());
    await tester.pumpAndSettle();
    expect(find.byType(KeyProfileEditorPage), findsNothing);
    expect(profiles.active.name, 'Vail');
    expect(profiles.active.dit, {LogicalKeyboardKey.bracketLeft});
    expect(profiles.active.dah, {LogicalKeyboardKey.bracketRight});
  });

  testWidgets('the test area keys with the draft bindings; repeats ignored; '
      'release stops a held tone', (tester) async {
    await pumpEditor(
      tester,
      KeyProfile.defaults.copyWith(
        id: 'p2',
        straight: {LogicalKeyboardKey.keyK},
        keyerMode: KeyerMode.straight,
      ),
    );
    // Focus is on the test key (autofocus). K is the straight key now.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.keyK);
    await tester.pump();
    expect(sink.events.where((e) => e.on), hasLength(1));
    final lamp = tester.widget<Icon>(find.byKey(KeyTestArea.lampKey));
    expect(
      lamp.color,
      isNot(
        Theme.of(
          tester.element(find.byType(KeyTestArea)),
        ).colorScheme.outlineVariant,
      ),
    );
    // Space is not bound any more.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(sink.events.where((e) => e.on), hasLength(1));
    // Lost key-up: the explicit release turns the tone off.
    await tester.tap(find.byKey(KeyTestArea.releaseKey));
    await tester.pump();
    expect(sink.isOn, isFalse);
    expect(profiles.saved, isEmpty, reason: 'testing saves nothing');
  });
}
