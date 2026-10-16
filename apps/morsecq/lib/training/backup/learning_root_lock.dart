import 'dart:io';

import 'package:path/path.dart' as p;

/// A cooperative lock on a learning profile shared by app instances.
///
/// Every instance holds the profile lock shared while it uses the profile.
/// Replacing or recovering `training/` needs it exclusively, which fails
/// while another instance (Linux runs non-unique instances) has the profile
/// open. Converting shared to exclusive briefly releases the profile lock,
/// so an instance first takes a separate gate lock: with only one converter
/// at a time, nobody can take the profile exclusively in that gap, and a
/// failed upgrade keeps an unbroken claim on the same profile state.
///
/// Both lock files sit beside `training/`, so a replacement never moves
/// them. POSIX locks belong to the process and Windows locks to the handle:
/// keep one [LearningRootLock] per process.
final class LearningRootLock {
  LearningRootLock._(this._profileDir, this._file);

  static const String fileName = '.learning.lock';
  static const String gateName = '.learning.gate';

  final String _profileDir;
  final RandomAccessFile _file;
  RandomAccessFile? _gate;
  bool _closed = false;

  bool get isExclusive => _gate != null;

  /// Opens the lock file under [profileDir] and takes the shared lock,
  /// waiting for a running replacement in another instance to finish.
  static Future<LearningRootLock> acquire(String profileDir) async {
    await Directory(profileDir).create(recursive: true);
    final file = await File(
      p.join(profileDir, fileName),
    ).open(mode: FileMode.append);
    try {
      await file.lock(FileLock.blockingShared);
    } on Object {
      await file.close();
      rethrow;
    }
    return LearningRootLock._(profileDir, file);
  }

  /// Upgrades to the exclusive lock without waiting. Returns false, still
  /// holding the shared lock, when another instance has the profile open
  /// or is upgrading itself.
  Future<bool> tryExclusive() async {
    _ensureOpen();
    if (isExclusive) return true;
    final gate = await File(
      p.join(_profileDir, gateName),
    ).open(mode: FileMode.append);
    try {
      await gate.lock(FileLock.exclusive);
    } on FileSystemException {
      await gate.close();
      return false;
    }
    await _file.unlock();
    try {
      await _file.lock(FileLock.exclusive);
    } on FileSystemException {
      // Nobody else can hold the profile exclusively while we hold the
      // gate, so this returns promptly.
      await _file.lock(FileLock.blockingShared);
      await _closeGate(gate);
      return false;
    }
    _gate = gate;
    return true;
  }

  /// Returns to the shared lock after an exclusive operation.
  Future<void> release() async {
    _ensureOpen();
    final gate = _gate;
    if (gate == null) return;
    await _file.unlock();
    await _file.lock(FileLock.blockingShared);
    _gate = null;
    await _closeGate(gate);
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final gate = _gate;
    _gate = null;
    if (gate != null) await _closeGate(gate);
    try {
      await _file.unlock();
    } on FileSystemException {
      // Closing releases it anyway.
    }
    await _file.close();
  }

  static Future<void> _closeGate(RandomAccessFile gate) async {
    try {
      await gate.unlock();
    } on FileSystemException {
      // Closing releases it anyway.
    }
    await gate.close();
  }

  void _ensureOpen() {
    if (_closed) throw StateError('Learning lock closed');
  }
}
