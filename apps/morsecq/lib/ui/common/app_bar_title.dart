import 'package:flutter/material.dart';

/// An [AppBar] title that never hides words behind an ellipsis.
///
/// One line at the bar's title style when it fits; otherwise wrapped lines
/// at a smaller size, scaled down further only when even those overflow the
/// bar (a narrow phone, a long language or large text). Use it for every
/// app bar title so long translations stay readable.
class AppBarTitle extends StatelessWidget {
  const AppBarTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) return Text(text, maxLines: 1);
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout(maxWidth: constraints.maxWidth);
        final fits = !painter.didExceedMaxLines;
        painter.dispose();
        if (fits) return Text(text, maxLines: 1, softWrap: false);
        final small = style.copyWith(
          fontSize: (style.fontSize ?? 22) * 0.78,
          height: 1.15,
        );
        // Never break inside a word: wrap at the bar width or at the longest
        // unbreakable run, whichever is wider, then scale to fit the bar.
        final wrapped = TextPainter(
          text: TextSpan(text: text, style: small),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final width = wrapped.minIntrinsicWidth > constraints.maxWidth
            ? wrapped.minIntrinsicWidth.ceilToDouble()
            : constraints.maxWidth;
        wrapped.dispose();
        // The bar gives its title unbounded height; bound the box to the
        // toolbar so FittedBox scales tall wrapped text down to fit it.
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight;
        return SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: width,
              child: Text(
                text,
                style: small,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        );
      },
    );
  }
}
