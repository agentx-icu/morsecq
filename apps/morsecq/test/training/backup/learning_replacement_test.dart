import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/training/backup/learning_backup_format.dart';
import 'package:morsecq/training/backup/learning_replacement.dart';
import 'package:morsecq/training/backup/learning_root_lock.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:path/path.dart' as p;

/// Fails the [failAt]-th rename and/or every delete, then behaves normally.
final class _FaultyFs extends LearningFs {
  _FaultyFs({this.failRenames = const {}, this.failDeletes = false});
  final Set<int> failRenames;
  final bool failDeletes;
  int renames = 0;

  @override
  Future<Directory> rename(Directory from, String to) {
    renames++;
    if (failRenames.contains(renames)) {
      throw FileSystemException('injected rename $renames', from.path);
    }
    return super.rename(from, to);
  }

  @override
  Future<void> delete(Directory dir) {
    if (failDeletes) throw FileSystemException('injected delete', dir.path);
    return super.delete(dir);
  }
}

void main() {
  late String root;
  setUp(() async {
    root = (await Directory.systemTemp.createTemp('morsecq_replace_')).path;
  });
  tearDown(() => Directory(root).delete(recursive: true));

  final backup = LearningBackup(
    createdAt: DateTime.utc(2026, 10, 16),
    documents: {
      'docs/materials.json': {
        'v': 1,
        'materials': <Object?>['restored'],
      },
    },
  );
  File doc(String dir) => File(p.join(root, dir, 'docs', 'materials.json'));
  Future<void> seedActive() async {
    await doc('training').create(recursive: true);
    await doc('training').writeAsString('{"v":1,"materials":["old"]}');
  }

  Future<String?> active() async =>
      await doc('training').exists() ? doc('training').readAsString() : null;
  Set<String> entries() =>
      Directory(root).listSync().map((e) => p.basename(e.path)).toSet();

  test('a commit swaps training/ and leaves no leftovers', () async {
    await seedActive();
    final r = LearningReplacement(root);
    expect(await r.commit(await r.stage(backup)), isTrue);
    expect(await active(), contains('restored'));
    expect(entries(), {'training'});
  });

  test('restoring into a profile that never learned', () async {
    final r = LearningReplacement(root);
    expect(await r.commit(await r.stage(backup)), isTrue);
    expect(await active(), contains('restored'));
  });

  test('moving training/ aside fails: nothing changes', () async {
    await seedActive();
    final r = LearningReplacement(root, fs: _FaultyFs(failRenames: {1}));
    final staging = await r.stage(backup);
    await expectLater(
      r.commit(staging),
      throwsA(
        isA<LearningReplacementException>().having(
          (e) => e.failure,
          'failure',
          LearningReplacementFailure.rolledBack,
        ),
      ),
    );
    expect(await active(), contains('old'));
    expect(entries(), {'training'});
  });

  test('the commit rename fails: the previous directory moves back', () async {
    await seedActive();
    final r = LearningReplacement(root, fs: _FaultyFs(failRenames: {2}));
    await expectLater(
      r.commit(await r.stage(backup)),
      throwsA(
        isA<LearningReplacementException>().having(
          (e) => e.failure,
          'failure',
          LearningReplacementFailure.rolledBack,
        ),
      ),
    );
    expect(await active(), contains('old'));
    expect(entries(), {'training'});
  });

  test('rollback also fails: stranded, and recovery restores it', () async {
    await seedActive();
    final r = LearningReplacement(root, fs: _FaultyFs(failRenames: {2, 3}));
    await expectLater(
      r.commit(await r.stage(backup)),
      throwsA(
        isA<LearningReplacementException>().having(
          (e) => e.failure,
          'failure',
          LearningReplacementFailure.stranded,
        ),
      ),
    );
    expect(await active(), isNull);
    expect(await recoverLearningRoot(root), isTrue);
    expect(await active(), contains('old'));
    expect(entries(), {'training'});
  });

  test('only the cleanup fails: restored, recovery finishes it', () async {
    await seedActive();
    final r = LearningReplacement(root, fs: _FaultyFs(failDeletes: true));
    expect(await r.commit(await r.stage(backup)), isFalse);
    expect(await active(), contains('restored'));
    expect(
      entries().where((e) => e.startsWith('training.previous-')),
      hasLength(1),
    );
    expect(await recoverLearningRoot(root), isTrue);
    expect(entries(), {'training'});
    expect(await active(), contains('restored'));
  });

  test('a crash between the renames recovers the previous profile', () async {
    await seedActive();
    final r = LearningReplacement(root);
    await r.stage(backup);
    // Simulate the process dying right after training/ was moved aside.
    await Directory(
      p.join(root, 'training'),
    ).rename(p.join(root, 'training.previous-1'));
    expect(await recoverLearningRoot(root), isTrue);
    expect(await active(), contains('old'));
    expect(entries(), {'training'});
  });

  test('an uncommitted staging directory is discarded', () async {
    await LearningReplacement(root).stage(backup);
    expect(await recoverLearningRoot(root), isTrue);
    expect(entries(), isEmpty);
    expect(await recoverLearningRoot(root), isFalse);
  });

  test('ambiguous leftovers are kept and reported', () async {
    for (final name in ['training.previous-1', 'training.previous-2']) {
      await doc(name).create(recursive: true);
    }
    await expectLater(
      recoverLearningRoot(root),
      throwsA(isA<LearningRecoveryException>()),
    );
    expect(entries(), {'training.previous-1', 'training.previous-2'});
    await expectLater(
      LearningReplacement(root).stage(backup),
      throwsA(isA<LearningRecoveryException>()),
    );
    expect(entries(), {'training.previous-1', 'training.previous-2'});
  });

  test(
    'clearing removes leftovers so recovery cannot resurrect them',
    () async {
      await seedActive();
      await doc('training.previous-1').create(recursive: true);
      await LocalLearningStore(root: () async => root).clear();
      expect(await recoverLearningRoot(root), isFalse);
      expect(await active(), isNull);
      expect(entries(), isEmpty);
    },
  );

  group('lock', () {
    test('a sole holder can upgrade and return to shared', () async {
      final lock = await LearningRootLock.acquire(root);
      expect(await lock.tryExclusive(), isTrue);
      expect(lock.isExclusive, isTrue);
      await lock.release();
      expect(lock.isExclusive, isFalse);
      await lock.close();
      await lock.close();
      expect(lock.tryExclusive, throwsStateError);
      // The lock file lives beside training/, never inside it.
      expect(entries(), {LearningRootLock.fileName, LearningRootLock.gateName});
    });

    test(
      'another process holding it blocks the exclusive upgrade',
      () async {
        final lock = await LearningRootLock.acquire(root);
        addTearDown(lock.close);
        final holder = await Process.start('python3', [
          '-c',
          'import fcntl,sys\n'
              'f=open(sys.argv[1],"a+")\n'
              'fcntl.lockf(f,fcntl.LOCK_SH)\n'
              'print("held",flush=True)\n'
              'sys.stdin.read()\n',
          p.join(root, LearningRootLock.fileName),
        ]);
        addTearDown(holder.kill);
        await holder.stdout.first;
        expect(await lock.tryExclusive(), isFalse);
        expect(lock.isExclusive, isFalse);
        await holder.stdin.close();
        await holder.exitCode;
        expect(await lock.tryExclusive(), isTrue);
      },
      skip: Platform.isWindows ? 'POSIX fcntl helper' : false,
    );

    test(
      'another instance upgrading keeps this one shared and unbroken',
      () async {
        final lock = await LearningRootLock.acquire(root);
        addTearDown(lock.close);
        final holder = await Process.start('python3', [
          '-c',
          'import fcntl,sys\n'
              'f=open(sys.argv[1],"a+")\n'
              'fcntl.lockf(f,fcntl.LOCK_EX)\n'
              'print("held",flush=True)\n'
              'sys.stdin.read()\n',
          p.join(root, LearningRootLock.gateName),
        ]);
        addTearDown(holder.kill);
        await holder.stdout.first;
        // The gate is taken: no conversion starts, the shared lock stays.
        expect(await lock.tryExclusive(), isFalse);
        expect(lock.isExclusive, isFalse);
        await holder.stdin.close();
        await holder.exitCode;
        expect(await lock.tryExclusive(), isTrue);
        await lock.release();
      },
      skip: Platform.isWindows ? 'POSIX fcntl helper' : false,
    );

    test('a restore keeps the recordings already on the device', () async {
      await seedActive();
      final media = File(p.join(root, 'media', 'recordings', 'rec_new.wav'));
      await media.create(recursive: true);
      final r = LearningReplacement(root);
      await r.commit(await r.stage(backup));
      expect(
        await File(
          p.join(root, 'media', 'recordings_kept.json'),
        ).readAsString(),
        contains('media/recordings/rec_new.wav'),
      );
    });
  });
}
