import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq/ui/reference/morse_keypad.dart';
import 'package:morsecq/ui/reference/morse_pattern_text.dart';
import 'package:morsecq/ui/reference/morse_to_text_view.dart';
import 'package:morsecq/ui/reference/reference_strings.dart';
import 'package:morsecq/ui/reference/tap_to_key_view.dart';
import 'package:morsecq/ui/reference/text_to_morse_view.dart';
import 'package:morsecq/ui/reference/translator_screen.dart';

import 'reference_test_support.dart';

const Duration _dit15 = Duration(milliseconds: 80);

/// Between the decoder's char-gap (2 dit = 160 ms) and word-gap (5 dit =
/// 400 ms) thresholds at its 80 ms initial dit.
const Duration _charGapSilence = Duration(milliseconds: 250);

Future<FakeReferencePlayer> _pump(
  WidgetTester tester, {
  Size size = kPhone,
  TranslatorMode mode = TranslatorMode.textToMorse,
}) async {
  setSurfaceSize(tester, size);
  final fake = FakeReferencePlayer();
  await pumpScreen(
    tester,
    TranslatorScreen(
      playerFactory: fake.create,
      clock: fake.clock,
      initialMode: mode,
    ),
  );
  return fake;
}

String _display(String raw) => displayMorsePattern(raw);

void main() {
  group('Text -> Morse', () {
    testWidgets('pattern follows the text live', (tester) async {
      await _pump(tester);
      await tester.enterText(find.byKey(TextToMorseView.inputKey), 'SOS');
      await tester.pump();
      expect(find.text(_display('... --- ...'), findRichText: true), findsOneWidget);
      await tester.enterText(find.byKey(TextToMorseView.inputKey), 'CQ DX');
      await tester.pump();
      expect(
        find.text(_display('-.-. --.- / -.. -..-'), findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('prosigns encode as one run and unsupported chars are reported',
        (tester) async {
      await _pump(tester);
      await tester.enterText(find.byKey(TextToMorseView.inputKey), 'K <AR> é');
      await tester.pump();
      expect(find.text(_display('-.- / .-.-.'), findRichText: true), findsOneWidget);
      expect(find.text(ReferenceStrings.skippedChars('é')), findsOneWidget);
    });

    testWidgets('play keys the injected player and highlights progress', (tester) async {
      final fake = await _pump(tester);
      await tester.enterText(find.byKey(TextToMorseView.inputKey), 'EE');
      await tester.pump();
      await tester.tap(find.byKey(TextToMorseView.playKey));
      await tester.pump();
      expect(fake.sink.isOn, isTrue);
      expect(find.text(ReferenceStrings.stop), findsOneWidget);
      // First dit is highlighted (rich text with three spans).
      final MorsePatternText shown = tester.widget(
        find.byWidgetPredicate((w) => w is MorsePatternText && w.pattern == '. .'),
      );
      expect(shown.activeMark, 0);
      // dit + char gap -> second dit.
      fake.clock.advance(_dit15 * 4);
      await tester.pump();
      final MorsePatternText later = tester.widget(
        find.byWidgetPredicate((w) => w is MorsePatternText && w.pattern == '. .'),
      );
      expect(later.activeMark, 1);
      fake.clock.advance(_dit15 * 2);
      await tester.pump();
      expect(fake.sink.isOn, isFalse);
      expect(find.text(ReferenceStrings.play), findsOneWidget);
    });

    testWidgets('play is disabled with no pattern', (tester) async {
      await _pump(tester);
      final FilledButton button = tester.widget(find.byKey(TextToMorseView.playKey));
      expect(button.onPressed, isNull);
    });

    testWidgets('copy puts the display pattern on the clipboard', (tester) async {
      await _pump(tester);
      final List<MethodCall> calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));
      await tester.enterText(find.byKey(TextToMorseView.inputKey), 'SOS');
      await tester.pump();
      await tester.tap(find.byKey(TextToMorseView.copyKey));
      await tester.pumpAndSettle();
      final MethodCall set = calls.singleWhere((c) => c.method == 'Clipboard.setData');
      expect((set.arguments as Map<Object?, Object?>)['text'], _display('... --- ...'));
      expect(find.text(ReferenceStrings.patternCopied), findsOneWidget);
    });
  });

  group('Morse -> Text', () {
    testWidgets('typed pattern decodes to text', (tester) async {
      await _pump(tester, mode: TranslatorMode.morseToText);
      await tester.enterText(find.byKey(MorseToTextView.inputKey), '.- -...');
      await tester.pump();
      expect(find.text('AB'), findsOneWidget);
      await tester.enterText(
        find.byKey(MorseToTextView.inputKey),
        '... --- ... / ... --- ...',
      );
      await tester.pump();
      expect(find.text('SOS SOS'), findsOneWidget);
    });

    testWidgets('unknown patterns render as <pattern>', (tester) async {
      await _pump(tester, mode: TranslatorMode.morseToText);
      await tester.enterText(find.byKey(MorseToTextView.inputKey), '.- ......');
      await tester.pump();
      expect(find.text('A<......>'), findsOneWidget);
      expect(find.text(ReferenceStrings.unknownPatternHelp), findsOneWidget);
    });

    testWidgets('prosign patterns render bracketed', (tester) async {
      await _pump(tester, mode: TranslatorMode.morseToText);
      await tester.enterText(find.byKey(MorseToTextView.inputKey), '...-.-');
      await tester.pump();
      expect(find.text('<SK>'), findsOneWidget);
    });

    testWidgets('keypad types dits, dahs and gaps', (tester) async {
      await _pump(tester, mode: TranslatorMode.morseToText);
      await tester.tap(find.byKey(MorseKeypad.ditKey));
      await tester.tap(find.byKey(MorseKeypad.dahKey));
      await tester.tap(find.byKey(MorseKeypad.charGapKey));
      await tester.tap(find.byKey(MorseKeypad.dahKey));
      await tester.tap(find.byKey(MorseKeypad.ditKey));
      await tester.tap(find.byKey(MorseKeypad.ditKey));
      await tester.tap(find.byKey(MorseKeypad.ditKey));
      await tester.pump();
      final TextField field = tester.widget(find.byKey(MorseToTextView.inputKey));
      expect(field.controller!.text, '.- -...');
      expect(find.text('AB'), findsOneWidget);

      await tester.tap(find.byKey(MorseKeypad.wordGapKey));
      await tester.tap(find.byKey(MorseKeypad.ditKey));
      await tester.pump();
      expect(find.text('AB E'), findsOneWidget);

      await tester.tap(find.byKey(MorseKeypad.backspaceKey));
      await tester.pump();
      expect(field.controller!.text, '.- -... / ');
      expect(find.text('AB'), findsOneWidget);

      await tester.tap(find.byKey(MorseKeypad.clearKey));
      await tester.pump();
      expect(field.controller!.text, isEmpty);
      expect(find.text(ReferenceStrings.emptyOutput), findsOneWidget);
    });

    testWidgets('keypad keys are touch-sized', (tester) async {
      await _pump(tester, mode: TranslatorMode.morseToText);
      for (final key in <Key>[MorseKeypad.ditKey, MorseKeypad.dahKey]) {
        expect(tester.getSize(find.byKey(key)).height, greaterThanOrEqualTo(48));
      }
    });
  });

  group('Key', () {
    Future<void> mark(WidgetTester tester, FakeReferencePlayer fake, Duration length) async {
      final Finder key = find.byType(StraightKeyButton);
      final gesture = await tester.startGesture(tester.getCenter(key));
      await tester.pump();
      fake.clock.advance(length);
      await tester.pump();
      await gesture.up();
      await tester.pump();
    }

    testWidgets('touch keying decodes through the real decoder', (tester) async {
      final fake = await _pump(tester, mode: TranslatorMode.key);
      expect(find.byType(StraightKeyButton), findsOneWidget);
      expect(tester.getSize(find.byType(StraightKeyButton)).shortestSide,
          greaterThanOrEqualTo(48));
      // Decoder starts at an 80 ms dit; key "A" = dit dah.
      await mark(tester, fake, const Duration(milliseconds: 80));
      fake.clock.advance(const Duration(milliseconds: 80));
      await tester.pump();
      await mark(tester, fake, const Duration(milliseconds: 240));
      expect(find.text(_display('.-'), findRichText: true), findsOneWidget);
      // Silence > 2 dit (160 ms) commits the character on a tick; stay under
      // the 5-dit word threshold (400 ms) so no trailing space is added.
      fake.clock.advance(_charGapSilence);
      await tester.pump();
      expect(find.text('A'), findsOneWidget);
      // The key shares the playback sink, so the sidetone keyed too.
      expect(fake.onCount, 2);
    });

    testWidgets('Space keys from the keyboard', (tester) async {
      final fake = await _pump(tester, mode: TranslatorMode.key);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.pump();
      fake.clock.advance(const Duration(milliseconds: 80));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();
      fake.clock.advance(_charGapSilence);
      await tester.pump();
      expect(find.text('E'), findsOneWidget);
    });

    testWidgets('clear forgets the text', (tester) async {
      final fake = await _pump(tester, mode: TranslatorMode.key);
      await mark(tester, fake, const Duration(milliseconds: 80));
      fake.clock.advance(_charGapSilence);
      await tester.pump();
      expect(find.text('E'), findsOneWidget);
      await tester.tap(find.byKey(TapToKeyView.clearKey));
      await tester.pump();
      expect(find.text('E'), findsNothing);
      expect(find.text(ReferenceStrings.emptyOutput), findsWidgets);
    });
  });

  group('layout', () {
    testWidgets('wide window uses two panes', (tester) async {
      await _pump(tester, size: kDesktop);
      final TextToMorseView view = tester.widget(find.byType(TextToMorseView));
      expect(view.twoPane, isTrue);
    });

    testWidgets('switching mode stops playback', (tester) async {
      final fake = await _pump(tester);
      await tester.enterText(find.byKey(TextToMorseView.inputKey), 'T');
      await tester.pump();
      await tester.tap(find.byKey(TextToMorseView.playKey));
      await tester.pump();
      expect(fake.sink.isOn, isTrue);
      await tester.tap(find.text(ReferenceStrings.modeMorseToText));
      await tester.pumpAndSettle();
      expect(fake.sink.isOn, isFalse);
      expect(find.byType(MorseToTextView), findsOneWidget);
    });
  });
}
