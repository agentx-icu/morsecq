import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/learn/comprehension/listening_comprehension_screen.dart';

import '../helpers/fake_playback.dart';
import '../helpers/l10n.dart';
import '../helpers/test_controller.dart';

/// Progress store whose saves can fail.
final class _FlakyProgress implements TrainerStore {
  _FlakyProgress(TrainerProgress initial)
    : _inner = InMemoryTrainerStore(initial);
  final InMemoryTrainerStore _inner;
  bool failing = false;
  @override
  Future<TrainerProgress?> load() => _inner.load();
  @override
  Future<void> save(TrainerProgress progress) async {
    if (failing) throw StateError('disk full');
    await _inner.save(progress);
  }

  @override
  Future<void> clear() => _inner.clear();
}

Future<FakeLearnPlaybackFactory> _open(
  WidgetTester tester,
  TrainingController controller,
) async {
  tester.view.physicalSize = const Size(430, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final playback = FakeLearnPlaybackFactory();
  await tester.pumpWidget(
    l10nApp(
      home: ListeningComprehensionScreen(
        controller: controller,
        playback: playback,
        initialMode: ListeningMode.words,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return playback;
}

Future<void> _listenAndAnswer(
  WidgetTester tester,
  FakeLearnPlaybackFactory playback,
) async {
  await tester.tap(find.byKey(const ValueKey('comprehension-play')));
  await tester.pump();
  playback.clock.advance(const Duration(minutes: 5));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, 'WRONG');
  await tester.ensureVisible(
    find.byKey(const ValueKey('comprehension-submit')),
  );
  await tester.tap(find.byKey(const ValueKey('comprehension-submit')));
  await tester.pumpAndSettle();
}

Future<void> _choose(
  WidgetTester tester,
  String dropdownKey,
  String item,
) async {
  await tester.tap(find.byKey(ValueKey(dropdownKey)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item).last);
  await tester.pumpAndSettle();
}

ButtonStyleButton _nextButton(WidgetTester tester) =>
    tester.widget(find.byKey(const ValueKey('comprehension-next')));

void main() {
  testWidgets('before listening, the mode and spacing can be chosen', (
    tester,
  ) async {
    final t = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 40),
    );
    addTearDown(t.controller.dispose);
    await _open(tester, t.controller);
    expect(find.text(en.comprehensionWordsHelp), findsOneWidget);
    await _choose(tester, 'comprehension-mode', en.comprehensionStory);
    expect(find.text(en.comprehensionStoryHelp), findsOneWidget);
    expect(find.text(en.comprehensionWordsHelp), findsNothing);

    final char = t.controller.trainerSettings.characterWpm;
    await _choose(tester, 'comprehension-speed', '13');
    expect(
      find.text(en.comprehensionSpeed(char.toStringAsFixed(0), '13')),
      findsOneWidget,
    );
    await _choose(tester, 'comprehension-speed', '25');
    expect(
      find.text(en.comprehensionSpeed('25', '25')),
      findsOneWidget,
      reason: 'characters are never slower than the spacing',
    );
    expect(
      t.controller.trainerSettings.characterWpm,
      char,
      reason: 'a practice choice never changes the saved settings',
    );
  });

  testWidgets('Next waits for the save, then deals a new exercise', (
    tester,
  ) async {
    final t = await TestTraining.create(
      progress: TrainerProgress(currentLesson: 40),
    );
    addTearDown(t.controller.dispose);
    final playback = await _open(tester, t.controller);
    await _listenAndAnswer(tester, playback);
    expect(t.controller.progress.listeningAttempts, hasLength(1));
    expect(_nextButton(tester).onPressed, isNotNull);
    await tester.ensureVisible(
      find.byKey(const ValueKey('comprehension-next')),
    );
    await tester.tap(find.byKey(const ValueKey('comprehension-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('comprehension-target')), findsNothing);
    expect(find.byKey(const ValueKey('comprehension-play')), findsOneWidget);
    expect(find.byType(ListeningComprehensionScreen), findsOneWidget);
  });

  testWidgets('a failed save is offered again and Next stays off until then', (
    tester,
  ) async {
    final store = _FlakyProgress(TrainerProgress(currentLesson: 40));
    final c = TrainingController(
      progressStore: store,
      settingsStore: InMemoryTrainingSettingsStore(),
      now: () => kTestNow,
      random: Random(1),
    );
    await c.load();
    addTearDown(c.dispose);
    final playback = await _open(tester, c);
    store.failing = true;
    await _listenAndAnswer(tester, playback);
    expect(find.text(en.comprehensionSaveFailed), findsOneWidget);
    expect(_nextButton(tester).onPressed, isNull);

    store.failing = false;
    await tester.tap(find.text(en.actionRetry));
    await tester.pumpAndSettle();
    expect(find.text(en.comprehensionSaveFailed), findsNothing);
    expect(_nextButton(tester).onPressed, isNotNull);
    expect(c.progress.listeningAttempts, hasLength(1), reason: 'saved once');
  });
}
