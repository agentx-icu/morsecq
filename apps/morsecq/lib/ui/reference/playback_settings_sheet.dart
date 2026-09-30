import 'package:flutter/material.dart';

import 'reference_playback_settings.dart';
import 'reference_strings.dart';

/// Opens the speed / Farnsworth / tone sheet for [settings].
Future<void> showReferencePlaybackSettings(
  BuildContext context,
  ReferencePlaybackSettings settings,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ReferencePlaybackSettingsSheet(settings: settings),
      ),
    ),
  );
}

/// Sliders for the reference playback settings; rebuilds as they change.
class ReferencePlaybackSettingsSheet extends StatelessWidget {
  const ReferencePlaybackSettingsSheet({super.key, required this.settings});

  final ReferencePlaybackSettings settings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (BuildContext context, _) {
        final double? fw = settings.farnsworthWpm;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(ReferenceStrings.playbackSettings, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            _SliderRow(
              label: ReferenceStrings.characterSpeed,
              value: settings.wpm,
              valueLabel: ReferenceStrings.wpm(settings.wpm),
              min: ReferencePlaybackSettings.minWpm,
              max: ReferencePlaybackSettings.maxWpm,
              divisions: (ReferencePlaybackSettings.maxWpm -
                      ReferencePlaybackSettings.minWpm)
                  .round(),
              onChanged: (double v) => settings.wpm = v,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(ReferenceStrings.farnsworth),
              subtitle: const Text(ReferenceStrings.farnsworthHelp),
              value: settings.farnsworthEnabled,
              onChanged: settings.setFarnsworthEnabled,
            ),
            if (fw != null)
              _SliderRow(
                label: ReferenceStrings.effectiveSpeed,
                value: fw,
                valueLabel: ReferenceStrings.wpm(fw),
                min: ReferencePlaybackSettings.minWpm,
                max: settings.wpm,
                divisions: (settings.wpm - ReferencePlaybackSettings.minWpm)
                    .round()
                    .clamp(1, 100),
                onChanged: (double v) => settings.farnsworthWpm = v,
              ),
            _SliderRow(
              label: ReferenceStrings.tone,
              value: settings.toneHz,
              valueLabel: ReferenceStrings.hz(settings.toneHz),
              min: ReferencePlaybackSettings.minToneHz,
              max: ReferencePlaybackSettings.maxToneHz,
              divisions: ((ReferencePlaybackSettings.maxToneHz -
                          ReferencePlaybackSettings.minToneHz) /
                      25)
                  .round(),
              onChanged: (double v) => settings.toneHz = v,
            ),
          ],
        );
      },
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final String valueLabel;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
            Text(valueLabel, style: theme.textTheme.labelLarge),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
