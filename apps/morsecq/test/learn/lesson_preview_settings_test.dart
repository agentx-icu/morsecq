import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';

import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

final class _PendingPlayback {
  _PendingPlayback(this.settings) {
    sink = RecordingSink(clock: clock);
    playback = LearnPlayback(
      sink: sink,
      clock: clock,
      flash: null,
      dispose: () async => disposed = true,
    );
  }

  final TrainingSettings settings;
  final clock = FakeClock();
  late final RecordingSink sink;
  late final LearnPlayback playback;
  final ready = Completer<LearnPlayback>();
  bool disposed = false;

  void complete() => ready.complete(playback);
}

final class _DelayedPlaybackFactory implements LearnPlaybackFactory {
  final pending = <_PendingPlayback>[];

  @override
  Future<LearnPlayback> create(TrainingSettings settings) {
    final next = _PendingPlayback(settings);
    pending.add(next);
    return next.ready.future;
  }
}

void main() {
  Future<(TestTraining, _DelayedPlaybackFactory)> pump(
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final training = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 3),
      settings: const TrainingSettings(hapticEnabled: true),
    );
    addTearDown(training.controller.dispose);
    final factory = _DelayedPlaybackFactory();
    await tester.pumpWidget(
      l10nApp(
        home: LearnHome(controller: training.controller, playback: factory),
      ),
    );
    await tester.pumpAndSettle();
    return (training, factory);
  }

  testWidgets('disabling haptics cancels a preview still being prepared', (
    tester,
  ) async {
    final (training, factory) = await pump(tester);
    await tester.tap(find.byKey(const ValueKey('hear-newest')));
    await tester.pump();
    final old = factory.pending.single;
    await training.controller.updateSettings(
      training.controller.settings.copyWith(hapticEnabled: false),
    );
    old.complete();
    await tester.pumpAndSettle();
    expect(old.sink.events.where((event) => event.on), isEmpty);
    expect(old.disposed, isTrue);
  });

  testWidgets('changing output settings stops a preview already playing', (
    tester,
  ) async {
    final (training, factory) = await pump(tester);
    await tester.tap(find.byKey(const ValueKey('hear-newest')));
    await tester.pump();
    final old = factory.pending.single;
    old.complete();
    await tester.pumpAndSettle();
    expect(old.sink.isOn, isTrue);
    await training.controller.updateSettings(
      training.controller.settings.copyWith(hapticEnabled: false),
    );
    await tester.pumpAndSettle();
    expect(old.sink.isOn, isFalse);
    expect(old.disposed, isTrue);
  });

  testWidgets(
    'a new preview does not reuse a pending bundle for old settings',
    (tester) async {
      final (training, factory) = await pump(tester);
      await tester.tap(find.byKey(const ValueKey('hear-newest')));
      await tester.pump();
      final old = factory.pending.single;
      await training.controller.updateSettings(
        training.controller.settings.copyWith(hapticEnabled: false),
      );
      await tester.tap(find.byKey(const ValueKey('hear-newest')));
      await tester.pump();
      expect(factory.pending, hasLength(2));
      final current = factory.pending.last;
      expect(current.settings.hapticEnabled, isFalse);
      old.complete();
      await tester.pumpAndSettle();
      expect(old.sink.events.where((event) => event.on), isEmpty);
      expect(old.disposed, isTrue);
      current.complete();
      await tester.pumpAndSettle();
      expect(current.sink.events.where((event) => event.on), isNotEmpty);
    },
  );
}
