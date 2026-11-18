import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/keying/key_profile.dart';
import 'package:morsecq/keying/key_profiles.dart';
import 'package:morsecq/ui/keying/key_setup_page.dart';
import 'package:morsecq/ui/keying/key_test_area.dart';
import 'package:provider/provider.dart';

import '../learn/helpers/l10n.dart';

final class _RetryStore implements KeyValueStore {
  final saved = InMemoryKeyValueStore();
  bool failNext = true;

  @override
  String? getString(String key) => saved.getString(key);

  @override
  Future<void> setString(String key, String value) async {
    if (failNext) {
      failNext = false;
      throw StateError('profile storage unavailable');
    }
    await saved.setString(key, value);
  }

  @override
  Future<void> remove(String key) => saved.remove(key);
}

void main() {
  late KeyProfiles profiles;
  late RecordingSink sink;

  Future<void> pumpEditor(
    WidgetTester tester,
    KeyProfile profile, {
    KeyValueStore? store,
  }) async {
    profiles = KeyProfiles(store ?? InMemoryKeyValueStore());
    sink = RecordingSink(clock: FakeClock());
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
    await tester.pumpAndSettle();
    expect(find.byType(KeyProfileEditorPage), findsNothing);
    expect(profiles.active.name, 'Vail');
    expect(profiles.active.dit, {LogicalKeyboardKey.bracketLeft});
    expect(profiles.active.dah, {LogicalKeyboardKey.bracketRight});
  });

  testWidgets('a failed profile save keeps the draft open for retry', (
    tester,
  ) async {
    await pumpEditor(
      tester,
      KeyProfile.defaults.copyWith(id: 'retry'),
      store: _RetryStore(),
    );
    await tester.enterText(find.byKey(const Key('keys-name')), 'Retry profile');
    final save = find.byKey(const Key('keys-save'));

    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('keys-error')), findsOneWidget);
    expect(find.byType(KeyProfileEditorPage), findsOneWidget);
    expect(profiles.active.isDefault, isTrue);

    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.byType(KeyProfileEditorPage), findsNothing);
    expect(profiles.active.name, 'Retry profile');
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
