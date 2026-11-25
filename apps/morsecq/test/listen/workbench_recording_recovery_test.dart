import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_doc_store.dart';
import 'package:morsecq/ui/listen/workbench/recording_files.dart';
import 'package:morsecq/ui/listen/workbench/workbench_controller.dart';
import 'package:morsecq/ui/listen/workbench/workbench_screen.dart';
import 'package:path/path.dart' as p;

import '../learn/helpers/l10n.dart';
import '../learn/helpers/test_controller.dart';
import 'workbench_support.dart';
import 'workbench_wait.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final mode in ['recovered-index', 'damaged-entry']) {
    testWidgets('opening the workbench preserves a WAV omitted by $mode', (
      tester,
    ) async {
      final root = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('morsecq_index_crossaudit_'),
      ))!;
      final profile = root.path;
      final docs = FileTrainingDocStore(
        Directory(p.join(profile, 'training', 'docs')),
      );
      final audio = RecordingLibrary(
        profile,
      ).fileFor('media/recordings/new.wav');
      final material = AudioMaterial(
        id: 'new',
        title: 'New recording',
        file: 'media/recordings/new.wav',
        originalName: 'new.wav',
        start: Duration.zero,
        end: const Duration(milliseconds: 500),
        sampleRate: 8000,
        channels: 1,
        createdAt: DateTime.utc(2026),
      );
      final controller = TrainingController(
        progressStore: InMemoryTrainerStore(),
        settingsStore: InMemoryTrainingSettingsStore(),
        docs: docs,
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        controller.dispose();
        await tester.runAsync(() => root.delete(recursive: true));
      });
      await tester.runAsync(() async {
        await controller.load();
        await audio.parent.create(recursive: true);
        await audio.writeAsBytes(cwWav('E'));
        await docs.write(AudioMaterialStore.doc, {'v': 1, 'materials': []});
        await docs.write(AudioMaterialStore.doc, {
          'v': 1,
          'materials': [material.toJson()],
        });
        if (mode == 'recovered-index') {
          // A valid older backup omits the newer, intact recording.
          await File(
            p.join(docs.directory.path, '${AudioMaterialStore.doc}.json'),
          ).writeAsString('{');
        } else {
          final malformed = material.toJson()..['createdAt'] = 'damaged date';
          await File(
            p.join(docs.directory.path, '${AudioMaterialStore.doc}.json'),
          ).writeAsString(
            jsonEncode({
              'v': 1,
              'materials': [malformed],
            }),
          );
        }
        expect(await audio.exists(), isTrue);
        expect(
          await File(p.join(profile, 'media', 'recordings_kept.json')).exists(),
          isFalse,
        );
      });
      await tester.pumpWidget(
        l10nApp(
          home: WorkbenchScreen(
            player: FakeClipPlayer(),
            profileRoot: () async => profile,
            training: () async => controller,
          ),
        ),
      );
      final library = find.widgetWithIcon(
        IconButton,
        Icons.library_music_outlined,
      );
      await waitForWorkbenchCondition(
        tester,
        () =>
            library.evaluate().isNotEmpty &&
            tester.widget<IconButton>(library).onPressed != null,
        description: 'finish production workbench initialization',
      );
      expect(
        await tester.runAsync(audio.exists),
        isTrue,
        reason:
            'A partial/recovered index must not turn recoverable audio into permanent data loss just by opening WorkbenchScreen',
      );
    });
  }
  test(
    'deleting a saved selection removes only its unshared recording',
    () async {
      final root = await Directory.systemTemp.createTemp('workbench_delete_');
      addTearDown(() => root.delete(recursive: true));
      final training = await TestTraining.create();
      addTearDown(training.controller.dispose);
      final library = RecordingLibrary(root.path);
      final player = FakeClipPlayer();
      addTearDown(player.dispose);
      final workbench = WorkbenchController(library: library, player: player);
      addTearDown(workbench.dispose);
      AudioMaterial material(String id, String file) => AudioMaterial(
        id: id,
        title: id,
        file: file,
        originalName: '$id.wav',
        start: Duration.zero,
        end: const Duration(milliseconds: 500),
        sampleRate: 8000,
        channels: 1,
        createdAt: DateTime.utc(2026),
      );
      final selected = material('selected', 'media/recordings/selected.wav');
      final shared = material('shared', selected.file);
      final other = material('other', 'media/recordings/other.wav');
      for (final row in [selected, shared, other]) {
        await training.controller.upsertAudioMaterial(row);
        final file = library.fileFor(row.file);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(cwWav('E'));
      }
      expect(
        await workbench.deleteSaved(training.controller, selected),
        isTrue,
      );
      expect(await library.exists(selected.file), isTrue);
      expect(await workbench.deleteSaved(training.controller, shared), isTrue);
      expect(await library.exists(selected.file), isFalse);
      expect(await library.exists(other.file), isTrue);
      expect(
        (await training.controller.loadAudioMaterials()).map((m) => m.id),
        ['other'],
      );
    },
  );
}
