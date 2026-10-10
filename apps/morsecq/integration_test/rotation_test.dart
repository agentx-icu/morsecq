// Real-device rotation: the real main(), rotated portrait <-> landscape
// through the platform. Desktop has no rotation, so the E2E desktop run
// skips it; run it on an iOS simulator / Android emulator or a phone.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart' as app;
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/reference/reference_screen.dart';
import 'package:morsecq/ui/shell/app_shell.dart';

import 'support/scene_walk.dart';
import 'support/shot_harness.dart';

final bool _mobile = Platform.isIOS || Platform.isAndroid;

bool _landscape(WidgetTester tester) {
  final size = tester.view.physicalSize;
  return size.width > size.height;
}

/// Asks the platform for [orientation] and waits until the window really
/// turned (an orientation request is not a guarantee).
Future<void> _rotate(WidgetTester tester, {required bool landscape}) async {
  await SystemChrome.setPreferredOrientations(
    landscape
        ? const [DeviceOrientation.landscapeLeft]
        : const [DeviceOrientation.portraitUp],
  );
  final deadline = DateTime.now().add(const Duration(seconds: 15));
  while (_landscape(tester) != landscape && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await tester.pump();
  }
  expect(
    _landscape(tester),
    landscape,
    reason:
        'the window did not rotate to ${landscape ? 'landscape' : 'portrait'}',
  );
  await settle(tester, extra: const Duration(milliseconds: 500));
  expect(tester.takeException(), isNull);
}

/// The text field holding focus (its focus node's context is the Focus
/// inside the EditableText).
EditableText _focusedField() {
  final context = FocusManager.instance.primaryFocus!.context!;
  return context.widget is EditableText
      ? context.widget as EditableText
      : context.findAncestorWidgetOfExactType<EditableText>()!;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('rotation keeps the tab, typed text, focus and the drill', (
    tester,
  ) async {
    addTearDown(() => SystemChrome.setPreferredOrientations(const []));
    await app.main();
    await settle(tester, extra: const Duration(milliseconds: 500));
    expect(find.byType(AppShell), findsOneWidget);
    final s = S.of(tester.element(find.byType(AppShell)));
    await _rotate(tester, landscape: false);

    // Reference tab with a search typed in.
    await selectTab(tester, ShellTab.reference);
    final search = find.byKey(ReferenceScreen.searchFieldKey);
    await tester.tap(search);
    await tester.enterText(search, 'CQ');
    await settle(tester);
    for (final landscape in [true, false]) {
      await _rotate(tester, landscape: landscape);
      expect(find.byType(ReferenceScreen), findsOneWidget);
      expect(tester.widget<TextField>(search).controller!.text, 'CQ');
      expect(_focusedField().controller.text, 'CQ');
    }

    // A receive drill with an answer being typed.
    FocusManager.instance.primaryFocus?.unfocus();
    await selectTab(tester, ShellTab.learn);
    final home = tester.widget<LearnHome>(find.byType(LearnHome));
    if (home.controller.learnerStage == LearnerStage.firstUse) {
      await tapHittable(
        tester,
        find.byKey(const ValueKey('placement-skip-intro')),
        'explicit lesson challenge',
      );
    } else {
      await tapText(tester, s.learnContinueLesson);
    }
    expect(find.byType(ReceiveDrillScreen), findsOneWidget);
    final answer = find.descendant(
      of: find.byType(ReceiveDrillScreen),
      matching: find.byType(TextField),
    );
    await tester.tap(answer);
    await tester.enterText(answer, 'KM');
    await settle(tester);
    for (final landscape in [true, false]) {
      await _rotate(tester, landscape: landscape);
      expect(find.byType(ReceiveDrillScreen), findsOneWidget);
      expect(tester.widget<TextField>(answer).controller!.text, 'KM');
      expect(_focusedField().controller.text, 'KM');
    }
  }, skip: !_mobile);
}
