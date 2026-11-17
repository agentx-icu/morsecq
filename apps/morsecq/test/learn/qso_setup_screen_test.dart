import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';
import 'package:morsecq/ui/learn/qso/qso_protocol_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_screen.dart';
import 'package:morsecq/ui/learn/qso/qso_setup_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

Future<(TestTraining, FakeLearnPlaybackFactory)> _pump(
  WidgetTester tester, {
  int lesson = 3,
  Future<void> Function(TrainingController c)? before,
  Future<void>? playbackGate,
}) async {
  tester.view.physicalSize = const Size(430, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final t = await TestTraining.create(
    progress: TrainerProgress(currentLesson: lesson),
  );
  addTearDown(t.controller.dispose);
  await before?.call(t.controller);
  final playback = FakeLearnPlaybackFactory();
  await tester.pumpWidget(
    l10nApp(
      home: QsoSetupScreen(
        controller: t.controller,
        playback: playbackGate == null
            ? playback
            : _GatedPreview(playback, playbackGate),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (t, playback);
}

final class _GatedPreview implements LearnPlaybackFactory {
  const _GatedPreview(this.delegate, this.gate);
  final FakeLearnPlaybackFactory delegate;
  final Future<void> gate;

  @override
  Future<LearnPlayback> create(TrainingSettings settings) async {
    await gate;
    return delegate.create(settings);
  }
}

ButtonStyleButton _start(WidgetTester tester) =>
    tester.widget<ButtonStyleButton>(find.byKey(const ValueKey('qso-start')));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// A QSO played to the end with level-2 hints.
QsoSession _finished() {
  final s = QsoSession.start(
    scenario: QsoScenario.shortExchange,
    seed: 4,
    local: const QsoStation(
      callsign: 'BI1ABC',
      name: 'TOM',
      qth: 'PARIS',
      serialNumber: '001',
      parkReference: 'K-1234',
    ),
    characterWpm: 20,
    effectiveWpm: 20,
  );
  var id = 0;
  while (!s.isDone) {
    while (s.consecutiveErrors < QsoSession.hintAfterErrors) {
      s.submit('e${id++}', 'ZZZ');
    }
    s.submit('a${id++}', s.hint().example);
  }
  return s;
}

final class _StationWriteGate implements TrainingDocStore {
  final _delegate = InMemoryTrainingDocStore();
  final pending = Completer<void>();
  int stationWrites = 0;

  @override
  Future<Map<String, Object?>?> read(String name) => _delegate.read(name);

  @override
  Future<void> write(String name, Map<String, Object?> json) async {
    if (name == QsoPractice.stationDoc) {
      stationWrites++;
      await pending.future;
    }
    await _delegate.write(name, json);
  }

  @override
  Future<void> delete(String name) => _delegate.delete(name);

  @override
  Future<List<String>> names() => _delegate.names();
}

Future<(TrainingController, _StationWriteGate)> _gatedSetup(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(430, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final docs = _StationWriteGate();
  final controller = TrainingController(
    progressStore: InMemoryTrainerStore(),
    settingsStore: InMemoryTrainingSettingsStore(),
    docs: docs,
  );
  await controller.load();
  addTearDown(controller.dispose);
  final draft = QsoSession.start(
    scenario: QsoScenario.shortExchange,
    seed: 11,
    local: const QsoStation(callsign: 'BI1ABC', name: 'TOM', qth: 'PARIS'),
    characterWpm: 20,
    effectiveWpm: 20,
  );
  await controller.saveQsoDraft(draft);
  await tester.pumpWidget(
    l10nApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            key: const ValueKey('open-qso'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => QsoSetupScreen(
                  controller: controller,
                  playback: FakeLearnPlaybackFactory(),
                ),
              ),
            ),
            child: const Text('QSO'),
          ),
        ),
      ),
    ),
  );
  await _tap(tester, find.byKey(const ValueKey('open-qso')));
  return (controller, docs);
}

void main() {
  testWidgets('starting a QSO admits only one navigation while saving', (
    tester,
  ) async {
    final (_, docs) = await _gatedSetup(tester);
    await tester.showKeyboard(find.byType(TextField).first);
    await tester.pump();
    final start = _start(tester).onPressed!;
    final resume = tester
        .widget<ButtonStyleButton>(find.byKey(const ValueKey('qso-resume')))
        .onPressed!;
    start();
    await tester.pump();
    expect(docs.stationWrites, 1);
    start();
    resume();
    docs.pending.complete();
    await tester.pumpAndSettle();

    expect(docs.stationWrites, 1);
    expect(find.byType(QsoScreen, skipOffstage: false), findsOneWidget);
    expect(tester.widget<QsoScreen>(find.byType(QsoScreen)).resumed, isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(QsoSetupScreen), findsOneWidget);
  });

  testWidgets('leaving setup during a station save keeps the old QSO draft', (
    tester,
  ) async {
    final (controller, docs) = await _gatedSetup(tester);
    _start(tester).onPressed!();
    await tester.pump();
    expect(docs.stationWrites, 1);

    await tester.pageBack();
    await tester.pump();
    docs.pending.complete();
    await tester.pumpAndSettle();

    expect(find.byType(QsoScreen, skipOffstage: false), findsNothing);
    expect(find.byKey(const ValueKey('open-qso')), findsOneWidget);
    expect((await controller.loadQsoDraft())?.session.seed, 11);
  });

  testWidgets('untaught symbols play on tap, reusing one playback', (
    tester,
  ) async {
    final (t, playback) = await _pump(tester);
    final chips = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('qso-missing-'),
    );
    expect(chips, findsWidgets);
    await _tap(tester, chips.first);
    await tester.pump(const Duration(seconds: 2));
    expect(playback.created, hasLength(1));
    expect(playback.sink.events.where((e) => e.on), isNotEmpty);
    await _tap(tester, chips.at(1));
    await tester.pump(const Duration(seconds: 2));
    expect(
      playback.created,
      hasLength(1),
      reason: 'same settings, same player',
    );

    // New settings rebuild the playback with them.
    await t.controller.updateSettings(
      t.controller.settings.copyWith(
        trainer: t.controller.trainerSettings.copyWith(toneHz: 600),
      ),
    );
    await _tap(tester, chips.first);
    await tester.pump(const Duration(seconds: 2));
    expect(playback.created, hasLength(2));
    expect(playback.created.last.trainer.toneHz, 600);
    expect(playback.disposeCalls, 1);
  });

  testWidgets('navigation cancels a preview that is still preparing', (
    tester,
  ) async {
    final ready = Completer<void>();
    final (_, playback) = await _pump(tester, playbackGate: ready.future);
    final chip = find
        .byWidgetPredicate(
          (w) =>
              w is ActionChip &&
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('qso-missing-'),
        )
        .first;
    await _tap(tester, chip);
    await _tap(tester, find.byKey(const ValueKey('qso-practise-protocol')));
    expect(find.byType(QsoProtocolScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    ready.complete();
    await tester.pump();
    expect(playback.sink.events.where((e) => e.on), isEmpty);

    await _tap(tester, chip);
    expect(playback.sink.events.where((e) => e.on), isNotEmpty);
    expect(playback.created, hasLength(1));
  });

  testWidgets('each scenario asks for and validates its own fields', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.byType(TextField), findsOneWidget, reason: 'callsign only');
    expect(_start(tester).onPressed, isNotNull);

    await _tap(tester, find.text(en.learnQsoRespond));
    expect(find.byType(TextField), findsNWidgets(3));
    await tester.enterText(find.byType(TextField).at(1), 'TWO WORDS');
    await tester.pump();
    expect(find.text(en.learnQsoInvalidWord), findsOneWidget);
    expect(_start(tester).onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(1), 'ANN');
    await tester.pump();
    expect(find.text(en.learnQsoInvalidWord), findsNothing);
    expect(_start(tester).onPressed, isNotNull);

    await _tap(tester, find.byKey(const ValueKey('qso-scenario-contest')));
    final serial = find.byKey(const ValueKey('qso-station-serial'));
    await tester.enterText(serial, 'ABC');
    await tester.pump();
    expect(find.text(en.qsoAdvancedInvalidSerial), findsOneWidget);
    expect(_start(tester).onPressed, isNull);

    await _tap(tester, find.byKey(const ValueKey('qso-scenario-pota')));
    final park = find.byKey(const ValueKey('qso-station-park'));
    await tester.enterText(park, '!!');
    await tester.pump();
    expect(find.text(en.qsoAdvancedInvalidPark), findsOneWidget);
    expect(_start(tester).onPressed, isNull);
    expect(find.byKey(const ValueKey('qso-station-serial')), findsNothing);
  });

  testWidgets('an invalid callsign also disables the exchange shortcut', (
    tester,
  ) async {
    await _pump(tester);
    final exchange = find.byKey(const ValueKey('qso-practise-exchange'));
    expect(tester.widget<ButtonStyleButton>(exchange).onPressed, isNotNull);
    await tester.enterText(find.byType(TextField).first, '12');
    await tester.pump();
    expect(tester.widget<ButtonStyleButton>(exchange).onPressed, isNull);
  });

  testWidgets('the exchange shortcut runs a short exchange and comes back', (
    tester,
  ) async {
    await _pump(tester);
    await _tap(tester, find.text(en.learnQsoCall));
    await _tap(tester, find.byKey(const ValueKey('qso-practise-exchange')));
    final qso = tester.widget<QsoScreen>(find.byType(QsoScreen));
    expect(qso.session.scenario, QsoScenario.shortExchange);
    expect(qso.resumed, isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(QsoSetupScreen), findsOneWidget);
  });

  testWidgets('readiness drills open from the card', (tester) async {
    final (t, _) = await _pump(tester, lesson: 42);
    final shorthand = find.byKey(const ValueKey('qso-practise-shorthand'));
    expect(
      tester.widget<ButtonStyleButton>(shorthand).onPressed != null,
      t.controller.availableReceiveKinds.contains(
        ReceiveDrillKind.abbreviations,
      ),
    );
    await _tap(tester, shorthand);
    expect(
      tester
          .widget<ReceiveDrillScreen>(find.byType(ReceiveDrillScreen))
          .session
          .kind,
      ReceiveDrillKind.abbreviations,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    final unmastered = t.controller.qsoReadiness.unmastered;
    expect(unmastered, isNotEmpty);
    await _tap(tester, find.byKey(const ValueKey('qso-practise-symbols')));
    final drill = tester.widget<ReceiveDrillScreen>(
      find.byType(ReceiveDrillScreen),
    );
    expect(drill.session.chars, everyElement(isIn(unmastered)));
    await tester.pageBack();
    await tester.pumpAndSettle();

    await _tap(tester, find.byKey(const ValueKey('qso-practise-protocol')));
    expect(find.byType(QsoProtocolScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(QsoSetupScreen), findsOneWidget);
  });

  testWidgets('a draft holding a finished QSO is recorded, not resumed', (
    tester,
  ) async {
    final done = _finished();
    final (t, _) = await _pump(tester, before: (c) => c.saveQsoDraft(done));
    expect(find.byKey(const ValueKey('qso-resume')), findsNothing);
    expect(await t.controller.loadQsoDraft(), isNull);
    final record = t.controller.progress.history.single;
    expect(record.source, ExerciseSource.qso);
  });
}
