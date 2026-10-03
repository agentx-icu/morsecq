import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Keeps MorseCQ's identity data out of OS backups on iOS and macOS by
/// marking `<application support>/morsecq` excluded (NSURLIsExcludedFromBackupKey,
/// set natively by `BackupExclusion` in the Runner). The parent of the
/// identity tree is marked, not the tree itself: an import replaces that
/// tree and creates recovery siblings, and Apple notes that such file
/// operations can drop the attribute on the items they recreate.
///
/// Android has no per-path call: its manifest opts out of backup and device
/// transfer (res/xml/data_extraction_rules.xml). Desktop Linux / Windows
/// backups are the user's own configuration.
abstract final class BackupExclusion {
  static const MethodChannel _channel = MethodChannel(
    'icu.agentx.morsecq/backup_exclusion',
  );

  /// Call before any identity data is written. Never throws: a failure is
  /// reported and the app carries on (the data is still encrypted at rest
  /// when a password is set).
  static Future<void> excludeAppData() async {
    if (kIsWeb || !(Platform.isIOS || Platform.isMacOS)) return;
    try {
      final Directory support = await getApplicationSupportDirectory();
      final Directory dir = Directory(p.join(support.path, 'morsecq'));
      await dir.create(recursive: true);
      await _channel.invokeMethod<bool>('exclude', {'path': dir.path});
    } on Object catch (error) {
      debugPrint('[BackupExclusion] could not exclude app data: $error');
    }
  }
}
