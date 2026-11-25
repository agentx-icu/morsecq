import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';

void main() {
  test('stop cancels a clip during the previous clip cleanup', () async {
    final engine = _ClipEngine();
    final player = SoloudClipPlayer.withEngine(engine);
    addTearDown(player.dispose);
    await player.play(
      Uint8List.fromList([1]),
      length: Duration.zero,
      loop: true,
    );
    engine.release = Completer<void>();

    final replacing = player.play(
      Uint8List.fromList([2]),
      length: Duration.zero,
      loop: true,
    );
    await engine.releasing.future;
    final stopping = player.stop();
    engine.release!.complete();
    await Future.wait([replacing, stopping]);

    expect(engine.played, [1]);
    expect(player.isPlaying, isFalse);
  });

  test(
    'a replacement waits for a cancelled native load to be released',
    () async {
      final engine = _ClipEngine()
        ..load = Completer<void>()
        ..release = Completer<void>();
      final player = SoloudClipPlayer.withEngine(engine);
      addTearDown(player.dispose);
      final first = player.play(
        Uint8List.fromList([1]),
        length: Duration.zero,
        loop: true,
      );
      await engine.loading.future;
      final second = player.play(
        Uint8List.fromList([2]),
        length: Duration.zero,
        loop: true,
      );
      engine.load!.complete();
      await engine.releasing.future;
      await Future<void>.delayed(Duration.zero);
      final duringCleanup = List<int>.of(engine.played);
      engine.release!.complete();
      await Future.wait([first, second]);

      expect(duringCleanup, isEmpty);
      expect(engine.played, [2]);
      expect(engine.events, ['load 1', 'dispose 1', 'load 2', 'play 2']);
    },
  );
}

final class _ClipEngine implements SoLoud {
  final played = <int>[];
  final events = <String>[];
  final releasing = Completer<void>();
  final loading = Completer<void>();
  Completer<void>? release;
  Completer<void>? load;
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> init({
    PlaybackDevice? device,
    bool automaticCleanup = false,
    int sampleRate = 44100,
    int bufferSize = 2048,
    Channels channels = Channels.stereo,
    bool lowLatency = true,
    AndroidAAudioAttributes androidAAudioAttributes =
        AndroidAAudioAttributes.mediaMusic,
  }) async {
    _initialized = true;
  }

  @override
  void deinit() => _initialized = false;

  @override
  Future<AudioSource> loadMem(
    String path,
    Uint8List buffer, {
    LoadMode mode = LoadMode.memory,
    bool autoDispose = false,
  }) async {
    final id = buffer.single;
    events.add('load $id');
    if (!loading.isCompleted) loading.complete();
    await load?.future;
    // The fake needs a synthetic native identifier to exercise the wrapper.
    // ignore: invalid_use_of_internal_member
    return AudioSource(SoundHash(id));
  }

  @override
  SoundHandle play(
    AudioSource sound, {
    int busId = 0,
    double volume = 1,
    double pan = 0,
    bool paused = false,
    bool looping = false,
    Duration loopingStartAt = Duration.zero,
    Duration? loopingEndAt,
  }) {
    final id = sound.soundHash.hash;
    played.add(id);
    events.add('play $id');
    return SoundHandle(id);
  }

  @override
  bool getIsValidVoiceHandle(SoundHandle handle) => true;

  @override
  Future<void> stop(SoundHandle handle) async {}

  @override
  Future<void> disposeSource(AudioSource source) async {
    events.add('dispose ${source.soundHash.hash}');
    if (!releasing.isCompleted) releasing.complete();
    await release?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
