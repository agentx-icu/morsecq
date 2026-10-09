import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';
import 'package:morsecq/ui/learn/placement/placement_screen.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

final class _RetrySetup implements LearnPlaybackFactory {
  final fake = FakeLearnPlaybackFactory();
  final ready = Completer<void>();
  int creates = 0;
  @override
  Future<LearnPlayback> create(TrainingSettings settings) async {
    if (++creates == 1) throw StateError('device unavailable during setup');
    await ready.future;
    return fake.create(settings);
  }
}

void main() {
  testWidgets(
    'placement setup retry owns only one subscription and disposes it',
    (tester) async {
      final training = await TestTraining.create();
      addTearDown(training.controller.dispose);
      final playback = _RetrySetup();
      await tester.pumpWidget(
        l10nApp(
          home: PlacementScreen(
            controller: training.controller,
            playback: playback,
            seed: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.comprehensionAudioFailed), findsOneWidget);
      await tester.tap(find.text(en.actionRetry));
      await tester.pump();
      await tester.tap(find.text(en.actionRetry));
      await tester.pump();
      expect(playback.creates, 2, reason: 'concurrent retries share setup');
      playback.ready.complete();
      await tester.pumpAndSettle();
      expect(playback.fake.created, hasLength(1));
      expect(find.text(en.comprehensionAudioFailed), findsNothing);
      await tester.tap(find.byKey(const ValueKey('placement-start')));
      await tester.pump();
      expect(playback.fake.sink.isOn, isTrue);
      expect(playback.fake.clock.pendingTimers, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(playback.fake.disposeCalls, 1);
      expect(playback.fake.clock.pendingTimers, 0);
      expect(playback.fake.sink.isOn, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
