import 'package:flutter/material.dart';

import 'chat_strings.dart';
import 'morse_playback_settings.dart';

/// Bottom sheet with the listener's speed / Farnsworth / tone sliders.
Future<void> showPlaybackSettingsSheet(
  BuildContext context,
  MorsePlaybackSettings settings,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _PlaybackSettingsSheet(settings: settings),
  );
}

class _PlaybackSettingsSheet extends StatelessWidget {
  const _PlaybackSettingsSheet({required this.settings});

  final MorsePlaybackSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ChatStrings.playbackSettings,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _SliderRow(
                label: ChatStrings.characterSpeed,
                value: settings.wpm,
                min: MorsePlaybackSettings.minWpm,
                max: MorsePlaybackSettings.maxWpm,
                unit: ChatStrings.wpm,
                onChanged: (v) => settings.wpm = v.roundToDouble(),
              ),
              _SliderRow(
                label: ChatStrings.farnsworthSpeed,
                value: settings.farnsworthWpm,
                min: MorsePlaybackSettings.minWpm,
                max: settings.wpm,
                unit: ChatStrings.wpm,
                onChanged: (v) => settings.farnsworthWpm = v.roundToDouble(),
              ),
              _SliderRow(
                label: ChatStrings.tone,
                value: settings.toneHz,
                min: MorsePlaybackSettings.minToneHz,
                max: MorsePlaybackSettings.maxToneHz,
                unit: ChatStrings.hz,
                onChanged: (v) => settings.toneHz = (v / 10).round() * 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(min, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${clamped.round()} $unit'),
        Slider(
          value: clamped,
          min: min,
          max: max <= min ? min + 1 : max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
