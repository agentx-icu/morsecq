import 'package:flutter/widgets.dart';

/// Layout breakpoint (logical pixels). Below it the shell uses a bottom
/// [NavigationBar]; at or above it, a side [NavigationRail]. 600 is the
/// Material "compact / medium" boundary, so phones in portrait are compact and
/// tablets, foldables and desktop windows are not.
const double kCompactMaxWidth = 600;

/// Coarse layout class used by the shell. Deliberately two-valued: the
/// product only distinguishes "phone-like" from "everything wider" today.
enum LayoutClass { compact, expanded }

LayoutClass layoutClassForWidth(double width) =>
    width < kCompactMaxWidth ? LayoutClass.compact : LayoutClass.expanded;

/// Reads the layout class from the nearest [MediaQuery]. Keep this the single
/// place that inspects width so the breakpoint cannot drift between widgets.
LayoutClass layoutClassOf(BuildContext context) =>
    layoutClassForWidth(MediaQuery.sizeOf(context).width);
