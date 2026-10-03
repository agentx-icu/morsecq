import 'dart:io';
import 'dart:ui' show Rect;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../i18n/current_strings.dart';

/// Where backup bytes go and come from. Abstracted so widget tests never
/// touch the native pickers and so the platform split (save dialog on
/// desktop, share sheet on mobile) lives in exactly one place.
abstract interface class BackupFileGateway {
  /// Hands [bytes] to the user. Returns true when the file was saved/shared,
  /// false when the user cancelled. Throws on I/O failure.
  ///
  /// [shareOrigin] is the global rect of the control that triggered the
  /// export. iPadOS presents the share sheet as a popover anchored to it;
  /// without one the popover floats in the middle of the screen, detached
  /// from the button. Ignored by the desktop save dialog.
  Future<bool> saveBackup(
    Uint8List bytes, {
    required String fileName,
    Rect? shareOrigin,
  });

  /// Lets the user pick a backup file; null when cancelled.
  Future<Uint8List?> pickBackup();
}

/// Real implementation: `file_picker` save dialog on desktop, `share_plus`
/// share sheet on Android/iOS (there is no user-visible file system to save
/// into, and the share sheet reaches Files / Drive / AirDrop / mail).
final class PlatformBackupFileGateway implements BackupFileGateway {
  const PlatformBackupFileGateway();

  static const _mimeType = 'application/octet-stream';

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<bool> saveBackup(
    Uint8List bytes, {
    required String fileName,
    Rect? shareOrigin,
  }) async {
    if (_isMobile) return _shareOnMobile(bytes, fileName, shareOrigin);
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: _mimeType,
      // No BuildContext this deep: the native dialog reads the current
      // UI language through currentS().
      dialogTitle: currentS().accountBackupSaveDialogTitle,
    );
    return uri != null;
  }

  Future<bool> _shareOnMobile(
    Uint8List bytes,
    String fileName,
    Rect? shareOrigin,
  ) async {
    // The share sheet needs a real file; the app's temp dir is private to us
    // and readable by the share extension.
    final dir = await Directory.systemTemp.createTemp('morsecq_backup_');
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: _mimeType, name: fileName)],
          subject: currentS().accountBackupShareSubject,
          sharePositionOrigin: shareOrigin,
        ),
      );
      return result.status != ShareResultStatus.dismissed;
    } finally {
      // Best effort; a leftover temp file is harmless.
      await dir.delete(recursive: true).then<void>((_) {}, onError: (_) {});
    }
  }

  @override
  Future<Uint8List?> pickBackup() async {
    final file = await FilePicker.pickFile(
      dialogTitle: currentS().accountBackupChooseDialogTitle,
    );
    if (file == null) return null;
    return file.readAsBytes();
  }
}

/// Test double: records what was saved and returns scripted picks.
final class FakeBackupFileGateway implements BackupFileGateway {
  FakeBackupFileGateway({this.saveResult = true, this.pickResult});

  bool saveResult;
  Uint8List? pickResult;
  Object? saveError;
  final List<Uint8List> saved = [];
  final List<String> savedNames = [];
  final List<Rect?> shareOrigins = [];

  @override
  Future<bool> saveBackup(
    Uint8List bytes, {
    required String fileName,
    Rect? shareOrigin,
  }) async {
    final error = saveError;
    if (error != null) throw error;
    saved.add(bytes);
    savedNames.add(fileName);
    shareOrigins.add(shareOrigin);
    return saveResult;
  }

  @override
  Future<Uint8List?> pickBackup() async => pickResult;
}
