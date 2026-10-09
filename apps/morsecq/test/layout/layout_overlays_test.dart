// Layout sweep, part two: dialogs, sheets, menus, snackbars, dropdowns,
// error and result states, each re-asserted in every configuration of the
// sweep (see layout_harness.dart).
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/i18n/l10n_extension.dart';
import 'package:morsecq/training/material_store.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/receive_session_start.dart';
import 'package:morsecq/training/send_session.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/common/feedback.dart';
import 'package:morsecq/ui/learn/comprehension/listening_comprehension_screen.dart';
import 'package:morsecq/ui/learn/drill_session_guard.dart';
import 'package:morsecq/ui/learn/goals/goal_route_screen.dart';
import 'package:morsecq/ui/learn/learn_glossary.dart';
import 'package:morsecq/ui/learn/materials/material_editor_screen.dart';
import 'package:morsecq/ui/learn/materials/material_export_sheet.dart';
import 'package:morsecq/ui/learn/materials/materials_screen.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';
import 'package:morsecq/ui/learn/placement/placement_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_summary_view.dart';
import 'package:morsecq/ui/learn/receive/drill_picker_sheet.dart';
import 'package:morsecq/ui/learn/receive/guided_practice_sheet.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/send/send_result_view.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_recall_screen.dart';
import 'package:morsecq/ui/listen/listen_screen.dart';
import 'package:morsecq/ui/listen/workbench/recording_files.dart';
import 'package:morsecq/ui/listen/workbench/workbench_library_sheet.dart';
import 'package:morsecq/ui/listen/workbench/workbench_screen.dart';
import 'package:morsecq/ui/reference/playback_settings_sheet.dart';
import 'package:morsecq/ui/reference/reference_catalog.dart';
import 'package:morsecq/ui/reference/reference_playback_settings.dart';
import 'package:morsecq/ui/reference/reference_screen.dart';
import 'package:morsecq/ui/stats/char_grid.dart';
import 'package:morsecq/ui/stats/stats_model.dart';
import 'package:morsecq/ui/telegraph/telegraph_interpret_sheet.dart';
import 'package:morsecq/ui/tools/band_tool.dart';
import 'package:morsecq/ui/tools/grid_locator_tool.dart';
import 'package:morsecq/ui/tools/radio_tools_screen.dart';

import '../../integration_test/support/shot_harness.dart'
    show kShotLocales, parseShotLocale;
import '../learn/helpers/fake_playback.dart';
import '../learn/helpers/test_controller.dart';
import '../listen/fake_pcm_source.dart';
import '../listen/workbench_support.dart';
import '../reference/reference_test_support.dart' show FakeReferencePlayer;
import 'layout_harness.dart';

typedef _Shown = Finder Function(WidgetTester tester);

typedef _Scene = ({
  SceneBuilder build,
  ScreenPrepare prepare,
  _Shown shown,
  Future<void> Function(TestTraining t)? setup,
  ScreenPrepare? refresh,
  TrainingSettings settings,
});

_Scene _scene(
  SceneBuilder build,
  ScreenPrepare prepare,
  _Shown shown, {
  Future<void> Function(TestTraining t)? setup,
  ScreenPrepare? refresh,
  TrainingSettings settings = kShortSettings,
}) => (
  build: build,
  prepare: prepare,
  shown: shown,
  setup: setup,
  refresh: refresh,
  settings: settings,
);

Finder _modal(WidgetTester tester) => find.byWidgetPredicate(
  (w) => w is Dialog || w is BottomSheet || w is SnackBar,
);
Finder _dialog(WidgetTester tester) => find.byType(Dialog);
Finder _sheet(WidgetTester tester) => find.byType(BottomSheet);
Finder _menu(WidgetTester tester) =>
    find.byWidgetPredicate((w) => w is PopupMenuItem);

int _dropdownItems() =>
    find.byWidgetPredicate((w) => w is DropdownMenuItem).evaluate().length;

/// A dropdown scene: Flutter closes an open dropdown whenever the window
/// metrics change, so the menu is opened again for every configuration.
/// The open menu builds its items a second time next to the closed
/// button's copy, which is how "open" is recognised.
_Scene _dropdown(SceneBuilder build, Key selector) {
  var closed = 0;
  bool isOpen() => _dropdownItems() > closed;
  Future<void> open(WidgetTester tester) async {
    if (isOpen()) return;
    await _tap(tester, find.byKey(selector));
  }

  return _scene(
    build,
    (tester, t, p) async {
      await _runIo(tester);
      closed = _dropdownItems();
      await open(tester);
    },
    (tester) => isOpen()
        ? find.byKey(selector)
        : find.byKey(const ValueKey('dropdown closed')),
    refresh: (tester, t, p) => open(tester),
  );
}

final _host = GlobalKey();

/// An empty page that dialogs and sheets open over.
Widget _hostPage(TestTraining t, FakeLearnPlaybackFactory p) =>
    Scaffold(key: _host, body: const SizedBox.expand());

/// Opens an overlay over [_hostPage] without awaiting its result.
_Scene _overlay(
  void Function(BuildContext context, TestTraining t) open, {
  Future<void> Function(TestTraining t)? setup,
}) => _scene(
  _hostPage,
  (tester, t, p) async {
    open(_host.currentContext!, t);
    await _settleUi(tester);
  },
  _modal,
  setup: setup,
);

Future<void> _settleUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await _settleUi(tester);
}

S _s(WidgetTester tester) => tester.element(find.byType(Scaffold).first).s;

TrainingMaterial _material(TestTraining t) => MaterialImport.create(
  id: 'm1',
  title: 'Contest exchange practice',
  kind: MaterialKind.text,
  text: 'CQ TEST DE K1ABC K1ABC TEST 5NN 001',
  analysis: MaterialImport.analyze(
    'CQ TEST DE K1ABC K1ABC TEST 5NN 001',
    MaterialKind.text,
  ),
  now: t.controller.now(),
);

Future<void> _seedMaterial(TestTraining t) =>
    t.controller.upsertMaterial(_material(t));

Widget _materials(TestTraining t, FakeLearnPlaybackFactory p) =>
    MaterialsScreen(controller: t.controller, playback: p);

Future<void> _openMaterialMenu(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
  await _tap(tester, find.byTooltip(_s(tester).materialsActions));
}

final _workbenchRoot = Directory.systemTemp.createTempSync('morsecq_wb_');

Widget _workbench(TestTraining t, FakeLearnPlaybackFactory p) =>
    WorkbenchScreen(
      picker: FakePicker(
        PickedRecording(name: 'sos.wav', bytes: cwWav('SOS TEST')),
      ),
      player: FakeClipPlayer(),
      profileRoot: () async => _workbenchRoot.path,
      training: () async => t.controller,
    );

/// Lets file IO and decoding finish; the waveform never settles.
Future<void> _runIo(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  });
  await _settleUi(tester);
}

Future<void> _importRecording(WidgetTester tester) async {
  await _runIo(tester);
  await tester.tap(find.byKey(const ValueKey('workbench-import-empty')));
  await _runIo(tester);
}

/// A QSO answered through all three stages of the short exchange.
QsoSession _finishedQso() {
  final session = QsoSession.start(
    scenario: QsoScenario.shortExchange,
    seed: 11,
    local: const QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS'),
    characterWpm: 20,
    effectiveWpm: 20,
  );
  session.submit('a', '${session.remote.callsign} DE BD1XYZ K');
  session.submit('b', 'UR RST 599 K');
  session.submit('c', 'TU 73 <SK>');
  return session;
}

Future<void> _enter(WidgetTester tester, Key key, String text) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.enterText(find.byKey(key), text);
  await _settleUi(tester);
}

final _scenes = <String, _Scene>{
  'glossary': _overlay((c, t) => unawaited(showLearnGlossary(c))),
  'leave-drill': _overlay((c, t) => unawaited(confirmLeaveDrill(c))),
  'confirm': _overlay(
    (c, t) => unawaited(
      confirm(
        c,
        title: c.s.offlineClearData,
        body: c.s.offlineClearDataBody,
        confirmLabel: c.s.offlineClearData,
      ),
    ),
  ),
  // Snackbars expire, so it is shown again before every configuration.
  'snack': _scene(
    _hostPage,
    (tester, t, p) async {},
    (tester) => find.byType(SnackBar),
    refresh: (tester, t, p) async {
      final context = _host.currentContext!;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      showSnack(context, context.s.learnReplayAssistedNote);
      await _settleUi(tester);
    },
  ),
  'drill-picker': _overlay(
    (c, t) => unawaited(showDrillPickerSheet(c, ReceiveDrillKind.values)),
  ),
  'guided-practice': _overlay(
    (c, t) => unawaited(showGuidedPracticeSheet(c, GuidedLevel.short)),
  ),
  'telegraph-interpret': _overlay(
    (c, t) => unawaited(showTelegraphInterpretation(c, '0022 0948 CQ')),
  ),
  'mnemonic': _scene(
    (t, p) => ReferenceScreen(playerFactory: FakeReferencePlayer().create),
    (tester, t, p) async {
      await tester.pump(const Duration(milliseconds: 300));
      await tester.longPress(
        find.text(ReferenceCatalog.alphabet.first.label).first,
      );
      await _settleUi(tester);
    },
    _dialog,
  ),
  'playback-settings': _overlay(
    (c, t) => unawaited(
      showReferencePlaybackSettings(c, ReferencePlaybackSettings()),
    ),
  ),
  'char-detail': _overlay(
    (c, t) => unawaited(
      CharDetailSheet.show(
        c,
        StatsSnapshot.from(t.controller.progress, now: kTestNow),
        'K',
      ),
    ),
  ),
  'save-recording': _overlay(
    (c, t) => unawaited(showSaveSelectionDialog(c, 'SOS TEST')),
  ),
  'material-export': _overlay(
    (c, t) => unawaited(
      showMaterialExportSheet(
        c,
        controller: t.controller,
        material: _material(t),
      ),
    ),
    setup: _seedMaterial,
  ),
  'materials-list': _scene(
    _materials,
    (tester, t, p) => tester.pump(const Duration(milliseconds: 300)),
    (tester) => find.text('Contest exchange practice'),
    setup: _seedMaterial,
  ),
  'materials-menu': _scene(
    _materials,
    (tester, t, p) => _openMaterialMenu(tester),
    _menu,
    setup: _seedMaterial,
  ),
  'materials-delete': _scene(
    _materials,
    (tester, t, p) async {
      await _openMaterialMenu(tester);
      await _tap(tester, find.text(_s(tester).materialsDelete).last);
    },
    _dialog,
    setup: _seedMaterial,
  ),
  'materials-practise': _scene(
    _materials,
    (tester, t, p) async {
      await _openMaterialMenu(tester);
      await _tap(tester, find.text(_s(tester).materialsPractise).last);
    },
    _dialog,
    setup: _seedMaterial,
  ),
  'material-editor-problems': _scene(
    (t, p) => MaterialEditorScreen(
      controller: t.controller,
      initialText: 'CQ 你好 TEST ¿? <BT> K',
    ),
    (tester, t, p) => tester.pump(const Duration(milliseconds: 400)),
    (tester) => find.byType(MaterialPreview),
  ),
  'listen-settings': _scene(
    (t, p) => ListenScreen(source: FakePcmSource()),
    (tester, t, p) => _tap(tester, find.byTooltip(_s(tester).listenSettings)),
    _sheet,
  ),
  'workbench-imported': _scene(
    _workbench,
    (tester, t, p) => _importRecording(tester),
    (tester) => find.byKey(const ValueKey('workbench-waveform')),
  ),
  'workbench-library': _scene(_workbench, (tester, t, p) async {
    await _importRecording(tester);
    // Save the clip first so the library lists something.
    await _tap(tester, find.byKey(const ValueKey('workbench-save')));
    await tester.enterText(
      find.byKey(const ValueKey('workbench-save-title')),
      'Contest pile-up with long title',
    );
    await _tap(tester, find.byKey(const ValueKey('workbench-save-confirm')));
    await _runIo(tester);
    await _tap(tester, find.byTooltip(_s(tester).workbenchLibrary));
    await _runIo(tester);
  }, (tester) => find.text('Contest pile-up with long title')),
  'send-result': _scene(
    (t, p) => SendPracticeScreen(
      controller: t.controller,
      playback: p,
      session: SendSession(
        target: 'K',
        timing: const MorseTiming(wpm: 20),
        now: () => t.clock.now,
        lesson: 1,
      ),
    ),
    (tester, t, p) async {
      final key = find.byType(StraightKeyButton);
      final gesture = await tester.startGesture(tester.getCenter(key));
      await tester.pump();
      p.clock.advance(const Duration(milliseconds: 180));
      await tester.pump();
      await gesture.up();
      p.clock.advance(const Duration(milliseconds: 400));
      await tester.pump();
      await _tap(tester, find.text(_s(tester).learnDone));
    },
    (tester) => find.byType(SendResultView),
    settings: const TrainingSettings(keyerMode: KeyerMode.straight),
  ),
  'placement-result': _scene(
    (t, p) => PlacementScreen(controller: t.controller, playback: p),
    (tester, t, p) async {
      await _tap(tester, find.text(_s(tester).placementStart));
      await tester.pump(const Duration(seconds: 30));
      await _tap(tester, find.text(_s(tester).placementStop));
    },
    (tester) => find.byKey(const ValueKey('placement-adopt')),
  ),
  'qso-summary': _scene(
    (t, p) => QsoScreen(
      controller: t.controller,
      playback: p,
      session: _finishedQso(),
    ),
    (tester, t, p) => tester.pump(const Duration(seconds: 2)),
    (tester) => find.byType(QsoSummaryView),
  ),
  'telegraph-recall-answered': _scene(
    (t, p) => TelegraphRecallScreen(
      controller: t.controller,
      codebook: TelegraphCodebook.taiwan,
      random: Random(1),
    ),
    (tester, t, p) async {
      await tester.pump(const Duration(milliseconds: 300));
      await _tap(tester, find.byKey(const Key('telegraph-reveal')));
    },
    (tester) => find.byKey(const Key('telegraph-answer')),
  ),
  'first-lesson-sounds': _scene(
    (t, p) => FirstLessonScreen(controller: t.controller, playback: p),
    (tester, t, p) =>
        _tap(tester, find.byKey(const ValueKey('first-lesson-heard'))),
    (tester) => find.byKey(const ValueKey('first-lesson-continue-worked')),
  ),
  'comprehension-heard': _scene(
    (t, p) =>
        ListeningComprehensionScreen(controller: t.controller, playback: p),
    (tester, t, p) async {
      await _runIo(tester);
      await _tap(tester, find.byKey(const ValueKey('comprehension-play')));
      for (var i = 0; i < 20; i++) {
        p.clock.advance(const Duration(seconds: 5));
        await tester.pump(const Duration(seconds: 5));
      }
    },
    (tester) => find.byKey(const ValueKey('comprehension-submit')),
  ),
  'comprehension-mode-menu': _dropdown(
    (t, p) =>
        ListeningComprehensionScreen(controller: t.controller, playback: p),
    const ValueKey('comprehension-mode'),
  ),
  'goal-menu': _dropdown(
    (t, p) => GoalRouteScreen(controller: t.controller, playback: p),
    const ValueKey('goal-selector'),
  ),
  'grid-invalid': _scene(
    (t, p) => RadioTool.grid.build(),
    (tester, t, p) async {
      await _enter(tester, GridLocatorTool.mineKey, 'ZZ99XX');
      await _enter(tester, GridLocatorTool.latitudeKey, '123.4');
    },
    (tester) => find.text(_s(tester).toolsGridInvalidLocator),
  ),
  'band-invalid': _scene(
    (t, p) => RadioTool.bands.build(),
    (tester, t, p) => _enter(tester, BandTool.frequencyKey, '0'),
    (tester) => find.text(_s(tester).toolsBandsInvalidFrequency),
  ),
};

/// Overlays that need the whole app (providers the shell installs).
final _appScenes =
    <String, ({ScenePrepare open, Finder Function(WidgetTester) shown})>{
      'language-dialog': (
        open: (tester) => openFromMe(tester, Icons.language),
        shown: _dialog,
      ),
      'clear-data': (
        open: (tester) => openFromMe(tester, Icons.delete_outline),
        shown: _dialog,
      ),
    };

void main() {
  setUpAll(loadSweepFonts);
  tearDownAll(() => _workbenchRoot.deleteSync(recursive: true));

  for (final tag in kShotLocales) {
    final locale = parseShotLocale(tag);
    for (final MapEntry(key: name, value: scene) in _scenes.entries) {
      testWidgets('$name fits every window in $tag', (tester) async {
        final problems = await sweepScreen(
          tester,
          locale,
          scene.build,
          prepare: scene.prepare,
          setup: scene.setup,
          settings: scene.settings,
          shown: scene.shown,
          refresh: scene.refresh,
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
}
