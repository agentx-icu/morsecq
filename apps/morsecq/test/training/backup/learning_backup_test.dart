import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/training/audio_material_store.dart';
import 'package:morsecq/training/backup/learning_backup_format.dart';
import 'package:morsecq/training/backup/learning_document_rules.dart';
import 'package:morsecq/training/backup/learning_replacement.dart';
import 'package:morsecq/training/backup/learning_snapshot.dart';
import 'package:morsecq/training/kept_recordings.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/material_store.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/send_detail_store.dart';
import 'package:morsecq/training/telegraph_sessions.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/ui/listen/workbench/recording_files.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:path/path.dart' as p;

import 'learning_profile_fixture.dart';

void main() {
  late Directory temp;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('morsecq_backup_');
  });
  tearDown(() => temp.delete(recursive: true));

  Future<String> profile(String name) async =>
      (await Directory(p.join(temp.path, name)).create()).path;

  Future<LearningBackup> backupOf(String dir) async {
    final snapshot = await captureLearning(dir);
    expect(snapshot.skipped, isEmpty);
    final bytes = LearningBackup(
      createdAt: DateTime.utc(2026, 10, 16, 14),
      documents: snapshot.documents,
      appVersion: '1.0.1+2',
    ).encode();
    return LearningBackup.decode(bytes);
  }

  Future<void> restore(String dir, LearningBackup backup) async {
    final replacement = LearningReplacement(dir);
    expect(await replacement.commit(await replacement.stage(backup)), isTrue);
  }

  test(
    'a backup restores every learning record into another profile',
    () async {
      final source = await profile('a');
      final c = await LocalLearningStore(
        root: () async => source,
      ).openController();
      final detail = await populateLearningProfile(c, source);
      c.dispose();
      final backup = await backupOf(source);
      expect(
        backup.documents.keys,
        contains('docs/${QsoPractice.finishedPrefix}shortexchange_704.json'),
      );
      // Opening a profile credits its parked QSO: the restored profile must
      // reach the same state as reopening the original.
      final reopened = await LocalLearningStore(
        root: () async => source,
      ).openController();
      final expectedProgress = reopened.progress.toJson();
      final expectedSettings = reopened.settings;
      final expectedNames = await reopened.docNames();
      reopened.dispose();
      final summary = backup.summary();
      expect(summary.lesson, 12);
      expect(summary.sessions, 2);
      expect(summary.materials, 1);
      expect(summary.audioMaterials, 1);
      expect(backup.appVersion, '1.0.1+2');
      expect(backup.documents.keys, everyElement(isNot(contains('.bak'))));

      // The target has its own learning and a recording backups never carry.
      final target = await profile('b');
      final other = await LocalLearningStore(
        root: () async => target,
      ).openController();
      await other.setLesson(3);
      await other.saveQsoDraft(
        QsoSession.start(
          scenario: QsoScenario.shortExchange,
          seed: 9,
          local: const QsoStation(callsign: 'W9X', name: 'BO', qth: 'IL'),
          characterWpm: 20,
          effectiveWpm: 13,
        ),
      );
      await other.flush();
      other.dispose();
      final localRecording = File(p.join(target, 'media/recordings/local.wav'));
      await localRecording.create(recursive: true);

      await restore(target, backup);

      final r = await LocalLearningStore(
        root: () async => target,
      ).openController();
      addTearDown(r.dispose);
      expect(r.loadError, isNull);
      expect(r.progress.toJson(), expectedProgress);
      expect(r.settings, expectedSettings);
      expect(await r.docNames(), expectedNames);
      // The recording already on this device is kept from the sweep.
      expect(await KeptRecordings(target).load(), {
        'media/recordings/local.wav',
      });
      expect((await r.loadMaterials()).single.id, 'backup_words');
      expect((await r.loadAudioMaterials()).single.note, 'CQ');
      expect((await r.loadQsoStation())!.callsign, 'K1ABC');
      expect((await r.loadQsoDraft())!.pendingId, 'draft-reply');
      expect(await r.isSendDetailFavorite(detail), isTrue);
      expect((await r.loadSendDetail(detail))!.ref, detail);
      expect(
        (await r.readTelegraphRecall()).answered(
          TelegraphCodebook.values.first,
        ),
        1,
      );
      // Restore replaces training/ only: recordings stay where they were.
      expect(await localRecording.exists(), isTrue);
      expect(
        await File(p.join(target, 'media/recordings/kept.wav')).exists(),
        isFalse,
      );
      expect(
        Directory(target).listSync().map((e) => p.basename(e.path)).toSet(),
        {'training', 'media'},
      );
    },
  );

  group('capture', () {
    late String dir;
    late File materials;
    setUp(() async {
      dir = await profile('p');
      materials = File(p.join(dir, 'training/docs/materials.json'));
      await materials.parent.create(recursive: true);
    });

    test('a semantically damaged document falls back to its backup', () async {
      await materials.writeAsString(jsonEncode({'materials': 'broken'}));
      await File(
        '${materials.path}.bak',
      ).writeAsString(jsonEncode({'v': 1, 'materials': <Object?>[]}));
      final snapshot = await captureLearning(dir);
      expect(snapshot.skipped, isEmpty);
      expect(snapshot.documents['docs/materials.json'], {
        'v': 1,
        'materials': <Object?>[],
      });
    });

    test('unusable and unknown documents are reported, not dropped', () async {
      await materials.writeAsString('{"materials": 3}');
      await File(p.join(dir, 'training/docs/mystery.json')).writeAsString('{}');
      await File(
        p.join(dir, 'training/docs/send_index.json.tmp'),
      ).writeAsString('{}');
      final snapshot = await captureLearning(dir);
      expect(snapshot.documents, isEmpty);
      expect(snapshot.skipped, ['docs/materials.json', 'docs/mystery.json']);
    });

    test('damage already quarantined is still reported', () async {
      final progress = File(p.join(dir, 'training/progress.json'));
      await progress.writeAsString('{"currentLesson": 0}');
      // The first read sets the primary aside; later captures must still
      // report the document instead of exporting a fresh profile quietly.
      for (var i = 0; i < 2; i++) {
        final snapshot = await captureLearning(dir);
        expect(snapshot.skipped, [LearningDocumentRules.progress]);
      }
      expect(await File('${progress.path}.corrupt').exists(), isTrue);
      await File('${materials.path}.corrupt').writeAsString('{');
      expect((await captureLearning(dir)).skipped, [
        'docs/materials.json',
        LearningDocumentRules.progress,
      ]);
    });

    test('a profile that never learned exports nothing', () async {
      final snapshot = await captureLearning(await profile('empty'));
      expect(snapshot.documents, isEmpty);
      expect(snapshot.skipped, isEmpty);
    });
  });

  group('decode refuses', () {
    Map<String, Object?> body(Map<String, Object?> documents) =>
        <String, Object?>{
          'format': LearningBackup.format,
          'version': LearningBackup.version,
          'createdAt': '2026-10-16T14:00:00.000Z',
          'appVersion': '',
          'documents': documents,
        };
    List<int> sealed(Map<String, Object?> b) =>
        utf8.encode(jsonEncode({...b, 'sha256': LearningBackup.checksum(b)}));
    Matcher problem(LearningBackupProblem reason) => throwsA(
      isA<LearningBackupException>().having((e) => e.reason, 'reason', reason),
    );
    final session = QsoSession.start(
      scenario: QsoScenario.shortExchange,
      seed: 1,
      local: const QsoStation(callsign: 'K1ABC', name: 'AL', qth: 'CA'),
      characterWpm: 20,
      effectiveWpm: 13,
    ).toJson();
    final valid = <String, Object?>{
      'docs/${MaterialStore.doc}.json': {'v': 1, 'materials': <Object?>[]},
    };

    test('a valid sealed envelope is accepted', () {
      final backup = LearningBackup.decode(sealed(body(valid)));
      expect(backup.documents.keys, ['docs/materials.json']);
      expect(backup.summary().lesson, 1);
    });

    test('files that are not backups', () {
      expect(
        () => LearningBackup.decode(utf8.encode('not json')),
        problem(LearningBackupProblem.notBackup),
      );
      expect(
        () => LearningBackup.decode(sealed({...body(valid), 'format': 'x'})),
        problem(LearningBackupProblem.notBackup),
      );
      expect(
        () => LearningBackup.decode(utf8.encode('[1]')),
        problem(LearningBackupProblem.notBackup),
      );
    });

    test('a backup from a newer version', () {
      expect(
        () => LearningBackup.decode(sealed({...body(valid), 'version': 2})),
        problem(LearningBackupProblem.newerVersion),
      );
    });

    test('an edited or truncated file', () {
      final text = utf8.decode(sealed(body(valid)));
      expect(
        () => LearningBackup.decode(
          utf8.encode(text.replaceFirst('"v":1', '"v":2')),
        ),
        problem(LearningBackupProblem.damaged),
      );
      expect(
        () => LearningBackup.decode(
          utf8.encode(text.substring(0, text.length - 5)),
        ),
        problem(LearningBackupProblem.notBackup),
      );
    });

    test('paths outside the known documents, even when sealed', () {
      for (final path in <String>[
        '../progress.json',
        'docs/../../x.json',
        'docs/evil.json',
        'media/recordings/a.wav',
        'progress.json.bak',
        'media/recordings_kept.json',
      ]) {
        expect(
          () =>
              LearningBackup.decode(sealed(body({path: <String, Object?>{}}))),
          problem(LearningBackupProblem.damaged),
          reason: path,
        );
      }
    });

    test('documents the app could not load, even when sealed', () {
      for (final (key, value) in <(String, Object?)>[
        (LearningDocumentRules.progress, {'currentLesson': 0}),
        (
          LearningDocumentRules.settings,
          {
            'trainer': {'sessionLengthChars': -1},
          },
        ),
        ('docs/${QsoPractice.draftDoc}.json', {'session': 'x'}),
        ('docs/${SendDetailStore.indexDoc}.json', {'entries': 1}),
        ('docs/${TelegraphSessions.recallDoc}.json', {'v': 99}),
        ('docs/${AudioMaterialStore.doc}.json', <String, Object?>{}),
        ('docs/send_abc.json', <String, Object?>{}),
        ('docs/${MaterialStore.doc}.json', 'not a map'),
        // Fields the runtime loaders need beyond a valid session.
        (
          'docs/${QsoPractice.draftDoc}.json',
          {'session': session, 'pendingText': 123},
        ),
        (
          'docs/${QsoPractice.finishedPrefix}shortexchange_1.json',
          {'session': session, 'activeMs': 'broken'},
        ),
      ]) {
        expect(
          () => LearningBackup.decode(sealed(body({key: value}))),
          problem(LearningBackupProblem.damaged),
          reason: key,
        );
      }
    });

    test('oversized input before decoding it', () {
      expect(
        () => LearningBackup.decode(Uint8List(LearningBackup.maxBytes + 1)),
        problem(LearningBackupProblem.tooLarge),
      );
    });

    test('encoding past the size decode accepts', () {
      final backup = LearningBackup(
        createdAt: DateTime.utc(2026),
        documents: {
          'docs/${MaterialStore.doc}.json': {
            'v': 1,
            'materials': ['x' * 1000],
          },
        },
      );
      final size = backup.encode().length;
      expect(
        LearningBackup.decode(
          backup.encode(limit: size),
          limit: size,
        ).documents,
        hasLength(1),
      );
      expect(
        () => backup.encode(limit: size - 1),
        problem(LearningBackupProblem.tooLarge),
      );
      expect(
        () => LearningBackup.decode(backup.encode(), limit: size - 1),
        problem(LearningBackupProblem.tooLarge),
      );
    });

    test('encoding a backup this version could not restore', () {
      expect(
        () => LearningBackup(
          createdAt: DateTime.utc(2026),
          documents: {'docs/evil.json': <String, Object?>{}},
        ).encode(),
        problem(LearningBackupProblem.damaged),
      );
    });
  });

  test('the suggested file name carries the extension', () {
    final name = LearningBackup(
      createdAt: DateTime(2026, 10, 16, 9, 5),
      documents: const {},
    ).suggestedFileName();
    expect(name, 'morsecq-20261016-0905.morsecq-backup.json');
  });

  test('progress survives a canonical round trip of doubles and ints', () {
    final progress = TrainerProgress().withLesson(4).toJson();
    final backup = LearningBackup(
      createdAt: DateTime.utc(2026),
      documents: {LearningDocumentRules.progress: progress},
    );
    final again = LearningBackup.decode(backup.encode());
    expect(again.documents[LearningDocumentRules.progress], progress);
    expect(again.summary().lesson, 4);
  });

  test('releasing and adding kept recordings', () async {
    final dir = await profile('k');
    final kept = KeptRecordings(dir);
    expect(await kept.load(), isEmpty);
    await kept.addAll({'media/recordings/a.wav', 'media/recordings/b.wav'});
    await kept.release('media/recordings/a.wav');
    await kept.release('media/recordings/z.wav');
    expect(await kept.load(), {'media/recordings/b.wav'});
    // Overlapping deletions from separate instances lose no update, even
    // while a save is rotating the file.
    final files = {for (var i = 0; i < 8; i++) 'media/recordings/r$i.wav'};
    await kept.save(files);
    await Future.wait([for (final f in files) KeptRecordings(dir).release(f)]);
    expect(await kept.load(), isEmpty);
  });

  group('workbench sweep', () {
    late String dir;
    late RecordingLibrary library;
    late File keptFile;
    setUp(() async {
      dir = await profile('sweep');
      library = RecordingLibrary(dir);
      for (final name in ['kept.wav', 'stray.wav']) {
        await library.fileFor('media/recordings/$name').create(recursive: true);
      }
      keptFile = File(p.join(dir, 'media', 'recordings_kept.json'));
    });
    Future<TrainingController> open() async {
      final c = await LocalLearningStore(
        root: () async => dir,
      ).openController();
      addTearDown(c.dispose);
      return c;
    }

    const all = {'media/recordings/kept.wav', 'media/recordings/stray.wav'};

    test('keeps listed recordings and collects the rest', () async {
      await keptFile.writeAsString('{"files": ["media/recordings/kept.wav"]}');
      await sweepUnreferencedRecordings(await open(), library);
      expect(await library.recordings(), {'media/recordings/kept.wav'});
    });

    for (final (label, content) in [
      ('damaged', '{"files": ['),
      ('invalid', '{"files": 3}'),
    ]) {
      test('a $label kept list protects every recording', () async {
        await keptFile.writeAsString(content);
        final c = await open();
        await sweepUnreferencedRecordings(c, library);
        expect(await library.recordings(), all);
        // The list is rebuilt, so later sweeps stay protective too.
        expect(await KeptRecordings(dir).load(), all);
        await sweepUnreferencedRecordings(c, library);
        expect(await library.recordings(), all);
      });
    }

    test('a list only left as a quarantined copy still protects', () async {
      await keptFile.parent.create(recursive: true);
      await File('${keptFile.path}.corrupt').writeAsString('{"files": [');
      expect(await KeptRecordings(dir).load(), isNull);
      await sweepUnreferencedRecordings(await open(), library);
      expect(await library.recordings(), all);
    });

    test('an older .bak never narrows the protection', () async {
      // Two restores: the backup copy lists less than the damaged primary.
      final kept = KeptRecordings(dir);
      await kept.save({'media/recordings/kept.wav'});
      await kept.save(all);
      await keptFile.writeAsString('{"files": [');
      expect(await kept.load(), isNull);
      await keptFile.delete();
      expect(await kept.load(), isNull, reason: 'only the older .bak left');
      await sweepUnreferencedRecordings(await open(), library);
      expect(await library.recordings(), all);
      expect(await kept.load(), all);
    });

    test(
      'a failed rebuild deletes nothing, now or on the next sweep',
      () async {
        await keptFile.writeAsString('{"files": [');
        final c = await open();
        // A directory where the temp file goes makes every save fail.
        final blocker = Directory('${keptFile.path}.tmp');
        await blocker.create();
        for (var i = 0; i < 2; i++) {
          await expectLater(
            sweepUnreferencedRecordings(c, library),
            throwsA(isA<FileSystemException>()),
          );
          expect(await library.recordings(), all);
        }
        await blocker.delete();
        await sweepUnreferencedRecordings(c, library);
        expect(await library.recordings(), all);
      },
    );
  });

  test('the checksum is canonical and fixed across platforms', () {
    final a = <String, Object?>{
      'b': [1, -0.0, 9007199254740993, 1.5e-7, 'é漢字🙂'],
      'a': {'z': true, 'y': null},
    };
    final b = <String, Object?>{
      'a': {'y': null, 'z': true},
      'b': [1, -0.0, 9007199254740993, 1.5e-7, 'é漢字🙂'],
    };
    expect(LearningBackup.checksum(a), LearningBackup.checksum(b));
    expect(LearningBackup.checksum(a), kChecksumVector);
  });
}

/// The canonical text `{"a":{"y":null,"z":true},"b":[1,-0.0,9007199254740993,
/// 1.5e-7,"é漢字🙂"]}` hashed outside Dart. Recomputing it would hide a change
/// in the canonical encoding that makes existing backups unreadable.
const String kChecksumVector =
    'fa2810107931ba7be27731ea966c2effd42839d20706dee3fac33f5f4e005d78';
