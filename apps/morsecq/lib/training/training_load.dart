import 'package:morse_trainer/morse_trainer.dart';

/// Ordinary I/O failures allow an explicit retry from the training UI.
/// A future schema is incompatible and must never yield writable defaults.
Future<(T?, Object?)> loadCompatibleTrainingData<T>(
  Future<T?> Function() load,
) async {
  try {
    return (await load(), null);
  } on UnsupportedDataVersion {
    rethrow;
  } on Object catch (error) {
    return (null, error);
  }
}
