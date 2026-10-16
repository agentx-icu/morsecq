import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';

/// A [ChoiceChip] whose label wraps at large text sizes and in long
/// languages instead of fading out on one line.
///
/// A chip measures its label at its full width, then lays it out narrower
/// by its padding and checkmark, so a wrapped label would lose its last
/// line. Here the padding lives inside the label and there is no
/// checkmark, so both passes see the same width; the selected colour marks
/// the choice. The default chip's spacing is kept.
ChoiceChip wrappingChoiceChip({
  Key? key,
  required String label,
  required bool selected,
  required ValueChanged<bool>? onSelected,
  MaterialTapTargetSize? materialTapTargetSize,
}) => ChoiceChip(
  key: key,
  showCheckmark: false,
  padding: EdgeInsets.zero,
  labelPadding: EdgeInsets.zero,
  selected: selected,
  onSelected: onSelected,
  materialTapTargetSize: materialTapTargetSize,
  label: Builder(
    builder: (context) {
      // The default chip's spacing: 8 px of padding plus a label padding
      // that narrows from 8 to 4 px as the text scales from 1x to 2x.
      final style = DefaultTextStyle.of(context).style;
      final size = style.fontSize ?? 14;
      final scale = MediaQuery.textScalerOf(context).scale(size) / 14;
      final side = 8 + 8 - 4 * clampDouble(scale - 1, 0, 1);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: side, vertical: 8),
        // The chip's own text style limits its label to one line.
        child: DefaultTextStyle(style: style, child: Text(label)),
      );
    },
  ),
);
