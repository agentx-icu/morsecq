import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/di/app_preferences.dart';
import 'package:morsecq/di/app_services.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:path/path.dart' as p;

/// The storage contract of doc/architecture/OFFLINE_LEARNING.md, exercised
/// against the device file system rather than in-memory stores.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory scratch;
  late String learningDir;
  late LocalLearningStore store;
  setUp(() async {
    scratch = await Directory.systemTemp.createTemp('morsecq_contract_');
    learningDir = p.join(scratch.path, 'morsecq', 'guest');
    store = LocalLearningStore(root: () async => learningDir);
  });
  tearDown(() => scratch.delete(recursive: true));

  File progressFile() => File(p.join(learningDir, 'training', 'progress.json'));

  testWidgets('backgrounding saves progress and documents before a kill', (
    tester,
  ) async {
    final host = TrainingControllerHost(store);
    final locale = LocaleController(InMemoryKeyValueStore());
    final services = AppServices(locale: locale, flush: host.flush)..start();
    final controller = await host.controller();
    // Neither write is awaited: only the lifecycle barrier may cover them.
    controller.setDailyGoal(61).ignore();
    controller.writeDoc('contract-note', {'value': 'kept'}).ignore();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await host.flush();
    // Simulate the process being killed: no further flush or orderly close.
    services.dispose();
    locale.dispose();
    host.dispose();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    final reopened = await store.openController();
    expect(reopened.progress.dailyGoalChars, 61);
    expect(await reopened.readDoc('contract-note'), {'value': 'kept'});
    reopened.dispose();
  });

  testWidgets('clearing removes learning only and the app keeps learning', (
    tester,
  ) async {
    final prefsFile = File(p.join(scratch.path, 'settings.json'));
    final prefs = AppPreferences(await JsonFileKeyValueStore.open(prefsFile));
    prefs.reference.wpm = 23;
    await prefs.flush();
    prefs.dispose();

    final host = TrainingControllerHost(store);
    final old = await host.controller();
    await old.setDailyGoal(88);
    await old.writeDoc('contract-note', {'value': 'gone'});
    final media = Directory(p.join(learningDir, 'media'))..createSync();
    File(p.join(media.path, 'clip.wav')).writeAsBytesSync([1, 2, 3]);

    final clearing = host.clear();
    // A write racing the confirmed clear must not survive it.
    Object? lateError;
    try {
      await old.setDailyGoal(99);
    } on Object catch (error) {
      lateError = error;
    }
    await clearing;
    expect(old.isDisposed, isTrue);
    expect(media.existsSync(), isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final reopened = await host.controller();
    expect(
      reopened.progress.dailyGoalChars,
      TrainerProgress().dailyGoalChars,
      reason: 'late write ${lateError ?? 'accepted'} must not resurrect data',
    );
    expect(await reopened.readDoc('contract-note'), isNull);
    await reopened.setDailyGoal(42);
    await host.flush();
    host.dispose();

    final again = await store.openController();
    expect(again.progress.dailyGoalChars, 42);
    again.dispose();
    final kept = AppPreferences(await JsonFileKeyValueStore.open(prefsFile));
    expect(kept.reference.wpm, 23);
    kept.dispose();
  });

  testWidgets('a corrupt progress file recovers the previous save', (
    tester,
  ) async {
    final first = await store.openController();
    await first.setDailyGoal(70);
    await first.setDailyGoal(71);
    await first.flush();
    first.dispose();
    // A torn write the atomic rename should make impossible, but a disk or
    // sync tool can still produce.
    progressFile().writeAsStringSync('{"dailyGoalChars": 7');

    final reopened = await store.openController();
    expect(reopened.progress.dailyGoalChars, 70);
    expect(File('${progressFile().path}.corrupt').existsSync(), isTrue);
    reopened.dispose();
  });

  testWidgets('rapid unawaited writes leave one complete latest document', (
    tester,
  ) async {
    final controller = await store.openController();
    for (var goal = 100; goal < 160; goal++) {
      controller.setDailyGoal(goal).ignore();
    }
    await controller.flush();
    controller.dispose();
    final decoded = jsonDecode(progressFile().readAsStringSync());
    expect(decoded, isA<Map<String, Object?>>());
    final reopened = await store.openController();
    expect(reopened.progress.dailyGoalChars, 159);
    reopened.dispose();
    expect(File('${progressFile().path}.tmp').existsSync(), isFalse);
  });
}
