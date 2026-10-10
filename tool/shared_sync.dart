import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Pins the packages MorseCQ shares with the DitMesh repository.
/// Run from the repository root: `dart run tool/shared_sync.dart [mode]`
///
/// `tool/shared_packages.lock.json` lists every Git-visible file of the shared
/// packages with the SHA-256 of MorseCQ's copy and of DitMesh's copy at the
/// last pin, plus the DitMesh commit that pin was taken from. A file whose two
/// hashes differ must be explained by a divergence rule (`product`,
/// `morsecq-ahead` or `ditmesh-ahead`, each with a reason).
///
/// Modes (DIR is a DitMesh checkout):
///   --check (default)   CI gate; needs no DitMesh checkout. The tree must
///                       match the pins exactly, every divergence must be
///                       explained, and no rule may be stale.
///   --compare DIR       Local report: which files changed on which side
///                       since the pin. Exit 1 when anything is unpinned.
///   --write             Re-pin MorseCQ's hashes; with `--ditmesh DIR` also
///                       DitMesh's hashes and commit. Divergence rules are
///                       kept as written; the result is then checked.
const manifestPath = 'tool/shared_packages.lock.json';

/// Allowed divergence kinds and what each means.
const divergenceKinds = <String, String>{
  'product': 'intentional, product-specific; stays different',
  'morsecq-ahead': 'MorseCQ has changes DitMesh has not taken yet',
  'ditmesh-ahead': 'DitMesh has changes MorseCQ has not taken yet',
};

const _usage = '''
usage: dart run tool/shared_sync.dart [--check]
       dart run tool/shared_sync.dart --compare <path-to-ditmesh>
       dart run tool/shared_sync.dart --write [--ditmesh <path-to-ditmesh>]''';

void main(List<String> args) {
  exitCode = runSharedSync(args, root: '.', out: stdout, err: stderr);
}

/// Entry point with an explicit repository [root], so tests can drive it.
int runSharedSync(
  List<String> args, {
  required String root,
  required StringSink out,
  required StringSink err,
}) {
  final String mode;
  String? ditmesh;
  if (args.isEmpty || (args.length == 1 && args.first == '--check')) {
    mode = 'check';
  } else if (args.length == 2 && args.first == '--compare') {
    mode = 'compare';
    ditmesh = args[1];
  } else if (args.first == '--write' &&
      (args.length == 1 || (args.length == 3 && args[1] == '--ditmesh'))) {
    mode = 'write';
    ditmesh = args.length == 3 ? args[2] : null;
  } else {
    err.writeln(_usage);
    return 64;
  }
  final manifestFile = File('$root/$manifestPath');
  if (!manifestFile.existsSync()) {
    err.writeln('[shared-sync] $manifestPath not found under $root');
    return 1;
  }
  try {
    final manifest = Manifest.parse(manifestFile.readAsStringSync());
    final tree = snapshot(root, manifest.packages);
    switch (mode) {
      case 'check':
        return _report(validate(manifest, tree), out, err);
      case 'compare':
        final other = snapshot(ditmesh!, manifest.packages);
        return compare(
          manifest,
          tree,
          other,
          gitState(ditmesh, manifest.packages),
          out,
        );
      default:
        final updated = repin(
          manifest,
          tree,
          ditmeshTree: ditmesh == null
              ? null
              : snapshot(ditmesh, manifest.packages),
          ditmeshState: ditmesh == null
              ? null
              : gitState(ditmesh, manifest.packages),
        );
        manifestFile.writeAsStringSync(updated.encode());
        out.writeln('[shared-sync] wrote $manifestPath');
        return _report(validate(updated, tree), out, err);
    }
  } on FormatException catch (e) {
    err.writeln('[shared-sync] bad $manifestPath: ${e.message}');
    return 1;
  } on ProcessException catch (e) {
    err.writeln('[shared-sync] git failed: ${e.message}');
    return 1;
  }
}

int _report(List<String> errors, StringSink out, StringSink err) {
  if (errors.isEmpty) {
    out.writeln('[shared-sync] shared packages match $manifestPath');
    return 0;
  }
  errors.forEach(err.writeln);
  err.writeln(
    '[shared-sync] ${errors.length} problem(s). Shared package files are '
    'pinned: after a deliberate change, sync or record the divergence, then '
    'run `dart run tool/shared_sync.dart --write` (see '
    'doc/testing/TEST_PYRAMID.md, "Shared packages").',
  );
  return 1;
}

/// The hashes of one file on both sides; null means the side lacks it.
final class Pin {
  const Pin(this.morsecq, this.ditmesh);

  final String? morsecq;
  final String? ditmesh;

  bool get same => morsecq == ditmesh;
}

/// One explained difference: an exact file path, or a directory prefix
/// ending in `/`.
final class Divergence {
  const Divergence(this.path, this.kind, this.reason);

  final String path;
  final String kind;
  final String reason;

  bool covers(String file) =>
      path.endsWith('/') ? file.startsWith(path) : file == path;
}

/// Commit and dirtiness of a DitMesh checkout.
final class GitState {
  const GitState(this.commit, {required this.dirty});

  final String? commit;
  final bool dirty;
}

final class Manifest {
  Manifest({
    required this.packages,
    required this.ditmesh,
    required this.divergence,
    required Map<String, Pin> files,
  }) : files = SplayTreeMap<String, Pin>.of(files);

  final List<String> packages;
  final GitState ditmesh;
  final List<Divergence> divergence;
  final SplayTreeMap<String, Pin> files;

  static Manifest parse(String source) {
    final json = jsonDecode(source);
    if (json is! Map<String, Object?>) {
      throw const FormatException('top level must be an object');
    }
    final packages = json['packages'];
    final ditmesh = json['ditmesh'];
    final rules = json['divergence'];
    final files = json['files'];
    if (packages is! List ||
        ditmesh is! Map ||
        rules is! List ||
        files is! Map) {
      throw const FormatException(
        'needs packages, ditmesh, divergence and files',
      );
    }
    return Manifest(
      packages: [for (final p in packages) p as String],
      ditmesh: GitState(
        ditmesh['commit'] as String?,
        dirty: ditmesh['dirty'] == true,
      ),
      divergence: [
        for (final r in rules.cast<Map<String, Object?>>())
          Divergence(
            r['path'] as String? ?? '',
            r['kind'] as String? ?? '',
            r['reason'] as String? ?? '',
          ),
      ],
      files: {
        for (final MapEntry(:key, :value) in files.entries)
          key as String: switch (value) {
            final String hash => Pin(hash, hash),
            final Map<String, Object?> both => Pin(
              both['morsecq'] as String?,
              both['ditmesh'] as String?,
            ),
            _ => throw FormatException('bad pin for $key'),
          },
      },
    );
  }

  /// Identical files are a single hash; differing ones list both sides.
  String encode() {
    final json = <String, Object?>{
      'about':
          'Pins of the packages shared with DitMesh. Maintained by '
          'tool/shared_sync.dart; edit only the divergence rules by hand.',
      'packages': packages,
      'ditmesh': {'commit': ditmesh.commit, 'dirty': ditmesh.dirty},
      'divergence': [
        for (final d in divergence)
          {'path': d.path, 'kind': d.kind, 'reason': d.reason},
      ],
      'files': {
        for (final MapEntry(:key, :value) in files.entries)
          key: value.same
              ? value.morsecq
              : {'morsecq': value.morsecq, 'ditmesh': value.ditmesh},
      },
    };
    return '${const JsonEncoder.withIndent('  ').convert(json)}\n';
  }
}

/// SHA-256 of every Git-visible file (tracked, or untracked and not ignored)
/// under `packages/<name>/` of the repository at [repo].
Map<String, String> snapshot(String repo, List<String> packages) {
  final result = Process.runSync('git', [
    '-C',
    repo,
    'ls-files',
    '-z',
    '--cached',
    '--others',
    '--exclude-standard',
    '--',
    for (final p in packages) 'packages/$p/',
  ], stdoutEncoding: utf8);
  if (result.exitCode != 0) {
    throw ProcessException('git', ['ls-files'], '${result.stderr}'.trim());
  }
  final hashes = SplayTreeMap<String, String>();
  for (final path in (result.stdout as String).split('\x00')) {
    if (path.isEmpty) continue;
    final file = File('$repo/$path');
    // A tracked file deleted in the working tree is simply absent.
    if (!file.existsSync()) continue;
    hashes[path] = sha256.convert(file.readAsBytesSync()).toString();
  }
  return hashes;
}

/// HEAD of the checkout at [repo], and whether the shared [packages] have
/// uncommitted changes there.
GitState gitState(String repo, [List<String> packages = const []]) {
  final head = Process.runSync('git', ['-C', repo, 'rev-parse', 'HEAD']);
  final status = Process.runSync('git', [
    '-C',
    repo,
    'status',
    '--porcelain',
    '--',
    for (final p in packages) 'packages/$p/',
  ]);
  return GitState(
    head.exitCode == 0 ? '${head.stdout}'.trim() : null,
    dirty: '${status.stdout}'.trim().isNotEmpty,
  );
}

/// Every reason the [tree] does not match [manifest]; empty when it does.
List<String> validate(Manifest manifest, Map<String, String> tree) {
  final errors = <String>[];
  for (final MapEntry(key: path, value: pin) in manifest.files.entries) {
    final current = tree[path];
    if (pin.morsecq == null) {
      if (current != null) errors.add('unpinned: $path (new in MorseCQ)');
    } else if (current == null) {
      errors.add('missing: $path (pinned, but no longer in the tree)');
    } else if (current != pin.morsecq) {
      errors.add('changed: $path (content differs from its pin)');
    }
  }
  for (final path in tree.keys) {
    if (!manifest.files.containsKey(path)) {
      errors.add('unpinned: $path (new in MorseCQ)');
    }
  }
  final roots = [for (final p in manifest.packages) 'packages/$p/'];
  final differing = [
    for (final MapEntry(:key, :value) in manifest.files.entries)
      if (!value.same) key,
  ];
  for (final rule in manifest.divergence) {
    final where = 'divergence rule "${rule.path}"';
    if (!roots.any((r) => rule.path.startsWith(r))) {
      errors.add('$where: not inside a shared package');
    }
    if (!divergenceKinds.containsKey(rule.kind)) {
      errors.add(
        '$where: kind "${rule.kind}" is not one of '
        '${divergenceKinds.keys.join(', ')}',
      );
    }
    if (rule.reason.trim().isEmpty) errors.add('$where: reason is empty');
    if (!differing.any(rule.covers)) {
      errors.add('$where: stale, no pinned file differs from DitMesh');
    }
  }
  for (final path in differing) {
    if (!manifest.divergence.any((r) => r.covers(path))) {
      errors.add(
        'unexplained divergence: $path differs from DitMesh\'s copy '
        '(add a divergence rule with a reason)',
      );
    }
  }
  return errors;
}

/// Reports what changed on each side since the pin. Returns 1 when any file
/// moved since the pin (including files that became identical), else 0.
int compare(
  Manifest manifest,
  Map<String, String> tree,
  Map<String, String> ditmeshTree,
  GitState ditmeshState,
  StringSink out,
) {
  final pinnedAt = manifest.ditmesh.commit ?? 'unknown';
  out.writeln(
    '[shared-sync] pinned against DitMesh $pinnedAt'
    '${manifest.ditmesh.dirty ? ' (dirty)' : ''}; comparing with '
    '${ditmeshState.commit ?? 'unknown'}'
    '${ditmeshState.dirty ? ' (dirty)' : ''}',
  );
  final sections = <String, List<String>>{
    'MorseCQ changed since the pin': [],
    'DitMesh changed since the pin': [],
    'Both changed since the pin': [],
    'Now identical (re-pin with --write --ditmesh)': [],
  };
  final pinnedDifferent = <String>[];
  var identical = 0;
  final paths = SplayTreeSet<String>()
    ..addAll(manifest.files.keys)
    ..addAll(tree.keys)
    ..addAll(ditmeshTree.keys);
  for (final path in paths) {
    final pin = manifest.files[path] ?? const Pin(null, null);
    final now = Pin(tree[path], ditmeshTree[path]);
    final ours = now.morsecq != pin.morsecq;
    final theirs = now.ditmesh != pin.ditmesh;
    if (!ours && !theirs) {
      now.same ? identical++ : pinnedDifferent.add(path);
      continue;
    }
    final section = now.same
        ? 'Now identical (re-pin with --write --ditmesh)'
        : ours && theirs
        ? 'Both changed since the pin'
        : ours
        ? 'MorseCQ changed since the pin'
        : 'DitMesh changed since the pin';
    sections[section]!.add('  $path${_presence(now)}');
  }
  out.writeln(
    '  $identical identical, ${pinnedDifferent.length} differ as '
    'pinned',
  );
  for (final kind in divergenceKinds.keys) {
    final rules = manifest.divergence.where((r) => r.kind == kind);
    final n = pinnedDifferent.where((p) => rules.any((r) => r.covers(p)));
    if (n.isNotEmpty) out.writeln('    ${n.length} $kind');
  }
  var moved = 0;
  for (final MapEntry(:key, :value) in sections.entries) {
    if (value.isEmpty) continue;
    moved += value.length;
    out.writeln('$key (${value.length}):');
    value.forEach(out.writeln);
  }
  return moved == 0 ? 0 : 1;
}

String _presence(Pin now) => now.morsecq == null
    ? ' [only in DitMesh]'
    : now.ditmesh == null
    ? ' [only in MorseCQ]'
    : '';

/// The manifest re-pinned to [tree]; DitMesh's hashes and state come from
/// [ditmeshTree] / [ditmeshState] when given, else stay as pinned.
Manifest repin(
  Manifest manifest,
  Map<String, String> tree, {
  Map<String, String>? ditmeshTree,
  GitState? ditmeshState,
}) {
  String? theirs(String path) =>
      ditmeshTree != null ? ditmeshTree[path] : manifest.files[path]?.ditmesh;
  final paths = SplayTreeSet<String>()
    ..addAll(tree.keys)
    ..addAll(ditmeshTree?.keys ?? manifest.files.keys);
  return Manifest(
    packages: manifest.packages,
    ditmesh: ditmeshState ?? manifest.ditmesh,
    divergence: manifest.divergence,
    files: {
      for (final path in paths)
        if (tree[path] != null || theirs(path) != null)
          path: Pin(tree[path], theirs(path)),
    },
  );
}
