import 'dart:async';

import 'package:test/test.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';

import 'helpers/test_core.dart';

final class _FailingStore implements TrainerStore {
  final delegate = InMemoryTrainerStore(TrainerProgress(currentLesson: 30));
  bool fail = true;
  Future<void>? saveGate;

  @override
  Future<TrainerProgress?> load() => delegate.load();
  @override
  Future<void> clear() => delegate.clear();
  @override
  Future<void> save(TrainerProgress progress) async {
    await saveGate;
    if (fail) throw StateError('progress disk unavailable');
    await delegate.save(progress);
  }
}

QsoSession _finished({String? planStepId}) {
  final session = QsoSession.start(
    scenario: QsoScenario.shortExchange,
    seed: 88,
    local: const QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS'),
    characterWpm: 20,
    effectiveWpm: 20,
    planStepId: planStepId,
  );
  session.submit('call', '${session.remote.callsign} DE BD1XYZ K');
  session.submit('rst', 'UR RST 599 K');
  session.submit('bye', 'TU 73 <SK>');
  expect(session.isDone, isTrue);
  return session;
}

Future<TrainingCore> _controller(
  TrainerStore store,
  InMemoryTrainingDocStore docs,
  TestClock clock,
) async {
  final controller = TestTrainingCore(
    progressStore: store,
    settingsStore: InMemoryTrainingSettingsStore(),
    docs: docs,
    now: () => clock.now,
  );
  await controller.load();
  return controller;
}

const _doc = '${QsoPractice.finishedPrefix}shortexchange_88';

void main() {
  test(
    'a duplicate waits for pending progress before reporting saved',
    () async {
      final gate = Completer<void>();
      final store = _FailingStore()..saveGate = gate.future;
      final c = await _controller(
        store,
        InMemoryTrainingDocStore(),
        TestClock(),
      );
      addTearDown(c.dispose);
      final session = _finished();
      final first = c.recordQso(session, Duration.zero);
      var duplicateReturned = false;
      final duplicate = c.recordQso(session, Duration.zero).then((value) {
        duplicateReturned = true;
        return value;
      });
      await Future<void>.delayed(Duration.zero);
      final returnedBeforeWrite = duplicateReturned;
      gate.complete();
      expect((await first).saved, isFalse);
      final result = await duplicate;
      expect(returnedBeforeWrite, isFalse);
      expect(result.duplicate, isTrue);
      expect(result.saved, isFalse);

      store.fail = false;
      expect((await c.recordQso(session, Duration.zero)).saved, isTrue);
      expect((await store.load())!.history, hasLength(1));
    },
  );

  test('failed save parks the original completion timestamp', () async {
    final store = _FailingStore();
    final docs = InMemoryTrainingDocStore();
    final clock = TestClock();
    final c = await _controller(store, docs, clock);
    expect(
      await c.finishQso(_finished(), const Duration(seconds: 30)),
      isFalse,
    );
    expect((await docs.read(_doc))!['completedAt'], kTestNow.toIso8601String());
    // A later retry of the same unsaved result must preserve its first date.
    clock.advance(const Duration(days: 5));
    expect(await c.finishQso(_finished(), Duration.zero), isFalse);
    expect((await docs.read(_doc))!['completedAt'], kTestNow.toIso8601String());
  });

  for (final hasNewPlan in [false, true]) {
    test(
      'recovery completes the dated plan with new plan: $hasNewPlan',
      () async {
        final store = _FailingStore();
        final docs = InMemoryTrainingDocStore();
        final clock = TestClock();
        const stepId = 'yesterday/0_qso';
        final plan = DailyPlan(
          id: 'yesterday',
          date: DailyPlan.dateKey(clock.now),
          profileKey: '',
          seed: 88,
          budgetMinutes: 10,
          settings: const PlanSettings(
            characterWpm: 20,
            effectiveWpm: 20,
            toneHz: 700,
            groupSize: 5,
          ),
          steps: [
            PlanStep(
              id: stepId,
              kind: PlanStepKind.qso,
              pool: const ['shortExchange'],
              minutes: 10,
              charBudget: 1,
              lesson: 30,
              reason: PlanReason.goalExchange,
            ),
          ],
        ).start(stepId);
        await store.delegate.save(
          TrainerProgress(currentLesson: 30, dailyPlan: plan),
        );
        final controller = await _controller(store, docs, clock);
        expect(
          await controller.finishQso(
            _finished(planStepId: stepId),
            Duration.zero,
          ),
          isFalse,
        );
        controller.dispose();

        clock.advance(const Duration(days: 1));
        store.fail = false;
        final reopened = await _controller(store, docs, clock);
        addTearDown(reopened.dispose);
        if (hasNewPlan) await reopened.ensureTodayPlan();
        await reopened.recoverFinishedQso();

        final saved = (await store.load())!;
        final originalPlan = hasNewPlan ? saved.previousPlan : saved.dailyPlan;
        expect(
          originalPlan!.stepById(stepId)!.resultRef,
          saved.history.single.id,
        );
        expect(originalPlan.isComplete, isTrue);
        expect(reopened.unfinishedEarlierPlan, isNull);
      },
    );
  }

  test(
    'recovering after 28 days does not create fresh route or streak credit',
    () async {
      final store = _FailingStore();
      final docs = InMemoryTrainingDocStore();
      final clock = TestClock();
      final c = await _controller(store, docs, clock);
      expect(
        await c.finishQso(_finished(), const Duration(seconds: 30)),
        isFalse,
      );
      c.dispose();
      clock.advance(const Duration(days: 35));
      store.fail = false;
      final reopened = await _controller(store, docs, clock);
      await reopened.recoverFinishedQso();
      expect(reopened.progress.history.single.at, kTestNow);
      expect(
        reopened.progress.lastPracticeDay,
        TrainerProgress.dayOf(kTestNow),
      );
      expect(reopened.progress.streakAsOf(clock.now), 0);
      expect(
        reopened.learningRoute.milestones
            .where((m) => m.skill == RouteSkill.qso)
            .every((m) => m.attempts == 0),
        isTrue,
      );
      expect(await docs.read(_doc), isNull);
      await reopened.recoverFinishedQso();
      expect(reopened.progress.history, hasLength(1));
    },
  );

  test(
    'legacy parked results recover activity with unknown independent evidence',
    () async {
      final docs = InMemoryTrainingDocStore();
      final clock = TestClock();
      final c = await _controller(InMemoryTrainerStore(), docs, clock);
      await docs.write(_doc, {
        'session': _finished().toJson(),
        'activeMs': 1000,
      });
      await c.recoverFinishedQso();
      expect(c.progress.history.single.at, kTestNow);
      expect(c.progress.history.single.sourceRef, 'qso:shortExchange:3/3');
      expect(c.progress.history.single.completed, isTrue);
      expect(c.progress.history.single.isKnownUnassisted, isFalse);
      expect(
        c.learningRoute.milestones
            .where((m) => m.skill == RouteSkill.qso)
            .every((m) => m.attempts == 0),
        isTrue,
      );
      expect(await docs.read(_doc), isNull);
    },
  );

  test(
    'retrying a legacy undated result cannot manufacture a completion date',
    () async {
      final store = _FailingStore();
      final docs = InMemoryTrainingDocStore();
      final clock = TestClock();
      final c = await _controller(store, docs, clock);
      await docs.write(_doc, {
        'session': _finished().toJson(),
        'activeMs': 1000,
      });
      expect(await c.finishQso(_finished(), Duration.zero), isFalse);
      expect((await docs.read(_doc))!['completedAt'], isNull);
      c.dispose();
      store.fail = false;
      clock.advance(const Duration(days: 35));
      final reopened = await _controller(store, docs, clock);
      await reopened.recoverFinishedQso();
      expect(reopened.progress.history.single.isKnownUnassisted, isFalse);
    },
  );

  test(
    'immediate direct recording still establishes independent evidence',
    () async {
      final c = await _controller(
        InMemoryTrainerStore(),
        InMemoryTrainingDocStore(),
        TestClock(),
      );
      await c.recordQso(_finished(), const Duration(seconds: 30));
      expect(c.progress.history.single.at, kTestNow);
      expect(c.progress.history.single.isKnownUnassisted, isTrue);
      expect(
        c.learningRoute.milestones
            .where((m) => m.skill == RouteSkill.qso)
            .any((m) => m.attempts > 0),
        isTrue,
      );
    },
  );
}
