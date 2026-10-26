import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_doc_store.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';

const _me = QsoStation(callsign: 'BD1XYZ', name: 'LI', qth: 'PARIS');

TrainingController _controller(String root) => TrainingController(
  progressStore: InMemoryTrainerStore(TrainerProgress(currentLesson: 30)),
  settingsStore: InMemoryTrainingSettingsStore(
    const TrainingSettings(keyerMode: KeyerMode.straight),
  ),
  docs: FileTrainingDocStore.inDataDirectory(root),
);

Future<(TrainingController, FakeLearnPlaybackFactory, String)> _open(
  WidgetTester tester,
) async {
  final directory = (await tester.runAsync(
    () => Directory.systemTemp.createTemp('morsecq_visible_qso_'),
  ))!;
  final controller = _controller(directory.path);
  await tester.runAsync(controller.load);
  final playback = FakeLearnPlaybackFactory();
  final session = QsoSession.start(
    scenario: QsoScenario.shortExchange,
    seed: 11,
    local: _me,
    characterWpm: 20,
    effectiveWpm: 20,
  );
  tester.view.physicalSize = const Size(430, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await _drain(tester, controller);
    controller.dispose();
    await tester.runAsync(() => directory.delete(recursive: true));
    tester.view.reset();
  });
  await tester.pumpWidget(
    l10nApp(
      home: QsoScreen(
        controller: controller,
        playback: playback,
        session: session,
        screenWake: _NoWake(),
      ),
    ),
  );
  await tester.pump();
  for (var i = 0; i < 400; i++) {
    playback.clock.advance(const Duration(milliseconds: 100));
    await tester.pump();
  }
  return (controller, playback, directory.path);
}

Future<QsoDraft?> _readWhileVisible(
  WidgetTester tester,
  TrainingController controller,
  String root, {
  Duration advance = const Duration(milliseconds: 750),
}) async {
  // Pump beyond the bounded 400 ms checkpoint, then await only writes the UI
  // already submitted. Do not background, dispose or call its draft-save hook.
  await tester.pump(advance);
  await _drain(tester, controller);
  expect(find.byType(QsoScreen), findsOneWidget);
  final reopened = _controller(root);
  try {
    await tester.runAsync(reopened.load);
    return await tester.runAsync<QsoDraft?>(reopened.loadQsoDraft);
  } finally {
    reopened.dispose();
  }
}

Future<Object?> _drain(
  WidgetTester tester,
  TrainingController controller, {
  bool expectSuccess = true,
}) async {
  var done = false;
  Object? failure;
  unawaited(
    controller.flush().then<void>(
      (_) {
        done = true;
      },
      onError: (Object error) {
        failure = error;
        done = true;
      },
    ),
  );
  final deadline = Stopwatch()..start();
  while (!done && deadline.elapsed < const Duration(seconds: 10)) {
    // Real file completions and the widget's fake-zone microtasks both need
    // to run. Wait on completion, rather than a fixed IO-settle iteration count.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }
  expect(done, isTrue, reason: 'The accepted draft writes did not settle');
  if (expectSuccess) expect(failure, isNull);
  return failure;
}

Future<void> _key(WidgetTester tester, FakeClock clock, String text) async {
  final key = find.byType(StraightKeyButton);
  expect(key, findsOneWidget);
  for (final element in MorseEncoder.encode(text, const MorseTiming(wpm: 20))) {
    if (element.on) {
      final gesture = await tester.startGesture(tester.getCenter(key));
      clock.advance(element.duration);
      await tester.pump();
      await gesture.up();
      await tester.pump();
    } else {
      clock.advance(element.duration);
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
  testWidgets('visible typed reply reaches disk before any exit callback', (
    tester,
  ) async {
    final (controller, _, root) = await _open(tester);
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('qso-typed-reply')),
      'VISIBLE_TYPED_MARKER',
    );
    final draft = await _readWhileVisible(tester, controller, root);
    expect(draft?.pendingText, 'VISIBLE_TYPED_MARKER');
    expect(draft?.typedReply, isTrue);
    expect(draft?.pendingWasTyped, isTrue);
  });

  testWidgets('visible keyed reply reaches disk before any exit callback', (
    tester,
  ) async {
    final (controller, playback, root) = await _open(tester);
    await _key(tester, playback.clock, 'CQ');
    final decoded = tester.widget<Text>(
      find.byKey(const ValueKey('qso-decoded')),
    );
    expect(decoded.data?.trim(), 'CQ');
    final draft = await _readWhileVisible(tester, controller, root);
    expect(draft?.pendingText.trim(), 'CQ');
    expect(draft?.typedReply, isFalse);
    expect(draft?.pendingWasTyped, isFalse);
  });

  testWidgets('continuous typing checkpoints from the first dirty edit', (
    tester,
  ) async {
    final (controller, _, root) = await _open(tester);
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    final input = find.byKey(const ValueKey('qso-typed-reply'));
    await tester.enterText(input, 'FIRST');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(input, 'FIRST_SECOND');
    await tester.pump(const Duration(milliseconds: 150));
    final draft = await _readWhileVisible(
      tester,
      controller,
      root,
      advance: Duration.zero,
    );
    expect(draft?.pendingText, 'FIRST_SECOND');
  });

  testWidgets('clearing a saved reply replaces its disk checkpoint', (
    tester,
  ) async {
    final (controller, _, root) = await _open(tester);
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('qso-typed-reply')),
      'TO_CLEAR',
    );
    expect(
      (await _readWhileVisible(tester, controller, root))?.pendingText,
      'TO_CLEAR',
    );
    await tester.tap(find.widgetWithText(OutlinedButton, en.learnQsoClear));
    final draft = await _readWhileVisible(tester, controller, root);
    expect(draft?.pendingText, '');
    expect(draft?.pendingWasTyped, isFalse);
  });

  testWidgets('submitting before the checkpoint preserves the advanced turn', (
    tester,
  ) async {
    final (controller, _, root) = await _open(tester);
    final session = tester.widget<QsoScreen>(find.byType(QsoScreen)).session;
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('qso-typed-reply')),
      '${session.remote.callsign} DE BD1XYZ K',
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const ValueKey('qso-send')));
    await tester.pump();
    expect(session.stage, QsoStage.exchange);
    final draft = await _readWhileVisible(tester, controller, root);
    expect(draft?.session.stage, QsoStage.exchange);
    expect(draft?.pendingText, '');
    expect(draft?.session.toJson()['typedReplies'], 1);
  });

  testWidgets('a disposed screen cannot overwrite the next QSO checkpoint', (
    tester,
  ) async {
    final (controller, _, root) = await _open(tester);
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('qso-typed-reply')),
      'OLD_SESSION',
    );
    final next = QsoSession.start(
      scenario: QsoScenario.shortExchange,
      seed: 99,
      local: _me,
      characterWpm: 20,
      effectiveWpm: 20,
    );
    final playback = FakeLearnPlaybackFactory();
    await tester.pumpWidget(
      l10nApp(
        home: QsoScreen(
          key: const ValueKey('next-qso'),
          controller: controller,
          playback: playback,
          session: next,
          screenWake: _NoWake(),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 400; i++) {
      playback.clock.advance(const Duration(milliseconds: 100));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('qso-typed-reply')),
      'NEW_SESSION',
    );
    final draft = await _readWhileVisible(tester, controller, root);
    expect(draft?.session.seed, 99);
    expect(draft?.pendingText, 'NEW_SESSION');
    expect(tester.takeException(), isNull);
  });

  testWidgets('background saves the latest edit before its timer fires', (
    tester,
  ) async {
    final (controller, _, root) = await _open(tester);
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('qso-typed-reply')),
      'BACKGROUND_CHECKPOINT',
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    final draft = await _readWhileVisible(
      tester,
      controller,
      root,
      advance: Duration.zero,
    );
    expect(draft?.pendingText, 'BACKGROUND_CHECKPOINT');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  });

  testWidgets('finished QSO cannot be recreated by a late checkpoint', (
    tester,
  ) async {
    final (controller, playback, root) = await _open(tester);
    final session = tester.widget<QsoScreen>(find.byType(QsoScreen)).session;
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    for (final (text, expected) in [
      ('${session.remote.callsign} DE BD1XYZ K', QsoStage.exchange),
      ('UR RST 599 K', QsoStage.closing),
      ('TU 73 <SK>', QsoStage.done),
    ]) {
      await tester.enterText(
        find.byKey(const ValueKey('qso-typed-reply')),
        text,
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('qso-send')));
      await tester.pump();
      expect(session.stage, expected, reason: 'The typed reply was accepted');
      for (var i = 0; i < 400; i++) {
        playback.clock.advance(const Duration(milliseconds: 100));
        await tester.pump();
      }
    }
    expect(session.isDone, isTrue);
    final deadline = Stopwatch()..start();
    while (controller.progress.history.isEmpty &&
        deadline.elapsed < const Duration(seconds: 10)) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }
    expect(controller.progress.history, hasLength(1));
    final draft = await _readWhileVisible(tester, controller, root);
    expect(draft, isNull);
    expect(controller.progress.history, hasLength(1));
  });

  testWidgets('a failed file checkpoint remains a failure until a new save', (
    tester,
  ) async {
    final (controller, _, root) = await _open(tester);
    await tester.tap(find.byKey(const ValueKey('qso-typed-mode')));
    await tester.pump();
    await _drain(tester, controller);
    final blockedTemp = Directory(
      '$root/training/docs/${QsoPractice.draftDoc}.json.tmp',
    );
    await tester.runAsync(() => blockedTemp.create());
    final input = find.byKey(const ValueKey('qso-typed-reply'));
    await tester.enterText(input, 'FAILED_CHECKPOINT');
    await tester.pump(const Duration(milliseconds: 750));
    expect(
      await _drain(tester, controller, expectSuccess: false),
      isA<FileSystemException>(),
    );
    await tester.runAsync(() => blockedTemp.delete());
    await tester.enterText(input, 'RECOVERED_CHECKPOINT');
    final draft = await _readWhileVisible(tester, controller, root);
    expect(draft?.pendingText, 'RECOVERED_CHECKPOINT');
  });
}
