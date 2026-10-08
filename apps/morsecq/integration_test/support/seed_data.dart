import 'dart:io';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/file_trainer_store.dart';

const kSeedSpan = Duration(hours: 1);
DateTime seedAnchor(DateTime now) {
  final morning = DateTime(now.year, now.month, now.day, 9, 12);
  if (!morning.add(kSeedSpan).isAfter(now)) return morning;
  final back = now.subtract(const Duration(hours: 3));
  final midnight = DateTime(now.year, now.month, now.day);
  if (!back.isBefore(midnight)) return back;
  return midnight.add(kSeedSpan).isAfter(now) ? back : midnight;
}

/// A week of Koch practice (lesson 4, K M R S U) with a few S/U slips, so
/// the Learn home, the statistics page and the calendar have content. The
/// last receive session is at [anchor] and the send session just after it,
/// so "today" always has practice (see [seedAnchor]).
Future<void> seedTrainingProgress(
  String dataDir, {
  required DateTime anchor,
}) async {
  var progress = TrainerProgress(currentLesson: 4, dailyGoalChars: 30);
  const target = 'KMRSU SUKMR RSUMK KMRSU';
  const answers = <String>[
    'KMRSU SUKMR RSUMK KMRSU',
    'KMRSU SUKMR RSUMK KMRUU',
    'KMRSU UUKMR RSUMK KMRSU',
    'KMRSU SUKMR RSUMK KMRSU',
    'KMRSS SUKMR RSUMK KMRSU',
    'KMRSU SUKMR RSSMK KMRSU',
  ];
  for (var i = answers.length - 1; i >= 0; i--) {
    final at = anchor.subtract(Duration(days: i));
    final score = SessionScore.evaluate(
      target,
      answers[i],
      at: at,
      elapsed: const Duration(minutes: 3),
      lesson: 4,
      drillKind: 'groups',
    );
    progress = progress.recordSession(score, now: at, lesson: 4);
  }
  final sendAt = anchor.add(const Duration(minutes: 40));
  final send = SessionScore.evaluate(
    'KMRS SUK',
    'KMRS SUK',
    at: sendAt,
    elapsed: const Duration(minutes: 1),
    lesson: 4,
    drillKind: 'send',
  );
  progress = progress.recordSession(
    send,
    now: sendAt,
    lesson: 4,
    updateSrs: false,
  );
  await Directory(dataDir).create(recursive: true);
  await FileTrainerStore.inDataDirectory(dataDir).save(progress);
}
