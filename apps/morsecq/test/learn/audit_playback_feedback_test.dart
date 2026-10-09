import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';
import 'package:morsecq/ui/learn/send/send_practice_screen.dart';

import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

final class _FailingOutput implements MorseSink {
  bool fail = true;
  int attemptedMarks = 0;
  @override
  Future<void> prepare() async {}
  @override
  Future<void> dispose() async {}
  @override
  void off() {}
  @override
  void on() {
    attemptedMarks++;
    if (fail && attemptedMarks >= 2) throw StateError('output removed');
  }
}

final class _Playback implements LearnPlaybackFactory {
  final clock = FakeClock();
  final sink = _FailingOutput();
  @override
  Future<LearnPlayback> create(TrainingSettings settings) async =>
      LearnPlayback(
        sink: sink,
        clock: clock,
        flash: null,
        dispose: sink.dispose,
      );
}

void main() {
  testWidgets(
    'audit failed send model remains ungraded and can be heard again',
    (tester) async {
      tester.view.physicalSize = const Size(430, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final t = await TestTraining.create(
        settings: const TrainingSettings(keyerMode: KeyerMode.straight),
      );
      final playback = _Playback();
      await tester.pumpWidget(
        l10nApp(
          home: SendPracticeScreen(
            controller: t.controller,
            playback: playback,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('send-guide-hear')));
      playback.clock.advance(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(StraightKeyButton), findsNothing);
      expect(t.controller.progress.history, isEmpty);
      final hear = tester.widget<FilledButton>(
        find.byKey(const ValueKey('send-guide-hear')),
      );
      expect(hear.onPressed, isNotNull);
      playback.sink.fail = false;
      await tester.tap(find.byKey(const ValueKey('send-guide-hear')));
      playback.clock.advance(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(StraightKeyButton), findsOneWidget);
      expect(t.controller.progress.history, isEmpty);
    },
  );

  testWidgets(
    'audit failed remote QSO output keeps the stage and offers retry',
    (tester) async {
      tester.view.physicalSize = const Size(430, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final t = await TestTraining.create(
        settings: const TrainingSettings(keyerMode: KeyerMode.straight),
      );
      final playback = _Playback();
      final session = QsoSession.start(
        scenario: QsoScenario.shortExchange,
        seed: 51,
        local: const QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS'),
        characterWpm: 20,
        effectiveWpm: 20,
      );
      await tester.pumpWidget(
        l10nApp(
          home: QsoScreen(
            controller: t.controller,
            playback: playback,
            session: session,
          ),
        ),
      );
      await tester.pumpAndSettle();
      playback.clock.advance(const Duration(minutes: 2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(session.stage, QsoStage.callConfirm);
      expect(t.controller.progress.history, isEmpty);
      expect(find.byType(StraightKeyButton), findsOneWidget);
      playback.sink.fail = false;
      await tester.tap(find.text(en.learnQsoPlayAgain));
      playback.clock.advance(const Duration(minutes: 2));
      await tester.pumpAndSettle();
      expect(session.stage, QsoStage.callConfirm);
      expect(session.repeats, 1);
      expect(find.byType(StraightKeyButton), findsOneWidget);
      expect(t.controller.progress.history, isEmpty);
      expect((await t.controller.loadQsoDraft())!.session.repeats, 1);
    },
  );
}
