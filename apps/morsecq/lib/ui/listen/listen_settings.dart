import 'package:flutter/material.dart';

import 'listen_strings.dart';

/// User-tunable decoder parameters for the Listen screen.
final class ListenSettings {
  const ListenSettings({
    this.blockSize = 256,
    this.minElementMs = 12,
    this.autoTune = true,
    this.manualHz = 700,
  });

  static const List<int> blockSizes = <int>[128, 256, 512];
  static const int minElementMinMs = 4;
  static const int minElementMaxMs = 40;
  static const double minHz = 400;
  static const double maxHz = 1000;

  /// Samples per gate decision.
  final int blockSize;

  /// Shortest tone / gap that counts (debounce), milliseconds.
  final int minElementMs;

  /// Follow the strongest tone automatically.
  final bool autoTune;

  /// Frequency used when [autoTune] is off.
  final double manualHz;

  double blockMs(int sampleRate) => blockSize * 1000 / sampleRate;

  ListenSettings copyWith({
    int? blockSize,
    int? minElementMs,
    bool? autoTune,
    double? manualHz,
  }) =>
      ListenSettings(
        blockSize: blockSize ?? this.blockSize,
        minElementMs: minElementMs ?? this.minElementMs,
        autoTune: autoTune ?? this.autoTune,
        manualHz: manualHz ?? this.manualHz,
      );

  @override
  bool operator ==(Object other) =>
      other is ListenSettings &&
      other.blockSize == blockSize &&
      other.minElementMs == minElementMs &&
      other.autoTune == autoTune &&
      other.manualHz == manualHz;

  @override
  int get hashCode => Object.hash(blockSize, minElementMs, autoTune, manualHz);
}

/// Bottom-sheet body editing [ListenSettings]. Reports every change through
/// [onChanged]; the caller owns persistence and the decoder rebuild.
class ListenSettingsSheet extends StatefulWidget {
  const ListenSettingsSheet({
    super.key,
    required this.settings,
    required this.sampleRate,
    required this.onChanged,
  });

  final ListenSettings settings;
  final int sampleRate;
  final ValueChanged<ListenSettings> onChanged;

  @override
  State<ListenSettingsSheet> createState() => _ListenSettingsSheetState();
}

class _ListenSettingsSheetState extends State<ListenSettingsSheet> {
  late ListenSettings _draft = widget.settings;

  void _apply(ListenSettings next, {bool notify = true}) {
    setState(() => _draft = next);
    if (notify) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          ListTile(
            title: Text(
              ListenStrings.settings,
              style: theme.textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            title: const Text(ListenStrings.autoTune),
            subtitle: const Text(ListenStrings.autoTuneHelp),
            value: _draft.autoTune,
            onChanged: (v) => _apply(_draft.copyWith(autoTune: v)),
          ),
          const Divider(),
          ListTile(
            title: const Text(ListenStrings.blockSize),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<int>(
                segments: <ButtonSegment<int>>[
                  for (final size in ListenSettings.blockSizes)
                    ButtonSegment<int>(
                      value: size,
                      label: Text('$size'),
                    ),
                ],
                selected: <int>{_draft.blockSize},
                showSelectedIcon: false,
                onSelectionChanged: (s) =>
                    _apply(_draft.copyWith(blockSize: s.first)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              '${ListenStrings.blockSamples(_draft.blockSize, _draft.blockMs(widget.sampleRate))}\n'
              '${ListenStrings.blockSizeHelp}',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text(ListenStrings.minElement),
            subtitle: const Text(ListenStrings.minElementHelp),
            trailing: Text(
              ListenStrings.ms(_draft.minElementMs),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Slider(
            value: _draft.minElementMs
                .clamp(
                  ListenSettings.minElementMinMs,
                  ListenSettings.minElementMaxMs,
                )
                .toDouble(),
            min: ListenSettings.minElementMinMs.toDouble(),
            max: ListenSettings.minElementMaxMs.toDouble(),
            divisions:
                ListenSettings.minElementMaxMs - ListenSettings.minElementMinMs,
            label: ListenStrings.ms(_draft.minElementMs),
            onChanged: (v) =>
                _apply(_draft.copyWith(minElementMs: v.round()), notify: false),
            onChangeEnd: (v) => _apply(_draft.copyWith(minElementMs: v.round())),
          ),
        ],
      ),
    );
  }
}
