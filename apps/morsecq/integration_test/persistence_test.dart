import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/di/app_preferences.dart';
import 'package:morsecq/training/local_learning_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('local learning and preferences survive reopening', (
    tester,
  ) async {
    final scratch = await Directory.systemTemp.createTemp(
      'morsecq_persistence_',
    );
    addTearDown(() => scratch.delete(recursive: true));
    final store = LocalLearningStore(root: () async => scratch.path);
    final controller = await store.openController();
    await controller.setDailyGoal(77);
    await controller.flush();
    controller.dispose();
    final reopened = await store.openController();
    expect(reopened.progress.dailyGoalChars, 77);
    reopened.dispose();
    final file = File('${scratch.path}/preferences.json');
    final prefs = AppPreferences(await JsonFileKeyValueStore.open(file));
    prefs.reference.wpm = 22;
    await prefs.flush();
    prefs.dispose();
    final next = AppPreferences(await JsonFileKeyValueStore.open(file));
    expect(next.reference.wpm, 22);
    next.dispose();
  });
}
