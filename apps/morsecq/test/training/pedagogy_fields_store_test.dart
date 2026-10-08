// The two progress fields added by the 2026-10-08 pedagogy work
// (`courseCompleted`, `firstLessonDoneAt`): a malformed value is a corrupt
// file that falls back to the preceding valid save.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/file_trainer_store.dart';
import 'package:path/path.dart' as p;

Future<Directory> _tmp() async {
  final d = await Directory.systemTemp.createTemp('morsecq_pedagogy_');
  addTearDown(() => d.delete(recursive: true));
  return d;
}

void main() {
  final done = TrainerProgress(
    currentLesson: 42,
    courseCompleted: true,
    firstLessonDoneAt: DateTime(2026, 10, 8, 9),
  );

  test('the fields survive a save and a load', () async {
    final dir = await _tmp();
    final store = FileTrainerStore.inDataDirectory(dir.path);
    await store.save(done);
    final loaded = await store.load();
    expect(loaded!.courseCompleted, isTrue);
    expect(loaded.firstLessonDoneAt, DateTime(2026, 10, 8, 9));
  });

  for (final (field, bad) in <(String, Object)>[
    ('firstLessonDoneAt', 123),
    ('firstLessonDoneAt', 'yesterday'),
    ('courseCompleted', 'yes'),
  ]) {
    test('a malformed $field ($bad) recovers the backup', () async {
      final dir = await _tmp();
      final store = FileTrainerStore.inDataDirectory(dir.path);
      await store.save(done);
      await store.save(done.withLesson(41));
      final file = File(p.join(dir.path, 'training', 'progress.json'));
      final json =
          jsonDecode(await file.readAsString()) as Map<String, Object?>;
      await file.writeAsString(
        jsonEncode(<String, Object?>{...json, field: bad}),
      );
      final loaded = await store.load();
      expect(loaded, isNotNull);
      expect(loaded!.currentLesson, 42, reason: 'served from the .bak');
      expect(loaded.courseCompleted, isTrue);
      expect(loaded.firstLessonDone, isTrue);
    });
  }
}
