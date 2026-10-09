import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_dsp/testing.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/listen/workbench/recording_files.dart';
import 'package:morsecq/ui/listen/workbench/workbench_controller.dart';
import 'package:morsecq/ui/listen/workbench/workbench_decode_panel.dart';

import '../learn/helpers/l10n.dart';
import '../learn/helpers/test_controller.dart';
import 'workbench_support.dart';

Future<(TestTraining, WorkbenchController)> _exposed(
  WidgetTester tester, {
  bool firstHalf = false,
  bool reveal = true,
}) async {
  tester.view.physicalSize = const Size(430, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final root = (await tester.runAsync(
    () => Directory.systemTemp.createTemp('workbench_audit_'),
  ))!;
  addTearDown(() => root.delete(recursive: true));
  final training = await TestTraining.create();
  addTearDown(training.controller.dispose);
  final player = FakeClipPlayer();
  final workbench = WorkbenchController(
    library: RecordingLibrary(root.path),
    player: player,
  );
  addTearDown(workbench.dispose);
  final repeated = SyntheticMorse(sampleRate: 8000).renderText('SOS');
  await tester.runAsync(() async {
    expect(
      await workbench.importRecording(
        PickedRecording(
          name: 'sos.wav',
          bytes: firstHalf
              ? wavOf(
                  Int16List.fromList([...repeated, ...repeated]),
                  sampleRate: 8000,
                )
              : cwWav('SOS TEST'),
        ),
      ),
      isTrue,
    );
    if (firstHalf) workbench.setSelection(0, workbench.end ~/ 2);
    await workbench.decode();
  });
  expect(workbench.result!.text, firstHalf ? 'SOS' : 'SOS TEST');
  await tester.pumpWidget(
    l10nApp(
      home: Scaffold(
        body: AnimatedBuilder(
          animation: workbench,
          builder: (_, _) => SingleChildScrollView(
            child: WorkbenchDecodePanel(
              controller: workbench,
              training: training.controller,
            ),
          ),
        ),
      ),
    ),
  );
  if (reveal) {
    await tester.tap(find.byKey(const ValueKey('workbench-show-decoder')));
    await tester.pump();
    expect(find.byKey(const ValueKey('workbench-text')), findsOneWidget);
  }
  return (training, workbench);
}

Future<void> _submit(WidgetTester tester, String answer) async {
  await tester.enterText(
    find.byKey(const ValueKey('workbench-answer')),
    answer,
  );
  final submit = find.byKey(const ValueKey('workbench-submit'));
  await tester.ensureVisible(submit);
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'an overlapping selection cannot erase already seen decoder assistance',
    (tester) async {
      final (training, workbench) = await _exposed(tester);
      final end = workbench.end;
      workbench.setSelection(0, end - 1);
      await tester.runAsync(workbench.decode);
      await tester.pump();
      expect(
        workbench.result!.text,
        'SOS TEST',
        reason: 'same revealed content',
      );
      expect(find.byKey(const ValueKey('workbench-text')), findsNothing);
      await _submit(tester, 'SOS TEST');
      expect(
        training.controller.progress.history.single.assistance,
        contains(Assistance.decoder),
        reason:
            'trimming one audio frame cannot make a known answer independent',
      );
    },
  );

  testWidgets('expanding an exposed selection keeps the new answer hidden', (
    tester,
  ) async {
    final (training, workbench) = await _exposed(tester, firstHalf: true);
    workbench.setSelection(0, workbench.info!.frameCount);
    await tester.runAsync(workbench.decode);
    await tester.pump();
    expect(workbench.result!.text, 'SOS SOS');
    expect(find.byKey(const ValueKey('workbench-text')), findsNothing);
    await _submit(tester, 'SOS SOS');
    expect(
      training.controller.progress.history.single.assistance,
      contains(Assistance.decoder),
    );
  });

  testWidgets('a disjoint selection stays hidden and independent', (
    tester,
  ) async {
    final (training, workbench) = await _exposed(tester, firstHalf: true);
    workbench.setSelection(workbench.end, workbench.info!.frameCount);
    workbench.setTuning(auto: false, hz: 700);
    await tester.runAsync(workbench.decode);
    await tester.pump();
    expect(workbench.result!.text, 'SOS');
    expect(find.byKey(const ValueKey('workbench-text')), findsNothing);
    await _submit(tester, 'SOS');
    expect(training.controller.progress.history.single.assistance, isEmpty);
  });

  testWidgets('a blind result reveals its target for later attempts only', (
    tester,
  ) async {
    final (training, workbench) = await _exposed(tester, reveal: false);
    expect(find.byKey(const ValueKey('workbench-text')), findsNothing);
    await _submit(tester, 'SOS TEST');
    expect(training.controller.progress.history.single.assistance, isEmpty);
    await tester.runAsync(workbench.decode);
    await tester.pump();
    await _submit(tester, 'SOS TEST');
    final history = training.controller.progress.history;
    expect(history, hasLength(2));
    expect(
      history.where(
        (attempt) => attempt.assistance?.contains(Assistance.decoder) == true,
      ),
      hasLength(1),
      reason:
          'only the attempt made after the scored target was seen is assisted',
    );
  });
}
