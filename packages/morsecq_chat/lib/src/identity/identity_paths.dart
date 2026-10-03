import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../util/posix_permissions.dart';

/// On-disk layout of the (single) morsecq identity.
///
/// ```text
/// <root>/                     e.g. <appSupport>/morsecq/identity
///   identity.json             display name, status, Tox ID, hasPassword
///   profile/tox_profile.tox   Tox savedata (always encrypted on disk when
///                             a password is set; native encrypts each save)
///   data/chat_history/        Tim2Tox message history (JSON per conversation)
///   data/offline_message_queue.json
///   data/file_recv/  data/avatars/  data/scratch/
///   training/                 IdentityService.dataDirectory(): other
///                             modules' per-identity state (morse_trainer)
/// ```
///
/// `tox_profile.tox` is the file name Tim2Tox's `initWithPath` reads and
/// writes inside the profile directory (same as toxee's
/// `AppPaths.profileFileInDirectory`).
class IdentityPaths {
  const IdentityPaths(this.root);

  /// Production layout under the platform application-support directory
  /// (Library/Application Support on macOS/iOS, the app's files dir on
  /// Android, XDG data dir on Linux, %APPDATA% on Windows).
  static Future<IdentityPaths> forApplicationSupport() async {
    final base = await getApplicationSupportDirectory();
    return IdentityPaths(p.join(base.path, 'morsecq', 'identity'));
  }

  final String root;

  String get identityFile => p.join(root, 'identity.json');
  String get profileDirectory => p.join(root, 'profile');
  String get profileFile => p.join(profileDirectory, 'tox_profile.tox');
  String get dataDirectory => p.join(root, 'data');
  String get historyDirectory => p.join(dataDirectory, 'chat_history');
  String get offlineQueueFile =>
      p.join(dataDirectory, 'offline_message_queue.json');
  String get fileRecvDirectory => p.join(dataDirectory, 'file_recv');
  String get avatarsDirectory => p.join(dataDirectory, 'avatars');
  String get scratchDirectory => p.join(dataDirectory, 'scratch');
  String get trainingDirectory => p.join(root, 'training');

  /// Creates every directory the engine writes into. The identity root and
  /// its parent (where import staging lives) are made owner-only first, so
  /// nothing below them is ever reachable by other local accounts.
  Future<void> ensureDirectories() async {
    await PosixPermissions.createPrivateDirectory(p.dirname(root));
    await PosixPermissions.createPrivateDirectory(root);
    for (final dir in [
      profileDirectory,
      historyDirectory,
      fileRecvDirectory,
      avatarsDirectory,
      scratchDirectory,
      trainingDirectory,
    ]) {
      await Directory(dir).create(recursive: true);
    }
  }

  bool get profileExists => File(profileFile).existsSync();

  /// Prefix of the staging directories an import creates next to [root]
  /// (`identity_backup.dart`); a failed import may leave one holding the
  /// previous identity as its only recovery copy.
  static const String importStagePrefix = '.morsecq-import-';

  /// Deletes the whole identity tree, and any import staging directory next
  /// to it (they hold an older copy of this identity). Irreversible.
  Future<void> deleteAll() async {
    final dir = Directory(root);
    if (await dir.exists()) await dir.delete(recursive: true);
    final parent = dir.parent;
    if (!await parent.exists()) return;
    await for (final entry in parent.list(followLinks: false)) {
      if (entry is Directory &&
          p.basename(entry.path).startsWith(importStagePrefix)) {
        await entry.delete(recursive: true);
      }
    }
  }
}
