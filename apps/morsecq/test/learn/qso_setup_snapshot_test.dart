import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_setup_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

const _stepId = 'contest-step';
const _snapshot = PlanSettings(
  characterWpm: 24,
  effectiveWpm: 14,
  toneHz: 650,
  groupSize: 5,
);

DailyPlan _plan({
  PlanStepKind kind = PlanStepKind.qso,
  PlanStepState state = PlanStepState.active,
  List<String> pool = const ['contestExchange'],
  String? date,
  String profile = '',
}) => DailyPlan(
  id: 'plan',
  date: date ?? DailyPlan.dateKey(kTestNow),
  profileKey: profile,
  seed: 1,
  budgetMinutes: 15,
  settings: const PlanSettings(
    characterWpm: 30,
    effectiveWpm: 30,
    toneHz: 700,
    groupSize: 5,
  ),
  steps: [
    PlanStep(
      id: _stepId,
      kind: kind,
      pool: pool,
      minutes: 3,
      charBudget: 50,
      lesson: 30,
      reason: PlanReason.goalExchange,
      state: state,
      seed: 317,
      settings: _snapshot,
    ),
  ],
);

Future<QsoSession> _start(WidgetTester tester, TestTraining t) async {
  await tester.pumpWidget(
    l10nApp(
      home: QsoSetupScreen(
        controller: t.controller,
        playback: FakeLearnPlaybackFactory(),
        initialScenario: QsoScenario.contestExchange,
        // The actual active plan snapshot must take precedence.
        practiceTiming: const MorseTiming(wpm: 22, farnsworthWpm: 9),
        planStepId: _stepId,
      ),
    ),
  );
  await tester.pumpAndSettle();
  final start = find.byKey(const ValueKey('qso-start'));
  await tester.ensureVisible(start);
  await tester.tap(start);
  await tester.pumpAndSettle();
  return tester.widget<QsoScreen>(find.byType(QsoScreen)).session;
}

void main() {
  testWidgets(
    'reopening a bound QSO retains the plan seed and speed snapshot',
    (tester) async {
      tester.view.physicalSize = const Size(430, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 30, dailyPlan: _plan()),
      );
      final originalSettings = t.controller.settings;
      final first = await _start(tester, t);
      expect(first.seed, 317);
      expect(first.characterWpm, 24);
      expect(first.effectiveWpm, 14);
      expect(first.planStepId, _stepId);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      final reopened = await _start(tester, t);
      expect(reopened.seed, first.seed);
      expect(reopened.remote.toJson(), first.remote.toJson());
      expect(reopened.turns.first.text, first.turns.first.text);
      expect(t.controller.settings, originalSettings);
    },
  );

  testWidgets('invalid plan bindings start ordinary QSO practice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final plans = [
      _plan(state: PlanStepState.pending),
      _plan(state: PlanStepState.done),
      _plan(kind: PlanStepKind.comprehension),
      _plan(pool: const ['potaActivation']),
      _plan(pool: const ['contestExchange', 'potaActivation']),
      _plan(date: '2026-09-29'),
      _plan(profile: 'another-profile'),
    ];
    for (final plan in plans) {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 30, dailyPlan: plan),
      );
      final session = await _start(tester, t);
      expect(session.planStepId, isNull, reason: plan.toJson().toString());
      expect(session.seed, isNot(317));
      expect(session.characterWpm, 22);
      expect(session.effectiveWpm, 9);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });
}
