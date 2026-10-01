import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/app_settings.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/appearance/appearance_page.dart';
import 'package:morsecq/ui/appearance/style_preview.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/theme.dart';
import 'package:provider/provider.dart';

import 'app_settings_test.dart' show FailingStore;

Future<void> pumpAppearance(
  WidgetTester tester,
  AppSettings settings, {
  Size size = const Size(430, 932),
  bool startOnHome = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: settings,
      child: AnimatedBuilder(
        animation: settings,
        builder: (context, _) => MaterialApp(
          theme: MorsecqTheme.light(style: settings.style),
          darkTheme: MorsecqTheme.dark(style: settings.style),
          themeMode: settings.themeMode,
          themeAnimationDuration: Duration.zero,
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: startOnHome ? const _DraftHome() : const AppearancePage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('preview and brightness are staged until Apply', (tester) async {
    final store = InMemoryKeyValueStore();
    final settings = AppSettings(backendLabel: 'test', store: store);
    addTearDown(settings.dispose);
    await pumpAppearance(tester, settings);
    await tester.tap(find.byKey(const ValueKey('style-radio')));
    await tester.ensureVisible(find.byKey(const ValueKey('mode-dark')));
    await tester.tap(find.byKey(const ValueKey('mode-dark')));
    await tester.pumpAndSettle();
    final preview = tester.widget<StylePreview>(
      find.byKey(const ValueKey('appearance-preview')),
    );
    expect(preview.style, UiStyle.radio);
    expect(preview.brightness, Brightness.dark);
    expect(settings.style, UiStyle.classic);
    expect(settings.themeMode, ThemeMode.system);
    expect(store.getString(AppSettings.storageKey), isNull);
    await tester.tap(find.byKey(const ValueKey('appearance-apply')));
    await tester.pumpAndSettle();
    expect(settings.style, UiStyle.radio);
    expect(settings.themeMode, ThemeMode.dark);
    expect(find.byType(AppearancePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Restore defaults is staged and write failure is visible', (
    tester,
  ) async {
    final settings = AppSettings(backendLabel: 'test', store: FailingStore());
    addTearDown(settings.dispose);
    await pumpAppearance(tester, settings);
    await tester.tap(find.byKey(const ValueKey('style-cartoon')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore defaults'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<StylePreview>(
            find.byKey(const ValueKey('appearance-preview')),
          )
          .style,
      UiStyle.classic,
    );
    await tester.tap(find.byKey(const ValueKey('style-radio')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('appearance-apply')));
    await tester.pumpAndSettle();
    expect(settings.style, UiStyle.classic);
    expect(find.text('Could not save appearance. Try again.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'discarding preview and applying later preserve underlying draft',
    (tester) async {
      final settings = AppSettings(backendLabel: 'test');
      addTearDown(settings.dispose);
      await pumpAppearance(tester, settings, startOnHome: true);
      await tester.enterText(find.byType(TextField), 'CQ CQ unfinished draft');
      await tester.tap(find.text('Open appearance'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('style-modern')));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(settings.style, UiStyle.classic);
      expect(find.text('CQ CQ unfinished draft'), findsOneWidget);
      await tester.tap(find.text('Open appearance'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('style-paper')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('appearance-apply')));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(settings.style, UiStyle.paper);
      expect(find.text('CQ CQ unfinished draft'), findsOneWidget);
    },
  );

  for (final size in [const Size(320, 740), const Size(1280, 800)]) {
    testWidgets('chooser remains usable at $size with large text', (
      tester,
    ) async {
      final settings = AppSettings(backendLabel: 'test');
      addTearDown(settings.dispose);
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpAppearance(tester, settings, size: size);
      for (final style in UiStyle.values) {
        final card = find.byKey(ValueKey('style-${style.name}'));
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(
        tester.getRect(find.byKey(const ValueKey('appearance-apply'))).bottom,
        lessThanOrEqualTo(size.height),
      );
    });
  }
}

class _DraftHome extends StatelessWidget {
  const _DraftHome();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        const TextField(),
        TextButton(
          onPressed: () => AppearancePage.open(context),
          child: const Text('Open appearance'),
        ),
      ],
    ),
  );
}
