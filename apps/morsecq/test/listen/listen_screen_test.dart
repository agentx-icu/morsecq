import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_dsp/testing.dart';
import 'package:morsecq/ui/listen/listen_screen.dart';
import 'package:morsecq/ui/listen/listen_strings.dart';

import 'fake_pcm_source.dart';

Future<void> _pump(WidgetTester tester, FakePcmSource source) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: ListenScreen(source: source)));
  await tester.pumpAndSettle();
}

String _decodedText(WidgetTester tester) =>
    tester
        .widget<SelectableText>(find.byKey(ListenScreen.decodedTextKey))
        .data!
        .trim();

void _pushText(FakePcmSource source, String text, {double wpm = 20}) {
  final pcm = SyntheticMorse(snrDb: 20).renderText(text, wpm: wpm);
  for (final chunk in SyntheticMorse.toByteChunks(pcm, 960)) {
    source.push(chunk);
  }
}

void main() {
  testWidgets('decodes synthetic PCM from the source into the text panel', (
    tester,
  ) async {
    final source = FakePcmSource();
    await _pump(tester, source);
    expect(find.text(ListenStrings.start), findsOneWidget);
    expect(find.text(ListenStrings.idleHint), findsOneWidget);

    await tester.tap(find.text(ListenStrings.start));
    await tester.pumpAndSettle();
    expect(source.isStreaming, isTrue);
    expect(source.lastSampleRate, 48000);
    expect(source.lastChannels, 1);
    expect(find.text(ListenStrings.stop), findsOneWidget);
    expect(find.text(ListenStrings.emptyHint), findsOneWidget);

    _pushText(source, 'SOS');
    await tester.pump();
    expect(_decodedText(tester), 'SOS');
    expect(find.text(ListenStrings.emptyHint), findsNothing);
    expect(find.text(ListenStrings.toneLocked), findsOneWidget);
    // Interpolated tune sits within a couple of Hz of 700 on a noisy tone
    // and the speed estimate carries ~1 ms of gate edge bias, so allow a
    // small band rather than the exact label.
    expect(find.textContaining(RegExp(r'^(69[5-9]|70[0-5]) Hz$')), findsOneWidget);
    expect(find.textContaining(RegExp(r'^(19|20|21) WPM$')), findsOneWidget);

    await tester.tap(find.text(ListenStrings.stop));
    await tester.pumpAndSettle();
    expect(source.isStreaming, isFalse);
    expect(source.stopCalls, 1);
    expect(find.text(ListenStrings.start), findsOneWidget);
    // Text survives stopping.
    expect(_decodedText(tester), 'SOS');
  });

  testWidgets('shows the permission-denied state and lets the user retry', (
    tester,
  ) async {
    final source = FakePcmSource(permissionGranted: false);
    await _pump(tester, source);
    await tester.tap(find.text(ListenStrings.start));
    await tester.pumpAndSettle();
    expect(find.text(ListenStrings.permissionDenied), findsOneWidget);
    expect(source.startCalls, 0);
    expect(find.text(ListenStrings.start), findsOneWidget);

    source.permissionGranted = true;
    await tester.tap(find.text(ListenStrings.permissionRetry));
    await tester.pumpAndSettle();
    expect(find.text(ListenStrings.permissionDenied), findsNothing);
    expect(source.isStreaming, isTrue);
  });

  testWidgets('reports a missing microphone without crashing', (tester) async {
    final source = FakePcmSource(startError: StateError('No input device'));
    await _pump(tester, source);
    await tester.tap(find.text(ListenStrings.start));
    await tester.pumpAndSettle();
    expect(find.text(ListenStrings.noInput), findsOneWidget);
    expect(source.isStreaming, isFalse);
    expect(find.text(ListenStrings.start), findsOneWidget);
  });

  testWidgets('clear empties the text and copy puts it on the clipboard', (
    tester,
  ) async {
    final source = FakePcmSource();
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await _pump(tester, source);
    await tester.tap(find.text(ListenStrings.start));
    await tester.pumpAndSettle();
    _pushText(source, 'CQ');
    await tester.pump();
    expect(_decodedText(tester), 'CQ');

    await tester.tap(find.byTooltip(ListenStrings.copy));
    await tester.pumpAndSettle();
    final clipboard = calls.where((c) => c.method == 'Clipboard.setData');
    expect(clipboard, hasLength(1));
    expect(
      (clipboard.single.arguments as Map<Object?, Object?>)['text'],
      startsWith('CQ'),
    );
    expect(find.text(ListenStrings.copied), findsOneWidget);

    await tester.tap(find.byTooltip(ListenStrings.clear));
    await tester.pump();
    expect(_decodedText(tester), isEmpty);
  });

  testWidgets('stops capturing when the app goes to the background', (
    tester,
  ) async {
    final source = FakePcmSource();
    await _pump(tester, source);
    await tester.tap(find.text(ListenStrings.start));
    await tester.pumpAndSettle();
    expect(source.isStreaming, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(source.isStreaming, isFalse);
    expect(source.stopCalls, 1);

    // Frames are not scheduled while paused; check the UI once visible again.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text(ListenStrings.stoppedInBackground), findsOneWidget);
    expect(find.text(ListenStrings.start), findsOneWidget);
    // Never resumes the microphone on its own.
    expect(source.isStreaming, isFalse);
  });

  testWidgets('dragging the tuning slider switches to manual', (tester) async {
    final source = FakePcmSource();
    await _pump(tester, source);
    expect(find.text(ListenStrings.toneSearching), findsOneWidget);
    final slider = find.byType(Slider).first;
    final rect = tester.getRect(slider);
    await tester.tapAt(Offset(rect.left + rect.width * 0.9, rect.center.dy));
    await tester.pumpAndSettle();
    expect(find.text(ListenStrings.toneManual), findsOneWidget);
    expect(find.text(ListenStrings.retune), findsOneWidget);

    await tester.tap(find.text(ListenStrings.retune));
    await tester.pumpAndSettle();
    expect(find.text(ListenStrings.toneSearching), findsOneWidget);
  });

  testWidgets('disposing the screen stops and releases the source', (
    tester,
  ) async {
    final source = FakePcmSource();
    await _pump(tester, source);
    await tester.tap(find.text(ListenStrings.start));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(source.isStreaming, isFalse);
    // The screen did not create the source, so it must not dispose it.
    expect(source.disposed, isFalse);
  });
}
