import 'package:flutter_test/flutter_test.dart';
import 'package:morse_dsp/testing.dart';
import 'package:morsecq/ui/listen/listen_controller.dart';
import 'package:morsecq/ui/listen/listen_settings.dart';

import 'fake_pcm_source.dart';

void _pushText(FakePcmSource source, String text, {double wpm = 20}) {
  final pcm = SyntheticMorse(snrDb: 20).renderText(text, wpm: wpm);
  for (final chunk in SyntheticMorse.toByteChunks(pcm, 960)) {
    source.push(chunk);
  }
}

void main() {
  test('start/stop lifecycle and decoded text', () async {
    final source = FakePcmSource();
    final controller = ListenController(source: source);
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);

    expect(controller.status, ListenStatus.idle);
    await controller.start();
    expect(controller.status, ListenStatus.listening);
    expect(source.isStreaming, isTrue);

    _pushText(source, 'SOS');
    expect(controller.text.trim(), 'SOS');
    expect(controller.wpm, closeTo(20, 3));
    expect(controller.isToneLocked, isTrue);
    expect(controller.frequencyHz, closeTo(700, 15));
    expect(controller.meter.value.hasSignal, isTrue);
    expect(notifications, greaterThan(3));

    await controller.stop();
    expect(controller.status, ListenStatus.idle);
    expect(source.isStreaming, isFalse);
    expect(controller.text.trim(), 'SOS');
  });

  test('permission denied does not start the stream', () async {
    final source = FakePcmSource(permissionGranted: false);
    final controller = ListenController(source: source);
    addTearDown(controller.dispose);
    await controller.start();
    expect(controller.status, ListenStatus.permissionDenied);
    expect(source.startCalls, 0);
  });

  test('start failure surfaces the platform message', () async {
    final source = FakePcmSource(startError: StateError('No input device'));
    final controller = ListenController(source: source);
    addTearDown(controller.dispose);
    await controller.start();
    expect(controller.status, ListenStatus.failed);
    expect(controller.errorMessage, contains('No input device'));
  });

  test('stream ending on its own returns to idle', () async {
    final source = FakePcmSource();
    final controller = ListenController(source: source);
    addTearDown(controller.dispose);
    await controller.start();
    await source.endStream();
    expect(controller.status, ListenStatus.idle);
  });

  test('changing block size keeps the text decoded so far', () async {
    final source = FakePcmSource();
    final controller = ListenController(source: source);
    addTearDown(controller.dispose);
    await controller.start();
    _pushText(source, 'SOS');
    controller.updateSettings(controller.settings.copyWith(blockSize: 128));
    expect(controller.text.trim(), 'SOS');
    _pushText(source, 'CQ');
    expect(controller.text.trim(), 'SOS CQ');
    expect(controller.settings.blockSize, 128);
  });

  test('manual frequency turns auto-tune off and back on', () async {
    final source = FakePcmSource();
    final controller = ListenController(source: source);
    addTearDown(controller.dispose);
    controller.setManualFrequency(650);
    expect(controller.settings.autoTune, isFalse);
    expect(controller.settings.manualHz, 650);
    expect(controller.frequencyHz, 650);
    controller.setAutoTune(true);
    expect(controller.settings.autoTune, isTrue);
  });

  test('clear empties text and forgets the background note', () async {
    final source = FakePcmSource();
    final controller = ListenController(source: source);
    addTearDown(controller.dispose);
    await controller.start();
    _pushText(source, 'E');
    await controller.stop(fromBackground: true);
    expect(controller.stoppedInBackground, isTrue);
    controller.clear();
    expect(controller.text, isEmpty);
    expect(controller.stoppedInBackground, isFalse);
  });

  test('owned source is disposed with the controller', () async {
    final source = FakePcmSource();
    final controller = ListenController(source: source, ownsSource: true);
    await controller.start();
    controller.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(source.isStreaming, isFalse);
    expect(source.disposed, isTrue);
  });

  test('settings value semantics', () {
    const a = ListenSettings();
    expect(a.copyWith(), a);
    expect(a.copyWith(minElementMs: 20), isNot(a));
    expect(a.blockMs(48000), closeTo(5.33, 0.01));
  });
}
