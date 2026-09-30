import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/l10n_extension.dart';
import 'package:morsecq/i18n/language_settings_tile.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:provider/provider.dart';

/// Pumps the tile inside a MaterialApp wired exactly the way main.dart is
/// expected to be: delegates + supportedLocales from `S`, `locale` from the
/// controller.
Future<LocaleController> pumpTile(
  WidgetTester tester, {
  InMemoryKeyValueStore? store,
}) async {
  final controller = LocaleController(store ?? InMemoryKeyValueStore());
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    ChangeNotifierProvider<LocaleController>.value(
      value: controller,
      child: Builder(
        builder: (context) => MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: context.watch<LocaleController>().locale,
          home: const Scaffold(body: LanguageSettingsTile()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  testWidgets('shows the system-default choice in English by default', (
    tester,
  ) async {
    await pumpTile(tester);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
  });

  testWidgets('choosing 简体中文 switches the app locale and persists it', (
    tester,
  ) async {
    final store = InMemoryKeyValueStore();
    final controller = await pumpTile(tester, store: store);

    await tester.tap(find.byType(LanguageSettingsTile));
    await tester.pumpAndSettle();
    expect(find.byType(SimpleDialog), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();

    expect(controller.locale, const Locale('zh'));
    expect(store.getString(LocaleController.storageKey), 'zh');
    expect(find.byType(SimpleDialog), findsNothing, reason: 'dialog closed');
    // The tile itself re-rendered in Chinese.
    expect(find.text('语言'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
  });

  testWidgets('restores a persisted choice and can return to system', (
    tester,
  ) async {
    final store = InMemoryKeyValueStore({
      LocaleController.storageKey: 'zh_CN',
    });
    final controller = await pumpTile(tester, store: store);
    expect(find.text('语言'), findsOneWidget);

    await tester.tap(find.byType(LanguageSettingsTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('跟随系统'));
    await tester.pumpAndSettle();

    expect(controller.locale, isNull);
    expect(store.getString(LocaleController.storageKey), isNull);
    // Test binding's system locale is en_US, so the tile reads English again.
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('context.s resolves the same instance as S.of', (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Builder(
          builder: (context) {
            captured = context;
            return Text(context.s.appName);
          },
        ),
      ),
    );
    expect(find.text('morsecq'), findsOneWidget);
    expect(identical(captured.s, S.of(captured)), isTrue);
  });
}
