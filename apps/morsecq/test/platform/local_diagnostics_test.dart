import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/diagnostics/local_diagnostics.dart';

void main() {
  test(
    'local crash evidence omits exception contents and rotates at a bound',
    () async {
      final dir = await Directory.systemTemp.createTemp('morsecq_diagnostics_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/logs/errors.log');
      final log = LocalDiagnostics(file, maximumBytes: 256);
      log.record(
        StateError('PRIVATE_USER_MATERIAL'),
        StackTrace.fromString('frame one'),
      );
      final evidence = await file.readAsString();
      expect(evidence, contains('StateError'));
      expect(evidence, contains('frame one'));
      expect(evidence, isNot(contains('PRIVATE_USER_MATERIAL')));
      for (var i = 0; i < 10; i++) {
        log.record(
          StateError('PRIVATE_USER_MATERIAL'),
          StackTrace.fromString('frame $i'),
        );
      }
      expect(await File('${file.path}.previous').exists(), isTrue);
      expect(await file.length(), lessThanOrEqualTo(256));
    },
  );
}
