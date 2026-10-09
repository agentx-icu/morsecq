import 'dart:convert';

import 'package:morse_trainer/morse_trainer.dart';
import 'package:test/test.dart';

String _libraryWithItems(List<String> items) {
  final now = DateTime.utc(2026, 10, 9);
  final material = MaterialImport.create(
    id: 'audit-material',
    title: 'Audit material',
    kind: MaterialKind.wordList,
    text: 'CQ',
    analysis: MaterialImport.analyze('CQ', MaterialKind.wordList),
    now: now,
  );
  final library = jsonDecode(MaterialLibraryCodec.encode([material])) as Map;
  (library['materials'].single as Map)['normalizedItems'] = items;
  return jsonEncode(library);
}

void main() {
  test('JSON imports enforce the entry limit inside each material', () {
    final raw = _libraryWithItems(
      List.generate(MaterialLimits.maxEntries + 1, (i) => 'W$i'),
    );
    expect(() => MaterialLibraryCodec.decode(raw), throwsFormatException);
  });

  test('JSON imports reject a material with no trainable entries', () {
    expect(
      () => MaterialLibraryCodec.decode(_libraryWithItems([])),
      throwsFormatException,
    );
  });

  test(
    'JSON imports reject empty entries rather than starting silent drills',
    () {
      expect(
        () => MaterialLibraryCodec.decode(_libraryWithItems([''])),
        throwsFormatException,
      );
    },
  );

  test('JSON exports reject a library larger than their own import limit', () {
    final text = 'CQ${' ' * 600000}';
    final analysis = MaterialImport.analyze(text, MaterialKind.text);
    expect(analysis.ok, isTrue);
    final materials = [
      for (var i = 0; i < 2; i++)
        MaterialImport.create(
          id: 'large-$i',
          title: 'Large $i',
          kind: MaterialKind.text,
          text: text,
          analysis: analysis,
          now: DateTime.utc(2026, 10, 9),
        ),
    ];
    var rejected = false;
    try {
      final raw = MaterialLibraryCodec.encode(materials);
      expect(utf8.encode(raw).length, greaterThan(MaterialLimits.maxBytes));
    } on FormatException {
      rejected = true;
    }
    expect(rejected, isTrue, reason: 'A reported export must be importable');
  });
}
