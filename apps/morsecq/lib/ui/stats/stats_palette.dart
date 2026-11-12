import 'package:flutter/material.dart';

import 'stats_math.dart';

/// Dashboard backgrounds/series derive from the active [ColorScheme]. Text
/// keeps themed colours when readable, with a monochrome contrast fallback.
///
/// * Sequential (magnitude): one hue, [surfaceContainerHighest] -> [primary].
/// * Categorical (identity): receive = primary, send = tertiary, fixed order.
/// * Accuracy buckets: a four-step sequential ramp plus a neutral "none".
final class StatsPalette {
  const StatsPalette(this.scheme);

  final ColorScheme scheme;

  /// Recessive grid / axis stroke.
  Color get grid => scheme.outlineVariant;

  Color get axisText => scheme.onSurfaceVariant;

  /// Series colours in fixed order: receive first, send second.
  Color get receive => scheme.primary;

  Color get send => scheme.tertiary;

  /// Colour for a single undistinguished series.
  Color get single => scheme.primary;

  /// One-hue sequential ramp: `t` in 0..1, 0 = empty cell, 1 = maximum.
  Color sequential(double t) {
    if (t <= 0) {
      return scheme.surfaceContainerHighest;
    }
    final clamped = t.clamp(0.0, 1.0);
    return Color.lerp(scheme.primaryContainer, scheme.primary, clamped)!;
  }

  /// Quantised ramp for `level` in `0..levels - 1`.
  Color sequentialLevel(int level, {int levels = 5}) =>
      level <= 0 ? sequential(0) : sequential(level / (levels - 1));

  /// Text colour that reads on [sequential] at `t`.
  Color onSequential(double t) {
    final preferred = t <= 0
        ? scheme.onSurfaceVariant
        : t >= 0.55
        ? scheme.onPrimary
        : scheme.onPrimaryContainer;
    return _readableText(sequential(t), preferred);
  }

  /// Background for an accuracy bucket. Weak is the error container so it is
  /// unmistakable; the rest climb the primary ramp.
  Color bucketBackground(AccuracyBucket bucket) => switch (bucket) {
    AccuracyBucket.none => scheme.surfaceContainerHighest,
    AccuracyBucket.weak => scheme.errorContainer,
    AccuracyBucket.fair => sequential(0.25),
    AccuracyBucket.good => sequential(0.6),
    AccuracyBucket.strong => sequential(1),
  };

  Color bucketForeground(AccuracyBucket bucket) =>
      _readableText(bucketBackground(bucket), switch (bucket) {
        AccuracyBucket.none => scheme.onSurfaceVariant,
        AccuracyBucket.weak => scheme.onErrorContainer,
        AccuracyBucket.fair => scheme.onPrimaryContainer,
        AccuracyBucket.good => scheme.onPrimary,
        AccuracyBucket.strong => scheme.onPrimary,
      });

  /// Keep existing themed text when readable; otherwise choose a themed
  /// alternative using the actual background luminance. Only a theme with
  /// no qualifying text colour needs the opaque black/white fallback.
  Color _readableText(Color background, Color preferred) {
    final luminance = background.computeLuminance();
    double ratio(Color text) {
      final other = text.computeLuminance();
      return ((luminance > other ? luminance : other) + 0.05) /
          ((luminance > other ? other : luminance) + 0.05);
    }

    for (final text in [
      preferred,
      scheme.onPrimary,
      scheme.onPrimaryContainer,
      scheme.onSurface,
      scheme.onSurfaceVariant,
    ]) {
      if (ratio(text) >= 4.5) return text;
    }
    return ratio(Colors.black) >= ratio(Colors.white)
        ? Colors.black
        : Colors.white;
  }
}
