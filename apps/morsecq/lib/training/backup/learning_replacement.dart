import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../kept_recordings.dart';
import 'learning_backup_format.dart';

/// Directory operations of a replacement; tests override them to inject a
/// failure at each step.
class LearningFs {
  const LearningFs();
  Future<Directory> rename(Directory from, String to) => from.rename(to);
  Future<void> delete(Directory dir) => dir.delete(recursive: true);
}

/// The outcome a caller must act on when a replacement did not commit.
enum LearningReplacementFailure {
  /// Nothing changed: the previous learning directory is in place.
  rolledBack,

  /// The previous directory could not be moved back. It is kept beside the
  /// profile; learning must stay unavailable until recovery succeeds.
  stranded,
}

final class LearningReplacementException implements Exception {
  const LearningReplacementException(this.failure, this.cause);
  final LearningReplacementFailure failure;
  final Object cause;
  @override
  String toString() => 'LearningReplacementException(${failure.name}): $cause';
}

/// Raised by [recoverLearningRoot] when the leftovers do not say which
/// directory is the learner's; nothing is deleted in that case.
final class LearningRecoveryException implements Exception {
  const LearningRecoveryException(this.candidates);
  final List<String> candidates;
  @override
  String toString() => 'LearningRecoveryException($candidates)';
}

const String _training = 'training';
const String _stagingPrefix = 'training.restore-';
const String _previousPrefix = 'training.previous-';

/// Swaps a profile's `training/` directory for a restored one.
///
/// [stage] writes the backup into a fresh sibling directory. [commit]
/// renames `training` aside, then the staging directory into place: that
/// second rename is the commit point. A failure before it moves the previous
/// directory back. The caller holds the learning storage exclusively (no
/// controller, no admitted reads or writes, no other process) throughout
/// [commit]. Crash safety relies on [recoverLearningRoot] at startup; it is
/// not a power-loss guarantee.
final class LearningReplacement {
  LearningReplacement(
    this.profileDir, {
    this.fs = const LearningFs(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final String profileDir;
  final LearningFs fs;
  final DateTime Function() _clock;

  Directory get _active => Directory(p.join(profileDir, _training));

  /// Writes [backup]'s documents to a new staging directory.
  ///
  /// Earlier leftovers are cleaned first; if that fails, a new restore is
  /// refused rather than adding another candidate directory.
  Future<Directory> stage(LearningBackup backup) async {
    final (_, previous) = await _leftovers(profileDir);
    if (previous.isNotEmpty && !await _active.exists()) {
      // Only recovery may decide what these are.
      throw LearningRecoveryException([for (final d in previous) d.path]);
    }
    await deleteLeftovers(profileDir, fs: fs);
    final staging = Directory(await _fresh(_stagingPrefix));
    try {
      for (final MapEntry(:key, :value) in backup.documents.entries) {
        final file = File(p.joinAll([staging.path, ...key.split('/')]));
        await file.parent.create(recursive: true);
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(value),
          flush: true,
        );
      }
      // An empty backup still restores an (empty) learning directory.
      await staging.create(recursive: true);
    } on Object {
      await discard(staging);
      rethrow;
    }
    return staging;
  }

  /// Best-effort removal of a staging directory that will not be committed.
  Future<void> discard(Directory staging) async {
    try {
      if (await staging.exists()) await fs.delete(staging);
    } on Object {
      // Recovery deletes uncommitted staging directories later.
    }
  }

  /// Replaces `training/` with [staging]. Returns false when only deleting
  /// the previous directory failed (the restore itself succeeded; recovery
  /// finishes the cleanup). Throws [LearningReplacementException].
  Future<bool> commit(Directory staging) async {
    final active = _active;
    try {
      await _keepLocalRecordings();
    } on Object catch (error) {
      await discard(staging);
      throw LearningReplacementException(
        LearningReplacementFailure.rolledBack,
        error,
      );
    }
    Directory? previous;
    if (await active.exists()) {
      try {
        previous = await fs.rename(active, await _fresh(_previousPrefix));
      } on Object catch (error) {
        await discard(staging);
        throw LearningReplacementException(
          LearningReplacementFailure.rolledBack,
          error,
        );
      }
    }
    try {
      await fs.rename(staging, active.path);
    } on Object catch (error) {
      if (previous != null) {
        try {
          await fs.rename(previous, active.path);
        } on Object {
          throw LearningReplacementException(
            LearningReplacementFailure.stranded,
            error,
          );
        }
      }
      await discard(staging);
      throw LearningReplacementException(
        LearningReplacementFailure.rolledBack,
        error,
      );
    }
    if (previous == null) return true;
    try {
      await fs.delete(previous);
      return true;
    } on Object {
      return false;
    }
  }

  /// Recordings stay on the device across a restore while the restored
  /// entries may not mention them: keep every one present now (under the
  /// caller's exclusivity) so the workbench sweep leaves them. Written
  /// before the swap, so a rollback only ever keeps more.
  Future<void> _keepLocalRecordings() async {
    final media = Directory(p.join(profileDir, 'media', 'recordings'));
    final files = <String>{};
    if (await media.exists()) {
      await for (final entity in media.list(followLinks: false)) {
        if (entity is File) {
          files.add('media/recordings/${p.basename(entity.path)}');
        }
      }
    }
    await KeptRecordings(profileDir).addAll(files);
  }

  Future<String> _fresh(String prefix) async {
    var stamp = _clock().toUtc().microsecondsSinceEpoch;
    while (true) {
      final path = p.join(profileDir, '$prefix$stamp');
      if (!await FileSystemEntity.isDirectory(path) &&
          !await File(path).exists()) {
        return path;
      }
      stamp++;
    }
  }
}

Future<(List<Directory>, List<Directory>)> _leftovers(String profileDir) async {
  final staging = <Directory>[];
  final previous = <Directory>[];
  final root = Directory(profileDir);
  if (!await root.exists()) return (staging, previous);
  await for (final entity in root.list(followLinks: false)) {
    if (entity is! Directory) continue;
    final name = p.basename(entity.path);
    if (name.startsWith(_stagingPrefix)) staging.add(entity);
    if (name.startsWith(_previousPrefix)) previous.add(entity);
  }
  return (staging, previous);
}

/// Deletes every staging and previous directory of the profile, whatever
/// state it is in (clearing learning data, or a restore that found the
/// active directory in place). Throws when one cannot be removed.
Future<void> deleteLeftovers(
  String profileDir, {
  LearningFs fs = const LearningFs(),
}) async {
  final (staging, previous) = await _leftovers(profileDir);
  for (final dir in [...staging, ...previous]) {
    await fs.delete(dir);
  }
}

/// Startup recovery after an interrupted replacement. Run once, before any
/// controller or recording library opens the profile, while holding the
/// exclusive storage lock.
///
/// * `training/` exists: the last replacement committed (or none ran);
///   leftovers are removed.
/// * `training/` missing, exactly one previous directory: the replacement
///   stopped before its commit point; the previous directory moves back.
/// * Only staging directories: they were never committed and are removed.
/// * Several previous directories and no `training/`: ambiguous; everything
///   is kept and [LearningRecoveryException] is thrown.
///
/// Returns whether anything was recovered or removed. A failure to delete a
/// leftover is ignored here (the next start retries).
Future<bool> recoverLearningRoot(
  String profileDir, {
  LearningFs fs = const LearningFs(),
}) async {
  final (staging, previous) = await _leftovers(profileDir);
  if (staging.isEmpty && previous.isEmpty) return false;
  final active = Directory(p.join(profileDir, _training));
  final remove = <Directory>[...staging];
  if (await active.exists()) {
    remove.addAll(previous);
  } else if (previous.length == 1) {
    await fs.rename(previous.single, active.path);
  } else if (previous.length > 1) {
    throw LearningRecoveryException([for (final d in previous) d.path]);
  }
  for (final dir in remove) {
    try {
      await fs.delete(dir);
    } on Object {
      // Left for the next start.
    }
  }
  return true;
}
