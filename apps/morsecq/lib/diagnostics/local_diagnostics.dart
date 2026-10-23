import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Code-owned event names, never a path, plugin message or learning content.
enum DiagnosticContext {
  framework,
  runtime,
  settingsOpen,
  preferencesSave,
  learningSave,
  applicationExitSave,
  backgroundBegin,
  backgroundEnd,
  referencePrepare,
  inputDeviceProbe,
  captureFailure,
  inputDeviceList,
  desktopTray,
  desktopTrayHost,
  desktopDisplay,
  desktopWindowSave,
  desktopCloseSave,
  desktopSoundSave,
  desktopSoundChange,
  desktopBeforeQuit,
  desktopRead,
  desktopOperation,
}

/// Bounded device-local evidence, with no exception messages or supplied stacks.
/// Only an internally captured VM stack contributes code coordinates / PCs.
/// Nothing is uploaded. Copying requires a user tap.
final class LocalDiagnostics {
  LocalDiagnostics(this.file, {this.maximumBytes = 256 * 1024})
    : assert(maximumBytes >= 192);

  final File file;
  final int maximumBytes;
  static const _header = 'MorseCQ diagnostics v3\n';
  static LocalDiagnostics? _current;
  static bool _hooksInstalled = false;

  /// Install before startup work, without opening any shared persistent store.
  static void installErrorHandlers() {
    if (_hooksInstalled) return;
    _hooksInstalled = true;
    final hooks = DiagnosticErrorHooks(
      previousFlutter: FlutterError.onError,
      previousPlatform: PlatformDispatcher.instance.onError,
    );
    FlutterError.onError = hooks.handleFlutter;
    PlatformDispatcher.instance.onError = hooks.handlePlatform;
  }

  /// Called only after the desktop instance owns the data directory.
  static Future<void> initialize() async {
    if (_current != null) return;
    try {
      final root = await getApplicationSupportDirectory();
      final log = LocalDiagnostics(File('${root.path}/logs/errors.log'));
      log._prepareFiles();
      _current = log;
    } on Object {
      // Hooks remain safe even if diagnostics storage is unavailable.
    }
  }

  static void report(
    DiagnosticContext context,
    Object error, [
    StackTrace? stack,
  ]) {
    capture(context, error, stack);
    if (kDebugMode) debugPrint('[${context.name}] $error\n${stack ?? ""}');
  }

  static void capture(
    DiagnosticContext context,
    Object error, [
    StackTrace? stack,
  ]) {
    _current?.record(error, stack, context: context);
  }

  void record(
    Object error,
    StackTrace? stack, {
    DiagnosticContext context = DiagnosticContext.runtime,
  }) {
    try {
      // A supplied StackTrace can be fromString or a custom implementation.
      // Do not call its toString, even when it resembles a package frame.
      final frames = _codeFrames(StackTrace.current.toString());
      final safeType = switch (error) {
        FlutterError() => 'FlutterError',
        PlatformException() => 'PlatformException',
        MissingPluginException() => 'MissingPluginException',
        FileSystemException() => 'FileSystemException',
        TimeoutException() => 'TimeoutException',
        FormatException() => 'FormatException',
        StateError() => 'StateError',
        ArgumentError() => 'ArgumentError',
        UnsupportedError() => 'UnsupportedError',
        AssertionError() => 'AssertionError',
        TypeError() => 'TypeError',
        _ => 'Object',
      };
      var entry =
          '${DateTime.now().toUtc().toIso8601String()} '
          '${context.name} $safeType\n';
      for (final frame in frames) {
        if (utf8.encode('$_header$entry$frame\n').length > maximumBytes) break;
        entry += '$frame\n';
      }
      final bytes = utf8.encode(entry);
      if (bytes.length + _header.length > maximumBytes) return;
      _prepareFiles();
      var current = _readCurrent();
      if (current.length + bytes.length > maximumBytes) {
        _replace(File('${file.path}.previous'), current);
        current = utf8.encode(_header);
      }
      _replace(file, [...current, ...bytes]);
    } on Object {
      // Neither storage nor a malformed error may break an error hook.
    }
  }

  void _prepareFiles() {
    _checkPaths(create: true);
    final previous = File('${file.path}.previous');
    // Older versions persisted raw stack text. Never retain or export it.
    if (previous.existsSync() &&
        (!_hasHeader(previous) || previous.lengthSync() > maximumBytes)) {
      previous.deleteSync();
    }
    if (!file.existsSync() ||
        !_hasHeader(file) ||
        file.lengthSync() > maximumBytes) {
      _replace(file, utf8.encode(_header));
    }
  }

  /// Reject links before every entry point. Replacements use a private temp
  /// directory and rename, so swapping a file for a symlink/hardlink cannot
  /// turn a diagnostic rewrite into a truncate/append of its target.
  void _checkPaths({bool create = false}) {
    final parent = file.parent;
    var kind = FileSystemEntity.typeSync(parent.path, followLinks: false);
    if (kind == FileSystemEntityType.notFound && create) {
      parent.createSync(recursive: true);
      kind = FileSystemEntity.typeSync(parent.path, followLinks: false);
    }
    if (kind != FileSystemEntityType.directory &&
        kind != FileSystemEntityType.notFound) {
      throw const FileSystemException('Unsafe diagnostic directory');
    }
    for (final path in [file.path, '${file.path}.previous']) {
      final type = FileSystemEntity.typeSync(path, followLinks: false);
      if (type != FileSystemEntityType.file &&
          type != FileSystemEntityType.notFound) {
        throw const FileSystemException('Unsafe diagnostic entry');
      }
    }
  }

  void _replace(File destination, List<int> bytes) {
    _checkPaths(create: true);
    final parent = file.parent.resolveSymbolicLinksSync();
    final temporary = Directory(parent).createTempSync('.diagnostics-');
    final staged = File('${temporary.path}/entry');
    try {
      staged.writeAsBytesSync(bytes, flush: true);
      _checkPaths();
      if (file.parent.resolveSymbolicLinksSync() != parent ||
          FileSystemEntity.typeSync(temporary.path, followLinks: false) !=
              FileSystemEntityType.directory) {
        throw const FileSystemException('Diagnostic directory changed');
      }
      staged.renameSync('$parent/${destination.uri.pathSegments.last}');
    } finally {
      try {
        if (Directory(parent).resolveSymbolicLinksSync() == parent &&
            FileSystemEntity.typeSync(temporary.path, followLinks: false) ==
                FileSystemEntityType.directory) {
          if (staged.existsSync()) staged.deleteSync();
          temporary.deleteSync();
        }
      } on Object {
        // Never follow a changed directory during best-effort cleanup.
      }
    }
  }

  List<int> _readCurrent() {
    _checkPaths();
    final handle = file.openSync();
    try {
      final bytes = handle.readSync(maximumBytes + 1);
      if (bytes.length > maximumBytes ||
          !utf8.decode(bytes, allowMalformed: true).startsWith(_header)) {
        throw const FileSystemException('Diagnostic entry changed');
      }
      _checkPaths();
      return bytes;
    } finally {
      handle.closeSync();
    }
  }

  static bool _hasHeader(File entry) {
    final handle = entry.openSync();
    try {
      return utf8.decode(
            handle.readSync(_header.length),
            allowMalformed: true,
          ) ==
          _header;
    } finally {
      handle.closeSync();
    }
  }

  static Future<String> read() async {
    try {
      final current = _current;
      if (current != null) return await current.readEvidence();
      final root = await getApplicationSupportDirectory();
      return await LocalDiagnostics(
        File('${root.path}/logs/errors.log'),
      ).readEvidence();
    } on Object {
      return 'MorseCQ local diagnostics unavailable';
    }
  }

  Future<String> readEvidence() async {
    try {
      return _readEvidence();
    } on Object {
      return 'MorseCQ local diagnostics unavailable';
    }
  }

  String _readEvidence() {
    _checkPaths();
    final parts = <String>[];
    for (final entry in [File('${file.path}.previous'), file]) {
      if (FileSystemEntity.typeSync(entry.path, followLinks: false) ==
          FileSystemEntityType.file) {
        final handle = entry.openSync();
        try {
          final bytes = handle.readSync(maximumBytes);
          _checkPaths();
          final text = utf8.decode(bytes, allowMalformed: true);
          if (text.startsWith(_header)) parts.add(text);
        } finally {
          handle.closeSync();
        }
      }
    }
    return 'MorseCQ local diagnostics\n${parts.join("\n")}';
  }

  /// Exercises the VM-format parser; production only passes StackTrace.current.
  @visibleForTesting
  static List<String> codeFramesForTesting(String text) => _codeFrames(text);

  static List<String> _codeFrames(String text) {
    final frames = <String>[];
    final source = RegExp(
      r'\(((?:package:(?:morsecq|morse_core|morse_io|morse_trainer|morse_dsp|radio_tools|flutter)/[A-Za-z_0-9/]+\.dart|dart:[A-Za-z_0-9/.]+)(?::[0-9]+){1,2})\)$',
    );
    final pc = RegExp(
      r'^\s*#([0-9]+)\s+abs ([0-9a-fA-F]+)(?:\s+virt ([0-9a-fA-F]+))?\b',
    );
    final base = RegExp(
      r'^\s*(isolate_dso_base|vm_dso_base|isolate_instructions|vm_instructions):\s*(?:0x)?([0-9a-fA-F]+)\b',
    );
    for (final line in const LineSplitter().convert(text)) {
      final match = source.firstMatch(line);
      if (match != null) {
        frames.add(match[1]!);
      } else if (pc.firstMatch(line) case final address?) {
        frames.add(
          'pc=0x${address[2]}${address[3] == null ? "" : " virtual=0x${address[3]}"}',
        );
      } else if (base.firstMatch(line) case final address?) {
        frames.add('${address[1]}=0x${address[2]}');
      }
      if (frames.length == 12) break;
    }
    return frames;
  }
}

/// Debug builds keep the previous framework/test handler; release never
/// forwards raw details. File storage is optional and independent of hooks.
final class DiagnosticErrorHooks {
  DiagnosticErrorHooks({
    this.debugMode = kDebugMode,
    this.previousFlutter,
    this.previousPlatform,
    this.record = LocalDiagnostics.capture,
  });

  final bool debugMode;
  final FlutterExceptionHandler? previousFlutter;
  final bool Function(Object, StackTrace)? previousPlatform;
  final void Function(DiagnosticContext, Object, StackTrace?) record;

  void handleFlutter(FlutterErrorDetails details) {
    record(DiagnosticContext.framework, details.exception, details.stack);
    if (debugMode) (previousFlutter ?? FlutterError.presentError)(details);
  }

  bool handlePlatform(Object error, StackTrace stack) {
    record(DiagnosticContext.runtime, error, stack);
    return debugMode ? previousPlatform?.call(error, stack) ?? false : true;
  }
}
