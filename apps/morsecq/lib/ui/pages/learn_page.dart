import 'package:flutter/material.dart';

import '../../training/training_controller.dart';
import '../../training/training_controller_host.dart';
import '../learn/learn_home.dart';
import '../learn/learn_playback.dart';
import '../learn/learn_scope.dart';

/// Morse training: lessons, keying drills, copy practice.
///
/// Wires the per-identity [TrainingController] through [LearnScope] and
/// renders [LearnHome]. Both hooks exist for tests: [controllerFactory]
/// swaps the file stores for in-memory ones and [playback] swaps the device
/// sidetone for a recording sink.
class LearnPage extends StatelessWidget {
  const LearnPage({
    super.key,
    this.controllerFactory,
    this.playback = const DevicePlaybackFactory(),
  });

  static const String title = 'Learn';
  static const String description =
      'Koch-method lessons, keying drills and copy practice.';

  final Future<TrainingController> Function(BuildContext context)?
  controllerFactory;
  final LearnPlaybackFactory playback;

  @override
  Widget build(BuildContext context) => LearnScope(
    // Shared per-identity controller when the app provides a host (so the
    // Me page's training-defaults route edits the same instance); tests may
    // inject their own factory.
    controllerFactory: controllerFactory ?? TrainingControllerHost.fromContext,
    playback: playback,
    title: title,
    description: description,
    builder: (context, controller, playback) => LearnHome(
      controller: controller,
      playback: playback,
      subtitle: description,
    ),
  );
}
