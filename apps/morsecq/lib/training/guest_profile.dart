import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'file_trainer_store.dart';
import 'training_controller.dart';
import 'training_doc_store.dart';
import 'training_settings_store.dart';

/// Whose learning data a training controller works on (functional spec
/// §8.2): the local guest, or an identity by public key. Chat always needs
/// a real identity.
sealed class LearningProfile {
  const LearningProfile();

  String get key;
}

final class GuestProfile extends LearningProfile {
  const GuestProfile();

  static const String profileKey = 'guest';

  @override
  String get key => profileKey;
}

final class IdentityProfile extends LearningProfile {
  const IdentityProfile(this.publicKey);

  final String publicKey;

  @override
  String get key => publicKey;
}

/// Guest learning data, kept apart from every identity under
/// `<support>/morsecq/guest/` (training files in its `training/`
/// sub-directory, like an identity's data directory). It never touches,
/// reads or decrypts an identity profile.
class GuestStore {
  GuestStore({Future<String> Function()? root}) : _root = root ?? _defaultRoot;

  static Future<String> _defaultRoot() async {
    final support = await getApplicationSupportDirectory();
    return p.join(support.path, 'morsecq', 'guest');
  }

  final Future<String> Function() _root;

  /// The guest's data directory (the equivalent of an identity's).
  Future<String> directory() async {
    final dir = await _root();
    await Directory(dir).create(recursive: true);
    return dir;
  }

  Future<File> _marker() async => File(p.join(await directory(), 'active'));

  /// Whether the learner chose guest mode last time (kept across restarts).
  Future<bool> isActive() async => (await _marker()).exists();

  Future<void> setActive(bool active) async {
    final marker = await _marker();
    if (active) {
      await marker.writeAsString('1', flush: true);
    } else if (await marker.exists()) {
      await marker.delete();
    }
  }

  /// Whether there is guest progress worth migrating.
  Future<bool> hasProgress() async {
    final dir = await directory();
    return File(
      p.join(dir, FileTrainerStore.subdirectory, FileTrainerStore.fileName),
    ).exists();
  }

  /// The guest's training controller (file stores under [directory]).
  Future<TrainingController> openController() async {
    final dir = await directory();
    final controller = TrainingController(
      progressStore: FileTrainerStore.inDataDirectory(dir),
      settingsStore: FileTrainingSettingsStore.inDataDirectory(dir),
      profileKey: GuestProfile.profileKey,
      docs: FileTrainingDocStore.inDataDirectory(dir),
    );
    await controller.load();
    return controller;
  }

  /// Deletes the guest's learning data (the learner asked to clear it).
  Future<void> clear() async {
    final training = Directory(
      p.join(await directory(), FileTrainerStore.subdirectory),
    );
    if (await training.exists()) await training.delete(recursive: true);
  }
}

/// What a migration did.
enum MigrationOutcome {
  /// Data moved; or nothing to move.
  done,

  /// This identity already received the guest data (idempotent retry).
  alreadyDone,
}

/// Moves (or, for a restored identity, explicitly replaces) training data
/// from the guest to an identity as one recoverable transaction:
/// stage a copy → validate it → move any existing target aside → commit by
/// rename → record completion → remove the guest copy. A failure before
/// the commit leaves the guest data untouched and usable; retrying never
/// duplicates anything because the files are copied, not credited again.
final class GuestMigration {
  GuestMigration({
    required this.guestDirectory,
    required this.identityDirectory,
  });

  final String guestDirectory;
  final String identityDirectory;

  String get _source => p.join(guestDirectory, FileTrainerStore.subdirectory);
  String get _target =>
      p.join(identityDirectory, FileTrainerStore.subdirectory);
  String get _staging => '$_target.guest-staging';
  File _doneMarker(String key) =>
      File(p.join(guestDirectory, 'migrated-${key.toLowerCase()}.json'));

  Future<MigrationOutcome> run({
    required String identityKey,
    required DateTime now,
  }) async {
    final marker = _doneMarker(identityKey);
    if (await marker.exists()) return MigrationOutcome.alreadyDone;
    final source = Directory(_source);
    if (!await source.exists()) return MigrationOutcome.done;

    // 1. Stage a copy (a leftover staging dir from a crash is redone).
    final staging = Directory(_staging);
    if (await staging.exists()) await staging.delete(recursive: true);
    await _copy(source, staging);

    // 2. Validate: the staged progress must load.
    final progress = File(p.join(_staging, FileTrainerStore.fileName));
    if (await progress.exists()) {
      final loaded = await FileTrainerStore(progress).load();
      if (loaded == null) {
        throw const FormatException('staged guest progress is unreadable');
      }
    }

    // 3. Move an existing target aside (never deleted here), 4. commit.
    final target = Directory(_target);
    if (await target.exists()) {
      await target.rename(
        '$_target.before-guest-${now.millisecondsSinceEpoch}',
      );
    }
    await staging.rename(_target);

    // 5. Record completion before removing the guest copy, so a retry after
    // a failed removal is a no-op rather than a second copy.
    await marker.writeAsString(
      jsonEncode(<String, Object?>{'at': now.toIso8601String()}),
      flush: true,
    );
    await source.delete(recursive: true);
    return MigrationOutcome.done;
  }

  static Future<void> _copy(Directory from, Directory to) async {
    await to.create(recursive: true);
    await for (final entity in from.list(recursive: false)) {
      final name = p.basename(entity.path);
      if (entity is Directory) {
        await _copy(entity, Directory(p.join(to.path, name)));
      } else if (entity is File) {
        await entity.copy(p.join(to.path, name));
      }
    }
  }
}
