import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/desktop/shortcuts.dart';
import 'package:morsecq/ui/reference/reference_screen.dart';
import 'package:morsecq/ui/shell/app_shell.dart';

import '../support/test_app.dart';

LogicalKeyboardKey _primary(TargetPlatform platform) =>
    usesCommandModifier(platform)
    ? LogicalKeyboardKey.metaLeft
    : LogicalKeyboardKey.controlLeft;

Future<void> _chord(
  WidgetTester tester,
  LogicalKeyboardKey modifier, {
  bool repeat = false,
}) async {
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
  if (repeat) await tester.sendKeyRepeatEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(modifier);
  await settle(tester);
}

EditableText _search(WidgetTester tester) => tester.widget<EditableText>(
  find.descendant(
    of: find.byKey(ReferenceScreen.searchFieldKey, skipOffstage: false),
    matching: find.byType(EditableText, skipOffstage: false),
    skipOffstage: false,
  ),
);

Future<void> _reference(WidgetTester tester) async {
  await tester.tap(find.byIcon(kShellDestinations[1].icon).last);
  await settle(tester);
}

void main() {
  for (final platform in [
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.iOS,
    TargetPlatform.android,
  ]) {
    group('$platform current Reference search', () {
      void platformTest(
        String name,
        Future<void> Function(WidgetTester) body,
      ) => testWidgets(
        name,
        body,
        variant: TargetPlatformVariant.only(platform),
      );

      platformTest(
        'primary K focuses once from navigation; wrong keys do not',
        (tester) async {
          await pumpApp(tester, size: kDesktopSize);
          await _reference(tester);
          final search = _search(tester);
          expect(search.focusNode.hasFocus, isFalse);
          final primary = _primary(platform);
          final wrong = primary == LogicalKeyboardKey.metaLeft
              ? LogicalKeyboardKey.controlLeft
              : LogicalKeyboardKey.metaLeft;
          await _chord(tester, wrong);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await _chord(tester, primary);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
          await _chord(tester, primary);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
          await tester.pump();
          expect(search.focusNode.hasFocus, isFalse);
          var focused = 0;
          search.focusNode.addListener(() {
            if (search.focusNode.hasFocus) focused++;
          });
          await _chord(tester, primary, repeat: true);
          expect(search.focusNode.hasFocus, isTrue);
          expect(focused, 1);
          expect(find.byKey(ReferenceScreen.searchFieldKey), findsOneWidget);
        },
      );

      platformTest(
        'inactive pages stay inactive and returning restores command',
        (tester) async {
          await pumpApp(tester, size: kDesktopSize);
          await _chord(tester, _primary(platform));
          expect(find.byKey(ReferenceScreen.searchFieldKey), findsNothing);
          expect(_search(tester).focusNode.hasFocus, isFalse);
          await _reference(tester);
          await _chord(tester, _primary(platform));
          await tester.enterText(
            find.byKey(ReferenceScreen.searchFieldKey),
            'CQ',
          );
          await tester.tap(find.byIcon(kShellDestinations[0].icon).last);
          await settle(tester);
          expect(_search(tester).focusNode.hasFocus, isFalse);
          await _chord(tester, _primary(platform));
          expect(find.byKey(ReferenceScreen.searchFieldKey), findsNothing);
          await _reference(tester);
          await _chord(tester, _primary(platform));
          expect(_search(tester).focusNode.hasFocus, isTrue);
          expect(_search(tester).controller.text, 'CQ');
        },
      );

      platformTest('editor keeps composition and selection', (tester) async {
        await pumpApp(tester, size: kDesktopSize);
        await _reference(tester);
        await tester.tap(find.byKey(ReferenceScreen.searchFieldKey));
        await tester.pump();
        const composing = TextEditingValue(
          text: 'ni',
          selection: TextSelection.collapsed(offset: 2),
          composing: TextRange(start: 0, end: 2),
        );
        tester.testTextInput.updateEditingValue(composing);
        await tester.pump();
        await _chord(tester, _primary(platform));
        expect(_search(tester).focusNode.hasFocus, isTrue);
        expect(_search(tester).controller.value, composing);
        expect(find.byKey(ReferenceScreen.searchFieldKey), findsOneWidget);
      });
    });
  }

  testWidgets(
    'compact navigation and resizing retain search and command focus',
    (tester) async {
      await pumpApp(tester);
      await _reference(tester);
      await _chord(tester, LogicalKeyboardKey.metaLeft);
      expect(_search(tester).focusNode.hasFocus, isTrue);
      await tester.enterText(find.byKey(ReferenceScreen.searchFieldKey), 'CQ');
      tester.view.physicalSize = kDesktopSize;
      await settle(tester);
      expect(_search(tester).focusNode.hasFocus, isTrue);
      expect(_search(tester).controller.text, 'CQ');
      await tester.tap(find.byIcon(kShellDestinations[0].icon).last);
      await settle(tester);
      await _reference(tester);
      await _chord(tester, LogicalKeyboardKey.metaLeft);
      expect(_search(tester).focusNode.hasFocus, isTrue);
      expect(_search(tester).controller.text, 'CQ');
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'covering dialog keeps its editor and does not focus Reference',
    (tester) async {
      await pumpApp(tester, size: kDesktopSize);
      await _reference(tester);
      final context = tester.element(find.byType(ReferenceScreen));
      unawaited(
        showDialog<void>(
          context: context,
          builder: (_) =>
              const AlertDialog(content: TextField(autofocus: true)),
        ),
      );
      await settle(tester);
      await _chord(tester, LogicalKeyboardKey.controlLeft);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(_search(tester).focusNode.hasFocus, isFalse);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'pushed route retains focus and selected Reference after Back',
    (tester) async {
      await pumpApp(tester, size: kDesktopSize);
      await _reference(tester);
      final context = tester.element(find.byType(ReferenceScreen));
      unawaited(
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: TextField(autofocus: true)),
          ),
        ),
      );
      await settle(tester);
      await _chord(tester, LogicalKeyboardKey.controlLeft);
      expect(_search(tester).focusNode.hasFocus, isFalse);
      Navigator.of(context).pop();
      await settle(tester);
      await _chord(tester, LogicalKeyboardKey.controlLeft);
      expect(_search(tester).focusNode.hasFocus, isTrue);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}
