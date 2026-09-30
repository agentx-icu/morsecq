// Generates the launcher / app icons for every platform from one drawing.
//
//   dart run tool/gen_app_icons.dart            (from the repository root)
//
// The drawing: "CQ" in Morse — `−·−·` over `−−·−` — white on the same
// dark-blue tile as the tray icons (tool/gen_tray_icons.dart), so the
// launcher, the tray and the notification small icon read as one family.
//
// Output:
//   apps/morsecq/icon/app_icon_1024.png                 master (square, opaque;
//                                                       store listings start here)
//   apps/morsecq/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png
//                                                       every entry of Contents.json,
//                                                       square + opaque (iOS masks)
//   apps/morsecq/macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png
//                                                       every entry of Contents.json,
//                                                       rounded tile on transparent
//   apps/morsecq/android/app/src/main/res/mipmap-*/ic_launcher.png
//                                                       legacy launcher icon, rounded
//   apps/morsecq/windows/runner/resources/app_icon.ico  16…256, rounded
//
// Linux has no icon in the Flutter template (the .desktop file of a package
// points at a PNG; use the 256 px master export when packaging).
//
// `package:image` is a dev dependency of apps/morsecq (this repo is a pub
// workspace, so the root resolution already contains it).
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

const String _app = 'apps/morsecq';
const String _iosSet = '$_app/ios/Runner/Assets.xcassets/AppIcon.appiconset';
const String _macSet = '$_app/macos/Runner/Assets.xcassets/AppIcon.appiconset';
const Map<String, int> _androidDensities = {
  'mdpi': 48,
  'hdpi': 72,
  'xhdpi': 96,
  'xxhdpi': 144,
  'xxxhdpi': 192,
};
const List<int> _icoSizes = [16, 32, 48, 64, 128, 256];

final img.Color _transparent = img.ColorRgba8(0, 0, 0, 0);
final img.Color _white = img.ColorRgba8(255, 255, 255, 255);
final img.Color _tile = img.ColorRgba8(0x1F, 0x4A, 0x7C, 255);

void main(List<String> args) {
  if (!File('pubspec.yaml').existsSync() || !Directory('apps').existsSync()) {
    stderr.writeln('[gen_app_icons] run from the repository root');
    exit(1);
  }
  var files = 0;

  // Master: 1024, opaque square (what the stores ask for).
  final master = _icon(1024, rounded: false);
  Directory('$_app/icon').createSync(recursive: true);
  _write('$_app/icon/app_icon_1024.png', img.encodePng(master));
  files++;

  // iOS: opaque squares in every size Contents.json lists (iOS applies the
  // mask itself and rejects alpha in the marketing icon).
  for (final entry in _appIconSet(_iosSet)) {
    final image = _icon(entry.pixels, rounded: false);
    _write('$_iosSet/${entry.filename}', img.encodePng(image));
    files++;
  }

  // macOS: rounded tile on transparent, Big Sur style.
  for (final entry in _appIconSet(_macSet)) {
    final image = _icon(entry.pixels, rounded: true);
    _write('$_macSet/${entry.filename}', img.encodePng(image));
    files++;
  }

  // Android legacy launcher icon per density.
  for (final density in _androidDensities.entries) {
    final dir = Directory('$_app/android/app/src/main/res/mipmap-${density.key}')
      ..createSync(recursive: true);
    final image = _icon(density.value, rounded: true);
    _write('${dir.path}/ic_launcher.png', img.encodePng(image));
    files++;
  }

  // Windows: one multi-resolution .ico, each size an independent entry
  // (addFrame would make an animated PNG inside the first entry).
  final frames = [for (final size in _icoSizes) _icon(size, rounded: true)];
  _write(
    '$_app/windows/runner/resources/app_icon.ico',
    img.IcoEncoder().encodeImages(frames),
  );
  files++;

  stdout.writeln('[gen_app_icons] wrote $files files');
}

/// One `Contents.json` entry resolved to its pixel edge (`size × scale`).
class _IconEntry {
  const _IconEntry(this.filename, this.pixels);
  final String filename;
  final int pixels;
}

/// Reads an `.appiconset/Contents.json` and returns each distinct filename
/// with its pixel size (the same file may be listed for several idioms).
List<_IconEntry> _appIconSet(String dir) {
  final json = jsonDecode(File('$dir/Contents.json').readAsStringSync())
      as Map<String, dynamic>;
  final images = (json['images'] as List<dynamic>).cast<Map<String, dynamic>>();
  final seen = <String>{};
  final entries = <_IconEntry>[];
  for (final image in images) {
    final filename = image['filename'] as String?;
    if (filename == null || !seen.add(filename)) continue;
    final size = double.parse((image['size'] as String).split('x').first);
    final scale = int.parse((image['scale'] as String).replaceAll('x', ''));
    entries.add(_IconEntry(filename, (size * scale).round()));
  }
  return entries;
}

/// The icon at [size]: the tile (rounded on transparent, or full-bleed
/// square) with the Morse for "CQ" centred on it.
img.Image _icon(int size, {required bool rounded}) {
  // Opaque icons are written as RGB: App Store Connect rejects an alpha
  // channel in the 1024 marketing icon.
  final image = img.Image(width: size, height: size, numChannels: rounded ? 4 : 3);
  img.fill(image, color: rounded ? _transparent : _tile);
  if (rounded) {
    img.fillRect(
      image,
      x1: 0,
      y1: 0,
      x2: size - 1,
      y2: size - 1,
      color: _tile,
      radius: (size * 0.22).round(),
    );
  }
  _morseRows(image, size, const ['-.-.', '--.-']); // C, Q
  return image;
}

/// Draws [rows] of Morse (`.` dot, `-` dash) centred on the canvas. Dot and
/// dash follow the 1:3 PARIS ratio with a one-unit gap, the same geometry
/// the app's pattern widget uses, scaled to fit the widest row.
void _morseRows(img.Image image, int size, List<String> rows) {
  // Units per row: dot = 1, dash = 3, gap = 1 between elements.
  int rowUnits(String row) {
    var units = 0;
    for (var i = 0; i < row.length; i++) {
      units += row[i] == '-' ? 3 : 1;
      if (i < row.length - 1) units += 1;
    }
    return units;
  }

  final widest = rows.map(rowUnits).reduce((a, b) => a > b ? a : b);
  // The glyph block takes ~64 % of the width; the stroke is one unit tall.
  final unit = size * 0.64 / widest;
  final stroke = (unit * 1.05).clamp(1.0, size.toDouble());
  final rowGap = unit * 2.2;
  final blockHeight = rows.length * stroke + (rows.length - 1) * rowGap;
  var y = (size - blockHeight) / 2;

  for (final row in rows) {
    final rowWidth = rowUnits(row) * unit;
    var x = (size - rowWidth) / 2;
    final centerY = y + stroke / 2;
    for (var i = 0; i < row.length; i++) {
      final isDash = row[i] == '-';
      final length = (isDash ? 3 : 1) * unit;
      if (isDash) {
        img.fillRect(
          image,
          x1: x.round(),
          y1: (centerY - stroke / 2).round(),
          x2: (x + length).round() - 1,
          y2: (centerY + stroke / 2).round() - 1,
          color: _white,
          radius: (stroke / 2).round(),
        );
      } else {
        img.fillCircle(
          image,
          x: (x + length / 2).round(),
          y: centerY.round(),
          radius: (stroke / 2).round().clamp(1, size),
          color: _white,
        );
      }
      x += length + unit;
    }
    y += stroke + rowGap;
  }
}

void _write(String path, List<int> bytes) {
  File(path).writeAsBytesSync(bytes, flush: true);
  stdout.writeln('  $path (${bytes.length} bytes)');
}
