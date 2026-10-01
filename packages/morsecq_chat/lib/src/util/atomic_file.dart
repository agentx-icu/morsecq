import 'dart:io';
import 'dart:typed_data';

int _nextStageId = 0;

/// Replaces a file only after a flushed, independent staging write completes.
/// A unique sibling keeps overlapping writers from sharing or deleting a stage.
Future<void> writeBytesAtomic(File target, Uint8List bytes) async {
  await target.parent.create(recursive: true);
  final stage = File(
    '${target.path}.$pid.${DateTime.now().microsecondsSinceEpoch}.'
    '${_nextStageId++}.new',
  );
  try {
    await stage.writeAsBytes(bytes, flush: true);
    await stage.rename(target.path);
  } catch (_) {
    if (await stage.exists()) await stage.delete();
    rethrow;
  }
}
