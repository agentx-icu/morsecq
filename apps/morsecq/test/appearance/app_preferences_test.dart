import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/app_preferences.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/lifecycle/background_task_api.dart';
import 'package:morsecq/ui/listen/listen_settings.dart';

/// In-memory store whose writes can be made to fail.
final class _FlakyStore implements KeyValueStore {
  _FlakyStore([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;
  bool failing = false;
  int writes = 0;

  @override
  String? getString(String key) => values[key];

  @override
  Future<void> setString(String key, String value) async {
    writes++;
    if (failing) throw StateError('disk full');
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    if (failing) throw StateError('disk full');
    values.remove(key);
  }
}

Map<String, Object?> _json(KeyValueStore store, String key) =>
    jsonDecode(store.getString(key)!) as Map<String, Object?>;

void main() {
  group('AppPreferences', () {
    test('an empty store starts from the documented defaults', () {
      final prefs = AppPreferences(InMemoryKeyValueStore());
      addTearDown(prefs.dispose);
      expect(prefs.reference.wpm, 15);
      expect(prefs.reference.farnsworthWpm, isNull);
      expect(prefs.reference.toneHz, 700);
      expect(prefs.listen.settings, const ListenSettings());
    });

    test('changes are saved and restored by the next start', () async {
      final store = InMemoryKeyValueStore();
      final first = AppPreferences(store);
      first.reference
        ..wpm = 22
        ..farnsworthWpm = 11
        ..toneHz = 650;
      first.listen.update(
        const ListenSettings(
          blockSize: 512,
          minElementMs: 20,
          autoTune: false,
          manualHz: 820,
        ),
      );
      await first.flush();
      first.dispose();

      expect(_json(store, 'reference.playback'), {
        'wpm': 22.0,
        'farnsworthWpm': 11.0,
        'toneHz': 650.0,
      });
      final again = AppPreferences(store);
      addTearDown(again.dispose);
      expect(again.reference.wpm, 22);
      expect(again.reference.farnsworthWpm, 11);
      expect(again.reference.toneHz, 650);
      expect(
        again.listen.settings,
        const ListenSettings(
          blockSize: 512,
          minElementMs: 20,
          autoTune: false,
          manualHz: 820,
        ),
      );
    });

    test('out-of-range or mistyped values fall back or are clamped', () {
      final prefs = AppPreferences(
        InMemoryKeyValueStore({
          'reference.playback': jsonEncode({
            'wpm': 90,
            'farnsworthWpm': 60,
            'toneHz': 'loud',
          }),
          'listen.decoder': jsonEncode({
            'blockSize': 300,
            'minElementMs': 1,
            'autoTune': 'yes',
            'manualHz': 5000,
          }),
        }),
      );
      addTearDown(prefs.dispose);
      expect(prefs.reference.wpm, 40);
      expect(
        prefs.reference.farnsworthWpm,
        40,
        reason: 'spacing never exceeds the character speed',
      );
      expect(prefs.reference.toneHz, 700);
      final listen = prefs.listen.settings;
      expect(listen.blockSize, 256, reason: 'only the offered block sizes');
      expect(listen.minElementMs, ListenSettings.minElementMinMs);
      expect(listen.autoTune, isTrue);
      expect(listen.manualHz, ListenSettings.maxHz);
    });

    test('unreadable documents fall back to defaults', () {
      for (final raw in ['{not json', '[1, 2]', '"text"']) {
        final prefs = AppPreferences(
          InMemoryKeyValueStore({
            'reference.playback': raw,
            'listen.decoder': raw,
          }),
        );
        expect(prefs.reference.wpm, 15, reason: raw);
        expect(prefs.listen.settings, const ListenSettings(), reason: raw);
        prefs.dispose();
      }
    });

    test('a failed save is reported by flush and retried later', () async {
      final store = _FlakyStore();
      final prefs = AppPreferences(store);
      addTearDown(prefs.dispose);
      store.failing = true;
      prefs.reference.wpm = 25;
      await expectLater(prefs.flush(), throwsStateError);

      // A save to another key while still failing does not clear the error.
      prefs.listen.update(const ListenSettings(blockSize: 128));
      await expectLater(prefs.flush(), throwsStateError);

      store.failing = false;
      await prefs.flush();
      expect(_json(store, 'reference.playback')['wpm'], 25.0);
      expect(_json(store, 'listen.decoder')['blockSize'], 128);
      final writes = store.writes;
      await prefs.flush();
      expect(store.writes, writes, reason: 'nothing left to retry');
    });

    test('the newest value wins when saves overlap', () async {
      final store = InMemoryKeyValueStore();
      final prefs = AppPreferences(store);
      addTearDown(prefs.dispose);
      for (final wpm in [16.0, 18.0, 30.0]) {
        prefs.reference.wpm = wpm;
      }
      await prefs.flush();
      expect(_json(store, 'reference.playback')['wpm'], 30.0);
    });
  });

  group('BackgroundTaskApi', () {
    const channel = MethodChannel(MethodChannelBackgroundTaskApi.channelName);

    test('platforms without a grace period ask for nothing', () async {
      const api = NoopBackgroundTaskApi();
      expect(await api.begin(), isNull);
      await api.end(1);
      expect(BackgroundTaskApi.forPlatform(), isA<NoopBackgroundTaskApi>());
    });

    test('iOS uses the method channel', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      expect(
        BackgroundTaskApi.forPlatform(),
        isA<MethodChannelBackgroundTaskApi>(),
      );
    });

    testWidgets('begin returns the native token and end passes it back', (
      tester,
    ) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        return call.method == 'begin' ? 42 : null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      final api = MethodChannelBackgroundTaskApi();
      final token = await api.begin();
      expect(token, 42);
      await api.end(token!);
      expect(calls.map((c) => (c.method, c.arguments)), [
        ('begin', null),
        ('end', 42),
      ]);
    });

    testWidgets('a missing or failing native side never throws', (
      tester,
    ) async {
      final api = MethodChannelBackgroundTaskApi();
      for (final Object error in [
        MissingPluginException('older native build'),
        PlatformException(code: 'refused'),
      ]) {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (call) async => throw error,
        );
        expect(await api.begin(), isNull, reason: '$error');
        await api.end(7);
      }
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
    });
  });
}
