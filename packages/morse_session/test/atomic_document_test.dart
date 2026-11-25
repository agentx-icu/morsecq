import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:test/test.dart';

Map<String, Object?> decode(Map<String, Object?> json) {
  UnsupportedDataVersion.check(json['v'], supported: 1, document: 'Test');
  return json;
}

void main() {
  test('a future primary is incompatible, not corrupt', () async {
    final fs = MemoryDocumentFs({'doc': '{"v":2}', 'doc.bak': '{"v":1}'});
    final before = Map.of(fs.files);
    await expectLater(
      AtomicDocument(fs, 'doc').readDecoded(decode),
      throwsA(isA<UnsupportedDataVersion>()),
    );
    expect(fs.files, before);
  });

  for (final futurePath in ['doc', 'doc.bak']) {
    test('a future $futurePath prevents every save mutation', () async {
      final fs = MemoryDocumentFs({
        'doc': '{"v":1}',
        'doc.bak': '{"v":1}',
        'doc.tmp': 'previous recovery temp',
        'doc.corrupt': 'previous corrupt document',
        futurePath: '{"v":2}',
      });
      final before = Map.of(fs.files);
      await expectLater(
        AtomicDocument(fs, 'doc').write({'v': 1}, validate: decode),
        throwsA(isA<UnsupportedDataVersion>()),
      );
      expect(fs.files, before);
    });
  }

  test('a future backup cannot be read as empty data', () async {
    final fs = MemoryDocumentFs({'doc.bak': '{"v":2}'});
    await expectLater(
      AtomicDocument(fs, 'doc').readDecoded(decode),
      throwsA(isA<UnsupportedDataVersion>()),
    );
    expect(fs.files, {'doc.bak': '{"v":2}'});
  });

  test('a second corrupt document retains the earlier recovery copy', () async {
    final fs = MemoryDocumentFs({
      'doc': 'second broken document',
      'doc.corrupt': 'first broken document',
      'doc.bak': '{"v":1}',
    });
    expect(await AtomicDocument(fs, 'doc').readDecoded(decode), {'v': 1});
    expect(fs.files['doc.corrupt'], 'second broken document');
    expect(fs.files.values, contains('first broken document'));
  });
}

final class MemoryDocumentFs implements DocumentFs {
  MemoryDocumentFs(this.files);

  final Map<String, String> files;

  @override
  Future<bool> exists(String path) async => files.containsKey(path);

  @override
  Future<String?> readText(String path) async => files[path];

  @override
  Future<void> writeText(String path, String text) async => files[path] = text;

  @override
  Future<void> rename(String from, String to) async {
    final text = files.remove(from);
    if (text == null) throw StateError('Missing document: $from');
    files[to] = text;
  }

  @override
  Future<void> delete(String path) async => files.remove(path);

  @override
  String canonical(String path) => path;

  @override
  bool isIoFailure(Object error) => false;
}
