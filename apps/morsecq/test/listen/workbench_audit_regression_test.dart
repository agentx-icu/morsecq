import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/listen/workbench/recording_files.dart';
import 'package:morsecq/ui/listen/workbench/workbench_controller.dart';
import 'package:morsecq/ui/listen/workbench/workbench_decode_panel.dart';

import '../learn/helpers/l10n.dart';
import '../learn/helpers/test_controller.dart';
import 'workbench_support.dart';

Future<(TestTraining, WorkbenchController)> _exposed(
  WidgetTester tester,
) async {
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
  await tester.runAsync(() async {
    expect(
      await workbench.importRecording(
        PickedRecording(name: 'sos.wav', bytes: cwWav('SOS TEST')),
      ),
      isTrue,
    );
    await workbench.decode();
  });
  expect(workbench.result!.text, 'SOS TEST');
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
  await tester.tap(find.byKey(const ValueKey('workbench-show-decoder')));
  await tester.pump();
  expect(find.byKey(const ValueKey('workbench-text')), findsOneWidget);
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
  test(
    'opening a saved recording cannot attach after exiting during stop',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'workbench_stop_audit_',
      );
      addTearDown(() => root.delete(recursive: true));
      final library = RecordingLibrary(root.path);
      const saved = 'media/recordings/rec_saved.wav';
      final initial = await library.importTo(
        PickedRecording(name: 'saved.wav', bytes: cwWav('SOS TEST')),
        relativePath: saved,
      );
      await closeReader(initial);
      final player = _DelayedStopPlayer();
      addTearDown(player.dispose);
      final workbench = WorkbenchController(library: library, player: player);
      addTearDown(() => closeReader(workbench.reader));
      final opening = workbench.openSaved(saved, 'Saved');
      await player.stopping.future;
      workbench.dispose();
      player.release.complete();
      expect(await opening, isFalse);
      expect(workbench.reader, isNull);
    },
  );

  test('an import finishing after disposal must release its reader', () async {
    final root = await Directory.systemTemp.createTemp('workbench_exit_audit_');
    addTearDown(() => root.delete(recursive: true));
    final player = FakeClipPlayer();
    addTearDown(player.dispose);
    final workbench = WorkbenchController(
      library: RecordingLibrary(root.path),
      player: player,
    );
    addTearDown(() => closeReader(workbench.reader));
    final data = StreamController<List<int>>();
    final copying = Completer<void>();
    final importing = workbench.importRecording(
      PickedRecording(
        name: 'slow.wav',
        read: () {
          copying.complete();
          return data.stream;
        },
      ),
    );
    await copying.future;
    workbench.dispose();
    data.add(cwWav('SOS TEST'));
    await data.close();
    await importing;
    expect(workbench.reader, isNull);
  });

  testWidgets('changing tuning cannot make an exposed recording independent', (
    tester,
  ) async {
    final (training, workbench) = await _exposed(tester);
    // Tuning changes the decoder, but not the already revealed audio content.
    workbench.setTuning(auto: false, hz: 700);
    await tester.runAsync(workbench.decode);
    await tester.pump();
    expect(workbench.result!.text, 'SOS TEST');
    await _submit(tester, 'SOS TEST');
    expect(
      training.controller.progress.history.single.assistance,
      contains(Assistance.decoder),
    );
  });

  testWidgets(
    'a new imported recording does not inherit the old answer reveal',
    (tester) async {
      final (training, workbench) = await _exposed(tester);
      final originalEnd = workbench.end;
      await tester.runAsync(() async {
        expect(
          await workbench.importRecording(
            PickedRecording(name: 'different.wav', bytes: cwWav('SOS TSET')),
          ),
          isTrue,
        );
        await workbench.decode();
      });
      await tester.pump();
      expect(workbench.end, originalEnd);
      expect(workbench.result!.text, 'SOS TSET');
      expect(find.byKey(const ValueKey('workbench-text')), findsNothing);
      await _submit(tester, 'SOS TSET');
      expect(training.controller.progress.history.single.assistance, isEmpty);
    },
  );
}

final class _DelayedStopPlayer implements ClipPlayer {
  final _delegate = FakeClipPlayer();
  final stopping = Completer<void>();
  final release = Completer<void>();

  @override
  bool get isPlaying => _delegate.isPlaying;
  @override
  Stream<bool> get playing => _delegate.playing;
  @override
  Future<void> dispose() => _delegate.dispose();
  @override
  Future<void> play(
    Uint8List wav, {
    required Duration length,
    bool loop = false,
  }) => _delegate.play(wav, length: length, loop: loop);
  @override
  Future<void> stop() async {
    if (!stopping.isCompleted) stopping.complete();
    await release.future;
    await _delegate.stop();
  }
}
