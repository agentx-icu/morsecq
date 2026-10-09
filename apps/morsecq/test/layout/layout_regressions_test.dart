// Back-port of the DitMesh layout review (2026-10-09): one fast case per
// defect that the shared screens had here too. Each failed before its fix.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/ui/common/app_bar_title.dart';
import 'package:morsecq/ui/common/feedback.dart';
import 'package:morsecq/ui/learn/goal_ring.dart';
import 'package:morsecq/ui/learn/settings/training_settings_screen.dart';
import 'package:morsecq/ui/listen/listen_screen.dart';
import 'package:morsecq/ui/reference/playback_settings_sheet.dart';
import 'package:morsecq/ui/reference/reference_playback_settings.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq/ui/stats/char_grid.dart';
import 'package:morsecq/ui/theme.dart';

import '../learn/helpers/fake_playback.dart';
import '../learn/helpers/test_controller.dart';
import '../listen/fake_pcm_source.dart';
import '../support/test_app.dart' show settle;

/// Logical [size] with [padding] (notch, bars), [keyboard] and [textScale].
void _view(
  WidgetTester tester,
  Size size, {
  FakeViewPadding padding = FakeViewPadding.zero,
  double keyboard = 0,
  double textScale = 1,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = padding;
  tester.view.viewPadding = padding;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      locale: locale,
      theme: MorsecqTheme.light(),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
}

/// A page whose button runs [open] (a sheet, a dialog, a route).
Widget _opener(void Function(BuildContext context) open) => Scaffold(
  body: Builder(
    builder: (context) => Center(
      child: TextButton(
        onPressed: () => open(context),
        child: const Text('open'),
      ),
    ),
  ),
);

/// [text] is drawn whole and inside [outer]; on one line unless it [wraps].
void _expectTextFits(
  WidgetTester tester,
  Finder text,
  Rect outer, {
  bool wraps = false,
}) {
  final Rect r = tester.getRect(text);
  expect(
    r.left >= outer.left - 0.5 &&
        r.top >= outer.top - 0.5 &&
        r.right <= outer.right + 0.5 &&
        r.bottom <= outer.bottom + 0.5,
    isTrue,
    reason: '$r inside $outer',
  );
  final RenderParagraph p = tester.renderObject<RenderParagraph>(text);
  if (!wraps) {
    expect(
      p.size.width,
      greaterThanOrEqualTo(p.getMaxIntrinsicWidth(double.infinity) - 0.5),
      reason: 'cut sideways',
    );
  }
  expect(
    p.size.height,
    greaterThanOrEqualTo(p.getMaxIntrinsicHeight(p.size.width) - 0.5),
    reason: 'cut at the bottom',
  );
}

const Size _landscape = Size(844, 390);
const FakeViewPadding _notch = FakeViewPadding(left: 47, right: 47, bottom: 21);

void main() {
  group('pages and dialogs', () {
    testWidgets('a pushed page keeps its rows clear of the landscape notch', (
      tester,
    ) async {
      _view(tester, _landscape, padding: _notch);
      await _pump(
        tester,
        _opener(
          (c) => Navigator.of(c).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('page')),
                body: ListView(
                  children: const <Widget>[ListTile(title: Text('row'))],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final Rect row = tester.getRect(find.byType(ListTile));
      expect(row.left, greaterThanOrEqualTo(47));
      expect(row.right, lessThanOrEqualTo(_landscape.width - 47));
    });

    testWidgets('a dialog stops at 560 px on an ultrawide monitor', (
      tester,
    ) async {
      _view(tester, const Size(3440, 1440));
      await _pump(
        tester,
        _opener(
          (c) => confirm(
            c,
            title: 'Delete',
            body: 'word ' * 200,
            confirmLabel: 'Delete',
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final Finder surface = find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Material),
          )
          .first;
      expect(tester.getSize(surface).width, lessThanOrEqualTo(560));
    });

    testWidgets('a long confirmation scrolls on a landscape phone', (
      tester,
    ) async {
      _view(tester, const Size(667, 375), padding: _notch, textScale: 2);
      await _pump(
        tester,
        _opener(
          (c) => confirm(
            c,
            title: 'Delete',
            body: 'word ' * 120,
            confirmLabel: 'Delete',
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Scrolls instead of silently clipping the body.
      final Finder body = find.textContaining('word word');
      await tester.ensureVisible(body);
      await tester.pumpAndSettle();
      final RenderParagraph p = tester.renderObject<RenderParagraph>(body);
      expect(
        p.size.height,
        greaterThanOrEqualTo(p.getMaxIntrinsicHeight(p.size.width) - 0.5),
      );
    });

    for (final double scale in <double>[1, 2]) {
      testWidgets('reference playback settings scroll on a landscape phone '
          'at ${scale}x', (tester) async {
        final settings = ReferencePlaybackSettings(farnsworthWpm: 8);
        addTearDown(settings.dispose);
        _view(tester, const Size(667, 375), textScale: scale);
        await _pump(
          tester,
          _opener((c) => showReferencePlaybackSettings(c, settings)),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('German bottom-bar labels stay above the home indicator at '
        '2x on a 320 px phone', (tester) async {
      const FakeViewPadding bars = FakeViewPadding(top: 24, bottom: 34);
      _view(tester, const Size(320, 568), padding: bars, textScale: 2);
      final root = Directory.systemTemp.createTempSync('morsecq_layout_');
      addTearDown(() => root.deleteSync(recursive: true));
      await tester.pumpWidget(
        MorsecqApp(
          learningStore: LocalLearningStore(root: () async => root.path),
          localeStore: InMemoryKeyValueStore({
            LocaleController.storageKey: 'de',
          }),
        ),
      );
      await settle(tester);
      final S de = lookupS(const Locale('de'));
      for (final ShellDestination d in kShellDestinations) {
        final Finder label = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(d.label(de)),
        );
        expect(tester.getRect(label).bottom, lessThanOrEqualTo(568 - 34));
      }
    });
  });

  group('app bar', () {
    for (final (int actions, bool centred) in <(int, bool)>[
      (0, true),
      (2, false),
    ]) {
      testWidgets('a wrapped app-bar title on iOS with $actions actions sits '
          '${centred ? 'centred' : 'at the start'}, like a one-line one', (
        tester,
      ) async {
        const String title = 'Ausstehende und fehlgeschlagene Nachrichten';
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Scaffold(
              appBar: AppBar(
                title: const AppBarTitle(title),
                actions: <Widget>[
                  for (var i = 0; i < actions; i++)
                    IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                ],
              ),
            ),
          ),
        );
        final Rect text = tester.getRect(find.text(title));
        if (centred) {
          expect((text.center.dx - 160).abs(), lessThan(2));
        } else {
          expect(text.left, lessThan(NavigationToolbar.kMiddleSpacing + 2));
        }
      });
    }
  });

  group('training widgets', () {
    testWidgets('the goal ring keeps "100%" inside at 3x', (tester) async {
      _view(tester, const Size(390, 844), textScale: 3);
      await _pump(
        tester,
        const Scaffold(
          body: Center(
            child: GoalRing(fraction: 1, size: 72, child: Text('100%')),
          ),
        ),
      );
      _expectTextFits(
        tester,
        find.text('100%'),
        tester.getRect(find.byType(GoalRing)),
      );
    });

    for (final (String char, double scale) in <(String, double)>[
      ('K', 2),
      ('<BT>', 3),
    ]) {
      testWidgets('a character cell keeps $char whole at ${scale}x', (
        tester,
      ) async {
        _view(tester, const Size(390, 844), textScale: scale);
        await _pump(
          tester,
          Scaffold(
            body: Center(
              child: CharCell(
                char: char,
                stats: const CharStats(attempts: 12, correct: 10),
                learned: true,
              ),
            ),
          ),
        );
        _expectTextFits(
          tester,
          find.text(char),
          tester.getRect(find.byType(CharCell)),
        );
      });
    }

    testWidgets('training settings fit a 320 px phone at 3x', (tester) async {
      final TestTraining t = await TestTraining.create();
      addTearDown(t.controller.dispose);
      _view(tester, const Size(320, 568), textScale: 3);
      await _pump(
        tester,
        TrainingSettingsScreen(
          controller: t.controller,
          playback: FakeLearnPlaybackFactory(),
        ),
      );
      // Every tile, not only the ones a lazy list builds on the first screen.
      for (var i = 0; i < 12; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the listen tone row fits a 320 px phone in Russian at 3x', (
      tester,
    ) async {
      _view(tester, const Size(320, 568), textScale: 3);
      await _pump(
        tester,
        ListenScreen(source: FakePcmSource()),
        locale: const Locale('ru'),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
