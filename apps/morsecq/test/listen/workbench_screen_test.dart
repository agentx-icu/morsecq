import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/ui/listen/workbench/recording_files.dart';
import 'package:morsecq/ui/listen/workbench/workbench_controller.dart';
import 'package:morsecq/ui/listen/workbench/workbench_library_sheet.dart';
import 'package:morsecq/ui/listen/workbench/workbench_screen.dart';
import 'package:morsecq/ui/listen/workbench/workbench_waveform.dart';
import 'package:path/path.dart' as p;

import '../learn/helpers/l10n.dart';
import '../learn/helpers/test_controller.dart';
import 'workbench_support.dart';
import 'workbench_wait.dart';

void main() {
  late Directory root;
  late String dataDir;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('wbs_');
    dataDir = p.join(root.path, 'training');
    await Directory(dataDir).create();
  });
  tearDown(() => root.delete(recursive: true));

  Future<(TestTraining, FakePicker, FakeClipPlayer)> pumpScreen(
    WidgetTester tester, {
    Size size = const Size(390, 2200),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final t = await TestTraining.create();
    final picker = FakePicker(
      PickedRecording(name: 'sos.wav', bytes: cwWav('SOS TEST')),
    );
    final player = FakeClipPlayer();
    await tester.pumpWidget(
      l10nApp(
        home: WorkbenchScreen(
          picker: picker,
          player: player,
          profileRoot: () async => dataDir,
          training: () async => t.controller,
        ),
      ),
    );
    await waitForWorkbench(
      tester,
      find.byKey(const ValueKey('workbench-import-empty')),
    );
    await waitForWorkbenchCondition(
      tester,
      () => tester.widget<IconButton>(_libraryButton).onPressed != null,
      description: 'enable the recording library',
    );
    return (t, picker, player);
  }

  testWidgets('import, decode, then copy it myself records activity only', (
    tester,
  ) async {
    final (t, _, player) = await pumpScreen(tester);
    expect(find.text(en.workbenchBackupNote), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
    await waitForWorkbench(
      tester,
      find.byKey(const ValueKey('workbench-decode')),
    );
    expect(find.byKey(const ValueKey('workbench-info')), findsOneWidget);
    expect(find.byKey(const ValueKey('workbench-waveform')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('workbench-play')));
    await waitForWorkbench(tester, find.text(en.workbenchStop));
    expect(player.plays, hasLength(1));

    await tester.tap(find.byKey(const ValueKey('workbench-decode')));
    await waitForWorkbench(tester, find.text(en.workbenchDecoderHidden));
    // Copy-it-myself is the default: the decoder text stays hidden.
    expect(find.text('SOS TEST'), findsNothing);
    expect(find.text(en.workbenchDecoderHidden), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('workbench-answer')),
      'SOS TEST',
    );
    await tester.tap(find.byKey(const ValueKey('workbench-submit')));
    await waitForWorkbenchCondition(
      tester,
      () => t.controller.progress.history.isNotEmpty,
      description: 'record the copy attempt',
    );
    expect(find.text(en.learnAccuracyPercent(100)), findsOneWidget);
    expect(find.text(en.workbenchAgainstDecoder), findsOneWidget);
    final record = t.controller.progress.history.single;
    expect(record.source, ExerciseSource.recording);
    expect(record.isKnownUnassisted, isTrue);
    expect(t.controller.progress.srs.cards, isEmpty);
    expect(t.controller.progress.charStats, isEmpty);
  });

  testWidgets('a rejected file reports why and keeps the screen usable', (
    tester,
  ) async {
    final (_, picker, _) = await pumpScreen(tester);
    picker.next = PickedRecording(
      name: 'x.wav',
      bytes: cwWav('E', sampleRate: 22050),
    );
    await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
    // Observe the transient error before the four-second SnackBar expires.
    await waitForWorkbench(tester, find.text(en.workbenchErrorRate));
    expect(find.text(en.workbenchErrorRate), findsOneWidget);
    expect(
      find.byKey(const ValueKey('workbench-import-empty')),
      findsOneWidget,
    );
  });

  testWidgets('a pending picker owns the import and library actions', (
    tester,
  ) async {
    final (_, picker, _) = await pumpScreen(tester);
    final pending = Completer<PickedRecording?>();
    picker.onPick = () => pending.future;
    final import = find.byKey(const ValueKey('workbench-import'));
    await tester.tap(import);
    await tester.pump();
    expect(tester.widget<IconButton>(import).onPressed, isNull);
    expect(tester.widget<IconButton>(_libraryButton).onPressed, isNull);
    expect(picker.calls, 1);
    pending.complete(null);
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(import).onPressed, isNotNull);
  });

  testWidgets('a picker failure reports an error and allows retry', (
    tester,
  ) async {
    final (_, picker, _) = await pumpScreen(tester);
    picker.onPick = () async => throw StateError('native picker failed');
    await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
    await waitForWorkbench(tester, find.text(en.workbenchErrorIo));
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('workbench-import-empty')),
      findsOneWidget,
    );
  });

  testWidgets('playback failure is shown and the clip can be retried', (
    tester,
  ) async {
    final (_, _, player) = await pumpScreen(tester);
    await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
    final play = find.byKey(const ValueKey('workbench-play'));
    await waitForWorkbench(tester, play);
    player.playError = StateError('output device gone');
    await tester.tap(play);
    await waitForWorkbench(tester, find.text(en.comprehensionAudioFailed));
    expect(tester.takeException(), isNull);
    player.playError = null;
    await tester.tap(play);
    await waitForWorkbench(tester, find.text(en.workbenchStop));
    expect(player.plays, hasLength(1));
  });

  testWidgets('a large pasted selection time is clamped before conversion', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
    final end = find.byKey(const ValueKey('workbench-end'));
    await waitForWorkbench(tester, end);
    final previous = tester.widget<TextField>(end).controller!.text;
    await tester.enterText(end, '9' * 320);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.widget<TextField>(end).controller!.text, previous);
  });

  Future<WorkbenchController> importForSelection(WidgetTester tester) async {
    await pumpScreen(tester);
    await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
    final view = find.byType(WorkbenchWaveform);
    await waitForWorkbench(tester, view);
    return tester.widget<WorkbenchWaveform>(view).controller;
  }

  testWidgets('dragging across the selection retains the opposite endpoint', (
    tester,
  ) async {
    final c = await importForSelection(tester);
    final total = c.info!.frameCount;
    final anchor = total ~/ 2;
    c.setSelection(total ~/ 4, anchor);
    await tester.pump();
    final bounds = tester.getRect(
      find.byKey(const ValueKey('workbench-waveform')),
    );
    Offset point(double fraction) =>
        Offset(bounds.left + bounds.width * fraction, bounds.center.dy);
    final drag = await tester.startGesture(point(.25));
    await drag.moveTo(point(.31));
    await drag.moveTo(point(.65));
    await drag.moveTo(point(.80));
    await drag.up();
    await tester.pump();

    expect(c.start, anchor);
    expect(c.end, closeTo(total * .8, 1));
  });

  testWidgets('playback notifications preserve a pending time edit', (
    tester,
  ) async {
    final c = await importForSelection(tester);
    final end = find.byKey(const ValueKey('workbench-end'));
    await tester.enterText(end, '1.23');
    c.setLoop(true);
    await tester.pump();

    expect(tester.widget<TextField>(end).controller!.text, '1.23');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(c.end, 9840);
  });

  testWidgets('leaving an unchanged time field keeps the exact frame', (
    tester,
  ) async {
    final c = await importForSelection(tester);
    final start = find.byKey(const ValueKey('workbench-start'));
    c.setSelection(1001, c.end);
    await tester.pump();
    await tester.tap(start);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('workbench-waveform')));
    await tester.pump();

    expect(c.start, 1001);
  });

  testWidgets('invalid time input restores the previous value', (tester) async {
    final c = await importForSelection(tester);
    final start = find.byKey(const ValueKey('workbench-start'));
    c.setSelection(1001, c.end);
    await tester.pump();
    final previous = tester.widget<TextField>(start).controller!.text;
    await tester.enterText(start, '1,,2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(tester.widget<TextField>(start).controller!.text, previous);
    expect(c.start, 1001);
  });

  testWidgets('replacing the recording discards its pending time edit', (
    tester,
  ) async {
    final (_, picker, _) = await pumpScreen(tester);
    await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
    final end = find.byKey(const ValueKey('workbench-end'));
    await waitForWorkbench(tester, end);
    final pending = Completer<PickedRecording?>();
    picker.onPick = () => pending.future;
    await tester.tap(find.byKey(const ValueKey('workbench-import')));
    await tester.enterText(end, '1.23');
    pending.complete(PickedRecording(name: 'next.wav', bytes: cwWav('E')));
    await waitForWorkbench(tester, find.text('next.wav'));

    final c = tester
        .widget<WorkbenchWaveform>(find.byType(WorkbenchWaveform))
        .controller;
    final seconds = (c.positionOf(c.end).inMilliseconds / 1000).toStringAsFixed(
      2,
    );
    expect(tester.widget<TextField>(end).controller!.text, seconds);
  });

  testWidgets('a saved selection with missing media offers relink', (
    tester,
  ) async {
    final (t, _, _) = await pumpScreen(tester);
    // In-memory training docs: no real I/O, so no runAsync.
    var seeded = false;
    unawaited(
      t.controller
          .upsertAudioMaterial(
            AudioMaterial(
              id: 'rec_1',
              title: 'Old net',
              file: 'media/recordings/rec_1.wav',
              originalName: 'net.wav',
              start: Duration.zero,
              end: const Duration(seconds: 2),
              sampleRate: 8000,
              channels: 1,
              createdAt: DateTime.utc(2026, 10, 3),
            ),
          )
          .then((_) => seeded = true),
    );
    await waitForWorkbenchCondition(
      tester,
      () => seeded,
      description: 'save the library fixture',
    );
    await tester.tap(find.byTooltip(en.workbenchLibrary));
    await waitForWorkbench(tester, find.text('Old net'));
    expect(find.text('Old net'), findsOneWidget);
    expect(find.text(en.workbenchMissing), findsOneWidget);
    await tester.tap(find.byTooltip(en.workbenchRelink));
    await waitForWorkbench(
      tester,
      find.text(en.workbenchMissing),
      absent: true,
    );
    expect(find.text(en.workbenchMissing), findsNothing);
    expect(
      await tester.runAsync(
        () => RecordingLibrary(dataDir).exists('media/recordings/rec_1.wav'),
      ),
      isTrue,
    );
  });

  testWidgets('a failed first library load can be retried in the sheet', (
    tester,
  ) async {
    final controller = WorkbenchController(
      library: RecordingLibrary(dataDir),
      player: FakeClipPlayer(),
    );
    addTearDown(controller.dispose);
    final training = TrainingController(
      progressStore: InMemoryTrainerStore(),
      settingsStore: InMemoryTrainingSettingsStore(),
      docs: _UnreadableOnce(),
    );
    addTearDown(training.dispose);
    var failures = 0;
    const openKey = Key('open-library-fixture');
    await tester.pumpWidget(
      l10nApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              key: openKey,
              onPressed: () => showWorkbenchLibrary(
                context,
                controller: controller,
                training: training,
                picker: null,
                onFailure: (_) => failures++,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(openKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(failures, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text(en.actionRetry));
    await tester.pumpAndSettle();
    expect(find.text(en.workbenchLibraryEmpty), findsOneWidget);
  });

  testWidgets('save a selection, then restore it from the list', (
    tester,
  ) async {
    final (t, _, _) = await pumpScreen(tester);
    await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
    await waitForWorkbench(
      tester,
      find.byKey(const ValueKey('workbench-decode')),
    );
    await tester.enterText(find.byKey(const ValueKey('workbench-end')), '1.5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await waitForWorkbench(
      tester,
      find.byKey(const ValueKey('workbench-save')),
      enabled: true,
    );
    await tester.tap(find.byKey(const ValueKey('workbench-save')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('workbench-save-title')),
      'First call',
    );
    await tester.tap(find.byKey(const ValueKey('workbench-save-confirm')));
    await waitForWorkbench(tester, find.text(en.workbenchSaved));
    final saved = await tester.runAsync(t.controller.loadAudioMaterials);
    expect(saved!.single.title, 'First call');
    expect(saved.single.end.inMilliseconds, closeTo(1500, 1));
    expect(saved.single.file, startsWith('media/recordings/rec_'));

    await tester.tap(find.byTooltip(en.workbenchLibrary));
    await waitForWorkbench(tester, find.text('First call'));
    await tester.tap(find.text('First call'));
    await waitForWorkbench(tester, find.byType(BottomSheet), absent: true);
    expect(find.text('First call'), findsOneWidget);
  });

  testWidgets('fits a 320 px phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpScreen(tester, size: const Size(320, 2600));
    await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
    await waitForWorkbench(
      tester,
      find.byKey(const ValueKey('workbench-decode')),
    );
    await tester.tap(find.byKey(const ValueKey('workbench-decode')));
    await waitForWorkbench(tester, find.text(en.workbenchDecoderHidden));
    expect(tester.takeException(), isNull);
  });
}

final _libraryButton = find.widgetWithIcon(
  IconButton,
  Icons.library_music_outlined,
);

final class _UnreadableOnce implements TrainingDocStore {
  bool _fail = true;

  @override
  Future<Map<String, Object?>?> read(String name) async {
    if (_fail) {
      _fail = false;
      throw const FileSystemException('recording metadata unavailable');
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
