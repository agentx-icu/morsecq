import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';

final class _FakeSoloudApi implements SoloudApi {
  final List<String> calls = <String>[];
  bool initialized = false;
  int nextId = 1;
  Completer<void>? initGate;
  Completer<void>? loadGate;
  Object? loadError;
  Object? playError;
  Object? stopError;
  Completer<void>? disposeSourceGate;
  Object? disposeSourceError;

  @override
  bool get isInitialized => initialized;

  @override
  Future<void> init() async {
    calls.add('init');
    final gate = initGate;
    if (gate != null) await gate.future;
    initialized = true;
  }

  @override
  Future<SidetoneSource> loadSineWaveform() async {
    calls.add('loadSineWaveform');
    final gate = loadGate;
    if (gate != null) await gate.future;
    final error = loadError;
    if (error != null) throw error;
    return SidetoneSource(nextId++);
  }

  @override
  void setWaveformFrequency(SidetoneSource source, double hz) =>
      calls.add('freq(${source.id}, $hz)');

  @override
  SidetoneVoice playLooping(SidetoneSource source, {required double volume}) {
    calls.add('playLooping(${source.id}, $volume)');
    final error = playError;
    if (error != null) throw error;
    return SidetoneVoice(100 + source.id);
  }

  @override
  void setVolume(SidetoneVoice voice, double volume) =>
      calls.add('setVolume(${voice.id}, $volume)');

  @override
  void fadeVolume(SidetoneVoice voice, double to, Duration over) =>
      calls.add('fade(${voice.id}, $to, ${over.inMilliseconds})');

  @override
  Future<void> stop(SidetoneVoice voice) async {
    calls.add('stop(${voice.id})');
    final error = stopError;
    if (error != null) throw error;
  }

  @override
  Future<void> disposeSource(SidetoneSource source) async {
    calls.add('disposeSource(${source.id})');
    final gate = disposeSourceGate;
    if (gate != null) await gate.future;
    final error = disposeSourceError;
    if (error != null) throw error;
  }

  @override
  Future<void> deinit() async {
    calls.add('deinit');
    initialized = false;
  }
}

void main() {
  late _FakeSoloudApi api;
  late SidetoneSink sink;

  setUp(() {
    api = _FakeSoloudApi();
    sink = SidetoneSink(api: api, frequencyHz: 600, volume: 0.5);
  });

  test('prepare initialises exactly once and starts a silent loop', () async {
    await Future.wait(<Future<void>>[sink.prepare(), sink.prepare()]);
    await sink.prepare();
    expect(sink.isPrepared, isTrue);
    expect(api.calls, <String>[
      'init',
      'loadSineWaveform',
      'freq(1, 600.0)',
      'playLooping(1, 0.0)',
    ]);
  });

  test('on / off ramp the running voice with the configured envelope',
      () async {
    await sink.prepare();
    api.calls.clear();
    sink.on();
    expect(sink.isOn, isTrue);
    sink.on(); // ignored
    sink.off();
    sink.off(); // ignored
    expect(api.calls, <String>['fade(101, 0.5, 5)', 'fade(101, 0.0, 5)']);
  });

  test('on / off before prepare are ignored (no engine access)', () {
    sink.on();
    sink.off();
    expect(api.calls, isEmpty);
    expect(sink.isOn, isFalse);
  });

  test('frequency and volume can be changed live', () async {
    await sink.prepare();
    api.calls.clear();
    sink.frequencyHz = 800;
    sink.volume = 2; // clamped
    sink.on();
    sink.volume = 0.25; // applied immediately while on
    expect(api.calls, <String>[
      'freq(1, 800.0)',
      'fade(101, 1.0, 5)',
      'setVolume(101, 0.25)',
    ]);
    expect(sink.volume, 0.25);
  });

  test('dispose stops the voice, frees the source and deinits', () async {
    await sink.prepare();
    sink.on();
    api.calls.clear();
    await sink.dispose();
    expect(api.calls, <String>['stop(101)', 'disposeSource(1)', 'deinit']);
    expect(sink.isPrepared, isFalse);
    expect(sink.isOn, isFalse);
    sink.on(); // safe after dispose
    expect(api.calls.length, 3);
  });

  test('dispose while init is pending creates no voice and deinits once',
      () async {
    api.initGate = Completer<void>();
    final prepare = sink.prepare();
    await pumpEventQueue();
    final dispose = sink.dispose();
    api.initGate!.complete();
    await Future.wait(<Future<void>>[prepare, dispose]);
    expect(api.calls, <String>['init', 'deinit']);
    expect(sink.isPrepared, isFalse);
  });

  test('dispose while the source loads frees it without starting a voice',
      () async {
    api.loadGate = Completer<void>();
    final prepare = sink.prepare();
    await pumpEventQueue();
    final dispose = sink.dispose();
    api.loadGate!.complete();
    await Future.wait(<Future<void>>[prepare, dispose]);
    expect(api.calls, <String>[
      'init',
      'loadSineWaveform',
      'disposeSource(1)',
      'deinit',
    ]);
  });

  test('dispose is single-flight and prepare after it fails', () async {
    await sink.prepare();
    api.calls.clear();
    await Future.wait(<Future<void>>[sink.dispose(), sink.dispose()]);
    await sink.dispose();
    expect(api.calls, <String>['stop(101)', 'disposeSource(1)', 'deinit']);
    await expectLater(sink.prepare(), throwsStateError);
  });

  test('a failed prepare gives the engine back and can be retried', () async {
    api.loadError = StateError('no waveform');
    await expectLater(sink.prepare(), throwsStateError);
    expect(api.calls, <String>['init', 'loadSineWaveform', 'deinit']);
    api.loadError = null;
    api.calls.clear();
    await sink.prepare();
    expect(sink.isPrepared, isTrue);
    expect(api.calls.first, 'init');
  });

  test('dispose during a failed prepare\'s cleanup waits for it', () async {
    api.playError = StateError('no voice');
    api.disposeSourceGate = Completer<void>();
    final prepare = expectLater(sink.prepare(), throwsStateError);
    await pumpEventQueue();
    expect(api.calls.last, 'disposeSource(1)', reason: 'cleanup is running');
    var disposed = false;
    final dispose = sink.dispose().then((_) => disposed = true);
    await pumpEventQueue();
    expect(disposed, isFalse);
    api.disposeSourceGate!.complete();
    await prepare;
    await dispose;
    expect(api.calls.where((c) => c.startsWith('disposeSource')), hasLength(1));
    expect(api.calls.last, 'deinit');
  });

  test('prepare during a failed prepare\'s cleanup joins it', () async {
    api.playError = StateError('no voice');
    api.disposeSourceGate = Completer<void>();
    final first = expectLater(sink.prepare(), throwsStateError);
    await pumpEventQueue();
    final second = expectLater(sink.prepare(), throwsStateError);
    api.disposeSourceGate!.complete();
    await first;
    await second;
    expect(api.calls.where((c) => c == 'loadSineWaveform'), hasLength(1));
    expect(api.calls.last, 'deinit');
    api.playError = null;
    await sink.prepare();
    expect(sink.isPrepared, isTrue);
  });

  test('a prepare whose cleanup also fails reports the first error and '
      'can be retried', () async {
    api.playError = StateError('no voice');
    api.disposeSourceError = ArgumentError('engine gone');
    await expectLater(sink.prepare(), throwsStateError);
    expect(api.calls.last, 'deinit');
    api.playError = null;
    api.disposeSourceError = null;
    await sink.prepare();
    expect(sink.isPrepared, isTrue);
  });

  test('dispose still frees the source and deinits when stop throws',
      () async {
    await sink.prepare();
    api.calls.clear();
    api.stopError = StateError('engine gone');
    await expectLater(sink.dispose(), throwsStateError);
    expect(api.calls, <String>['stop(101)', 'disposeSource(1)', 'deinit']);
  });

  test('custom ramp is honoured', () async {
    final custom = SidetoneSink(
      api: api,
      ramp: const Duration(milliseconds: 12),
    );
    await custom.prepare();
    custom.on();
    expect(api.calls.last, 'fade(101, 0.8, 12)');
  });
}
