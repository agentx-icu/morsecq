import 'package:flutter/material.dart';

/// Visual accompaniment to the real player state. The pulse shape is
/// intentionally neutral, so it never exposes an exercise's expected answer.
class SignalActivity extends StatelessWidget {
  const SignalActivity({super.key, required this.playing});

  final bool playing;

  static const _heights = [
    12.0,
    19.0,
    27.0,
    43.0,
    28.0,
    18.0,
    11.0,
    24.0,
    32.0,
    42.0,
    29.0,
    17.0,
    25.0,
    35.0,
    44.0,
    24.0,
    14.0,
    23.0,
    32.0,
    40.0,
    27.0,
    22.0,
    15.0,
    11.0,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ink = playing ? colors.primary : colors.onSurfaceVariant;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 3,
          children: [
            for (final height in _heights)
              Flexible(
                child: Container(
                  height: height,
                  width: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: ink.withValues(alpha: playing ? 0.85 : 0.46),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
