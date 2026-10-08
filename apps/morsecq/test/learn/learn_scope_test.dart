import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq/ui/learn/learn_scope.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:provider/provider.dart';

import 'helpers/l10n.dart';

void main() {
  testWidgets('host controller reloads after confirmed local clearing', (
    tester,
  ) async {
    final progressStore = InMemoryTrainerStore(
      TrainerProgress(currentLesson: 2),
    );
    final host = TrainingControllerHost(
      _ClearingStore(progressStore.clear),
      factory: () async {
        final controller = TrainingController(
          progressStore: progressStore,
          settingsStore: InMemoryTrainingSettingsStore(),
        );
        await controller.load();
        return controller;
      },
    );
    addTearDown(host.dispose);
    TrainingController? displayed;
    await tester.pumpWidget(
      Provider<TrainingControllerHost?>.value(
        value: host,
        child: l10nApp(
          home: LearnScope(
            controllerFactory: host.controllerFor,
            builder: (_, controller, _) {
              displayed = controller;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final previous = displayed!;
    await previous.setLesson(3);

    await host.clear();
    await tester.pumpAndSettle();

    expect(displayed, isNot(same(previous)));
    expect(displayed!.currentLesson, 1);
    await displayed!.setLesson(4);
    expect((await progressStore.load())!.currentLesson, 4);
    await tester.pumpWidget(const SizedBox());
  });
}

final class _ClearingStore extends LocalLearningStore {
  _ClearingStore(this.onClear);
  final Future<void> Function() onClear;
  @override
  Future<void> clear() => onClear();
}
