import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq/diagnostics/local_diagnostics.dart';
import 'package:morsecq/desktop/desktop_platform.dart';
import 'package:morsecq/desktop/desktop_diagnostics.dart';
import 'package:morsecq/desktop/testing/in_memory_key_value_store.dart';
import 'package:morsecq/di/app_preferences.dart';
import 'package:morsecq/i18n/key_value_store.dart' as preferences;

final class _FailingStore implements preferences.KeyValueStore {
  @override
  String? getString(String key) => null;
  @override
  Future<void> setString(String key, String value) async {
    throw const FileSystemException(
      'SYNTHETIC_PRIVATE_MESSAGE',
      '/private/training.json',
    );
  }

  @override
  Future<void> remove(String key) async =>
      throw StateError('SYNTHETIC_PRIVATE_MESSAGE');
}

final class _UntrustedStack implements StackTrace {
  bool read = false;
  @override
  String toString() {
    read = true;
    throw StateError('SYNTHETIC_PRIVATE_STACK');
  }
}

void main() {
  test('product-policy CI selects actual release-mode constants', () {
    if (const bool.fromEnvironment('MORSECQ_TEST_PRODUCT_POLICY')) {
      expect(kReleaseMode, isTrue);
      expect(kDebugMode, isFalse);
    }
  });

  test(
    'the actual preference-save catch obeys the compiled console policy',
    () async {
      final previous = debugPrint;
      final messages = <String>[];
      final prefs = AppPreferences(_FailingStore());
      addTearDown(() {
        prefs.dispose();
        debugPrint = previous;
      });
      debugPrint = (message, {wrapWidth}) {
        if (message != null) messages.add(message);
      };
      prefs.reference.wpm = 22;
      await expectLater(prefs.flush(), throwsStateError);
      if (kDebugMode) {
        expect(messages.join('\n'), contains('SYNTHETIC_PRIVATE_MESSAGE'));
        expect(messages.join('\n'), contains('/private/training.json'));
      } else {
        expect(messages, isEmpty);
      }
    },
  );

  test(
    'shared audio and wake failures never print raw errors in product mode',
    () async {
      final previous = debugPrint;
      final messages = <String>[];
      addTearDown(() => debugPrint = previous);
      debugPrint = (message, {wrapWidth}) {
        if (message != null) messages.add(message);
      };
      const error = FileSystemException(
        'SYNTHETIC_PRIVATE_MESSAGE',
        '/private/training.json',
      );
      await PlatformAudioSessionApi(
        platformOverride: TargetPlatform.iOS,
        openSession: () => throw error,
      ).configureForPlayback();
      await SerializedScreenWake((_) async => throw error).keepOn(true);
      if (kDebugMode) {
        expect(messages.length, 2);
        expect(
          messages.every(
            (message) => message.contains('SYNTHETIC_PRIVATE_MESSAGE'),
          ),
          isTrue,
        );
      } else {
        expect(messages, isEmpty);
      }
    },
  );

  test('default hooks select the compiled build policy', () {
    var previousCalls = 0;
    final hooks = DiagnosticErrorHooks(
      record: (_, _, _) {},
      previousFlutter: (_) => previousCalls++,
      previousPlatform: (_, _) {
        previousCalls++;
        return false;
      },
    );
    hooks.handleFlutter(
      FlutterErrorDetails(exception: StateError('SYNTHETIC_PRIVATE')),
    );
    expect(
      hooks.handlePlatform(StateError('SYNTHETIC_PRIVATE'), StackTrace.current),
      !kDebugMode,
    );
    expect(previousCalls, kDebugMode ? 2 : 0);
  });

  test(
    'untrusted stack contents never enter current or rotated diagnostics',
    () async {
      final dir = await Directory.systemTemp.createTemp('diagnostics_privacy_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/errors.log');
      final log = LocalDiagnostics(file, maximumBytes: 256);
      for (var i = 0; i < 10; i++) {
        log.record(
          StateError('SYNTHETIC_PRIVATE_MESSAGE'),
          StackTrace.fromString(
            '#0 SYNTHETIC_PRIVATE_STACK (file:///private/training/private.json:12:3)',
          ),
        );
      }
      for (final entry in [file, File('${file.path}.previous')]) {
        final evidence = await entry.readAsString();
        expect(evidence, isNot(contains('SYNTHETIC_PRIVATE')));
        expect(evidence, isNot(contains('/private/training')));
        expect(await entry.length(), lessThanOrEqualTo(256));
      }
      final copied = await log.readEvidence();
      expect(copied, isNot(contains('SYNTHETIC_PRIVATE')));
      expect(copied, isNot(contains('/private/training')));
    },
  );

  test('an absent desktop sink cannot silently re-enable raw debugPrint', () {
    final previous = debugPrint;
    final messages = <String>[];
    addTearDown(() => debugPrint = previous);
    debugPrint = (message, {wrapWidth}) {
      if (message != null) messages.add(message);
    };
    DesktopShellConfig(
      store: InMemoryKeyValueStore(),
    ).logger('SYNTHETIC_PRIVATE_MESSAGE /private/training/private.json');
    expect(messages, isEmpty);
  });

  test(
    'caught errors and explicit shell sinks are verbose only in debug mode',
    () {
      final previous = debugPrint;
      final messages = <String>[];
      final shellMessages = <String>[];
      addTearDown(() => debugPrint = previous);
      debugPrint = (message, {wrapWidth}) {
        if (message != null) messages.add(message);
      };
      const error = FileSystemException(
        'SYNTHETIC_PRIVATE_MESSAGE',
        '/private/training.json',
      );
      LocalDiagnostics.report(DiagnosticContext.preferencesSave, error);
      DesktopShellConfig(
        store: InMemoryKeyValueStore(),
        log: shellMessages.add,
      ).diagnose(DiagnosticContext.desktopRead, error);
      if (kDebugMode) {
        expect(messages.join('\n'), contains('SYNTHETIC_PRIVATE_MESSAGE'));
        expect(shellMessages.join('\n'), contains('SYNTHETIC_PRIVATE_MESSAGE'));
      } else {
        expect(messages, isEmpty);
        expect(shellMessages, isEmpty);
      }
    },
  );

  test(
    'release hooks do not forward raw details or request stderr fallback',
    () async {
      final dir = await Directory.systemTemp.createTemp('diagnostics_hooks_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/errors.log');
      final log = LocalDiagnostics(file);
      var previousCalls = 0;
      final contexts = <DiagnosticContext>[];
      final hooks = DiagnosticErrorHooks(
        debugMode: false,
        previousFlutter: (_) => previousCalls++,
        previousPlatform: (_, _) {
          previousCalls++;
          return false;
        },
        record: (context, error, stack) {
          contexts.add(context);
          log.record(error, stack, context: context);
        },
      );
      final stack = _UntrustedStack();
      const error = FileSystemException(
        'SYNTHETIC_PRIVATE_MESSAGE',
        '/private/training.json',
      );
      hooks.handleFlutter(FlutterErrorDetails(exception: error, stack: stack));
      expect(hooks.handlePlatform(error, stack), isTrue);
      expect(previousCalls, 0);
      expect(stack.read, isFalse);
      expect(contexts, [
        DiagnosticContext.framework,
        DiagnosticContext.runtime,
      ]);
      final evidence = await file.readAsString();
      expect(evidence, contains('FileSystemException'));
      expect(
        evidence,
        contains('package:morsecq/diagnostics/local_diagnostics.dart:'),
      );
      expect(evidence, isNot(contains('SYNTHETIC_PRIVATE')));
      expect(evidence, isNot(contains('/private/training')));
    },
  );

  test('debug hooks preserve the framework and platform error observers', () {
    var flutterCalls = 0;
    var platformCalls = 0;
    final hooks = DiagnosticErrorHooks(
      debugMode: true,
      record: (_, _, _) {},
      previousFlutter: (_) => flutterCalls++,
      previousPlatform: (_, _) {
        platformCalls++;
        return false;
      },
    );
    hooks.handleFlutter(FlutterErrorDetails(exception: StateError('debug')));
    expect(
      hooks.handlePlatform(StateError('debug'), StackTrace.current),
      isFalse,
    );
    expect(flutterCalls, 1);
    expect(platformCalls, 1);
  });

  test(
    'legacy raw diagnostics are replaced rather than rotated or exported',
    () async {
      final dir = await Directory.systemTemp.createTemp('diagnostics_legacy_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/errors.log');
      final previous = File('${file.path}.previous');
      await file.writeAsString(
        'SYNTHETIC_PRIVATE_LEGACY /private/training.json',
      );
      await previous.writeAsString(
        'SYNTHETIC_PRIVATE_ROTATED /private/training.json',
      );
      final log = LocalDiagnostics(file);
      expect(await log.readEvidence(), isNot(contains('SYNTHETIC_PRIVATE')));
      log.record(StateError('SYNTHETIC_PRIVATE_NEW'), null);
      expect(await file.readAsString(), isNot(contains('SYNTHETIC_PRIVATE')));
      expect(await previous.exists(), isFalse);
    },
  );

  test(
    'VM-format parser keeps only code coordinates and numeric AOT metadata',
    () {
      final frames = LocalDiagnostics.codeFramesForTesting('''
#0 PRIVATE_FUNCTION (package:morsecq/main.dart:30:4)
#1 PRIVATE_FUNCTION (file:///private/training.json:1:2)
#2 PRIVATE_FUNCTION (https://example.invalid/private?token=PRIVATE_TOKEN:1:2)
#3 PRIVATE_FUNCTION (package:unknown/PRIVATE_CONTENT.dart:1:2)
isolate_dso_base: 0x1234 PRIVATE_TRAILING_TEXT
  #00 abs 00001234 virt 00000012 PRIVATE_SYMBOL_TEXT
#4 PRIVATE_FUNCTION (dart:async/future_impl.dart:1:2)
PRIVATE_TEXT
''');
      expect(frames, [
        'package:morsecq/main.dart:30:4',
        'isolate_dso_base=0x1234',
        'pc=0x00001234 virtual=0x00000012',
        'dart:async/future_impl.dart:1:2',
      ]);
      expect(frames.join('\n'), isNot(contains('PRIVATE')));
    },
  );
}
