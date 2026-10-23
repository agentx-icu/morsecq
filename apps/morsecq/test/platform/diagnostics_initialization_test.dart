import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/diagnostics/local_diagnostics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'early hooks require no store, survive storage failure and retry after ownership',
    () async {
      final dir = await Directory.systemTemp.createTemp('diagnostics_init_');
      final previousFlutter = FlutterError.onError;
      final previousPlatform = PlatformDispatcher.instance.onError;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      var supportCalls = 0;
      var fail = true;
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getApplicationSupportDirectory');
        supportCalls++;
        if (fail) {
          throw PlatformException(
            code: 'unavailable',
            message: 'SYNTHETIC_PRIVATE_PROVIDER',
          );
        }
        return dir.path;
      });
      addTearDown(() async {
        FlutterError.onError = previousFlutter;
        PlatformDispatcher.instance.onError = previousPlatform;
        messenger.setMockMethodCallHandler(channel, null);
        await dir.delete(recursive: true);
      });

      LocalDiagnostics.installErrorHandlers();
      expect(
        supportCalls,
        0,
        reason: 'installing hooks must not open shared storage',
      );
      expect(await dir.list().isEmpty, isTrue);
      final installedFlutter = FlutterError.onError;
      final installedPlatform = PlatformDispatcher.instance.onError;
      LocalDiagnostics.installErrorHandlers();
      expect(FlutterError.onError, same(installedFlutter));
      expect(PlatformDispatcher.instance.onError, same(installedPlatform));
      await LocalDiagnostics.initialize();
      expect(supportCalls, 1);
      expect(await dir.list().isEmpty, isTrue);

      final release = DiagnosticErrorHooks(debugMode: false);
      expect(
        release.handlePlatform(
          StateError('SYNTHETIC_PRIVATE_EARLY'),
          StackTrace.current,
        ),
        isTrue,
      );
      expect(await dir.list().isEmpty, isTrue);

      // This is the call main makes only after its exclusive owner is acquired.
      fail = false;
      await LocalDiagnostics.initialize();
      LocalDiagnostics.capture(
        DiagnosticContext.preferencesSave,
        const FileSystemException(
          'SYNTHETIC_PRIVATE_MESSAGE',
          '/private/training.json',
        ),
        StackTrace.fromString('SYNTHETIC_PRIVATE_STACK'),
      );
      final copied = await LocalDiagnostics.read();
      expect(copied, contains('preferencesSave FileSystemException'));
      expect(copied, isNot(contains('SYNTHETIC_PRIVATE')));
      expect(copied, isNot(contains('/private/training')));
      final path = File('${dir.path}/logs/errors.log');
      expect(await path.length(), lessThanOrEqualTo(256 * 1024));
    },
  );
}
