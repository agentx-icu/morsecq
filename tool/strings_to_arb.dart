import 'dart:convert';
import 'dart:io';

/// Migrates `static const` UI strings from `*_strings.dart` files into the
/// app's ARB files. Run from the repository root:
///
/// ```bash
/// dart run tool/strings_to_arb.dart                 # all apps/morsecq/lib/ui/**/*_strings.dart
/// dart run tool/strings_to_arb.dart lib/ui/x/x_strings.dart   # specific files
/// dart run tool/strings_to_arb.dart --check         # exit 1 if anything is missing
/// dart run tool/strings_to_arb.dart --dry-run       # report, write nothing
/// ```
///
/// Rules (all of them make the tool safe to re-run at any time):
///   * Only `static const [String] name = '...';` members are extracted
///     (adjacent literals and `r'...'` supported). Interpolating consts,
///     functions, non-strings and route/URL values (`/x`, `https://`) are
///     skipped and listed.
///   * The ARB key is `<area><Member>` from the class name
///     (`ChatStrings.sendHint` -> `chatSendHint`).
///   * The template (`app_en.arb`) only ever GAINS keys; existing keys and
///     metadata are never touched. New keys get an `@key` description naming
///     the source member and file.
///   * Every other ARB gains the template keys it lacks, valued with the
///     English text and a `@key.description` starting with `@@TODO`.
///     Existing translations are never modified or removed.
void main(List<String> args) {
  final options = _Options.parse(args);
  if (options == null) {
    exit(2);
  }

  final sources = options.sources.isEmpty
      ? _defaultSources(options.appDir)
      : options.sources;
  if (sources.isEmpty) {
    stderr.writeln('[strings_to_arb] no *_strings.dart files found');
    exit(2);
  }

  final extracted = <ExtractedString>[];
  for (final path in sources) {
    final file = File(path);
    if (!file.existsSync()) {
      stderr.writeln('[strings_to_arb] missing source: $path');
      exit(2);
    }
    extracted.addAll(extractStrings(file.readAsStringSync(), sourcePath: path));
  }
  final collision = findKeyCollision(extracted);
  if (collision != null) {
    stderr.writeln('[strings_to_arb] $collision');
    exit(2);
  }

  final templateFile = File(options.templatePath);
  final template = ArbDocument.read(templateFile, locale: options.templateLocale);
  final added = mergeIntoTemplate(template, extracted);
  final report = StringBuffer()
    ..writeln(
      '[strings_to_arb] ${extracted.length} strings from '
      '${sources.length} file(s); ${added.length} new in '
      '${options.templatePath}',
    );
  for (final key in added) {
    report.writeln('  + $key');
  }

  var changed = added.isNotEmpty;
  final targets = <ArbDocument>[];
  for (final targetPath in options.targetPaths) {
    final target = ArbDocument.read(
      File(targetPath),
      locale: _localeFromArbName(targetPath),
    );
    final todo = mergeIntoTarget(template, target);
    changed |= todo.isNotEmpty;
    report.writeln(
      '[strings_to_arb] ${todo.length} untranslated key(s) added to '
      '$targetPath (${target.todoCount} marked @@TODO in total)',
    );
    for (final key in todo) {
      report.writeln('  + $key');
    }
    targets.add(target);
  }

  stdout.write(report);
  if (options.check) {
    if (changed) {
      stderr.writeln(
        '[strings_to_arb] --check: ARB files are out of date; run '
        '`dart run tool/strings_to_arb.dart` and commit the result',
      );
      exit(1);
    }
    stdout.writeln('[strings_to_arb] --check: ARB files are up to date');
    return;
  }
  if (options.dryRun || !changed) {
    return;
  }
  template.write();
  for (final target in targets) {
    target.write();
  }
}

// ---------------------------------------------------------------------------
// Extraction
// ---------------------------------------------------------------------------

/// One extracted string: the ARB key it maps to, the value and where it
/// came from.
class ExtractedString {
  const ExtractedString({
    required this.key,
    required this.value,
    required this.member,
    required this.sourcePath,
  });

  final String key;
  final String value;
  final String member;
  final String sourcePath;

  String get description => 'From $member ($sourcePath)';
}

final RegExp _classPattern = RegExp(r'class\s+([A-Za-z0-9_]+)Strings\b');

/// One string literal (single or double quoted, optional `r` prefix).
const String _literal =
    r'''(?:r?'(?:[^'\\]|\\.)*'|r?"(?:[^"\\]|\\.)*")''';

/// `static const [String] name = <literal> [<literal> ...];`
final RegExp _memberPattern = RegExp(
  r'static\s+const\s+(?:String\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*'
  '($_literal(?:\\s*$_literal)*)\\s*;',
  multiLine: true,
);

final RegExp _literalPattern = RegExp(_literal);
final RegExp _nonUiValue = RegExp(r'^(/|https?://)');

/// Extracts every `static const` string member of the `*Strings` class in
/// [source]. Members whose value is not a plain string literal are ignored.
List<ExtractedString> extractStrings(String source, {required String sourcePath}) {
  final classMatch = _classPattern.firstMatch(source);
  final area = classMatch != null
      ? _lowerFirst(classMatch.group(1)!)
      : _areaFromFileName(sourcePath);
  final className = classMatch != null
      ? '${classMatch.group(1)}Strings'
      : _upperFirst(area);

  final results = <ExtractedString>[];
  for (final match in _memberPattern.allMatches(source)) {
    final member = match.group(1)!;
    final value = _decodeLiterals(match.group(2)!);
    if (value == null) {
      stdout.writeln(
        '[strings_to_arb] skip $className.$member: interpolates a value',
      );
      continue;
    }
    if (_nonUiValue.hasMatch(value)) {
      stdout.writeln(
        '[strings_to_arb] skip $className.$member: route/URL, not UI text',
      );
      continue;
    }
    results.add(
      ExtractedString(
        key: '$area${_upperFirst(member)}',
        value: value,
        member: '$className.$member',
        sourcePath: sourcePath,
      ),
    );
  }
  return results;
}

/// Human-readable description of the first duplicate key, or null.
String? findKeyCollision(List<ExtractedString> extracted) {
  final seen = <String, ExtractedString>{};
  for (final e in extracted) {
    final other = seen[e.key];
    if (other != null && other.member != e.member) {
      return 'key ${e.key} produced by both ${other.member} and ${e.member}';
    }
    seen[e.key] = e;
  }
  return null;
}

/// Concatenates adjacent literals and resolves Dart escapes. Returns null when
/// a non-raw literal interpolates (`$name` / `${expr}`).
String? _decodeLiterals(String literals) {
  final out = StringBuffer();
  for (final m in _literalPattern.allMatches(literals)) {
    var text = m.group(0)!;
    final raw = text.startsWith('r');
    if (raw) text = text.substring(1);
    text = text.substring(1, text.length - 1);
    if (raw) {
      out.write(text);
      continue;
    }
    final decoded = _unescape(text);
    if (decoded == null) return null;
    out.write(decoded);
  }
  return out.toString();
}

String? _unescape(String text) {
  final out = StringBuffer();
  var i = 0;
  while (i < text.length) {
    final ch = text[i];
    if (ch == r'$') return null; // interpolation: not a plain literal
    if (ch != r'\') {
      out.write(ch);
      i++;
      continue;
    }
    i++;
    if (i >= text.length) return null;
    final esc = text[i];
    switch (esc) {
      case 'n':
        out.write('\n');
      case 't':
        out.write('\t');
      case 'r':
        out.write('\r');
      case 'u':
        final consumed = _unicodeEscape(text, i + 1, out);
        if (consumed < 0) return null;
        i += consumed;
      default:
        out.write(esc); // \' \" \\ \$ and anything else literal
    }
    i++;
  }
  return out.toString();
}

/// Decodes `\uXXXX` or `\u{X...}` starting at [start] (just after the `u`).
/// Returns the number of characters consumed after the `u`, or -1.
int _unicodeEscape(String text, int start, StringBuffer out) {
  if (start < text.length && text[start] == '{') {
    final end = text.indexOf('}', start);
    if (end < 0) return -1;
    final code = int.tryParse(text.substring(start + 1, end), radix: 16);
    if (code == null) return -1;
    out.write(String.fromCharCode(code));
    return end - start + 1;
  }
  if (start + 4 > text.length) return -1;
  final code = int.tryParse(text.substring(start, start + 4), radix: 16);
  if (code == null) return -1;
  out.write(String.fromCharCode(code));
  return 4;
}

String _areaFromFileName(String path) {
  final base = path.split(RegExp(r'[\\/]')).last;
  final stem = base.replaceAll(RegExp(r'_strings\.dart$'), '');
  final parts = stem.split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'app';
  return parts.first + parts.skip(1).map(_upperFirst).join();
}

String _lowerFirst(String s) =>
    s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

String _upperFirst(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ---------------------------------------------------------------------------
// ARB documents
// ---------------------------------------------------------------------------

/// In-memory ARB file that preserves key order and round-trips untouched
/// entries byte-for-byte (modulo 2-space JSON formatting).
class ArbDocument {
  ArbDocument(this.file, this.entries);

  /// Loads [file]; a missing file becomes an empty document for [locale].
  factory ArbDocument.read(File file, {required String locale}) {
    if (!file.existsSync()) {
      return ArbDocument(file, <String, Object?>{'@@locale': locale});
    }
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, Object?>) {
      throw FormatException('${file.path}: ARB root must be a JSON object');
    }
    decoded.putIfAbsent('@@locale', () => locale);
    return ArbDocument(file, decoded);
  }

  final File file;
  final Map<String, Object?> entries;

  /// Message keys (no `@` metadata, no `@@` header).
  Iterable<String> get messageKeys =>
      entries.keys.where((k) => !k.startsWith('@'));

  bool containsMessage(String key) => entries.containsKey(key);

  String? message(String key) => entries[key] as String?;

  void add(String key, String value, {required String description}) {
    entries[key] = value;
    entries['@$key'] = <String, Object?>{'description': description};
  }

  /// Number of `@key.description` values carrying the `@@TODO` marker.
  int get todoCount => entries.entries.where((e) {
    final meta = e.value;
    return e.key.startsWith('@') &&
        meta is Map &&
        (meta['description'] as String?)?.startsWith(todoMarker) == true;
  }).length;

  static const String todoMarker = '@@TODO';

  void write() {
    final json = const JsonEncoder.withIndent('  ').convert(entries);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('$json\n');
  }
}

/// Adds every extracted string missing from [template]. Returns the keys added.
List<String> mergeIntoTemplate(ArbDocument template, List<ExtractedString> strings) {
  final added = <String>[];
  for (final s in strings) {
    if (template.containsMessage(s.key)) continue;
    template.add(s.key, s.value, description: s.description);
    added.add(s.key);
  }
  return added;
}

/// Adds every template message missing from [target], valued with the
/// English text and flagged `@@TODO`. Returns the keys added.
List<String> mergeIntoTarget(ArbDocument template, ArbDocument target) {
  final added = <String>[];
  for (final key in template.messageKeys) {
    if (target.containsMessage(key)) continue;
    final value = template.message(key);
    if (value == null) continue;
    final source = template.entries['@$key'];
    final origin = source is Map ? source['description'] : null;
    target.add(
      key,
      value,
      description:
          '${ArbDocument.todoMarker}(l10n): translate from en'
          '${origin == null ? '' : ' — $origin'}',
    );
    added.add(key);
  }
  return added;
}

// ---------------------------------------------------------------------------
// CLI plumbing
// ---------------------------------------------------------------------------

class _Options {
  _Options({
    required this.appDir,
    required this.arbDir,
    required this.templateName,
    required this.targetNames,
    required this.sources,
    required this.dryRun,
    required this.check,
  });

  final String appDir;
  final String arbDir;
  final String templateName;
  final List<String> targetNames;
  final List<String> sources;
  final bool dryRun;
  final bool check;

  String get templatePath => '$arbDir/$templateName';
  String get templateLocale => _localeFromArbName(templateName);
  List<String> get targetPaths => [for (final t in targetNames) '$arbDir/$t'];

  static _Options? parse(List<String> args) {
    var appDir = 'apps/morsecq';
    String? arbDir;
    var template = 'app_en.arb';
    final targets = <String>[];
    final sources = <String>[];
    var dryRun = false;
    var check = false;
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      String next() {
        if (i + 1 >= args.length) {
          throw ArgumentError('$arg needs a value');
        }
        return args[++i];
      }
      try {
        switch (arg) {
          case '--app-dir':
            appDir = next();
          case '--arb-dir':
            arbDir = next();
          case '--template':
            template = next();
          case '--target':
            targets.add(next());
          case '--dry-run':
            dryRun = true;
          case '--check':
            check = true;
          case '--help' || '-h':
            stdout.writeln(_usage);
            return null;
          default:
            if (arg.startsWith('--')) {
              throw ArgumentError('unknown option $arg');
            }
            sources.add(arg);
        }
      } on ArgumentError catch (e) {
        stderr.writeln('[strings_to_arb] ${e.message}\n$_usage');
        return null;
      }
    }
    final resolvedArbDir = arbDir ?? '$appDir/lib/l10n';
    return _Options(
      appDir: appDir,
      arbDir: resolvedArbDir,
      templateName: template,
      targetNames: targets.isEmpty
          ? _otherArbFiles(resolvedArbDir, template)
          : targets,
      sources: sources,
      dryRun: dryRun,
      check: check,
    );
  }
}

const String _usage = '''
usage: dart run tool/strings_to_arb.dart [options] [<file>_strings.dart ...]

  --app-dir <dir>    app root (default apps/morsecq)
  --arb-dir <dir>    ARB directory (default <app-dir>/lib/l10n)
  --template <file>  template ARB (default app_en.arb)
  --target <file>    other ARB to sync (repeatable; default: every other
                     app_*.arb in --arb-dir)
  --dry-run          report only
  --check            exit 1 when any ARB would change (CI gate)

Without files, every <app-dir>/lib/ui/**/*_strings.dart is scanned.''';

List<String> _defaultSources(String appDir) {
  final root = Directory('$appDir/lib/ui');
  if (!root.existsSync()) return const [];
  return root
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .map((f) => f.path.replaceAll(r'\', '/'))
      .where((p) => p.endsWith('_strings.dart'))
      .toList()
    ..sort();
}

List<String> _otherArbFiles(String arbDir, String template) {
  final dir = Directory(arbDir);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(followLinks: false)
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((n) => n.startsWith('app_') && n.endsWith('.arb'))
      .where((n) => n != template)
      .toList()
    ..sort();
}

String _localeFromArbName(String path) {
  final name = path.split(RegExp(r'[\\/]')).last;
  final m = RegExp(r'^app_(.+)\.arb$').firstMatch(name);
  return m?.group(1) ?? 'en';
}
