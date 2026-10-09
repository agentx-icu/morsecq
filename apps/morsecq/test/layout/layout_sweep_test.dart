// Layout sweep: every screen at phone, rotated phone, tablet and desktop
// sizes, in all ten languages and at 1.0/1.3/2.0 text scale. The window is
// resized under a live screen (as rotation or a desktop drag does); any
// overflow or ellipsised text fails. It measures with a real multilingual
// font (the test font's square glyphs make Latin text ~1.8x too wide), so it
// runs only with MORSECQ_MATRIX_FONT; the Layout workflow passes Noto.
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/receive_session_start.dart';
import 'package:morsecq/ui/common/app_bar_title.dart';
import 'package:morsecq/ui/learn/comprehension/listening_comprehension_screen.dart';
import 'package:morsecq/ui/learn/goals/goal_route_screen.dart';
import 'package:morsecq/ui/learn/materials/material_editor_screen.dart';
import 'package:morsecq/ui/learn/materials/materials_screen.dart';
import 'package:morsecq/ui/learn/mistakes/mistake_notebook_screen.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';
import 'package:morsecq/ui/learn/placement/placement_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_protocol_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_setup_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/review/review_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/settings/training_settings_screen.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_practice_screen.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_recall_screen.dart';
import 'package:morsecq/ui/listen/listen_screen.dart';
import 'package:morsecq/ui/listen/workbench/workbench_screen.dart';
import 'package:morsecq/ui/reference/reference_screen.dart';
import 'package:morsecq/ui/reference/translator_screen.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq/ui/stats/stats_screen.dart';
import 'package:morsecq/ui/tools/radio_tools_screen.dart';

import '../learn/helpers/fake_playback.dart';
import '../learn/helpers/test_controller.dart';
import '../../integration_test/support/seed_data.dart';
import '../../integration_test/support/shot_harness.dart'
    show kShotLocales, parseShotLocale;
import '../listen/fake_pcm_source.dart';
import '../listen/workbench_support.dart';
import '../reference/reference_test_support.dart' show FakeReferencePlayer;
import '../support/test_app.dart' show settle;

const _font = String.fromEnvironment('MORSECQ_MATRIX_FONT');
const _mono = String.fromEnvironment('MORSECQ_MATRIX_MONO_FONT');

/// Logical window sizes: small/regular phones in both orientations, tablets
/// in both orientations, the desktop minimum window and full desktops.
const _sizes = <Size>[
  Size(320, 568),
  Size(360, 640),
  Size(390, 844),
  Size(568, 320),
  Size(844, 390),
  Size(768, 1024),
  Size(1024, 768),
  Size(1280, 800),
  Size(1920, 1080),
];

const _scales = <double>[1.0, 1.3, 2.0];

typedef _Scene = ({
  Widget Function(TestTraining t, FakeLearnPlaybackFactory p) build,
  Future<void> Function(WidgetTester tester)? prepare,
});

_Scene _screen(
  Widget Function(TestTraining t, FakeLearnPlaybackFactory p) build, [
  Future<void> Function(WidgetTester tester)? prepare,
]) => (build: build, prepare: prepare);

ReceiveDrillScreen _receive(TestTraining t, FakeLearnPlaybackFactory p) =>
    ReceiveDrillScreen(
      controller: t.controller,
      playback: p,
      session: t.controller.startLessonSession(),
    );

/// Types an answer and checks it: the receive screen's result phase.
Future<void> _answerRound(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 30));
  await tester.enterText(find.byType(TextField), 'KM');
  await tester.tap(find.byType(FilledButton).last);
  await tester.pump(const Duration(seconds: 1));
}

/// Finishes the one-round session: the receive summary.
Future<void> _finishSession(WidgetTester tester) async {
  await _answerRound(tester);
  await tester.tap(find.byType(FilledButton).last);
  await tester.pump(const Duration(seconds: 1));
}

final _scenes = <String, _Scene>{
  'receive': _screen(_receive),
  'receive-result': _screen(_receive, _answerRound),
  'receive-summary': _screen(_receive, _finishSession),
  'send': _screen(
    (t, p) => SendPracticeScreen(controller: t.controller, playback: p),
  ),
  'first-lesson': _screen(
    (t, p) => FirstLessonScreen(controller: t.controller, playback: p),
  ),
  'placement': _screen(
    (t, p) => PlacementScreen(controller: t.controller, playback: p),
  ),
  'materials': _screen(
    (t, p) => MaterialsScreen(controller: t.controller, playback: p),
  ),
  'material-editor': _screen(
    (t, p) => MaterialEditorScreen(
      controller: t.controller,
      initialText: 'CQ CQ DE K1ABC K1ABC PSE K',
    ),
  ),
  'review': _screen(
    (t, p) => ReviewScreen(controller: t.controller, playback: p),
  ),
  'training-settings': _screen(
    (t, p) => TrainingSettingsScreen(controller: t.controller, playback: p),
  ),
  'qso-setup': _screen(
    (t, p) => QsoSetupScreen(controller: t.controller, playback: p),
  ),
  'qso-protocol': _screen(
    (t, p) => QsoProtocolScreen(controller: t.controller),
  ),
  'telegraph': _screen(
    (t, p) => TelegraphPracticeScreen(controller: t.controller, playback: p),
  ),
  'stats': _screen(
    (t, p) => StatsScreen(
      loadProgress: () async => t.controller.progress,
      now: kTestNow,
    ),
  ),
  'qso': _screen(
    (t, p) => QsoScreen(
      controller: t.controller,
      playback: p,
      session: QsoSession.start(
        scenario: QsoScenario.respondToCq,
        seed: 11,
        local: const QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS'),
        characterWpm: 20,
        effectiveWpm: 20,
      ),
    ),
  ),
  'telegraph-recall': _screen(
    (t, p) => TelegraphRecallScreen(
      controller: t.controller,
      codebook: TelegraphCodebook.taiwan,
      random: Random(1),
    ),
  ),
  'comprehension': _screen(
    (t, p) =>
        ListeningComprehensionScreen(controller: t.controller, playback: p),
  ),
  'goals': _screen(
    (t, p) => GoalRouteScreen(controller: t.controller, playback: p),
  ),
  'mistakes': _screen(
    (t, p) => MistakeNotebookScreen(controller: t.controller, playback: p),
  ),
  'radio-tools': _screen((t, p) => const RadioToolsScreen()),
  for (final tool in RadioTool.values)
    'tool-${tool.name}': _screen((t, p) => tool.build()),
  'reference': _screen(
    (t, p) => ReferenceScreen(playerFactory: FakeReferencePlayer().create),
  ),
  'translator': _screen(
    (t, p) => TranslatorScreen(
      playerFactory: FakeReferencePlayer().create,
      initialText: 'CQ DE MORSECQ',
    ),
  ),
  'listen': _screen((t, p) => ListenScreen(source: FakePcmSource())),
  'workbench': _screen(
    (t, p) => WorkbenchScreen(
      picker: FakePicker(null),
      player: FakeClipPlayer(),
      profileRoot: () async => Directory.systemTemp.path,
      training: () async => t.controller,
    ),
  ),
};

/// Whole-app scenes: the shell with all three destinations laid out (the
/// rail and bottom bar swap as the window crosses the breakpoint), and the
/// pages opened from Me.
final _appScenes = <String, Future<void> Function(WidgetTester tester)?>{
  'shell': null,
  'appearance': (tester) => _openFromMe(tester, Icons.palette_outlined),
  'keys': (tester) => _openFromMe(tester, Icons.keyboard_outlined),
  'me-training-defaults': (tester) => _openFromMe(tester, Icons.tune),
};

Future<void> _openFromMe(WidgetTester tester, IconData icon) async {
  await tester.tap(find.byIcon(kShellDestinations.last.icon).last);
  await settle(tester);
  final tile = find.ancestor(
    of: find.byIcon(icon),
    matching: find.byType(ListTile),
  );
  await tester.ensureVisible(tile.first);
  await tester.tap(tile.first);
  await settle(tester);
}

String _clip(String s) => s.length > 48 ? '${s.substring(0, 48)}…' : s;

void _scan(RenderObject node, Set<String> out) {
  if (node is RenderParagraph && node.didExceedMaxLines) {
    out.add('truncated "${_clip(node.text.toPlainText())}"');
  }
  node.visitChildren((child) => _scan(child, out));
}

/// App bar titles drawn taller than the toolbar or outside the bar (the
/// paragraph itself may not exceed its lines while the bar clips it).
Iterable<String> _titlesOutsideToolbar(WidgetTester tester) sync* {
  final titles = find.byType(AppBarTitle, skipOffstage: false);
  for (final title in titles.evaluate()) {
    final text = find.descendant(
      of: find.byWidget(title.widget, skipOffstage: false),
      matching: find.byType(Text, skipOffstage: false),
    );
    final bar = find.ancestor(
      of: find.byWidget(title.widget, skipOffstage: false),
      matching: find.byType(AppBar, skipOffstage: false),
    );
    final rect = tester.getRect(text.first);
    final barRect = tester.getRect(bar.first);
    if (rect.height > kToolbarHeight + 0.5 ||
        rect.top < barRect.top - 0.5 ||
        rect.bottom > barRect.bottom + 0.5) {
      yield 'title "${(title.widget as AppBarTitle).text}" outside the bar';
    }
  }
}

Future<Set<String>> _sweep(
  WidgetTester tester,
  Future<void> Function() pumpRoot,
) async {
  final problems = <String>{};
  var where = 'open';
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final first = details.exceptionAsString().split('\n').first;
    final source = RegExp(
      r'lib/[\w/]+\.dart:\d+',
    ).firstMatch(details.toString())?.group(0);
    problems.add('$where: $first ${source ?? ''}');
  };
  try {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpRoot();
    for (final scale in _scales) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      for (final size in _sizes) {
        where = '${size.width.toInt()}x${size.height.toInt()}@$scale';
        tester.view.physicalSize = size;
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        final found = <String>{..._titlesOutsideToolbar(tester)};
        _scan(tester.binding.rootElement!.renderObject!, found);
        problems.addAll(found.map((p) => '$where: $p'));
      }
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  } finally {
    FlutterError.onError = previous;
  }
  return problems;
}

void main() {
  setUpAll(() async {
    if (_font.isEmpty) return; // Every test below is skipped.
    Future<void> load(String family, String path) async {
      final bytes = ByteData.sublistView(File(path).readAsBytesSync());
      await (FontLoader(family)..addFont(Future.value(bytes))).load();
    }

    await load('Roboto', _font);
    await load('monospace', _mono.isEmpty ? _font : _mono);
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  for (final tag in kShotLocales) {
    final locale = parseShotLocale(tag);
    for (final MapEntry(key: name, value: scene) in _scenes.entries) {
      testWidgets('$name fits every window in $tag', (tester) async {
        final t = await TestTraining.create(
          progress: TrainerProgress(currentLesson: 8, dailyGoalChars: 30),
          settings: kShortSettings,
        );
        addTearDown(t.controller.dispose);
        final problems = await _sweep(tester, () async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: S.localizationsDelegates,
              supportedLocales: S.supportedLocales,
              locale: locale,
              home: scene.build(t, FakeLearnPlaybackFactory()),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          await scene.prepare?.call(tester);
        });
        expect(problems, isEmpty, reason: problems.join('\n'));
      }, skip: _font.isEmpty);
    }

    for (final MapEntry(key: name, value: open) in _appScenes.entries) {
      testWidgets('$name fits every window in $tag', (tester) async {
        final dir = await tester.runAsync(
          () => Directory.systemTemp.createTemp('morsecq_layout_'),
        );
        addTearDown(() => dir!.deleteSync(recursive: true));
        await tester.runAsync(
          () => seedTrainingProgress(
            dir!.path,
            anchor: seedAnchor(DateTime.now()),
          ),
        );
        final problems = await _sweep(tester, () async {
          await tester.pumpWidget(
            MorsecqApp(
              learningStore: LocalLearningStore(root: () async => dir!.path),
              localeStore: InMemoryKeyValueStore({
                LocaleController.storageKey: tag,
              }),
            ),
          );
          await settle(tester);
          await open?.call(tester);
        });
        expect(problems, isEmpty, reason: problems.join('\n'));
      }, skip: _font.isEmpty);
    }
  }
}
