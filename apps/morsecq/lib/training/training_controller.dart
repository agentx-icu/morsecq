import 'package:flutter/foundation.dart';
import 'package:morse_session/morse_session.dart';

/// The app's learner-state controller: [TrainingCore] (package
/// `morse_session`) with Flutter change notification. Every screen keeps
/// listening to this type; the session starters are extensions on
/// [TrainingCore] and apply here unchanged.
final class TrainingController extends TrainingCore with ChangeNotifier {
  TrainingController({
    required super.progressStore,
    required super.settingsStore,
    super.course,
    super.now,
    super.random,
    super.profileKey,
    super.docs,
  });

  /// The mixin's `dispose` does not chain into the core, so both are run
  /// here; a second call (for example `close()` then `dispose()`) is a no-op.
  @override
  void dispose() {
    if (isDisposed) return;
    retireCore();
    super.dispose();
  }
}
