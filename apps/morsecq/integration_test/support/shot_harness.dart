// Flutter-layer screenshot harness for the integration tests.
//
// `package:integration_test` only has native `takeScreenshot` support on
// Android and iOS (Flutter 3.41.9). Rendering the app inside a
// [RepaintBoundary] and calling `toImage` works on all five platforms, needs
// no OS permission, and never sees another window. The PNG bytes travel to
// the host inside `binding.reportData` (base64, so the VM-service JSON stays
// small); `test_driver/integration_test.dart` writes them to disk.
//
// Knobs (all `--dart-define`):
//   MORSECQ_SHOT_PLATFORM     folder name in the report (default: the host OS)
//   MORSECQ_SHOT_LOCALES      comma list, default `en,zh`
//   MORSECQ_SHOT_PIXEL_RATIO  capture scale; default 1.0 on desktop, min(dpr, 2) on mobile
//   MORSECQ_SHOT_WINDOW       desktop window size `WxH`, default 1280x800
//   MORSECQ_SHOT_THEME        light (default) | dark | system
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morsecq/di/app_settings.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const String _platformDefine = String.fromEnvironment('MORSECQ_SHOT_PLATFORM');
const String _localesDefine = String.fromEnvironment(
  'MORSECQ_SHOT_LOCALES',
  defaultValue: 'en,zh',
);
const String _pixelRatioDefine = String.fromEnvironment(
  'MORSECQ_SHOT_PIXEL_RATIO',
);
const String _windowDefine = String.fromEnvironment(
  'MORSECQ_SHOT_WINDOW',
  defaultValue: '1280x800',
);
const String _themeDefine = String.fromEnvironment(
  'MORSECQ_SHOT_THEME',
  defaultValue: 'light',
);

/// Key under `binding.reportData` holding the captured frames.
const String kShotReportKey = 'morsecqScreenshots';

bool get isDesktopHost =>
    !kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

/// Folder name for this run's frames.
String shotPlatform() {
  if (_platformDefine.isNotEmpty) return _platformDefine;
  if (Platform.isMacOS) return 'macos';
  if (Platform.isLinux) return 'linux';
  if (Platform.isWindows) return 'windows';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  return 'unknown';
}

List<String> shotLocales() => _localesDefine
    .split(',')
    .map((l) => l.trim())
    .where((l) => l.isNotEmpty)
    .toList(growable: false);

Size desktopWindowSize() {
  final parts = _windowDefine.toLowerCase().split('x');
  if (parts.length == 2) {
    final w = double.tryParse(parts[0]);
    final h = double.tryParse(parts[1]);
    if (w != null && h != null && w > 0 && h > 0) return Size(w, h);
  }
  return const Size(1280, 800);
}

/// Lets real asynchronous work (file I/O, plugin channels) and animations
/// finish. `pumpAndSettle` alone throws on an endless animation (a blinking
/// caret, a spinner), so its timeout is caught and treated as "settled
/// enough"; the fixed pumps in front give plain futures a chance to run.
Future<void> settle(WidgetTester tester, {Duration extra = Duration.zero}) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
  } on FlutterError {
    // Something animates forever; the frame is still fine to capture.
  }
  if (extra > Duration.zero) {
    await Future<void>.delayed(extra);
    await tester.pump();
  }
}

/// Owns the capture boundary and the report list for one run.
class ShotHarness {
  ShotHarness(this.binding);

  final IntegrationTestWidgetsFlutterBinding binding;
  final GlobalKey boundaryKey = GlobalKey(debugLabel: 'shot-boundary');
  final String platform = shotPlatform();

  /// Report names captured so far (`<platform>/<locale>/<scene>`).
  final List<String> captured = <String>[];

  Widget wrap(Widget child) => RepaintBoundary(key: boundaryKey, child: child);

  /// Desktop: size and centre the real window so every capture has the same
  /// logical size regardless of what a previous run persisted. macOS clamps
  /// a window to the visible frame, so the achieved size is read back and
  /// simply used as-is when it differs.
  Future<void> prepareWindow(WidgetTester tester) async {
    if (!isDesktopHost) return;
    final size = desktopWindowSize();
    await windowManager.ensureInitialized();
    await windowManager.setSize(size);
    await windowManager.center();
    await windowManager.show();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      final logical = tester.view.physicalSize / tester.view.devicePixelRatio;
      if ((logical.width - size.width).abs() < 2 &&
          (logical.height - size.height).abs() < 2) {
        return;
      }
    }
    final got = tester.view.physicalSize / tester.view.devicePixelRatio;
    debugPrint('[shot] window is ${got.width}x${got.height}, wanted $size');
  }

  /// Pins the theme so the frames do not follow the host's appearance.
  Future<void> applyTheme(WidgetTester tester) async {
    final mode = switch (_themeDefine) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
    tester.element(find.byType(MaterialApp)).read<AppSettings>().themeMode =
        mode;
    await settle(tester);
  }

  double _pixelRatio(WidgetTester tester) {
    final forced = double.tryParse(_pixelRatioDefine);
    if (forced != null && forced > 0) return forced;
    if (isDesktopHost) return 1.0;
    return math.min(tester.view.devicePixelRatio, 2.0);
  }

  /// Captures the current frame as `<platform>/<locale>/<scene>`.
  Future<void> capture(WidgetTester tester, String locale, String scene) async {
    await settle(tester);
    final RenderObject? ro = boundaryKey.currentContext?.findRenderObject();
    if (ro is! RenderRepaintBoundary) {
      throw StateError('screenshot boundary is not mounted');
    }
    final ui.Image image = await ro.toImage(pixelRatio: _pixelRatio(tester));
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final int width = image.width;
    final int height = image.height;
    image.dispose();
    if (data == null) throw StateError('PNG encoding failed for $scene');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final name = '$platform/$locale/$scene';
    final Map<String, dynamic> report = binding.reportData ??=
        <String, dynamic>{};
    final list = (report[kShotReportKey] ??= <Object?>[]) as List<Object?>;
    list.add(<String, Object?>{
      'name': name,
      'width': width,
      'height': height,
      'png': base64Encode(bytes),
    });
    captured.add(name);
    debugPrint('[shot] $name ${width}x$height (${bytes.length} bytes)');
  }
}
