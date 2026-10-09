import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_io/testing.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/learn/comprehension/listening_comprehension_screen.dart';
import 'package:morsecq/ui/learn/learn_playback.dart';

import '../helpers/l10n.dart';
import '../helpers/test_controller.dart';

/// Exercises the actual SidetoneSink recovery path. Only the OS/audio API is
/// replaced; a silent refusal must not become a completed listening attempt.
final class _SoloudOutput implements SoloudApi {
  bool refuseOutput = false;
  int? failFadeAt;
  int audibleMarks = 0;
  int startedVoices = 0;
  int refusedResumes = 0;
  int refusedStarts = 0;
  @override
  bool isInitialized = false;
  @override
  Future<void> init() async => isInitialized = true;
  @override
  Future<SidetoneSource> loadSineWaveform() async => const SidetoneSource(1);
  @override
  void setWaveformFrequency(SidetoneSource source, double hz) {}
  @override
  SidetoneVoice playLooping(SidetoneSource source, {required double volume}) {
    if (refuseOutput) {
      refusedStarts++;
      throw StateError('OS refused audio output');
    }
    return SidetoneVoice(++startedVoices);
  }

  @override
  void resumeVoice(SidetoneVoice voice) {
    if (refuseOutput) {
      refusedResumes++;
      throw StateError('OS refused audio output');
    }
  }

  @override
  void fadeVolume(SidetoneVoice voice, double to, Duration over) {
    if (to > 0 && ++audibleMarks == failFadeAt) {
      throw StateError('output lost during a later mark');
    }
  }

  @override
  void setVolume(SidetoneVoice voice, double volume) {}
  @override
  Future<void> stop(SidetoneVoice voice) async {}
  @override
  Future<void> disposeSource(SidetoneSource source) async {}
  @override
  Future<void> deinit() async => isInitialized = false;
}

final class _SidetonePlayback implements LearnPlaybackFactory {
  _SidetonePlayback(this.api, {this.refuseAfterPrepare = false});
  final _SoloudOutput api;
  final bool refuseAfterPrepare;
  final clock = FakeClock();
  SidetoneSink? tone;
  int creates = 0;
  @override
  Future<LearnPlayback> create(TrainingSettings settings) async {
    creates++;
    final sink = SidetoneSink(api: api);
    await sink.prepare();
    tone = sink;
    if (refuseAfterPrepare && creates == 1) api.refuseOutput = true;
    return LearnPlayback(
      sink: CompositeSink([sink]),
      sidetone: sink,
      clock: clock,
      flash: null,
      dispose: sink.dispose,
    );
  }
}

Future<TestTraining> _open(
  WidgetTester tester,
  _SidetonePlayback playback,
) async {
  final training = await TestTraining.create(
    progress: TrainerProgress(currentLesson: 40),
  );
  addTearDown(training.controller.dispose);
  await tester.pumpWidget(
    l10nApp(
      home: ListeningComprehensionScreen(
        controller: training.controller,
        playback: playback,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return training;
}

Future<void> _complete(WidgetTester tester, _SidetonePlayback playback) async {
  await tester.ensureVisible(find.byKey(const ValueKey('comprehension-play')));
  await tester.tap(find.byKey(const ValueKey('comprehension-play')));
  await tester.pump();
  playback.clock.advance(const Duration(minutes: 5));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'prepared Sidetone denied by the OS cannot enable independent grading',
    (tester) async {
      final api = _SoloudOutput();
      final playback = _SidetonePlayback(api, refuseAfterPrepare: true);
      final training = await _open(tester, playback);
      expect(api.startedVoices, 1, reason: 'prepare really created a voice');
      await _complete(tester, playback);
      expect(api.refusedResumes, greaterThan(0));
      expect(api.refusedStarts, greaterThan(0));
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(const ValueKey('comprehension-submit')), findsNothing);
      expect(find.text(en.comprehensionAudioFailed), findsOneWidget);
      expect(training.controller.progress.listeningAttempts, isEmpty);
      expect(training.controller.progress.mistakeNotebook.entries, isEmpty);
    },
  );

  testWidgets(
    'later real Sidetone fade failure stops timers and leaves no listening evidence',
    (tester) async {
      final api = _SoloudOutput()..failFadeAt = 2;
      final playback = _SidetonePlayback(api);
      final training = await _open(tester, playback);
      await tester.tap(find.byKey(const ValueKey('comprehension-play')));
      await tester.pump();
      expect(api.audibleMarks, 1);
      expect(
        () => playback.clock.advance(const Duration(minutes: 5)),
        returnsNormally,
      );
      await tester.pumpAndSettle();
      expect(api.audibleMarks, 2);
      expect(playback.clock.pendingTimers, 0);
      expect(find.byType(TextField), findsNothing);
      expect(find.text(en.comprehensionAudioFailed), findsOneWidget);
      expect(training.controller.progress.listeningAttempts, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed replay revokes prior completion until a full audible retry',
    (tester) async {
      final api = _SoloudOutput();
      final playback = _SidetonePlayback(api);
      final training = await _open(tester, playback);
      await _complete(tester, playback);
      expect(find.byType(TextField), findsOneWidget);
      api.refuseOutput = true;
      await _complete(tester, playback);
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(const ValueKey('comprehension-reveal')), findsNothing);
      expect(training.controller.progress.listeningAttempts, isEmpty);
      await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
      api.refuseOutput = false;
      await tester.ensureVisible(find.text(en.actionRetry));
      await tester.tap(find.text(en.actionRetry));
      await tester.pumpAndSettle();
      await _complete(tester, playback);
      await tester.enterText(find.byType(TextField), 'WRONG');
      await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
      await tester.pumpAndSettle();
      expect(
        training.controller.progress.listeningAttempts.single.assisted,
        isTrue,
      );
    },
  );
}
