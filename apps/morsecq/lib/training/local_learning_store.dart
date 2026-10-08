import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../ui/learn/learn_scope.dart';
import 'training_controller.dart';

/// Device-local learning storage, independent of any account.
class LocalLearningStore {
  LocalLearningStore({Future<String> Function()? root})
    : _root = root ?? _defaultRoot;
  final Future<String> Function() _root;
  static Future<String> _defaultRoot() async =>
      p.join((await getApplicationSupportDirectory()).path, 'morsecq', 'guest');
  Future<String> directory() async {
    final dir = await _root();
    await Directory(dir).create(recursive: true);
    return dir;
  }

  Future<TrainingController> openController() async =>
      LearnScope.controllerForDirectory(await directory(), profileKey: 'guest');
  Future<void> clear() async {
    final dir = await directory();
    for (final name in ['training', 'media']) {
      final folder = Directory(p.join(dir, name));
      if (await folder.exists()) await folder.delete(recursive: true);
    }
  }
}
