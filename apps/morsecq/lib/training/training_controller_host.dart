import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'local_learning_store.dart';
import 'training_controller.dart';

/// Owns one local controller shared by every learning/settings screen.
class TrainingControllerHost {
  TrainingControllerHost(
    this.store, {
    Future<TrainingController> Function()? factory,
  }) : _factory = factory ?? store.openController;
  final LocalLearningStore store;
  final Future<TrainingController> Function() _factory;
  Future<TrainingController>? _pending;
  TrainingController? _current;
  bool _disposed = false;
  bool _suspended = false;
  final ValueNotifier<int> _reloads = ValueNotifier(0);
  ValueListenable<int> get reloads => _reloads;
  Future<TrainingController> controllerFor(BuildContext context) =>
      controller();
  Future<TrainingController> controller() {
    if (_disposed || _suspended) {
      return Future.error(StateError('Learning storage unavailable'));
    }
    return _pending ??= _load();
  }

  Future<TrainingController> _load() async {
    try {
      final controller = await _factory();
      if (_disposed) {
        controller.dispose();
        throw StateError('Learning host disposed');
      }
      _current = controller;
      return controller;
    } on Object {
      _pending = null;
      rethrow;
    }
  }

  static Future<TrainingController> fromContext(BuildContext context) =>
      context.read<TrainingControllerHost>().controller();
  Future<void> flush() async {
    final pending = _pending;
    if (pending != null) await (await pending).flush();
  }

  Future<void> _suspendLearning() async {
    if (_suspended) throw StateError('Learning operation already in progress');
    _suspended = true;
    try {
      await flush();
    } on Object catch (error) {
      // The barrier reports an earlier failed save only after every queued
      // write has settled. Those files are about to be removed, so a past
      // failure must not keep the learner from clearing.
      debugPrint('Clearing after a failed learning save: $error');
    }
    _current?.dispose();
    _current = null;
    _pending = null;
  }

  void _resumeLearning() {
    if (_disposed) return;
    _suspended = false;
    _reloads.value++;
  }

  Future<void> clear() async {
    await _suspendLearning();
    try {
      await store.clear();
    } finally {
      _resumeLearning();
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _current?.dispose();
    _current = null;
    _reloads.dispose();
  }
}
