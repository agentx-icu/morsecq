import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';

import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('QSO setup stays paused in the background on $platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final playback = _DelayedPlayback();
      final session = await _pump(tester, playback);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      playback.complete();
      await tester.pump();
      final backgroundOutput = List.of(playback.sink.events);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(backgroundOutput, isEmpty);
      expect(playback.sink.events, isEmpty);
      expect(session.learnerTurns, 0);
      await tester.tap(find.byIcon(Icons.volume_up_outlined));
      await tester.pump();
      expect(playback.sink.events, isNotEmpty);
      expect(session.repeats, 0, reason: 'The initial call was never heard');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(playback.disposals, 1);
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('QSO retired during setup disposes its late playback', (
    tester,
  ) async {
    final playback = _DelayedPlayback();
    await _pump(tester, playback);
    await tester.pumpWidget(const SizedBox.shrink());
    playback.complete();
    await tester.pump();
    expect(playback.sink.events, isEmpty);
    expect(playback.disposals, 1);
  });
}

Future<QsoSession> _pump(WidgetTester tester, _DelayedPlayback playback) async {
  tester.view.physicalSize = const Size(430, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final training = await TestTraining.create();
  addTearDown(training.controller.dispose);
  final session = QsoSession.start(
    scenario: QsoScenario.respondToCq,
    seed: 11,
    local: const QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS'),
    characterWpm: 20,
    effectiveWpm: 20,
  );
  await tester.pumpWidget(
    l10nApp(
      home: QsoScreen(
        controller: training.controller,
        playback: playback,
        session: session,
        screenWake: _NoWake(),
      ),
    ),
  );
  return session;
}

final class _DelayedPlayback implements LearnPlaybackFactory {
  final _ready = Completer<LearnPlayback>();
  final clock = FakeClock();
  late final sink = RecordingSink(clock: clock);
  int disposals = 0;

  @override
  Future<LearnPlayback> create(TrainingSettings settings) => _ready.future;

  void complete() => _ready.complete(
    LearnPlayback(
      sink: sink,
      clock: clock,
      flash: null,
      dispose: () async => disposals++,
    ),
  );
}

final class _NoWake implements ScreenWakeApi {
  @override
  Future<void> keepOn(bool on) async {}
}
