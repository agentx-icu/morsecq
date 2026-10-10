import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../shared_sync.dart';

/// A throwaway Git repository with `packages/<name>/` files.
final class _Repo {
  _Repo(this.dir) {
    _git(['init', '-q']);
  }

  final Directory dir;

  String get path => dir.path;

  void put(String rel, String content) {
    File('$path/$rel')
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  void remove(String rel) => File('$path/$rel').deleteSync();

  void commit() {
    _git(['add', '-A']);
    _git([
      '-c',
      'user.name=t',
      '-c',
      'user.email=t@example.invalid',
      'commit',
      '-qm',
      'c',
    ]);
  }

  void _git(List<String> args) {
    final r = Process.runSync('git', ['-C', path, ...args]);
    if (r.exitCode != 0) throw StateError('git $args: ${r.stderr}');
  }

  Map<String, Object?> get manifest =>
      jsonDecode(File('$path/$manifestPath').readAsStringSync())
          as Map<String, Object?>;

  set manifest(Map<String, Object?> json) => File('$path/$manifestPath')
    ..createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
}

final class _Run {
  _Run(this.code, this.out, this.err);

  final int code;
  final String out;
  final String err;
}

_Run _sync(_Repo repo, List<String> args) {
  final out = StringBuffer();
  final err = StringBuffer();
  final code = runSharedSync(args, root: repo.path, out: out, err: err);
  return _Run(code, '$out', '$err');
}

void main() {
  late _Repo morsecq;
  late _Repo ditmesh;

  setUp(() {
    final tmp = Directory.systemTemp.createTempSync('shared_sync_test');
    addTearDown(() => tmp.deleteSync(recursive: true));
    morsecq = _Repo(Directory('${tmp.path}/morsecq')..createSync());
    ditmesh = _Repo(Directory('${tmp.path}/ditmesh')..createSync());
    for (final repo in [morsecq, ditmesh]) {
      repo
        ..put('packages/core/lib/a.dart', 'a')
        ..put('packages/core/lib/b.dart', 'b')
        ..put('packages/core/.gitignore', 'build/\n')
        ..put('packages/core/build/out.txt', 'ignored')
        ..put('packages/other/lib/x.dart', 'not shared');
    }
    ditmesh.commit();
    morsecq.manifest = {
      'packages': ['core'],
      'ditmesh': {'commit': null, 'dirty': false},
      'divergence': <Object>[],
      'files': <String, Object>{},
    };
  });

  _Run pin() => _sync(morsecq, ['--write', '--ditmesh', ditmesh.path]);

  test('pinning identical packages passes the check', () {
    expect(pin().code, 0);
    final files = morsecq.manifest['files']! as Map<String, Object?>;
    expect(files.keys, [
      'packages/core/.gitignore',
      'packages/core/lib/a.dart',
      'packages/core/lib/b.dart',
    ], reason: 'ignored and non-shared files are not pinned');
    expect(files.values, everyElement(isA<String>()));
    final pinned = morsecq.manifest['ditmesh']! as Map<String, Object?>;
    expect(pinned['commit'], matches(RegExp(r'^[0-9a-f]{40}$')));
    expect(pinned['dirty'], isFalse);
    expect(_sync(morsecq, ['--check']).code, 0);
    expect(_sync(morsecq, []).code, 0);
  });

  test('editing, adding or deleting a shared file fails the check', () {
    pin();
    morsecq.put('packages/core/lib/a.dart', 'a2');
    var run = _sync(morsecq, ['--check']);
    expect(run.code, 1);
    expect(run.err, contains('changed: packages/core/lib/a.dart'));

    morsecq
      ..put('packages/core/lib/a.dart', 'a')
      ..put('packages/core/lib/c.dart', 'c');
    run = _sync(morsecq, ['--check']);
    expect(run.err, contains('unpinned: packages/core/lib/c.dart'));

    morsecq
      ..remove('packages/core/lib/c.dart')
      ..remove('packages/core/lib/b.dart');
    run = _sync(morsecq, ['--check']);
    expect(run.err, contains('missing: packages/core/lib/b.dart'));
  });

  test('a divergence needs a rule with a known kind and a reason', () {
    morsecq.put('packages/core/lib/a.dart', 'a-morsecq');
    var run = pin();
    expect(run.code, 1, reason: '--write still validates');
    expect(
      run.err,
      contains('unexplained divergence: packages/core/lib/a.dart'),
    );
    final files = morsecq.manifest['files']! as Map<String, Object?>;
    expect(files['packages/core/lib/a.dart'], isA<Map<String, Object?>>());

    morsecq.manifest = morsecq.manifest
      ..['divergence'] = [
        {'path': 'packages/core/', 'kind': 'whatever', 'reason': ' '},
      ];
    run = _sync(morsecq, ['--check']);
    expect(run.err, contains('kind "whatever" is not one of'));
    expect(run.err, contains('reason is empty'));

    morsecq.manifest = morsecq.manifest
      ..['divergence'] = [
        {
          'path': 'packages/core/lib/a.dart',
          'kind': 'product',
          'reason': 'names the app',
        },
      ];
    expect(_sync(morsecq, ['--check']).code, 0);
  });

  test('stale and out-of-package rules fail the check', () {
    pin();
    morsecq.manifest = morsecq.manifest
      ..['divergence'] = [
        {'path': 'packages/core/', 'kind': 'morsecq-ahead', 'reason': 'r'},
        {'path': 'apps/', 'kind': 'product', 'reason': 'r'},
      ];
    final run = _sync(morsecq, ['--check']);
    expect(run.code, 1);
    expect(run.err, contains('"packages/core/": stale'));
    expect(run.err, contains('"apps/": not inside a shared package'));
  });

  test('--write without a checkout keeps DitMesh hashes as pinned', () {
    pin();
    morsecq.put('packages/core/lib/b.dart', 'b-new');
    morsecq.manifest = morsecq.manifest
      ..['divergence'] = [
        {
          'path': 'packages/core/lib/b.dart',
          'kind': 'morsecq-ahead',
          'reason': 'r',
        },
      ];
    expect(_sync(morsecq, ['--write']).code, 0);
    final files = morsecq.manifest['files']! as Map<String, Object?>;
    final b = files['packages/core/lib/b.dart']! as Map<String, Object?>;
    expect(b['morsecq'], isNot(b['ditmesh']));
  });

  test('--compare names the side that moved since the pin', () {
    pin();
    morsecq.put('packages/core/lib/a.dart', 'a-ours');
    ditmesh
      ..put('packages/core/lib/b.dart', 'b-theirs')
      ..put('packages/core/lib/d.dart', 'd');
    final run = _sync(morsecq, ['--compare', ditmesh.path]);
    expect(run.code, 1);
    expect(
      run.out,
      allOf(
        contains(
          'MorseCQ changed since the pin (1):\n  packages/core/lib/a.dart',
        ),
        contains('DitMesh changed since the pin (2):'),
        contains('  packages/core/lib/d.dart [only in DitMesh]'),
        contains('(dirty)'),
      ),
    );
  });

  test('--compare is quiet when only pinned divergence remains', () {
    morsecq.put('packages/core/lib/a.dart', 'a-morsecq');
    pin();
    morsecq.manifest = morsecq.manifest
      ..['divergence'] = [
        {'path': 'packages/core/lib/a.dart', 'kind': 'product', 'reason': 'r'},
      ];
    final run = _sync(morsecq, ['--compare', ditmesh.path]);
    expect(run.code, 0);
    expect(run.out, contains('2 identical, 1 differ as pinned'));
    expect(run.out, contains('    1 product\n'));
  });

  test('bad arguments and a malformed manifest are reported', () {
    expect(_sync(morsecq, ['--compare']).code, 64);
    expect(_sync(morsecq, ['--write', '--ditmesh']).code, 64);
    File('${morsecq.path}/$manifestPath').writeAsStringSync('[]');
    final run = _sync(morsecq, ['--check']);
    expect(run.code, 1);
    expect(run.err, contains('bad $manifestPath'));
  });
}
