import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/backup_exclusion.dart';
import 'package:path/path.dart' as p;

/// Identity data must stay out of OS backups (it holds the Tox identity).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('iOS/macOS: the app-support morsecq folder is marked excluded',
      () async {
    final Directory support = await Directory.systemTemp.createTemp('as_');
    addTearDown(() => support.delete(recursive: true));
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
    const exclusion = MethodChannel('icu.agentx.morsecq/backup_exclusion');
    final List<MethodCall> calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(pathProvider, (_) async => support.path);
    messenger.setMockMethodCallHandler(exclusion, (call) async {
      calls.add(call);
      return true;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(pathProvider, null);
      messenger.setMockMethodCallHandler(exclusion, null);
    });
    await BackupExclusion.excludeAppData();
    if (!(Platform.isIOS || Platform.isMacOS)) {
      expect(calls, isEmpty);
      return;
    }
    expect(calls.single.method, 'exclude');
    expect(
      (calls.single.arguments as Map)['path'],
      p.join(support.path, 'morsecq'),
    );
    expect(Directory(p.join(support.path, 'morsecq')).existsSync(), isTrue);
  });

  test('the Runner apps register the exclusion channel', () {
    for (final String file in [
      'ios/Runner/AppDelegate.swift',
      'macos/Runner/MainFlutterWindow.swift',
    ]) {
      final String source = File(file).readAsStringSync();
      expect(source, contains('"icu.agentx.morsecq/backup_exclusion"'));
      expect(source, contains('isExcludedFromBackup = true'));
      expect(source, contains('BackupExclusion.register('));
    }
  });

  test('Android opts out of cloud backup and device transfer entirely', () {
    final String manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:dataExtractionRules="@xml/data_extraction_rules"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    const domains = [
      'root', 'file', 'database', 'sharedpref', 'external',
      'device_root', 'device_file', 'device_database', 'device_sharedpref',
    ];
    final String rules = File(
      'android/app/src/main/res/xml/data_extraction_rules.xml',
    ).readAsStringSync();
    for (final String section in ['cloud-backup', 'device-transfer']) {
      final String body = rules.substring(
        rules.indexOf('<$section>'),
        rules.indexOf('</$section>'),
      );
      for (final String d in domains) {
        expect(body, contains('<exclude domain="$d" path="." />'), reason: '$section/$d');
      }
    }
    final String legacy = File(
      'android/app/src/main/res/xml/backup_rules.xml',
    ).readAsStringSync();
    for (final String d in domains) {
      expect(legacy, contains('<exclude domain="$d" path="." />'));
    }
  });
}
