import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';

void main() {
  group('LocaleController', () {
    test('defaults to following the system when nothing is stored', () {
      final controller = LocaleController(InMemoryKeyValueStore());
      expect(controller.locale, isNull);
      expect(controller.followsSystem, isTrue);
    });

    test('setLocale notifies and persists the canonical name', () async {
      final store = InMemoryKeyValueStore();
      final controller = LocaleController(store);
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.setLocale(const Locale('zh'));

      expect(controller.locale, const Locale('zh'));
      expect(store.getString(LocaleController.storageKey), 'zh');
      expect(notifications, 1);
    });

    test('a new controller restores the persisted choice', () async {
      final store = InMemoryKeyValueStore();
      await LocaleController(store).setLocale(const Locale('en'));

      final restored = LocaleController(store);
      expect(restored.locale, const Locale('en'));
      expect(restored.followsSystem, isFalse);
    });

    test('returning to system default removes the stored key', () async {
      final store = InMemoryKeyValueStore({
        LocaleController.storageKey: 'zh_CN',
      });
      final controller = LocaleController(store);
      expect(controller.locale, const Locale('zh'));

      await controller.setLocale(null);

      expect(controller.locale, isNull);
      expect(store.getString(LocaleController.storageKey), isNull);
    });

    test('setting the same locale twice notifies once', () async {
      final controller = LocaleController(InMemoryKeyValueStore());
      var notifications = 0;
      controller.addListener(() => notifications++);
      await controller.setLocale(const Locale('zh'));
      await controller.setLocale(const Locale('zh', 'CN'));
      expect(notifications, 1);
    });

    test('an unsupported locale is ignored', () async {
      final store = InMemoryKeyValueStore();
      final controller = LocaleController(store);
      await controller.setLocale(const Locale('fr'));
      expect(controller.locale, isNull);
      expect(store.getString(LocaleController.storageKey), isNull);
    });

    test('a corrupt stored value falls back to system default', () {
      final controller = LocaleController(
        InMemoryKeyValueStore({LocaleController.storageKey: 'klingon'}),
      );
      expect(controller.locale, isNull);
    });

    test('localeName / parseLocaleName round-trip and tolerate variants', () {
      expect(LocaleController.localeName(const Locale('zh')), 'zh');
      expect(
        LocaleController.localeName(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ),
        'zh_Hant',
      );
      expect(LocaleController.localeName(const Locale('en')), 'en');
      for (final name in ['zh', 'zh_CN', 'zh-Hans', 'zh_Hans_CN', 'ZH']) {
        expect(
          LocaleController.parseLocaleName(name),
          const Locale('zh'),
          reason: name,
        );
      }
      expect(LocaleController.parseLocaleName('en_US'), const Locale('en'));
      expect(LocaleController.parseLocaleName(''), isNull);
      expect(LocaleController.parseLocaleName(null), isNull);
    });

    test('supportedLocales mirrors the generated S class', () {
      expect(
        LocaleController.supportedLocales.map((l) => l.languageCode),
        containsAll(['en', 'zh']),
      );
    });
  });

  group('JsonFileKeyValueStore', () {
    late Directory dir;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('morsecq_i18n_store_');
    });

    tearDown(() => dir.deleteSync(recursive: true));

    test('persists across instances and survives a missing file', () async {
      final file = File('${dir.path}/prefs/i18n.json');
      final store = await JsonFileKeyValueStore.open(file);
      expect(store.getString('k'), isNull);

      await store.setString('k', 'v');
      final reopened = await JsonFileKeyValueStore.open(file);
      expect(reopened.getString('k'), 'v');

      await reopened.remove('k');
      final again = await JsonFileKeyValueStore.open(file);
      expect(again.getString('k'), isNull);
    });

    test('treats a corrupt file as empty instead of throwing', () async {
      final file = File('${dir.path}/i18n.json')..writeAsStringSync('{not json');
      final store = await JsonFileKeyValueStore.open(file);
      expect(store.getString('anything'), isNull);
    });
  });
}
