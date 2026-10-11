import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/di/app_settings.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/training/qso_practice.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/appearance/appearance_page.dart';
import 'package:morsecq/ui/learn/learn_home.dart';
import 'package:morsecq/ui/learn/placement/placement_screen.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

/// A progress file that cannot be read.
final class _UnreadableStore implements TrainerStore {
  @override
  Future<TrainerProgress?> load() async =>
      throw const FileSystemException('unreadable progress');

  @override
  Future<void> save(TrainerProgress progress) async {}

  @override
  Future<void> clear() async {}
}

Future<void> _pumpHome(WidgetTester tester, TrainingController c) async {
  tester.view.physicalSize = const Size(430, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  addTearDown(c.dispose);
  final settings = AppSettings(store: InMemoryKeyValueStore());
  addTearDown(settings.dispose);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: settings,
      child: l10nApp(
        home: LearnHome(controller: c, playback: FakeLearnPlaybackFactory()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<TrainingController> _atLesson(int lesson) async =>
    (await TestTraining.create(
      progress: TrainerProgress(currentLesson: lesson),
    )).controller;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('unreadable progress starts fresh and says so', (tester) async {
    final c = TrainingController(
      progressStore: _UnreadableStore(),
      settingsStore: InMemoryTrainingSettingsStore(),
      now: () => kTestNow,
      random: Random(1),
    );
    await c.load();
    expect(c.loadError, isA<FileSystemException>());
    await _pumpHome(tester, c);
    expect(find.text(en.learnLoadFailed), findsOneWidget);
    expect(c.progress.currentLesson, 1, reason: 'a fresh start, not a crash');
  });

  testWidgets('readable progress shows no load warning', (tester) async {
    await _pumpHome(tester, await _atLesson(10));
    expect(find.text(en.learnLoadFailed), findsNothing);
  });

  testWidgets('a first-use learner can check their level', (tester) async {
    final c = await _atLesson(1);
    expect(c.learnerStage, LearnerStage.firstUse);
    await _pumpHome(tester, c);
    await _tap(tester, find.byKey(const ValueKey('placement-check')));
    expect(find.byType(PlacementScreen), findsOneWidget);
  });

  testWidgets('the palette button opens appearance', (tester) async {
    await _pumpHome(tester, await _atLesson(10));
    await _tap(tester, find.byTooltip(en.appearanceTitle));
    expect(find.byType(AppearancePage), findsOneWidget);
  });

  for (final lesson in [2, 42]) {
    testWidgets('the QSO entry states its readiness at lesson $lesson', (
      tester,
    ) async {
      final c = await _atLesson(lesson);
      await _pumpHome(tester, c);
      final readiness = c.qsoReadiness;
      final expected = switch (readiness.level) {
        QsoReadinessLevel.symbols => en.learnQsoSymbolsToGo(
          readiness.missing.length,
        ),
        QsoReadinessLevel.ready => en.learnQsoReady,
        _ => en.learnQsoPractiseFirst,
      };
      if (lesson == 2) {
        expect(readiness.level, QsoReadinessLevel.symbols);
        expect(readiness.missing, isNotEmpty);
      } else {
        expect(
          readiness.level,
          isNot(QsoReadinessLevel.symbols),
          reason: 'every symbol is taught by lesson 42',
        );
      }
      expect(find.text(expected), findsOneWidget);
    });
  }
}
