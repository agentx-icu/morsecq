// Opt-in real-widget PNG evidence; the Visual matrix workflow runs this.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/app_settings.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/pages/reference_page.dart';
import '../../integration_test/support/seed_data.dart';
import '../../integration_test/support/shot_harness.dart'
    show kShotLocales, parseShotLocale;
import '../support/test_app.dart' show settle;

const _render = bool.fromEnvironment('MORSECQ_RENDER_MATRIX');
const _output = String.fromEnvironment('MORSECQ_MATRIX_DIR');
const _font = String.fromEnvironment('MORSECQ_MATRIX_FONT');
const _mono = String.fromEnvironment('MORSECQ_MATRIX_MONO_FONT');
const _serif = String.fromEnvironment('MORSECQ_MATRIX_SERIF_FONT');

void main() {
  testWidgets('render ten languages and five styles on phone and desktop', (
    tester,
  ) async {
    expect(_output, isNotEmpty);
    expect(_font, isNotEmpty);
    Future<void> font(String family, String path) async {
      if (path.isEmpty) return;
      final bytes = await tester.runAsync(() => File(path).readAsBytes());
      await (FontLoader(
        family,
      )..addFont(Future.value(ByteData.sublistView(bytes!)))).load();
    }

    await font('Roboto', _font);
    await font('Ahem', _font);
    await font('monospace', _mono);
    await font('serif', _serif);
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final profiles =
        <({String locale, UiStyle style, ThemeMode mode, bool phone})>{
          for (final locale in kShotLocales)
            for (final phone in [false, true])
              (
                locale: locale,
                style: UiStyle.modern,
                mode: ThemeMode.light,
                phone: phone,
              ),
          for (final style in UiStyle.values)
            for (final mode in [ThemeMode.light, ThemeMode.dark])
              for (final phone in [false, true])
                (locale: 'en', style: style, mode: mode, phone: phone),
        };
    expect(profiles.length, 38);
    final frames = <String>[];
    final shadows = debugDisableShadows;
    debugDisableShadows = false;
    try {
      for (final profile in profiles) {
        final device = profile.phone ? 'phone' : 'desktop';
        final name =
            '${profile.locale}/${profile.style.name}/${profile.mode.name}/$device';
        tester.view.physicalSize = profile.phone
            ? const Size(430, 932)
            : const Size(1280, 800);
        final boundary = GlobalKey();
        final dir = await tester.runAsync(
          () => Directory.systemTemp.createTemp('morsecq_visual_'),
        );
        try {
          await tester.runAsync(
            () => seedTrainingProgress(
              dir!.path,
              anchor: seedAnchor(DateTime.now()),
            ),
          );
          await tester.pumpWidget(
            RepaintBoundary(
              key: boundary,
              child: MorsecqApp(
                key: ValueKey(name),
                learningStore: LocalLearningStore(root: () async => dir!.path),
                localeStore: InMemoryKeyValueStore({
                  LocaleController.storageKey: profile.locale,
                  AppSettings.storageKey: jsonEncode({
                    'style': profile.style.name,
                    'mode': profile.mode.name,
                  }),
                }),
              ),
            ),
          );
          await settle(tester);
          final s = lookupS(parseShotLocale(profile.locale));
          Future<void> capture(String scene) async {
            expect(tester.takeException(), isNull, reason: '$name/$scene');
            await tester.runAsync(() async {
              final render =
                  boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final pixels = await render.toImage(pixelRatio: 1);
              try {
                final png = await pixels.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                final file = File('$_output/$name/$scene.png');
                await file.parent.create(recursive: true);
                await file.writeAsBytes(png!.buffer.asUint8List());
                expect(await file.length(), greaterThan(8192));
              } finally {
                pixels.dispose();
              }
            });
            frames.add('$name/$scene.png');
          }

          expect(find.byType(LearnHome), findsOneWidget);
          expect(find.text(s.learnContinueLesson), findsOneWidget);
          await capture('learn_home');
          final nav = find.byWidgetPredicate(
            (widget) => widget is NavigationRail || widget is NavigationBar,
          );
          await tester.tap(
            find.descendant(
              of: nav,
              matching: find.byIcon(kShellDestinations[1].icon),
            ),
          );
          await settle(tester);
          expect(find.byType(ReferencePage), findsOneWidget);
          expect(find.byTooltip(s.referenceTranslatorTitle), findsWidgets);
          await capture('reference');
        } finally {
          await tester.pumpWidget(const SizedBox());
          await settle(tester);
          await tester.runAsync(() => dir!.delete(recursive: true));
        }
      }
    } finally {
      debugDisableShadows = shadows;
    }
    expect(frames, hasLength(76));
    await tester.runAsync(
      () => File('$_output/manifest.json').writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert({'profiles': profiles.length, 'frames': frames}),
      ),
    );
  }, skip: !_render);
}
