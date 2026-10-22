import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Bounded device-local crash evidence. Exception messages, material text and
/// audio are never recorded; nothing is uploaded. Copying requires a user tap.
final class LocalDiagnostics {
  LocalDiagnostics(this.file, {this.maximumBytes = 256 * 1024});
  final File file;
  final int maximumBytes;
  static LocalDiagnostics? _current;

  static Future<void> initialize() async {
    if (_current != null) return;
    try {
      final root = await getApplicationSupportDirectory();
      final log = _current = LocalDiagnostics(
        File('${root.path}/logs/errors.log'),
      );
      final previousFlutter = FlutterError.onError;
      FlutterError.onError = (details) {
        log.record(details.exception, details.stack);
        (previousFlutter ?? FlutterError.presentError)(details);
      };
      final previousPlatform = PlatformDispatcher.instance.onError;
      PlatformDispatcher.instance.onError = (error, stack) {
        log.record(error, stack);
        return previousPlatform?.call(error, stack) ?? false;
      };
    } on Object {
      // Diagnostics must never prevent using local learning data.
    }
  }

  void record(Object error, StackTrace? stack) {
    try {
      file.parent.createSync(recursive: true);
      final bytes = utf8
          .encode(
            '${DateTime.now().toUtc().toIso8601String()} ${error.runtimeType}\n${stack ?? ""}\n',
          )
          .take(maximumBytes)
          .toList();
      if (file.existsSync() &&
          file.lengthSync() + bytes.length > maximumBytes) {
        final previous = File('${file.path}.previous');
        if (previous.existsSync()) previous.deleteSync();
        file.renameSync(previous.path);
      }
      file.writeAsBytesSync(bytes, mode: FileMode.append, flush: true);
    } on FileSystemException {
      // Preserve the original failure when storage is full or unavailable.
    }
  }

  static Future<String> read() async {
    try {
      final root = await getApplicationSupportDirectory();
      final file = _current?.file ?? File('${root.path}/logs/errors.log');
      final parts = <String>[];
      for (final entry in [File('${file.path}.previous'), file]) {
        if (await entry.exists()) {
          parts.add(
            utf8.decode(await entry.readAsBytes(), allowMalformed: true),
          );
        }
      }
      return 'MorseCQ local diagnostics\n${parts.join("\n")}';
    } on Object {
      return 'MorseCQ local diagnostics unavailable';
    }
  }
}
