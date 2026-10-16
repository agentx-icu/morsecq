import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/receive_session.dart';
import 'package:morsecq/training/training_controller.dart';
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
      home: QsoSetupScreen(controller: t.controller, playback: playback),
    ),
  );
  await tester.pumpAndSettle();
  return (t, playback);
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

void main() {
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
