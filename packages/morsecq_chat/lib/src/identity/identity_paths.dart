import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// On-disk layout of the (single) morsecq identity.
///
/// ```text
/// <root>/                     e.g. <appSupport>/morsecq/identity
///   identity.json             display name, status, Tox ID, hasPassword
///   profile/tox_profile.tox   Tox savedata (encrypted at rest when a
///                             password is set and the engine is stopped)
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

  /// Creates every directory the engine writes into.
  Future<void> ensureDirectories() async {
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

  /// Deletes the whole identity tree. Irreversible.
  Future<void> deleteAll() async {
    final dir = Directory(root);
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
