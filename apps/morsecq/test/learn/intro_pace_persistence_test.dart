import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_plan.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/learn/onboarding/first_lesson_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

class _ControlledStore implements TrainingSettingsStore {
  final saveGate = Completer<void>();
  @override
  Future<TrainingSettings?> load() async => TrainingSettings.defaults;
  @override
  Future<void> save(TrainingSettings settings) => saveGate.future;
  @override
  Future<void> clear() async {}
}

Future<void> _trials(WidgetTester tester) async {
  for (final key in [
    'first-lesson-heard',
    'first-lesson-continue-worked',
    'first-lesson-continue-trials',
  ]) {
    await tester.ensureVisible(find.byKey(ValueKey(key)));
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
  }
}

void main() {
  for (final fail in [false, true]) {
    testWidgets(
      'pace save ${fail ? 'failure' : 'delay'} keeps playback and history comparable',
      (tester) async {
        final store = _ControlledStore();
        final c = TrainingController(
          progressStore: InMemoryTrainerStore(),
          settingsStore: store,
          now: () => kTestNow,
        );
        await c.load();
        addTearDown(c.dispose);
        await c.ensureTodayPlan();
        final session = c.startOnboardingSession();
        await tester.pumpWidget(
          l10nApp(
            home: FirstLessonScreen(
              controller: c,
              playback: FakeLearnPlaybackFactory(),
              trialSession: session,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await _trials(tester);
        await tester.ensureVisible(find.byKey(const ValueKey('beginner-pace')));
        await tester.tap(find.byKey(const ValueKey('beginner-pace')));
        await tester.pumpAndSettle();
        final option = tester.widget<FilledButton>(
          find.byKey(const ValueKey('trial-K')),
        );
        expect(
          option.onPressed,
          isNull,
          reason: 'no answers while pace is being committed',
        );
        if (fail) {
          store.saveGate.completeError(StateError('disk'));
        } else {
          store.saveGate.complete();
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(session.timing.farnsworthWpm, fail ? 8 : 6);
        expect(session.timing.farnsworthWpm, c.trainerSettings.farnsworthWpm);
        if (!fail) {
          final next = c.todayPlan!.steps.firstWhere(
            (s) => s.kind == PlanStepKind.recognition,
          );
          final recognition = await c.startPlanReceiveStep(next);
          expect(
            recognition.timing.farnsworthWpm,
            6,
            reason: 'the beginner pace continues into the next plan step',
          );
        }
      },
    );
  }
}
