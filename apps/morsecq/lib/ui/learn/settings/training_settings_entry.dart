import 'package:flutter/material.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/training_controller.dart';
import '../../../training/training_controller_host.dart';
import '../learn_playback.dart';
import 'training_settings_screen.dart';

/// Named-route target for `/settings/training` (pushed from the Me page).
/// Resolves the shared [TrainingController] through
/// [TrainingControllerHost.fromContext] so the settings page edits the same
/// instance the Learn tab uses.
class TrainingSettingsEntry extends StatefulWidget {
  const TrainingSettingsEntry({
    super.key,
    this.playback = const DevicePlaybackFactory(),
  });

  final LearnPlaybackFactory playback;

  @override
  State<TrainingSettingsEntry> createState() => _TrainingSettingsEntryState();
}

class _TrainingSettingsEntryState extends State<TrainingSettingsEntry> {
  late final Future<TrainingController> _controller =
      TrainingControllerHost.fromContext(context);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TrainingController>(
      future: _controller,
      builder: (context, snapshot) {
        final controller = snapshot.data;
        if (controller != null) {
          return TrainingSettingsScreen(
            controller: controller,
            playback: widget.playback,
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(context.s.learnSettings)),
          body: Center(
            child: snapshot.hasError
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      context.s.learnIdentityRequired,
                      textAlign: TextAlign.center,
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
