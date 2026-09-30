// Generates the system-tray icons under apps/morsecq/assets/tray/.
//
//   dart run tool/gen_tray_icons.dart            (from the repository root)
//
// Output (all rendered from the same "· −" glyph):
//   tray_template_{16,22,32}.png  macOS template: black glyph on transparent,
//                                 AppKit tints it for light/dark menu bars.
//   tray_icon_{16,22,32}.png      Linux (AppIndicator): white glyph on a
//                                 rounded dark-blue tile so it reads on any
//                                 panel colour.
//   tray_icon.ico                 Windows: the three tile PNGs packed into one
//                                 multi-resolution .ico (PNG-compressed
//                                 entries, supported since Vista). The tray
//                                 loads it with LoadImage(IMAGE_ICON), which
//                                 rejects a bare PNG.
//
// `package:image` is a dev dependency of apps/morsecq (this repo is a pub
// workspace, so the root resolution already contains it).
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:image/image.dart' as img;

const List<int> _sizes = [16, 22, 32];
const String _outDir = 'apps/morsecq/assets/tray';

final img.Color _transparent = img.ColorRgba8(0, 0, 0, 0);
final img.Color _black = img.ColorRgba8(0, 0, 0, 255);
final img.Color _white = img.ColorRgba8(255, 255, 255, 255);
final img.Color _tile = img.ColorRgba8(0x1F, 0x4A, 0x7C, 255);

void main(List<String> args) {
  if (!File('pubspec.yaml').existsSync() || !Directory('apps').existsSync()) {
    stderr.writeln('[gen_tray_icons] run from the repository root');
    exit(1);
  }
  final dir = Directory(_outDir)..createSync(recursive: true);

  final tiles = <img.Image>[];
  for (final size in _sizes) {
    final template = _glyph(size, background: null, glyph: _black);
    _write('${dir.path}/tray_template_$size.png', img.encodePng(template));

    final tile = _glyph(size, background: _tile, glyph: _white);
    _write('${dir.path}/tray_icon_$size.png', img.encodePng(tile));
    tiles.add(tile);
  }

  // Each size is an independent .ico entry (addFrame would nest the other
  // sizes as an animated PNG inside the 16 px entry).
  _write('${dir.path}/tray_icon.ico', img.IcoEncoder().encodeImages(tiles));
  stdout.writeln(
    '[gen_tray_icons] wrote ${_sizes.length * 2 + 1} files to '
    '${dir.path}',
  );
}

/// The "· −" glyph (a dot then a dash, Morse for "A" without the letter
/// spacing) centred on a [size]×[size] canvas. [background] null keeps the
/// canvas transparent (template); otherwise a rounded tile is drawn first.
img.Image _glyph(
  int size, {
  required img.Color? background,
  required img.Color glyph,
}) {
  final image = img.Image(width: size, height: size, numChannels: 4);
  img.fill(image, color: _transparent);
  if (background != null) {
    img.fillRect(
      image,
      x1: 0,
      y1: 0,
      x2: size - 1,
      y2: size - 1,
      color: background,
      radius: (size * 0.22).round(),
    );
  }

  final centerY = size ~/ 2;
  // Stroke weight: 2 px at 16, 3 px at 22, 4 px at 32.
  final stroke = (size / 8).round().clamp(2, 6);
  final half = stroke ~/ 2;
  final inset = (size * 0.16).round();

  // Dot: a filled circle at the left.
  final dotRadius = (stroke * 0.75).round().clamp(1, size);
  final dotX = inset + dotRadius;
  img.fillCircle(image, x: dotX, y: centerY, radius: dotRadius, color: glyph);

  // Dash: a rounded bar filling the rest of the width.
  final dashX1 = dotX + dotRadius + (size * 0.12).round();
  final dashX2 = size - 1 - inset;
  if (dashX2 > dashX1) {
    img.fillRect(
      image,
      x1: dashX1,
      y1: centerY - half,
      x2: dashX2,
      y2: centerY - half + stroke - 1,
      color: glyph,
      radius: half,
    );
  }
  return image;
}

void _write(String path, List<int> bytes) {
  File(path).writeAsBytesSync(bytes, flush: true);
  stdout.writeln('  $path (${bytes.length} bytes)');
}
