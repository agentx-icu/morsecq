import 'package:flutter/foundation.dart';

/// Touch-first platforms: big on-screen keys are the primary input and
/// haptics exist. Everything else is keyboard-first (Space / Ctrl keying).
///
/// Uses [defaultTargetPlatform] so widget tests can flip it with
/// `debugDefaultTargetPlatformOverride` and exercise both branches.
bool get isTouchPlatform =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Whether to surface keyboard shortcuts and autofocus keyable widgets.
bool get hasPhysicalKeyboardByDefault => !isTouchPlatform;

/// Two-column layouts start at this width (see plan §4 / task brief).
const double kLearnTwoColumnMinWidth = 900;
