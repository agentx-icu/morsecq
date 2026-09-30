import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Exercises `tool/strings_to_arb.dart` end to end in a scratch directory by
/// running it as a subprocess (the tool lives at the repository root, outside
/// this package, so it cannot be imported).
void main() {
  late Directory scratch;
  late String toolPath;

  setUpAll(() {
    toolPath = _locateTool();
  });

  setUp(() {
    scratch = Directory.systemTemp.createTempSync('morsecq_strings_to_arb_');
    Directory('${scratch.path}/app/lib/ui/chat').createSync(recursive: true);
    Directory('${scratch.path}/app/lib/l10n').createSync(recursive: true);
  });

  tearDown(() => scratch.deleteSync(recursive: true));

  File stringsFile(String body) =>
      File('${scratch.path}/app/lib/ui/chat/chat_strings.dart')
        ..writeAsStringSync(body);

  File enFile() => File('${scratch.path}/app/lib/l10n/app_en.arb');
  File zhFile() => File('${scratch.path}/app/lib/l10n/app_zh.arb');

  Future<ProcessResult> run([List<String> extra = const []]) => Process.run(
    Platform.resolvedExecutable,
    [toolPath, '--app-dir', '${scratch.path}/app', ...extra],
    workingDirectory: scratch.path,
  );

  Map<String, Object?> readArb(File f) =>
      jsonDecode(f.readAsStringSync()) as Map<String, Object?>;

  test('extracts consts into namespaced keys and flags zh as TODO', () async {
    stringsFile('''
abstract final class ChatStrings {
  static const String sendHint = 'Type a message';
  static const cancel = "Cancel";
  static const String twoLines =
      'Tox has no server: '
      'delivered later.';
  static const String quoted = 'It\\'s here';
  static const String route = '/settings/chat';
  static const String url = 'https://example.org';
  static String count(int n) => '\$n items';
  static const int notAString = 3;
}
''');
    enFile().writeAsStringSync('{"@@locale": "en"}');
    zhFile().writeAsStringSync('{"@@locale": "zh"}');

    final result = await run();
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

    final en = readArb(enFile());
    expect(en['chatSendHint'], 'Type a message');
    expect(en['chatCancel'], 'Cancel');
    expect(en['chatTwoLines'], 'Tox has no server: delivered later.');
    expect(en['chatQuoted'], "It's here");
    expect(en.containsKey('chatRoute'), isFalse, reason: 'routes skipped');
    expect(en.containsKey('chatUrl'), isFalse, reason: 'URLs skipped');
    expect(en.containsKey('chatCount'), isFalse, reason: 'functions skipped');
    expect(en.containsKey('chatNotAString'), isFalse);
    final meta = en['@chatSendHint'] as Map<String, Object?>;
    expect(meta['description'], contains('ChatStrings.sendHint'));
    expect(meta['description'], contains('chat_strings.dart'));

    final zh = readArb(zhFile());
    expect(zh['@@locale'], 'zh');
    expect(zh['chatSendHint'], 'Type a message', reason: 'English fallback');
    final zhMeta = zh['@chatSendHint'] as Map<String, Object?>;
    expect(zhMeta['description'], startsWith('@@TODO'));
  });

  test('never overwrites existing translations and is idempotent', () async {
    stringsFile('''
abstract final class ChatStrings {
  static const String send = 'Send';
  static const String stop = 'Stop';
}
''');
    enFile().writeAsStringSync(
      jsonEncode({
        '@@locale': 'en',
        'chatSend': 'Send it!',
        '@chatSend': {'description': 'hand written'},
      }),
    );
    zhFile().writeAsStringSync(
      jsonEncode({'@@locale': 'zh', 'chatSend': '发送'}),
    );

    final first = await run();
    expect(first.exitCode, 0, reason: '${first.stdout}\n${first.stderr}');
    final en = readArb(enFile());
    expect(en['chatSend'], 'Send it!', reason: 'existing value kept');
    expect((en['@chatSend'] as Map)['description'], 'hand written');
    expect(en['chatStop'], 'Stop', reason: 'new key added');

    final zh = readArb(zhFile());
    expect(zh['chatSend'], '发送', reason: 'translation kept');
    expect(zh.containsKey('@chatSend'), isFalse, reason: 'no TODO on done keys');
    expect(zh['chatStop'], 'Stop');
    expect((zh['@chatStop'] as Map)['description'], startsWith('@@TODO'));

    final enBefore = enFile().readAsStringSync();
    final zhBefore = zhFile().readAsStringSync();
    final second = await run();
    expect(second.exitCode, 0);
    expect(enFile().readAsStringSync(), enBefore, reason: 'idempotent');
    expect(zhFile().readAsStringSync(), zhBefore, reason: 'idempotent');

    final check = await run(['--check']);
    expect(check.exitCode, 0, reason: 'up to date => --check passes');
  });

  test('--check fails and --dry-run writes nothing when keys are missing',
      () async {
    stringsFile('''
abstract final class ChatStrings {
  static const String fresh = 'Fresh';
}
''');
    enFile().writeAsStringSync('{"@@locale": "en"}');
    zhFile().writeAsStringSync('{"@@locale": "zh"}');

    final check = await run(['--check']);
    expect(check.exitCode, 1, reason: '${check.stdout}\n${check.stderr}');
    expect(readArb(enFile()).containsKey('chatFresh'), isFalse);

    final dry = await run(['--dry-run']);
    expect(dry.exitCode, 0);
    expect(dry.stdout, contains('chatFresh'));
    expect(readArb(enFile()).containsKey('chatFresh'), isFalse);
  });

  test('a key produced by two members is a hard error', () async {
    stringsFile('''
abstract final class ChatStrings {
  static const String send = 'Send';
}
''');
    File('${scratch.path}/app/lib/ui/chat/other_chat_strings.dart')
        .writeAsStringSync('''
abstract final class ChatStrings {
  static const String send = 'Send again';
}
''');
    enFile().writeAsStringSync('{"@@locale": "en"}');
    final result = await run();
    expect(result.exitCode, 2);
    expect(result.stderr, contains('chatSend'));
  });
}

/// Walks up from the test's working directory (apps/morsecq) to the
/// repository root and returns the tool's path.
String _locateTool() {
  var dir = Directory.current;
  for (var i = 0; i < 5; i++) {
    final candidate = File('${dir.path}/tool/strings_to_arb.dart');
    if (candidate.existsSync()) return candidate.path;
    dir = dir.parent;
  }
  fail('tool/strings_to_arb.dart not found above ${Directory.current.path}');
}
