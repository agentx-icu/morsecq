import 'package:flutter/material.dart';

import '../responsive.dart';

/// Bottom padding a scrolling body needs so its last line can scroll clear
/// of a floating action button (56 px plus the 16 px margin on each side).
const double kFabClearance = 88;

/// An extended FAB while its label fits the fixed 56 px button (the label's
/// text scale is clamped like other edge labels, see [edgeLabelTextScaler]);
/// when even that does not fit (a narrow window, a long language) it becomes
/// a round icon FAB whose label is the tooltip and semantics label, instead
/// of painting outside the button.
class AdaptiveFab extends StatelessWidget {
  const AdaptiveFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;

  /// Whether [label] fits an extended FAB in [context].
  static bool labelFits(BuildContext context, String label) {
    final theme = Theme.of(context);
    final style =
        theme.floatingActionButtonTheme.extendedTextStyle ??
        theme.textTheme.labelLarge;
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      textScaler: edgeLabelTextScaler(context),
      maxLines: 1,
    )..layout();
    // Icon 24 + gap 8 + horizontal padding 2 x 16, and the button's height.
    final width = painter.width + 24 + 8 + 32;
    final fits =
        painter.height <= 56 - 16 &&
        width <= MediaQuery.sizeOf(context).width * 0.6;
    painter.dispose();
    return fits;
  }

  @override
  Widget build(BuildContext context) => labelFits(context, label)
      ? FloatingActionButton.extended(
          onPressed: onPressed,
          icon: icon,
          label: Text(label, textScaler: edgeLabelTextScaler(context)),
        )
      : FloatingActionButton(onPressed: onPressed, tooltip: label, child: icon);
}
