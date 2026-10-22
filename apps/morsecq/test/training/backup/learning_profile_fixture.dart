import 'dart:io';

import 'package:morse_core/morse_core.dart';
import 'package:morse_session/morse_session.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:path/path.dart' as p;

/// Fills [c] (a controller over [profileDir]) with one of every learning
/// document family a backup carries, and returns the send detail reference.
Future<String> populateLearningProfile(
  TrainingController c,
  String profileDir,
) async {
  await c.setLesson(12);
  await c.markFirstLessonDone();
  await c.updateSettings(
    c.settings.copyWith(
      trainer: c.trainerSettings.copyWith(characterWpm: 22, farnsworthWpm: 11),
    ),
  );
  final copy = c.startReceiveSession(ReceiveDrillKind.groups);
  while (!copy.isComplete) {
    copy.submit(copy.currentDrill.text);
  }
  await c.recordReceiveSession(copy);
  await c.upsertMaterial(
    MaterialImport.create(
      id: 'backup_words',
      title: 'Saved words',
      kind: MaterialKind.wordList,
      text: 'CQ\nDE\nTU',
      analysis: MaterialImport.analyze('CQ\nDE\nTU', MaterialKind.wordList),
      now: c.now(),
    ),
  );
  await c.recordTelegraphRecall(TelegraphCodebook.values.first, [
    (
      TelegraphCurriculum.introductoryFor(TelegraphCodebook.values.first).first,
      true,
      false,
    ),
  ]);

  final send = c.startGuidedSendSession();
  var elapsed = Duration.zero;
  for (final element in MorseEncoder.encode(send.target, send.nominalTiming)) {
    if (element.on) {
      send.keyDown(elapsed);
      send.keyUp(elapsed + element.duration);
    }
    elapsed += element.duration;
  }
  final detail = await c.saveSendDetail(send, send.finish());
  await c.setSendDetailFavorite(detail, true);
  await c.recordSendSession(send, detailRef: detail);
  send.dispose();

  const station = QsoStation(callsign: 'K1ABC', name: 'AL', qth: 'CA');
  await c.saveQsoStation(station);
  final qso = QsoSession.start(
    scenario: QsoScenario.shortExchange,
    seed: 703,
    local: station,
    characterWpm: 20,
    effectiveWpm: 13,
  );
  await c.saveQsoDraft(qso, pendingText: 'K1ABC', pendingId: 'draft-reply');
  // A finished QSO parked before its credit was saved.
  await c.writeDoc('${QsoPractice.finishedPrefix}shortexchange_704', {
    'session': qso.toJson(),
    'activeMs': 1000,
    'completedAt': c.now().toIso8601String(),
  });

  final media = File(p.join(profileDir, 'media', 'recordings', 'kept.wav'));
  await media.parent.create(recursive: true);
  await media.writeAsBytes([82, 73, 70, 70]);
  await c.upsertAudioMaterial(
    AudioMaterial(
      id: 'backup_audio',
      title: 'Saved selection',
      file: 'media/recordings/kept.wav',
      originalName: 'input.wav',
      start: Duration.zero,
      end: const Duration(seconds: 1),
      sampleRate: 8000,
      channels: 1,
      createdAt: c.now(),
      note: 'CQ',
    ),
  );
  await c.flush();
  return detail;
}
