import 'package:flutter/material.dart';

/// The smallest glyph size a layout may shrink text to.
const double kMinShrunkFontSize = 12;

/// An [InputDecoration.label] that never ends in an ellipsis while it can
/// stay readable: it scales down when a narrow field, a long language or
/// large text leaves too little width, but never below
/// [kMinShrunkFontSize]. Past that floor it shows the floor size with an
/// ellipsis (the layout sweep reports that, so the field itself is fixed).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (!constraints.hasBoundedWidth) return Text(text);
      final style = DefaultTextStyle.of(context).style;
      final scaler = MediaQuery.textScalerOf(context);
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      painter.dispose();
      if (width <= constraints.maxWidth) {
        return Text(text, maxLines: 1, softWrap: false);
      }
      final size = scaler.scale(style.fontSize ?? 16);
      final scale = constraints.maxWidth / width;
      if (scale * size >= kMinShrunkFontSize) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(text),
        );
      }
      return MediaQuery.withNoTextScaling(
        child: Text(
          text,
          style: style.copyWith(fontSize: kMinShrunkFontSize),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    },
  );
}
