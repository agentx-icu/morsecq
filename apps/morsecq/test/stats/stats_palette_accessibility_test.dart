import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/stats/stats_math.dart';
import 'package:morsecq/ui/stats/stats_palette.dart';
import 'package:morsecq/ui/theme.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  test(
    'existing statistical text pairs meet the documented 4.5 contrast floor',
    () {
      final failures = <String>[];
      for (final style in UiStyle.values) {
        for (final dark in [false, true]) {
          final scheme =
              (dark
                      ? MorsecqTheme.dark(style: style)
                      : MorsecqTheme.light(style: style))
                  .colorScheme;
          final palette = StatsPalette(scheme);
          for (final bucket in AccuracyBucket.values) {
            final ratio = contrast(
              palette.bucketForeground(bucket),
              palette.bucketBackground(bucket),
            );
            if (ratio < 4.5) {
              failures.add(
                '$style dark=$dark $bucket ${ratio.toStringAsFixed(4)}',
              );
            }
          }
          for (var step = 0; step <= 100; step++) {
            final t = step / 100;
            final ratio = contrast(
              palette.onSequential(t),
              palette.sequential(t),
            );
            if (ratio < 4.5) {
              failures.add(
                '$style dark=$dark t=$t ${ratio.toStringAsFixed(4)}',
              );
            }
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    },
  );
}
