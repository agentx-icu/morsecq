import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_doc_store.dart';
import 'package:morsecq/training/training_plan.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/training/training_settings_store.dart';

void main() {
  test('deleting the failed document resolves its pending failure', () async {
    final docs = _RetryDocs();
    final controller = TrainingController(
      progressStore: InMemoryTrainerStore(),
      settingsStore: InMemoryTrainingSettingsStore(),
      docs: docs,
    );
    addTearDown(controller.dispose);
    await expectLater(
      controller.writeDoc('materials', {'materials': []}),
      throwsA(isA<FileSystemException>()),
    );
    await controller.deleteDoc('materials');
    await controller.flush();
    expect(await docs.read('materials'), isNull);
  });

  test(
    'saving another document cannot hide an unresolved document failure',
    () async {
      final docs = _RetryDocs();
      final controller = TrainingController(
        progressStore: InMemoryTrainerStore(),
        settingsStore: InMemoryTrainingSettingsStore(),
        docs: docs,
      );
      addTearDown(controller.dispose);
      await expectLater(
        controller.writeDoc('materials', {'materials': []}),
        throwsA(isA<FileSystemException>()),
      );
      await controller.writeDoc('qso_draft', {'pendingText': 'CQ'});
      await expectLater(
        controller.flush(),
        throwsA(isA<FileSystemException>()),
      );
      await controller.writeDoc('materials', {'materials': []});
      await controller.flush();
      expect(await docs.read('materials'), {'materials': []});
    },
  );

  test(
    'a settings read failure preserves readable learning progress',
    () async {
      final progress = _FailingProgressStore();
      await progress.save(
        TrainerProgress(currentLesson: 9, dailyGoalChars: 77),
      );
      final controller = TrainingController(
        progressStore: progress,
        settingsStore: _UnreadableSettingsStore(),
      );
      addTearDown(controller.dispose);

      await controller.load();
      expect(controller.loadError, isA<FileSystemException>());
      expect(controller.currentLesson, 9);
      await controller.setDailyGoal(88);
      expect(progress.saved!.currentLesson, 9);
    },
  );

  test(
    'a progress read failure preserves readable training settings',
    () async {
      final progress = _FailingProgressStore()..failLoad = true;
      final settings = InMemoryTrainingSettingsStore();
      const saved = TrainingSettings(flashEnabled: true);
      await settings.save(saved);
      final controller = TrainingController(
        progressStore: progress,
        settingsStore: settings,
      );
      addTearDown(controller.dispose);

      await controller.load();
      expect(controller.loadError, isA<FileSystemException>());
      expect(controller.settings, saved);
    },
  );

  test(
    'retrying the selected goal saves it and refreshes the pending plan',
    () async {
      final progress = _FailingProgressStore();
      final controller = TrainingController(
        progressStore: progress,
        settingsStore: InMemoryTrainingSettingsStore(),
        now: () => DateTime(2026, 10, 9),
      );
      addTearDown(controller.dispose);
      await controller.load();
      await controller.commitProgress((p) => p.copyWith(courseCompleted: true));
      await controller.ensureTodayPlan();
      progress.failNext = true;

      await expectLater(
        controller.setLearningGoal(LearningGoal.contest),
        throwsA(isA<FileSystemException>()),
      );
      await controller.setLearningGoal(LearningGoal.contest);
      await controller.flush();

      expect(progress.saved!.learningGoal, LearningGoal.contest);
      expect(
        progress.saved!.dailyPlan!.steps
            .firstWhere((s) => s.kind == PlanStepKind.qso)
            .pool,
        ['contestExchange'],
      );
    },
  );

  test('a parked QSO survives an interrupted document replacement', () async {
    final directory = await Directory.systemTemp.createTemp('morsecq_audit_');
    addTearDown(() => directory.delete(recursive: true));
    final docs = FileTrainingDocStore.inDataDirectory(directory.path);
    final controller = TrainingController(
      progressStore: InMemoryTrainerStore(),
      settingsStore: InMemoryTrainingSettingsStore(),
      docs: docs,
      now: () => DateTime(2026, 10, 10),
    );
    addTearDown(controller.dispose);
    await controller.load();
    final qso = QsoSession.start(
      scenario: QsoScenario.shortExchange,
      seed: 501,
      local: const QsoStation(callsign: 'K1ABC', name: 'AL', qth: 'CA'),
      characterWpm: 20,
      effectiveWpm: 13,
    );
    qso.submit('call', '${qso.remote.callsign} DE K1ABC K');
    qso.submit('exchange', 'UR RST 599 K');
    qso.submit('closing', 'TU 73 <SK>');
    expect(qso.isDone, isTrue);
    const name = 'qso_finished_shortexchange_501';
    await controller.writeDoc(name, {
      'session': qso.toJson(),
      'activeMs': 1000,
      'completedAt': DateTime(2026, 10, 9).toIso8601String(),
    });
    // The old primary has rotated, but the new temporary file has not yet
    // been renamed. Recovery must discover the remaining valid backup.
    final primary = File('${docs.directory.path}/$name.json');
    await primary.rename('${primary.path}.bak');

    await controller.recoverFinishedQso();
    await controller.recoverFinishedQso();

    expect(controller.progress.history.length, 1);
    expect(controller.progress.history.single.at, DateTime(2026, 10, 9));
    expect(await docs.names(), isEmpty);
  });

  test('document enumeration deduplicates primary and backup names', () async {
    final directory = await Directory.systemTemp.createTemp('morsecq_docs_');
    addTearDown(() => directory.delete(recursive: true));
    final docs = FileTrainingDocStore(directory);
    await docs.write('material_library', {'version': 1});
    await docs.write('material_library', {'version': 2});
    await File('${directory.path}/qso_draft.json.tmp').writeAsString('{}');
    await File('${directory.path}/qso_draft.json.corrupt').writeAsString('{}');

    expect(await docs.names(), ['material_library']);
  });
}

final class _FailingProgressStore implements TrainerStore {
  TrainerProgress? saved;
  bool failNext = false;
  bool failLoad = false;

  @override
  Future<TrainerProgress?> load() async {
    if (failLoad) throw const FileSystemException('progress read failure');
    return saved;
  }

  @override
  Future<void> save(TrainerProgress progress) async {
    if (failNext) {
      failNext = false;
      throw const FileSystemException('temporary save failure');
    }
    saved = TrainerProgress.fromJson(progress.toJson());
  }

  @override
  Future<void> clear() async => saved = null;
}

final class _UnreadableSettingsStore implements TrainingSettingsStore {
  @override
  Future<TrainingSettings?> load() async =>
      throw const FileSystemException('settings read failure');

  @override
  Future<void> save(TrainingSettings settings) async {}

  @override
  Future<void> clear() async {}
}

final class _RetryDocs implements TrainingDocStore {
  final inner = InMemoryTrainingDocStore();
  bool failNext = true;

  @override
  Future<void> write(String name, Map<String, Object?> json) async {
    if (failNext) {
      failNext = false;
      throw const FileSystemException('document save failure');
    }
    await inner.write(name, json);
  }

  @override
  Future<Map<String, Object?>?> read(String name) => inner.read(name);

  @override
  Future<void> delete(String name) => inner.delete(name);

  @override
  Future<List<String>> names() => inner.names();
}
