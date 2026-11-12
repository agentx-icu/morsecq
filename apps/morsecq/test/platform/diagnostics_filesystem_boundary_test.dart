import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/diagnostics/local_diagnostics.dart';

class _PrivateType implements Type {
  @override
  String toString() => 'PRIVATE_TYPE_MARKER';
}

class _PrivateTypeError {
  bool read = false;
  @override
  Type get runtimeType {
    read = true;
    return _PrivateType();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a custom runtimeType is never read, persisted or copied', () async {
    final dir = await Directory.systemTemp.createTemp('diagnostics_type_');
    addTearDown(() => dir.delete(recursive: true));
    final log = LocalDiagnostics(File('${dir.path}/errors.log'));
    final error = _PrivateTypeError();
    log.record(error, null);
    expect(error.read, isFalse);
    final copied = await log.readEvidence();
    expect(copied, contains('runtime Object'));
    expect(copied, isNot(contains('PRIVATE_TYPE_MARKER')));
  });

  test(
    'legacy replacement does not truncate or append to an opened inode',
    () async {
      final dir = await Directory.systemTemp.createTemp('diagnostics_replace_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/errors.log');
      const original = '{"learning":"PRIVATE_LEARNING_BYTES"}';
      await file.writeAsString(original);
      final oldHandle = file.openSync();
      try {
        LocalDiagnostics(file).record(StateError('synthetic failure'), null);
        expect(String.fromCharCodes(oldHandle.readSync(1024)), original);
        expect(await file.readAsString(), contains('runtime StateError'));
        expect(
          await file.readAsString(),
          isNot(contains('PRIVATE_LEARNING_BYTES')),
        );
      } finally {
        oldHandle.closeSync();
      }
    },
  );

  for (final linkName in ['logs', 'errors.log', 'errors.log.previous']) {
    test('record, copy and initialization refuse the $linkName link', () async {
      final dir = await Directory.systemTemp.createTemp('diagnostics_link_');
      addTearDown(() => dir.delete(recursive: true));
      final logs = Directory('${dir.path}/logs');
      final learning = Directory('${dir.path}/learning')..createSync();
      final target = File('${learning.path}/errors.log');
      const original = 'MorseCQ diagnostics v3\nPRIVATE_LEARNING_BYTES';
      await target.writeAsString(original);
      late Link link;
      if (linkName == 'logs') {
        link = Link(logs.path);
        await link.create(learning.path);
      } else {
        await logs.create();
        link = Link('${logs.path}/$linkName');
        await link.create(target.path);
      }
      final log = LocalDiagnostics(File('${logs.path}/errors.log'));
      log.record(StateError('synthetic failure'), null);
      expect(await target.readAsString(), original);
      expect(
        await log.readEvidence(),
        isNot(contains('PRIVATE_LEARNING_BYTES')),
      );
      expect(
        FileSystemEntity.typeSync(link.path, followLinks: false),
        FileSystemEntityType.link,
      );
      expect(
        await learning.list().length,
        1,
        reason: 'no staging or other files in learning storage',
      );

      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      messenger.setMockMethodCallHandler(channel, (_) async => dir.path);
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      await LocalDiagnostics.initialize();
      expect(await target.readAsString(), original);
      expect(
        await LocalDiagnostics.read(),
        isNot(contains('PRIVATE_LEARNING_BYTES')),
      );
      expect(
        FileSystemEntity.typeSync(link.path, followLinks: false),
        FileSystemEntityType.link,
      );
    });
  }
}
