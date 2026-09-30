import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the two ARB files against drifting apart. `flutter test` runs with
/// the package root (apps/morsecq) as the working directory.
void main() {
  late Map<String, Object?> en;
  late Map<String, Object?> zh;

  setUpAll(() {
    en = _readArb('lib/l10n/app_en.arb');
    zh = _readArb('lib/l10n/app_zh.arb');
  });

  test('both ARB files declare their locale', () {
    expect(en['@@locale'], 'en');
    expect(zh['@@locale'], 'zh');
  });

  test('app_en.arb and app_zh.arb have identical message key sets', () {
    final enKeys = _messageKeys(en);
    final zhKeys = _messageKeys(zh);
    expect(
      zhKeys.difference(enKeys),
      isEmpty,
      reason: 'keys only in app_zh.arb',
    );
    expect(
      enKeys.difference(zhKeys),
      isEmpty,
      reason: 'keys missing from app_zh.arb — run '
          '`dart run tool/strings_to_arb.dart` from the repo root',
    );
  });

  test('every message value is a non-empty string', () {
    for (final arb in [en, zh]) {
      for (final key in _messageKeys(arb)) {
        expect(arb[key], isA<String>(), reason: key);
        expect((arb[key] as String).isNotEmpty, isTrue, reason: key);
      }
    }
  });

  test('zh uses every placeholder the en template declares', () {
    for (final key in _messageKeys(en)) {
      final meta = en['@$key'];
      if (meta is! Map) continue;
      final placeholders = meta['placeholders'];
      if (placeholders is! Map) continue;
      final zhValue = zh[key] as String;
      for (final name in placeholders.keys) {
        expect(
          zhValue.contains('{$name'),
          isTrue,
          reason: '$key: zh translation drops placeholder {$name}',
        );
      }
    }
  });

  test('plural messages carry an "other" branch in both files', () {
    final plural = RegExp(r'\{(\w+),\s*plural,');
    for (final arb in [en, zh]) {
      for (final key in _messageKeys(arb)) {
        final value = arb[key] as String;
        if (!plural.hasMatch(value)) continue;
        expect(value, contains('other{'), reason: '$key in ${arb['@@locale']}');
      }
    }
  });

  test('the four nav destinations and app name exist', () {
    for (final key in ['appName', 'navLearn', 'navChat', 'navGroups', 'navMe']) {
      expect(en.containsKey(key), isTrue, reason: key);
    }
    expect(en['appName'], zh['appName'], reason: 'product name is not translated');
  });

  test('every ChatException code has an error message', () {
    const codes = [
      'errorWrongPassword',
      'errorPeerOffline',
      'errorInvalidToxId',
      'errorAlreadyFriend',
      'errorOwnId',
      'errorGroupNotFound',
      'errorMessageTooLong',
      'errorUnknown',
    ];
    for (final key in codes) {
      expect(en.containsKey(key), isTrue, reason: key);
    }
  });
}

Map<String, Object?> _readArb(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path (cwd ${Directory.current.path})');
  final decoded = jsonDecode(file.readAsStringSync());
  expect(decoded, isA<Map<String, Object?>>());
  return decoded as Map<String, Object?>;
}

Set<String> _messageKeys(Map<String, Object?> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();
