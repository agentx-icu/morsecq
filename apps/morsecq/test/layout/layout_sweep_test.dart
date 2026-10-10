// Layout sweep: every screen at phone, rotated phone, tablet and desktop
// sizes (with phone notches and home indicators), in all ten languages and
// at text scales up to iOS's largest accessibility size. The window is
// resized under a live screen, as rotation or a desktop drag does. Any
// overflow, ellipsised or shrunken-unreadable text, text under a system
// inset or a FAB at the end of scrolling, or an app-bar title outside its
// bar fails. Needs MORSECQ_MATRIX_FONT (see layout_harness.dart); the Layout
// workflow passes Noto. Dialogs, sheets and result states:
// layout_overlays_test.dart.
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/receive_session_start.dart';
import 'package:morsecq/ui/appearance/appearance_page.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/keying/key_setup_page.dart';
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
import 'package:morsecq/ui/learn/receive/receive_summary_view.dart';
import 'package:morsecq/ui/learn/receive/round_result_view.dart';
import 'package:morsecq/ui/learn/review/review_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/settings/training_settings_screen.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_practice_screen.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_recall_screen.dart';
import 'package:morsecq/ui/listen/listen_screen.dart';
import 'package:morsecq/ui/listen/workbench/workbench_screen.dart';
import 'package:morsecq/ui/pages/offline_me_page.dart';
import 'package:morsecq/ui/reference/reference_screen.dart';
import 'package:morsecq/ui/reference/translator_screen.dart';
import 'package:morsecq/ui/stats/stats_screen.dart';
import 'package:morsecq/ui/tools/radio_tools_screen.dart';

import '../learn/helpers/fake_playback.dart';
import '../learn/helpers/test_controller.dart';
import '../../integration_test/support/shot_harness.dart'
    show kShotLocales, parseShotLocale;
import '../listen/fake_pcm_source.dart';
import '../listen/workbench_support.dart';
import '../reference/reference_test_support.dart' show FakeReferencePlayer;
import 'layout_harness.dart';

typedef _Scene = ({
  SceneBuilder build,
  ScreenPrepare? prepare,
  Finder Function(WidgetTester tester)? shown,
});

_Scene _screen(
  SceneBuilder build, [
  ScreenPrepare? prepare,
  Finder Function(WidgetTester tester)? shown,
]) => (build: build, prepare: prepare, shown: shown);

ReceiveDrillScreen _receive(TestTraining t, FakeLearnPlaybackFactory p) =>
    ReceiveDrillScreen(
      controller: t.controller,
      playback: p,
      session: t.controller.startLessonSession(),
    );

/// Types an answer and checks it: the receive screen's result phase.
Future<void> _answerRound(
  WidgetTester tester, [
  TestTraining? t,
  FakeLearnPlaybackFactory? p,
]) async {
  await tester.pump(const Duration(seconds: 30));
  await tester.enterText(find.byType(TextField), 'KM');
  await tester.tap(find.byType(FilledButton).last);
  await tester.pump(const Duration(seconds: 1));
}

/// Finishes the one-round session: the receive summary.
Future<void> _finishSession(
  WidgetTester tester,
  TestTraining t,
  FakeLearnPlaybackFactory p,
) async {
  await _answerRound(tester);
  await tester.tap(find.byType(FilledButton).last);
  await tester.pump(const Duration(seconds: 1));
}

final _scenes = <String, _Scene>{
  'receive': _screen(_receive),
  'receive-result': _screen(
    _receive,
    _answerRound,
    (tester) => find.byType(RoundResultView),
  ),
  'receive-summary': _screen(
    _receive,
    _finishSession,
    (tester) => find.byType(ReceiveSummaryView),
  ),
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
final _appScenes =
    <String, ({ScenePrepare? open, Finder Function(WidgetTester) shown})>{
      'shell': (
        open: null,
        shown: (t) => find.byWidgetPredicate(
          (w) => w is NavigationBar || w is NavigationRail,
        ),
      ),
      'shell-reference': (
        open: (tester) => openTab(tester, 1),
        shown: (t) => find.byType(ReferenceScreen),
      ),
      'shell-me': (
        open: (tester) => openTab(tester, 2),
        shown: (t) => find.byType(OfflineMePage),
      ),
      'appearance': (
        open: (tester) => openFromMe(tester, Icons.palette_outlined),
        shown: (t) => find.byType(AppearancePage),
      ),
      'keys': (
        open: (tester) => openFromMe(tester, Icons.keyboard_outlined),
        shown: (t) => find.byType(KeySetupPage),
      ),
      'me-training-defaults': (
        open: (tester) => openFromMe(tester, Icons.tune),
        shown: (t) => find.byType(TrainingSettingsScreen),
      ),
    };

/// Locales the iOS-platform pass runs in (Latin + CJK line breaking).
const _platformLocales = ['en', 'de', 'zh'];

void main() {
  setUpAll(loadSweepFonts);

  group('harness checks', () {
    Future<Set<String>> check(WidgetTester tester, Widget body) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: body)));
      final found = <String>{};
      scanTruncated(const Size(390, 844), found);
      scanVisible(const Size(390, 844), [
        const Rect.fromLTWH(0, 810, 390, 34),
      ], found);
      return found;
    }

    testWidgets('flags text a FittedBox shrank below the floor', (
      tester,
    ) async {
      final found = await check(
        tester,
        const Center(
          child: SizedBox(
            width: 40,
            child: FittedBox(child: Text('A very long label indeed')),
          ),
        ),
      );
      expect(found.single, startsWith('shrunk to'));
    });

    testWidgets('accepts text a FittedBox shrank only slightly', (
      tester,
    ) async {
      final found = await check(
        tester,
        const Center(
          child: SizedBox(width: 60, child: FittedBox(child: Text('Label!'))),
        ),
      );
      expect(found, isEmpty);
    });

    testWidgets('flags ellipsised text and text under the home indicator', (
      tester,
    ) async {
      final found = await check(
        tester,
        const Column(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                'Truncated words',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Spacer(),
            Text('Bottom line'),
          ],
        ),
      );
      expect(found, contains('truncated "Truncated words"'));
      expect(found, contains('under a system inset "Bottom line"'));
    });

    testWidgets('ignores text scrolled out of view and hidden hints', (
      tester,
    ) async {
      final found = await check(
        tester,
        Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [SizedBox(height: 2000), Text('Scrolled away')],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Opacity(
              opacity: 0,
              child: SizedBox(
                width: 30,
                child: Text(
                  'Invisible truncated hint',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
      expect(found, isEmpty);
    });
  }, skip: kSweepSkip);

  for (final tag in kShotLocales) {
    final locale = parseShotLocale(tag);
    for (final MapEntry(key: name, value: scene) in _scenes.entries) {
      testWidgets('$name fits every window in $tag', (tester) async {
        final problems = await sweepScreen(
          tester,
          locale,
          scene.build,
          prepare: scene.prepare,
          shown: scene.shown,
        );
        expect(problems, isEmpty, reason: problems.join('\n'));
      }, skip: kSweepSkip);
    }

    for (final MapEntry(key: name, value: app) in _appScenes.entries) {
      testWidgets('$name fits every window in $tag', (tester) async {
        final problems = await sweepApp(tester, tag, app.open, app.shown);
        expect(problems, isEmpty, reason: problems.join('\n'));
      }, skip: kSweepSkip);
    }
  }

  // Material on iOS uses Cupertino typography and platform behaviour.
  for (final tag in _platformLocales) {
    final locale = parseShotLocale(tag);
    for (final MapEntry(key: name, value: scene) in _scenes.entries) {
      testWidgets(
        '$name fits every window in $tag on iOS in paper style',
        (tester) async {
          final problems = await sweepScreen(
            tester,
            locale,
            scene.build,
            prepare: scene.prepare,
            shown: scene.shown,
            // Paper's serif headings, on iOS typography.
            style: UiStyle.paper,
          );
          expect(problems, isEmpty, reason: problems.join('\n'));
        },
        skip: kSweepSkip,
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );
    }
  }
}
