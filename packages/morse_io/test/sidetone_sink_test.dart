import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';

final class _FakeSoloudApi implements SoloudApi {
  final List<String> calls = <String>[];
  bool initialized = false;
  int nextId = 1;

  @override
  bool get isInitialized => initialized;

  @override
  Future<void> init() async {
    calls.add('init');
    initialized = true;
  }

  @override
  Future<SidetoneSource> loadSineWaveform() async {
    calls.add('loadSineWaveform');
    return SidetoneSource(nextId++);
  }

  @override
  void setWaveformFrequency(SidetoneSource source, double hz) =>
      calls.add('freq(${source.id}, $hz)');

  @override
  SidetoneVoice playLooping(SidetoneSource source, {required double volume}) {
    calls.add('playLooping(${source.id}, $volume)');
    return SidetoneVoice(100 + source.id);
  }

  @override
  void setVolume(SidetoneVoice voice, double volume) =>
      calls.add('setVolume(${voice.id}, $volume)');

  @override
  void fadeVolume(SidetoneVoice voice, double to, Duration over) =>
      calls.add('fade(${voice.id}, $to, ${over.inMilliseconds})');

  @override
  Future<void> stop(SidetoneVoice voice) async => calls.add('stop(${voice.id})');

  @override
  Future<void> disposeSource(SidetoneSource source) async =>
      calls.add('disposeSource(${source.id})');

  @override
  void deinit() {
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
