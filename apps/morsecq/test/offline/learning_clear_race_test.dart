import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/training/training_doc_store.dart';
import 'package:morsecq/training/training_settings_store.dart';

void main() {
  test(
    'clearing waits for every accepted write, then refuses new ones',
    () async {
      final docs = _GatedDocStore();
      final log = <String>[];
      docs.log = log;
      final host = _host(
        docs,
        onClear: () async {
          log.add('clear');
          docs.docs.clear();
        },
      );
      addTearDown(host.dispose);
      final held = await host.controller();

      // Write A blocks, then fails; transaction T was accepted before the
      // clear and writes after A.
      final gate = docs.gate('a');
      final a = held.writeDoc('a', {'v': 1});
      final t = held.docTransaction(() => held.writeDoc('t', {'v': 2}));
      final clearing = host.clear();
      var flushed = false;
      final hostFlush = host.flush().then(
        (_) => flushed = true,
        onError: (Object _) => flushed = true,
      );
      expect(() => held.writeDoc('late', {'v': 3}), throwsStateError);
      expect(() => held.docTransaction(() async {}), throwsStateError);

      await pumpEventQueue();
      expect(log, isNot(contains('clear')));
      expect(flushed, isFalse, reason: 'flush must wait for the blocked write');

      gate.completeError(StateError('disk full'));
      await expectLater(a, throwsStateError);
      await t;
      await clearing;
      await hostFlush;
      expect(log, ['write t', 'clear']);
      expect(docs.docs, isEmpty);
      expect(held.isDisposed, isTrue);

      final next = await host.controller();
      expect(next, isNot(same(held)));
    },
  );

  test('flush also waits for a write accepted while it waits', () async {
    final docs = _GatedDocStore();
    final controller = _controller(docs);
    addTearDown(controller.dispose);
    await controller.load();
    final gate = docs.gate('a');
    unawaited(controller.writeDoc('a', {'v': 1}));
    var done = false;
    final flush = controller.flush().then((_) => done = true);
    await pumpEventQueue();
    final late = docs.gate('b');
    unawaited(controller.writeDoc('b', {'v': 2}));
    gate.complete();
    await pumpEventQueue();
    expect(done, isFalse);
    late.complete();
    await flush;
    expect(docs.docs.keys, containsAll(['a', 'b']));
  });

  for (final fails in [false, true]) {
    test('clearing during a ${fails ? 'failing' : 'running'} load', () async {
      final opening = Completer<void>();
      final docs = _GatedDocStore();
      var cleared = 0;
      TrainingController? opened;
      final host = TrainingControllerHost(
        _ClearingStore(() async => cleared++),
        factory: () async {
          await opening.future;
          if (fails) throw StateError('unreadable');
          return opened = _controller(docs);
        },
      );
      addTearDown(host.dispose);
      final load = host.controller();
      final clearing = host.clear();
      await pumpEventQueue();
      expect(cleared, 0);
      opening.complete();
      await load.then((_) {}, onError: (Object _) {});
      await clearing;
      expect(cleared, 1);
      if (!fails) expect(opened!.isDisposed, isTrue);
    });
  }
}

TrainingController _controller(TrainingDocStore docs) => TrainingController(
  progressStore: InMemoryTrainerStore(),
  settingsStore: InMemoryTrainingSettingsStore(),
  docs: docs,
);

TrainingControllerHost _host(
  TrainingDocStore docs, {
  required Future<void> Function() onClear,
}) => TrainingControllerHost(
  _ClearingStore(onClear),
  factory: () async {
    final controller = _controller(docs);
    await controller.load();
    return controller;
  },
);

final class _ClearingStore extends LocalLearningStore {
  _ClearingStore(this.onClear);
  final Future<void> Function() onClear;
  @override
  Future<void> clear() => onClear();
}

/// Holds a document's write until its gate opens; logs completed writes.
final class _GatedDocStore implements TrainingDocStore {
  final InMemoryTrainingDocStore _inner = InMemoryTrainingDocStore();
  final Map<String, Completer<void>> _gates = {};
  List<String> log = [];

  Map<String, String> get docs => _inner.docs;

  Completer<void> gate(String name) => _gates[name] = Completer<void>();

  @override
  Future<void> write(String name, Map<String, Object?> json) async {
    await _gates.remove(name)?.future;
    await _inner.write(name, json);
    log.add('write $name');
  }

  @override
  Future<Map<String, Object?>?> read(String name) => _inner.read(name);

  @override
  Future<void> delete(String name) => _inner.delete(name);

  @override
  Future<List<String>> names() => _inner.names();
}
