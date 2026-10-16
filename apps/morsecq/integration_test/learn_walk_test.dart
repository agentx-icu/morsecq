// The Learn destination beyond the first day, on the device with real
// playback: today's plan, a receive drill from the picker answered through
// the real input and graded, free sending keyed on the on-screen key, a
// simulated QSO from setup to summary, a saved practice material and the
// telegraph-code entry, then a relaunch that must keep it all. A seeded
// week of Koch practice (lesson 4) stands in for a returning learner.
// Answers are scripted: this checks behaviour, not anyone's Morse ability.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/training/material_store.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/materials/material_editor_screen.dart';
import 'package:morsecq/ui/learn/materials/materials_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_setup_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_summary_view.dart';
import 'package:morsecq/ui/learn/receive/drill_picker_sheet.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';
import 'package:morsecq/ui/learn/send/send_result_view.dart';
import 'package:morsecq/ui/learn/telegraph/telegraph_practice_screen.dart';

import 'support/app_walk.dart';
import 'support/pedagogy_walk.dart';
import 'support/scene_walk.dart';
import 'support/seed_data.dart';
import 'support/shot_harness.dart';

const _materialTitle = 'Walk material';
const _materialText = 'CQ CQ DE K1ABC K';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('learn plan, drills, sending, QSO and materials persist', (
    tester,
  ) async {
    final app = await IsolatedApp.create(binding, 'morsecq_learn_');
    await seedTrainingProgress(
      await app.learningStore.directory(),
      anchor: seedAnchor(DateTime.now()),
    );
    final c = await app.launch(tester, key: 'learn');
    expect(c.currentLesson, 4);
    // Short sessions keep the run quick; the straight key makes a single
    // touch gesture one mark whatever the profile's keyer default.
    await tester.runAsync(
      () => c.updateSettings(
        c.settings.copyWith(
          trainer: c.settings.trainer.copyWith(
            sessionLengthChars: TrainingSettings.minSessionChars,
          ),
          keyerMode: KeyerMode.straight,
        ),
      ),
    );
    await settle(tester);
    final s = appStrings(tester);

    await _todayPlan(tester, s);
    await _receiveDrill(tester, s, c);
    await _sendPractice(tester, s, c);
    await _qso(tester, s, c);
    await _materials(tester, s);
    await _telegraph(tester, s);
    final sessions = c.progress.history.length;

    await app.quit(tester);
    final again = await app.launch(tester, key: 'learn-again');
    expect(again.progress.history.length, sessions);
    expect(again.currentLesson, 4, reason: 'practice never unlocks lessons');
    final materials = await tester.runAsync(again.loadMaterials);
    expect(materials!.map((m) => m.title), contains(_materialTitle));
    expect(tester.takeException(), isNull);
    await app.quit(tester);
  });
}

/// Leaves a running exercise through its back button, confirming the
/// leave dialog when the screen guards an unfinished session.
Future<void> _leave(WidgetTester tester, S s) async {
  await goBack(tester);
  final confirm = find.text(s.learnLeaveDrillConfirm);
  if (confirm.evaluate().isNotEmpty) {
    await tapHittable(tester, confirm, 'leave the drill');
  }
  await waitFor(
    tester,
    () => find.byType(LearnHome).hitTestable().evaluate().isNotEmpty,
    'back on the Learn home',
  );
}

Future<void> _tapLearnEntry(WidgetTester tester, String label) =>
    tapFirstHittable(
      tester,
      find.descendant(of: find.byType(LearnHome), matching: find.text(label)),
      label,
    );

Future<void> _openMorePractice(WidgetTester tester, S s) async {
  final guidedSend = find.byKey(const ValueKey('guided-send')).hitTestable();
  if (guidedSend.evaluate().isEmpty) {
    await _tapLearnEntry(tester, s.learnMorePractice);
  }
}

/// Today's plan card launches its first step.
Future<void> _todayPlan(WidgetTester tester, S s) async {
  final start = find.byKey(const ValueKey('plan-start'));
  await waitForWidget(tester, start, "today's plan is ready");
  await tapFirstHittable(tester, start, 'start today');
  await waitFor(
    tester,
    () => find.byType(LearnHome).hitTestable().evaluate().isEmpty,
    'a plan step opened',
  );
  await _leave(tester, s);
}

/// Receive practice from the drill picker: a graded session whose first
/// answer is wrong, saved to the history without moving the lesson.
Future<void> _receiveDrill(
  WidgetTester tester,
  S s,
  TrainingController c,
) async {
  final before = c.progress.history.length;
  await _tapLearnEntry(tester, s.learnReceivePractice);
  final tile = find.byKey(DrillPickerList.tileKey(ReceiveDrillKind.characters));
  await waitForWidget(tester, tile, 'drill picker');
  await tapHittable(tester, tile, 'characters drill');
  expect(find.byType(ReceiveDrillScreen), findsOneWidget);
  await completeReceive(tester, perfect: false);
  expect(find.byKey(const ValueKey('receive-verdict')), findsOneWidget);
  await waitFor(
    tester,
    () => c.progress.history.length == before + 1,
    'the drill is in the history',
  );
  final last = c.progress.history.last;
  expect(last.drillKind, ReceiveDrillKind.characters.name);
  expect(last.accuracy, lessThan(1), reason: 'the first answer was wrong');
  expect(c.currentLesson, 4);
  await tapHittable(
    tester,
    find.byKey(const ValueKey('receive-done')).first,
    'done',
  );
  await waitForWidget(
    tester,
    find.byType(LearnHome).hitTestable(),
    'back home',
  );
}

/// Free sending: a K keyed on the on-screen straight key is decoded and
/// scored, and the attempt is saved.
Future<void> _sendPractice(
  WidgetTester tester,
  S s,
  TrainingController c,
) async {
  final before = c.progress.history.length;
  await _tapLearnEntry(tester, s.learnSendPractice);
  expect(find.byType(SendPracticeScreen), findsOneWidget);
  // A learner still in the guided stages hears the model first.
  final hear = find.byKey(const ValueKey('send-guide-hear'));
  if (hear.evaluate().isNotEmpty) {
    await tapHittable(tester, hear, 'hear the model');
  }
  final key = find.byType(StraightKeyButton);
  await waitForWidget(tester, key, 'straight key');
  await tester.ensureVisible(key);
  await tester.pump();
  final binding = tester.binding;
  final policy = binding is LiveTestWidgetsFlutterBinding
      ? binding.framePolicy
      : null;
  if (binding is LiveTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  }
  try {
    final dit = tester
        .widget<SendPracticeScreen>(find.byType(SendPracticeScreen))
        .controller
        .trainerSettings
        .toTiming()
        .dit;
    for (final mark in [dit * 3, dit, dit * 3]) {
      final gesture = await tester.startGesture(tester.getCenter(key));
      await Future<void>.delayed(mark);
      await gesture.up();
      await Future<void>.delayed(dit);
    }
  } finally {
    if (binding is LiveTestWidgetsFlutterBinding && policy != null) {
      binding.framePolicy = policy;
    }
  }
  await settle(tester, extra: const Duration(milliseconds: 500));
  await tapFirstHittable(
    tester,
    find.widgetWithText(FilledButton, s.learnDone),
    'finish sending',
  );
  await waitForWidget(tester, find.byType(SendResultView), 'send result');
  await waitFor(
    tester,
    () => c.progress.history.length == before + 1,
    'the attempt is saved',
  );
  expect(c.progress.history.last.drillKind, startsWith('send'));
  await tapFirstHittable(
    tester,
    find.widgetWithText(OutlinedButton, s.learnDone),
    'done',
  );
  await waitForWidget(
    tester,
    find.byType(LearnHome).hitTestable(),
    'back home',
  );
}

/// A short-exchange QSO typed turn by turn from the example replies, to
/// the summary; the result is recorded.
Future<void> _qso(WidgetTester tester, S s, TrainingController c) async {
  final before = c.progress.history.length;
  await _tapLearnEntry(tester, s.learnQsoAction);
  await waitForWidget(tester, find.byType(QsoSetupScreen), 'QSO setup');
  final call = find.widgetWithText(TextField, s.learnQsoYourCall);
  await waitForWidget(tester, call, 'callsign field');
  await typeInto(tester, call, 'DL1ABC');
  await dismissKeyboard(tester);
  await tapHittable(tester, find.byKey(const ValueKey('qso-start')), 'start');
  await waitForWidget(tester, find.byType(QsoScreen), 'QSO running');
  final session = tester.widget<QsoScreen>(find.byType(QsoScreen)).session;
  final yourTurn = find.text(s.learnQsoYourTurn);
  // The first transmission plays to the end on its own.
  await waitForWidget(
    tester,
    yourTurn,
    'remote finished',
    timeout: const Duration(seconds: 60),
  );
  await tapFirstHittable(tester, find.text(s.learnQsoHint), 'hint');
  expect(find.byKey(const ValueKey('qso-hint')), findsOneWidget);
  await tapHittable(
    tester,
    find.byKey(const ValueKey('qso-typed-mode')),
    'typed replies',
  );
  for (var turn = 0; turn < 8 && !session.isDone; turn++) {
    // Later transmissions are paused, as a learner who has heard enough.
    final pause = find.byTooltip(s.learnQsoPause);
    if (pause.evaluate().isNotEmpty) {
      await tapHittable(tester, pause, 'pause the remote');
    }
    await waitForWidget(
      tester,
      yourTurn,
      'learner turn $turn',
      timeout: const Duration(seconds: 60),
    );
    final reply = session
        .hint()
        .example
        .replaceAll('<LOCAL>', session.local.callsign)
        .replaceAll('<REMOTE NAME>', session.remote.name)
        .replaceAll('<REMOTE>', session.remote.callsign);
    debugPrint('[learn] QSO ${session.stage.name}: $reply');
    await typeInto(
      tester,
      find.byKey(const ValueKey('qso-typed-reply')),
      reply,
    );
    await dismissKeyboard(tester);
    await tapHittable(tester, find.byKey(const ValueKey('qso-send')), 'send');
  }
  await waitForWidget(tester, find.byType(QsoSummaryView), 'QSO summary');
  await waitFor(
    tester,
    () => c.progress.history.length > before,
    'the QSO is recorded',
  );
  await tapHittable(tester, find.byKey(const ValueKey('qso-done')), 'done');
  await waitForWidget(tester, find.byType(QsoSetupScreen), 'setup again');
  await goBack(tester);
}

/// My materials: a new text is saved, listed and opens a practice drill.
Future<void> _materials(WidgetTester tester, S s) async {
  await _openMorePractice(tester, s);
  await _tapLearnEntry(tester, s.materialsTitle);
  await waitForWidget(tester, find.byType(MaterialsScreen), 'materials');
  await tapHittable(
    tester,
    find.byKey(const ValueKey('material-new')),
    'new material',
  );
  expect(find.byType(MaterialEditorScreen), findsOneWidget);
  await typeInto(
    tester,
    find.widgetWithText(TextField, s.materialsTitleField),
    _materialTitle,
  );
  await typeInto(
    tester,
    find.byKey(const ValueKey('material-text')),
    _materialText,
  );
  await dismissKeyboard(tester);
  final save = find.byKey(const ValueKey('material-save'));
  await waitFor(
    tester,
    () => tester.widget<ButtonStyleButton>(save).onPressed != null,
    'the text is analysed and can be saved',
  );
  await tapHittable(tester, save, 'save material');
  await waitForWidget(
    tester,
    find.descendant(
      of: find.byType(MaterialsScreen),
      matching: find.text(_materialTitle),
    ),
    'material listed',
  );
  await tapFirstHittable(tester, find.text(_materialTitle), 'practise it');
  await waitForWidget(
    tester,
    find.text(s.materialsPracticeMode),
    'practice mode choice',
  );
  await tapFirstHittable(
    tester,
    find.text(s.materialsPracticeAll),
    'every character of the text',
  );
  await waitForWidget(
    tester,
    find.byType(ReceiveDrillScreen),
    'the material opens as a receive drill',
  );
  expect(
    tester
        .widget<ReceiveDrillScreen>(find.byType(ReceiveDrillScreen))
        .session
        .currentDrill
        .text
        .trim(),
    isNotEmpty,
  );
  await goBack(tester);
  final confirm = find.text(s.learnLeaveDrillConfirm);
  if (confirm.evaluate().isNotEmpty) {
    await tapHittable(tester, confirm, 'leave the drill');
  }
  await waitForWidget(
    tester,
    find.byType(MaterialsScreen).hitTestable(),
    'back on materials',
  );
  await goBack(tester);
}

Future<void> _telegraph(WidgetTester tester, S s) async {
  await _openMorePractice(tester, s);
  await _tapLearnEntry(tester, s.telegraphTitle);
  await waitForWidget(
    tester,
    find.byType(TelegraphPracticeScreen),
    'telegraph practice',
  );
  expect(find.byKey(const Key('telegraph-recall')), findsOneWidget);
  await goBack(tester);
}
