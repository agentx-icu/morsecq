import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/advanced_learning.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_setup_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

const QsoStation _me = QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS');

Future<TestTraining> _training() => TestTraining.create(
  progress: TrainerProgress(currentLesson: 30),
  settings: const TrainingSettings(keyerMode: KeyerMode.straight),
);

QsoSession _session({QsoScenario scenario = QsoScenario.respondToCq}) =>
    QsoSession.start(
      scenario: scenario,
      seed: 11,
      local: _me,
      characterWpm: 20,
      effectiveWpm: 20,
    );

Future<void> _pumpScreen(
  WidgetTester tester,
  TestTraining t,
  QsoSession session,
  FakeLearnPlaybackFactory playback,
) async {
  tester.view.physicalSize = const Size(430, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    l10nApp(
      home: QsoScreen(
        controller: t.controller,
        playback: playback,
        session: session,
        screenWake: _NoWake(),
      ),
    ),
  );
  await tester.pump();
}

/// Lets the remote transmission play out on the fake clock.
Future<void> _finishPlayback(WidgetTester tester, FakeClock clock) async {
  for (var i = 0; i < 400; i++) {
    clock.advance(const Duration(milliseconds: 100));
    await tester.pump();
  }
}

/// Keys [text] on the on-screen straight key at 20 WPM.
Future<void> _key(WidgetTester tester, FakeClock clock, String text) async {
  final key = find.byType(StraightKeyButton);
  expect(key, findsOneWidget);
  for (final e in MorseEncoder.encode(text, const MorseTiming(wpm: 20))) {
    if (e.on) {
      final g = await tester.startGesture(tester.getCenter(key));
      clock.advance(e.duration);
      await tester.pump();
      await g.up();
      await tester.pump();
    } else {
      clock.advance(e.duration);
      await tester.pump();
    }
  }
  clock.advance(const Duration(milliseconds: 400));
  await tester.pump();
}

final class _NoWake implements ScreenWakeApi {
  @override
  Future<void> keepOn(bool on) async {}
}

void main() {
  testWidgets(
    'typed submission survives reload and stays assisted protocol practice',
    (tester) async {
      final t = await _training();
      final playback = FakeLearnPlaybackFactory();
      final session = _session(scenario: QsoScenario.shortExchange);
      await _pumpScreen(tester, t, session, playback);
      await _finishPlayback(tester, playback.clock);
      await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
      await tester.pump();
      final text = '${session.remote.callsign} DE BD1XYZ K';
      await tester.enterText(
        find.byKey(const ValueKey('qso-typed-reply')),
        text,
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('qso-send')));
      await tester.pumpAndSettle();
      expect(session.stage, QsoStage.exchange);
      expect(session.toJson()['typedReplies'], 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      final restored = (await t.controller.loadQsoDraft())!.session;
      expect(restored.toJson()['typedReplies'], 1);
      restored.submit('keyed-report', 'UR RST 599 K');
      restored.submit('keyed-closing', 'TU 73 <SK>');
      await t.controller.finishQso(restored, Duration.zero);
      final row = t.controller.progress.history.single;
      expect(row.sourceRef, 'qso:shortExchange:3/3');
      expect(row.assistance, contains(Assistance.hint));
      expect(row.isKnownUnassisted, isFalse);
      expect(
        t.controller.learningRoute.milestones
            .where((m) => m.skill == RouteSkill.qso)
            .every((m) => m.attempts == 0),
        isTrue,
      );
    },
  );

  testWidgets(
    'typed pending text remains assisted after switching to keying and reload',
    (tester) async {
      final t = await _training();
      final playback = FakeLearnPlaybackFactory();
      final session = _session(scenario: QsoScenario.shortExchange);
      await _pumpScreen(tester, t, session, playback);
      await _finishPlayback(tester, playback.clock);
      await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
      await tester.pump();
      final text = '${session.remote.callsign} DE BD1XYZ K';
      await tester.enterText(
        find.byKey(const ValueKey('qso-typed-reply')),
        text,
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
      await tester.pumpAndSettle();
      final saved = (await t.controller.readDoc(QsoPractice.draftDoc))!;
      expect(saved['typedReply'], isFalse);
      expect(saved['pendingWasTyped'], isTrue);
      final draft = (await t.controller.loadQsoDraft())!;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(
        l10nApp(
          home: QsoScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
            session: draft.session,
            resumed: draft,
            screenWake: _NoWake(),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('qso-send')));
      await tester.pump();
      expect(draft.session.stage, QsoStage.exchange);
      expect(draft.session.toJson()['typedReplies'], 1);
    },
  );

  testWidgets(
    'goal setup uses frozen speed and binds only its selected scenario',
    (tester) async {
      tester.view.physicalSize = const Size(430, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final changeScenario in [false, true]) {
        final t = await TestTraining.create(
          progress: TrainerProgress(
            currentLesson: 30,
            dailyPlan: DailyPlan(
              id: 'contest-plan',
              date: DailyPlan.dateKey(kTestNow),
              profileKey: '',
              seed: 1,
              budgetMinutes: 15,
              settings: const PlanSettings(
                characterWpm: 22,
                effectiveWpm: 9,
                toneHz: 600,
                groupSize: 5,
              ),
              steps: [
                PlanStep(
                  id: 'contest-plan-step',
                  kind: PlanStepKind.qso,
                  pool: const ['contestExchange'],
                  minutes: 3,
                  charBudget: 50,
                  lesson: 30,
                  reason: PlanReason.goalExchange,
                  state: PlanStepState.active,
                  seed: 317,
                ),
              ],
            ),
          ),
          settings: const TrainingSettings(keyerMode: KeyerMode.straight),
        );
        final original = t.controller.settings;
        await tester.pumpWidget(
          l10nApp(
            home: QsoSetupScreen(
              key: ValueKey(changeScenario),
              controller: t.controller,
              playback: FakeLearnPlaybackFactory(),
              initialScenario: QsoScenario.contestExchange,
              practiceTiming: const MorseTiming(wpm: 22, farnsworthWpm: 9),
              planStepId: 'contest-plan-step',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('qso-station-serial')),
          findsOneWidget,
        );
        if (changeScenario) {
          await tester.ensureVisible(
            find.byKey(const ValueKey('qso-scenario-pota')),
          );
          await tester.tap(find.byKey(const ValueKey('qso-scenario-pota')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('qso-station-park')),
            findsOneWidget,
          );
        }
        final start = find.byKey(const ValueKey('qso-start'));
        await tester.ensureVisible(start);
        await tester.tap(start);
        await tester.pumpAndSettle();
        final session = tester
            .widget<QsoScreen>(find.byType(QsoScreen))
            .session;
        expect(session.characterWpm, 22);
        expect(session.effectiveWpm, 9);
        expect(session.planStepId, changeScenario ? null : 'contest-plan-step');
        expect(
          session.scenario,
          changeScenario
              ? QsoScenario.potaActivation
              : QsoScenario.contestExchange,
        );
        expect(t.controller.settings, original);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    },
  );

  testWidgets('typed draft keeps unsent text and restores silently', (
    tester,
  ) async {
    final t = await _training();
    final playback = FakeLearnPlaybackFactory();
    final s = _session(scenario: QsoScenario.contestExchange);
    final text = '${s.remote.callsign} DE BD1XYZ K';
    await t.controller.saveQsoDraft(
      s,
      pendingText: text,
      pendingId: 'typed-draft',
      typedReply: true,
    );
    final draft = (await t.controller.loadQsoDraft())!;
    expect(draft.typedReply, isTrue);
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      l10nApp(
        home: QsoScreen(
          controller: t.controller,
          playback: playback,
          session: draft.session,
          resumed: draft,
          screenWake: _NoWake(),
        ),
      ),
    );
    await tester.pump();
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('qso-typed-reply')),
    );
    expect(field.controller!.text, text);
    expect(playback.sink.events, isEmpty);
    await tester.tap(find.byKey(const ValueKey('qso-send')));
    await tester.pump();
    expect(draft.session.stage, QsoStage.exchange);
    expect(draft.session.submit('typed-draft', text).duplicate, isTrue);
    await _finishPlayback(tester, playback.clock);
  });

  testWidgets(
    'POTA typed replies complete park exchange and corrected reference',
    (tester) async {
      final t = await _training();
      final playback = FakeLearnPlaybackFactory();
      final session = _session(scenario: QsoScenario.potaActivation);
      await _pumpScreen(tester, t, session, playback);
      await _finishPlayback(tester, playback.clock);
      await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
      await tester.pump();
      for (final text in [
        '${session.remote.callsign} DE BD1XYZ K',
        'UR RST 599 PARK US1234 K',
        'QSL RST ${session.report} PARK ${session.remote.parkOnAir} K',
        'TU 73 <SK>',
      ]) {
        await _finishPlayback(tester, playback.clock);
        await tester.enterText(
          find.byKey(const ValueKey('qso-typed-reply')),
          text,
        );
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('qso-send')));
        await tester.pumpAndSettle();
      }
      expect(session.isDone, isTrue);
      expect(session.firstTryStages, 4);
      expect(
        t.controller.progress.history.single.sourceRef,
        'qso:potaActivation:4/4',
      );
      expect(t.controller.progress.charStats, isEmpty);
    },
  );

  testWidgets('contest typed replies complete all stages and credit once', (
    tester,
  ) async {
    final t = await _training();
    final playback = FakeLearnPlaybackFactory();
    final session = _session(scenario: QsoScenario.contestExchange);
    await _pumpScreen(tester, t, session, playback);
    await _finishPlayback(tester, playback.clock);
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    for (final text in [
      '${session.remote.callsign} DE BD1XYZ K',
      'UR RST 5NN NR 001 K',
      'QSL RST ${session.report} NR ${session.remote.serialNumber} K',
      'TU 73',
    ]) {
      await _finishPlayback(tester, playback.clock);
      await tester.enterText(
        find.byKey(const ValueKey('qso-typed-reply')),
        text,
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('qso-send')));
      await tester.pumpAndSettle();
    }
    expect(session.isDone, isTrue);
    expect(session.firstTryStages, 4);
    expect(t.controller.progress.history, hasLength(1));
    expect(
      t.controller.progress.history.single.sourceRef,
      'qso:contestExchange:4/4',
    );
    await t.controller.finishQso(session, Duration.zero);
    expect(t.controller.progress.history, hasLength(1));
    expect(t.controller.progress.charStats, isEmpty);
  });

  testWidgets('targeted repeat is available only after the field was heard', (
    tester,
  ) async {
    final t = await _training();
    final playback = FakeLearnPlaybackFactory();
    final session = _session(scenario: QsoScenario.contestExchange);
    await _pumpScreen(tester, t, session, playback);
    expect(find.byKey(const ValueKey('qso-repeat-CALL')), findsOneWidget);
    expect(find.byKey(const ValueKey('qso-repeat-NR')), findsNothing);
    await _finishPlayback(tester, playback.clock);
    await tester.tap(find.byKey(const ValueKey('qso-repeat-CALL')));
    await tester.pump();
    expect(session.stage, QsoStage.callConfirm);
    expect(session.repeats, 1);
    expect(session.turns.last.text, 'CALL ${session.remote.callsign} K');
    expect(session.hints, 0);
    await _finishPlayback(tester, playback.clock);
  });

  testWidgets(
    'short exchange keys all three stages and records first-try evidence',
    (tester) async {
      final t = await _training();
      final playback = FakeLearnPlaybackFactory();
      final session = _session(scenario: QsoScenario.shortExchange);
      await _pumpScreen(tester, t, session, playback);
      for (final text in [
        '${session.remote.callsign} DE BD1XYZ K',
        'UR RST 599 K',
        'TU 73 <SK>',
      ]) {
        await _finishPlayback(tester, playback.clock);
        await _key(tester, playback.clock, text);
        await tester.tap(find.byKey(const ValueKey('qso-send')));
        await tester.pumpAndSettle();
        if (session.stage == QsoStage.exchange) {
          expect(find.text(en.learnQsoSignalReport), findsOneWidget);
          expect(
            find.text(en.learnQsoStageExchange),
            findsNothing,
            reason: 'the short exchange does not ask for a name or QTH',
          );
        }
      }
      expect(session.isDone, isTrue);
      expect(session.firstTryStages, 3);
      final row = t.controller.progress.history.single;
      expect(row.sourceRef, QsoReadiness.shortExchangeSourceRef);
      expect(row.isKnownUnassisted, isTrue);
      expect(t.controller.progress.charStats, isEmpty);
      expect(t.controller.currentLesson, 30);
    },
  );

  test(
    'errors and QRS remain distinct from successful first-try exchange',
    () async {
      final t = await _training();
      for (var seed = 21; seed <= 22; seed++) {
        final s = QsoSession.start(
          scenario: QsoScenario.shortExchange,
          seed: seed,
          local: _me,
          characterWpm: 20,
          effectiveWpm: 8,
        );
        s.submit('help', seed == 21 ? 'QRS' : 'WRONG');
        s.submit('call', '${s.remote.callsign} DE BD1XYZ K');
        s.submit('rst', 'UR RST 599 K');
        s.submit('end', 'TU 73 <SK>');
        await t.controller.recordQso(s, Duration.zero);
      }
      final qrs = t.controller.progress.history[0];
      final wrong = t.controller.progress.history[1];
      expect(qrs.assistance, contains(Assistance.replay));
      expect(qrs.sourceRef, QsoReadiness.shortExchangeSourceRef);
      expect(wrong.sourceRef, 'qso:shortExchange:2/3');
      expect(t.controller.qsoReadiness.exchangePractised, isFalse);
    },
  );

  testWidgets('remote text stays hidden until revealed; reveal is a hint', (
    tester,
  ) async {
    final t = await _training();
    final playback = FakeLearnPlaybackFactory();
    final session = _session();
    await _pumpScreen(tester, t, session, playback);
    expect(find.textContaining('CQ CQ CQ'), findsNothing);
    expect(find.text(en.learnQsoRemoteHidden), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('qso-reveal-0')));
    await tester.pump();
    expect(find.textContaining('CQ CQ CQ'), findsOneWidget);
    expect(session.hints, 1);
    await _finishPlayback(tester, playback.clock);
  });

  testWidgets('keying a correct reply advances the QSO and saves a draft', (
    tester,
  ) async {
    final t = await _training();
    final playback = FakeLearnPlaybackFactory();
    final session = _session();
    await _pumpScreen(tester, t, session, playback);
    await _finishPlayback(tester, playback.clock);
    expect(find.text(en.learnQsoYourTurn), findsOneWidget);

    await _key(
      tester,
      playback.clock,
      '${session.remote.callsign} DE BD1XYZ K',
    );
    final decoded = tester.widget<Text>(
      find.byKey(const ValueKey('qso-decoded')),
    );
    expect(decoded.data!.trim(), '${session.remote.callsign} DE BD1XYZ K');
    await tester.tap(find.byKey(const ValueKey('qso-send')));
    await tester.pump();
    expect(session.stage, QsoStage.exchange);
    expect(
      find.text(en.learnQsoStageExchange),
      findsOneWidget,
      reason: 'the full exchange still asks for report, name and QTH',
    );
    expect(find.text(en.learnQsoRemoteSending), findsOneWidget);
    await _finishPlayback(tester, playback.clock);
    expect(await t.controller.loadQsoDraft(), isNotNull);
    // No outbound chat, no receive statistics: only local state changed.
    expect(t.controller.progress.charStats, isEmpty);
  });

  testWidgets('a wrong callsign keeps the stage and explains why', (
    tester,
  ) async {
    final t = await _training();
    final playback = FakeLearnPlaybackFactory();
    final session = _session();
    await _pumpScreen(tester, t, session, playback);
    await _finishPlayback(tester, playback.clock);
    await _key(tester, playback.clock, 'K1ZZZ DE BD1XYZ K');
    await tester.tap(find.byKey(const ValueKey('qso-send')));
    await tester.pump();
    expect(session.stage, QsoStage.callConfirm);
    expect(find.text(en.learnQsoIssueWrongRemoteCall), findsOneWidget);
    await tester.tap(find.text(en.learnQsoHint));
    await tester.pump();
    expect(find.byKey(const ValueKey('qso-hint')), findsOneWidget);
  });

  testWidgets('the last transmission finishes, credits activity only', (
    tester,
  ) async {
    final t = await _training();
    final playback = FakeLearnPlaybackFactory();
    final session = _session(scenario: QsoScenario.callCq);
    // Play the first stages through the engine, then key the closing.
    session.submit('1', 'CQ CQ DE BD1XYZ K');
    session.submit(
      '2',
      '${session.remote.callsign} DE BD1XYZ UR RST 599 NAME LI QTH PARIS K',
    );
    session.submit('3', 'R R TNX ${session.remote.name}');
    expect(session.stage, QsoStage.closing);
    await _pumpScreen(tester, t, session, playback);
    // A resumed QSO never starts playback by itself.
    expect(find.text(en.learnQsoYourTurn), findsOneWidget);
    await _key(tester, playback.clock, 'TU 73 <SK>');
    await tester.tap(find.byKey(const ValueKey('qso-send')));
    await tester.pumpAndSettle();
    expect(session.isDone, isTrue);
    expect(find.text(en.learnQsoSummaryNote), findsOneWidget);
    final record = t.controller.progress.history.single;
    expect(record.source, ExerciseSource.qso);
    expect(t.controller.progress.charStats, isEmpty);
    expect(t.controller.currentLesson, 30);
    expect(await t.controller.loadQsoDraft(), isNull);
  });

  testWidgets('setup validates the station and offers resume', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final t = await _training();
    await t.controller.saveQsoDraft(_session());
    await tester.pumpWidget(
      l10nApp(
        home: QsoSetupScreen(
          controller: t.controller,
          playback: FakeLearnPlaybackFactory(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('qso-resume')), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '12');
    await tester.pump();
    expect(find.text(en.learnQsoInvalidCall), findsOneWidget);
    final start = tester.widget<ButtonStyleButton>(
      find.byKey(const ValueKey('qso-start')),
    );
    expect(start.onPressed, isNull);
  });

  testWidgets('a resumed QSO keeps the unsent reply and does not autoplay', (
    tester,
  ) async {
    final t = await _training();
    final playback = FakeLearnPlaybackFactory();
    final session = _session();
    final draft = QsoDraft(
      session: session,
      pendingText: '${session.remote.callsign} DE BD1XYZ K',
      pendingId: 'p1',
    );
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      l10nApp(
        home: QsoScreen(
          controller: t.controller,
          playback: playback,
          session: session,
          resumed: draft,
          screenWake: _NoWake(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text(en.learnQsoYourTurn), findsOneWidget, reason: 'silent');
    expect(playback.sink.events, isEmpty);
    await tester.tap(find.byKey(const ValueKey('qso-send')));
    await tester.pump();
    expect(session.stage, QsoStage.exchange);
    await _finishPlayback(tester, playback.clock);
  });

  test('a finished QSO keeps its draft until the result is saved', () async {
    final t = await _training();
    final s = _session(scenario: QsoScenario.callCq);
    s.submit('1', 'CQ CQ DE BD1XYZ K');
    s.submit(
      '2',
      '${s.remote.callsign} DE BD1XYZ UR RST 599 NAME LI QTH PARIS K',
    );
    s.submit('3', 'R R TNX ${s.remote.name}');
    s.submit('4', 'TU 73<SK>');
    expect(s.isDone, isTrue);
    await t.controller.saveQsoDraft(s);
    // As if the app died before recording: the setup flow commits it once.
    final draft = (await t.controller.loadQsoDraft())!;
    expect(draft.session.isDone, isTrue);
    expect(await t.controller.finishQso(draft.session, Duration.zero), isTrue);
    expect(await t.controller.finishQso(draft.session, Duration.zero), isTrue);
    expect(t.controller.progress.history, hasLength(1));
    expect(await t.controller.loadQsoDraft(), isNull);
  });

  test('a parked finished QSO is committed when learning data loads', () async {
    final t = await _training();
    final s = _session(scenario: QsoScenario.callCq);
    s.submit('1', 'CQ CQ DE BD1XYZ K');
    s.submit(
      '2',
      '${s.remote.callsign} DE BD1XYZ UR RST 599 NAME LI QTH PARIS K',
    );
    s.submit('3', 'R R TNX ${s.remote.name}');
    s.submit('4', 'TU 73 <SK>');
    const doc = '${QsoPractice.finishedPrefix}a';
    final other = QsoSession.start(
      scenario: QsoScenario.callCq,
      seed: 12,
      local: _me,
      characterWpm: 20,
      effectiveWpm: 20,
    );
    other.submit('1', 'CQ CQ DE BD1XYZ K');
    other.submit(
      '2',
      '${other.remote.callsign} DE BD1XYZ UR RST 599 NAME LI QTH PARIS K',
    );
    other.submit('3', 'R R TNX ${other.remote.name}');
    other.submit('4', 'TU 73 <SK>');
    await t.controller.writeDoc('${QsoPractice.finishedPrefix}b', {
      // A second, different finished QSO (seed 12): both are recovered.
      'session': other.toJson(),
      'activeMs': 1000,
    });
    await t.controller.writeDoc(doc, {'session': s.toJson(), 'activeMs': 1000});
    await t.controller.recoverFinishedQso();
    expect(t.controller.progress.history, hasLength(2));
    expect(
      t.controller.progress.history.every(
        (h) => h.source == ExerciseSource.qso,
      ),
      isTrue,
    );
    expect(await t.controller.readDoc(doc), isNull);
    expect(await t.controller.docNames(), isNot(contains(doc)));
    await t.controller.recoverFinishedQso();
    expect(t.controller.progress.history, hasLength(2));
  });
}
