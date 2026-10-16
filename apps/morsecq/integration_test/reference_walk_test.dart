// The Reference destination end to end on the device: every handbook
// section, search, real sidetone playback, the three translator tools
// (typed text, the on-screen keypad and a touch-keyed straight key), the
// five radio tools, Listen and the shared playback settings, which must
// survive a relaunch. Expected values come from the same pure-Dart
// libraries the app uses, never from hard-coded English.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morsecq/di/app_preferences.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/listen/listen_screen.dart';
import 'package:morsecq/ui/reference/morse_keypad.dart';
import 'package:morsecq/ui/reference/morse_pattern_text.dart';
import 'package:morsecq/ui/reference/morse_to_text_view.dart';
import 'package:morsecq/ui/reference/reference_catalog.dart';
import 'package:morsecq/ui/reference/reference_screen.dart';
import 'package:morsecq/ui/reference/reference_section_view.dart';
import 'package:morsecq/ui/reference/tap_to_key_view.dart';
import 'package:morsecq/ui/reference/text_to_morse_view.dart';
import 'package:morsecq/ui/reference/translator_screen.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq/ui/tools/radio_tools_screen.dart';
import 'package:morsecq/ui/tools/rst_tool.dart';
import 'package:provider/provider.dart';
import 'package:radio_tools/radio_tools.dart';

import 'support/app_walk.dart';
import 'support/scene_walk.dart';
import 'support/shot_harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reference handbook, translator, radio tools and listen', (
    tester,
  ) async {
    final app = await IsolatedApp.create(binding, 'morsecq_reference_');
    await app.launch(tester, key: 'reference');
    final s = appStrings(tester);
    await selectTab(tester, ShellTab.reference);
    expect(find.byType(ReferenceScreen), findsOneWidget);

    await _walkSections(tester, s);
    await _search(tester, s);
    await _translator(tester, s);
    await _radioTools(tester, s);
    await _listen(tester, s);
    await _playbackSettings(tester, s);

    // The playback settings are app preferences: they outlive the process.
    await app.quit(tester);
    await app.launch(tester, key: 'reference-again');
    final prefs = tester.element(find.byType(AppShell)).read<AppPreferences>();
    expect(prefs.reference.wpm, 40);
    expect(prefs.reference.farnsworthEnabled, isTrue);
    expect(tester.takeException(), isNull);
    await app.quit(tester);
  });
}

Finder _sectionView(ReferenceSection section) => find.byWidgetPredicate(
  (w) => w is ReferenceSectionView && w.section == section,
);

/// Opens each section from the tab bar (phone) or the section rail
/// (desktop), checks its first entry is listed, plays one prosign through
/// the real sidetone and opens a letter's mnemonic.
Future<void> _walkSections(WidgetTester tester, S s) async {
  for (final section in ReferenceSection.values) {
    await tapFirstHittable(
      tester,
      find.text(section.label(s)),
      'section ${section.name}',
    );
    await settle(tester, extra: const Duration(milliseconds: 200));
    final first = ReferenceCatalog.entriesFor(section).first;
    await waitForWidget(
      tester,
      find.descendant(
        of: _sectionView(section),
        matching: find.text(first.label),
      ),
      '${section.name} lists ${first.label}',
    );
  }

  // Real playback: the row turns into a Stop button while it sounds and
  // back into Play when the timeline completes.
  await tapFirstHittable(
    tester,
    find.text(ReferenceSection.prosigns.label(s)),
    'prosigns',
  );
  final play = find.descendant(
    of: _sectionView(ReferenceSection.prosigns),
    matching: find.byTooltip(s.referencePlay),
  );
  await waitForWidget(tester, play, 'prosign play buttons');
  await tester.tap(play.first);
  await tester.pump(const Duration(milliseconds: 100));
  await waitForWidget(
    tester,
    find.byTooltip(s.referenceStop),
    'prosign is sounding',
  );
  await waitFor(
    tester,
    () => find.byTooltip(s.referenceStop).evaluate().isEmpty,
    'prosign playback completes',
  );

  // Long-press a letter for its mnemonic.
  await tapFirstHittable(
    tester,
    find.text(ReferenceSection.alphabet.label(s)),
    'alphabet',
  );
  final letter = find.descendant(
    of: _sectionView(ReferenceSection.alphabet),
    matching: find.text(
      ReferenceCatalog.entriesFor(ReferenceSection.alphabet).first.label,
    ),
  );
  await waitForWidget(tester, letter, 'first letter card');
  await tester.longPress(letter.first);
  await settle(tester);
  expect(find.text(s.referenceMnemonicTitle), findsOneWidget);
  await tapText(tester, s.referenceClose);
  expect(find.text(s.referenceMnemonicTitle), findsNothing);
}

Future<void> _search(WidgetTester tester, S s) async {
  final field = find.byKey(ReferenceScreen.searchFieldKey);
  // On a phone the field scrolls away with the tabs: pull the page back
  // down to it, as a user would.
  for (var i = 0; i < 10 && field.hitTestable().evaluate().isEmpty; i++) {
    await tester.drag(
      find.byType(TabBarView),
      const Offset(0, 400),
      warnIfMissed: false,
    );
    await settle(tester);
  }
  expect(field.hitTestable(), findsOneWidget, reason: 'search field shown');
  await typeInto(tester, field, 'QRL');
  await settle(tester);
  expect(find.byType(ReferenceSearchResults), findsOneWidget);
  expect(
    find.descendant(
      of: find.byType(ReferenceSearchResults),
      matching: find.text('QRL'),
    ),
    findsWidgets,
  );
  await typeInto(tester, field, 'QQQQZZZZ');
  await settle(tester);
  expect(find.text(s.referenceNoResults), findsOneWidget);
  await dismissKeyboard(tester);
  await tapTooltip(tester, s.referenceClearSearch);
  expect(find.byType(ReferenceSearchResults), findsNothing);
  expect(
    tester.widget<TextField>(field).controller!.text,
    isEmpty,
    reason: 'clearing empties the field',
  );
}

Future<void> _translator(WidgetTester tester, S s) async {
  await tapTooltip(tester, s.referenceTranslatorTitle);
  expect(find.byType(TranslatorScreen), findsOneWidget);

  // Text -> Morse, with playback and copying.
  const plain = 'SOS 73';
  await typeInto(tester, find.byKey(TextToMorseView.inputKey), plain);
  await settle(tester);
  final pattern = MorseEncoder.toPattern(plain);
  expect(
    find.byWidgetPredicate(
      (w) => w is MorsePatternText && w.pattern == pattern,
    ),
    findsOneWidget,
  );
  await dismissKeyboard(tester);
  await tapHittable(tester, find.byKey(TextToMorseView.playKey), 'play');
  await waitForWidget(
    tester,
    find.descendant(
      of: find.byKey(TextToMorseView.playKey),
      matching: find.text(s.referenceStop),
    ),
    'translator is sounding',
  );
  await waitFor(
    tester,
    () => find
        .descendant(
          of: find.byKey(TextToMorseView.playKey),
          matching: find.text(s.referencePlay),
        )
        .evaluate()
        .isNotEmpty,
    'translator playback completes',
    timeout: const Duration(seconds: 30),
  );
  await tapHittable(tester, find.byKey(TextToMorseView.copyKey), 'copy');
  expect(find.text(s.referencePatternCopied), findsOneWidget);
  // The confirmation covers the bottom of a phone screen until it times out.
  await waitFor(
    tester,
    () => find.byType(SnackBar).evaluate().isEmpty,
    'copy confirmation dismissed',
  );

  // Chinese text is keyed as four-digit telegraph codes, per codebook.
  const chinese = '中文';
  await typeInto(tester, find.byKey(TextToMorseView.inputKey), chinese);
  await settle(tester);
  await dismissKeyboard(tester);
  String codes(TelegraphCodebook book) => ChineseTelegraphCode.encode(
    chinese,
    codebook: book,
  ).where((u) => u.hasCode).map((u) => u.code!).join(' ');
  expect(
    shownText(tester, find.byKey(TextToMorseView.telegraphKey)),
    s.referenceTelegraphCodes(codes(TelegraphCodebook.mainland)),
  );
  await tapHittable(
    tester,
    find.text(s.referenceTelegraphTaiwan),
    'Taiwan codebook',
  );
  expect(
    shownText(tester, find.byKey(TextToMorseView.telegraphKey)),
    s.referenceTelegraphCodes(codes(TelegraphCodebook.taiwan)),
  );

  // Morse -> Text with the on-screen keypad: ... --- ...
  await tapHittable(
    tester,
    find.text(s.referenceModeMorseToText),
    'Morse to text mode',
  );
  Future<void> key(Key k, int times) async {
    for (var i = 0; i < times; i++) {
      await tapHittable(tester, find.byKey(k), '$k');
    }
  }

  await key(MorseKeypad.ditKey, 3);
  await key(MorseKeypad.charGapKey, 1);
  await key(MorseKeypad.dahKey, 3);
  await key(MorseKeypad.charGapKey, 1);
  await key(MorseKeypad.ditKey, 3);
  expect(shownText(tester, find.byKey(MorseToTextView.outputKey)), 'SOS');
  await key(MorseKeypad.backspaceKey, 1); // ... --- ..
  expect(shownText(tester, find.byKey(MorseToTextView.outputKey)), 'SOI');
  await key(MorseKeypad.clearKey, 1);
  expect(
    shownText(tester, find.byKey(MorseToTextView.outputKey)),
    s.referenceEmptyOutput,
  );

  // Tap to key: a touch-keyed K (-.-) through the real decoder clock.
  await tapHittable(tester, find.text(s.referenceModeKey), 'key mode');
  await _keyK(tester);
  await waitFor(
    tester,
    () => shownText(tester, find.byKey(TapToKeyView.decodedKey)).trim() == 'K',
    'decoder resolves the keyed K',
  );
  await tapHittable(tester, find.byKey(TapToKeyView.clearKey), 'clear key');
  expect(
    shownText(tester, find.byKey(TapToKeyView.decodedKey)),
    s.referenceEmptyOutput,
  );
  await goBack(tester);
  expect(find.byType(TranslatorScreen), findsNothing);
}

/// Dah (300 ms), dit (70 ms), dah, 70 ms apart: far from the decoder's
/// 2-dit thresholds whatever its initial estimate. Frames render only on
/// explicit pumps meanwhile so a slow frame cannot stretch a gap.
Future<void> _keyK(WidgetTester tester) async {
  final keyButton = find.byType(StraightKeyButton);
  expect(keyButton, findsOneWidget);
  await tester.ensureVisible(keyButton);
  await tester.pump();
  final binding = tester.binding;
  final policy = binding is LiveTestWidgetsFlutterBinding
      ? binding.framePolicy
      : null;
  if (binding is LiveTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  }
  try {
    for (final ms in [300, 70, 300]) {
      final gesture = await tester.startGesture(tester.getCenter(keyButton));
      await Future<void>.delayed(Duration(milliseconds: ms));
      await gesture.up();
      await Future<void>.delayed(const Duration(milliseconds: 70));
    }
  } finally {
    if (binding is LiveTestWidgetsFlutterBinding && policy != null) {
      binding.framePolicy = policy;
    }
  }
  await settle(tester, extra: const Duration(milliseconds: 600));
}

Future<void> _radioTools(WidgetTester tester, S s) async {
  await tapHittable(
    tester,
    find.byKey(ReferenceScreen.radioToolsKey),
    'radio tools',
  );
  expect(find.byType(RadioToolsScreen), findsOneWidget);
  for (final tool in RadioTool.values) {
    await tapHittable(tester, find.byKey(tool.tileKey), 'tool ${tool.name}');
    expect(find.text(tool.title(s)), findsWidgets);
    switch (tool) {
      case RadioTool.grid:
        await _gridTool(tester, s);
      case RadioTool.bands:
        await _bandTool(tester, s);
      case RadioTool.speed:
        await _speedTool(tester, s);
      case RadioTool.rst:
        await _rstTool(tester, s);
      case RadioTool.clock:
        await _clockTool(tester);
    }
    await dismissKeyboard(tester);
    await goBack(tester);
    expect(find.byType(RadioToolsScreen), findsOneWidget);
  }
  await goBack(tester);
}

Future<void> _enter(WidgetTester tester, Key key, String text) async {
  await tester.ensureVisible(find.byKey(key));
  await typeInto(tester, find.byKey(key), text);
  await settle(tester);
}

Finder _valueText(String value) => find.byWidgetPredicate(
  (w) => w is SelectableText && w.data == value,
  description: 'value "$value"',
);

Future<void> _gridTool(WidgetTester tester, S s) async {
  await _enter(tester, const Key('grid-latitude'), '48.146');
  await _enter(tester, const Key('grid-longitude'), '11.608');
  final locator = Maidenhead.fromPoint(
    const GeoPoint(48.146, 11.608),
    length: 8,
  );
  expect(_valueText(locator), findsOneWidget, reason: 'locator $locator');
  await _enter(tester, const Key('grid-latitude'), '95');
  expect(find.text(s.toolsGridInvalidCoordinates), findsOneWidget);

  await _enter(tester, const Key('grid-mine'), 'JN58td');
  await _enter(tester, const Key('grid-theirs'), 'ZZ99');
  expect(find.text(s.toolsGridInvalidLocator), findsOneWidget);
  await _enter(tester, const Key('grid-theirs'), 'FN31pr');
  final a = Maidenhead.toPoint('JN58td');
  final b = Maidenhead.toPoint('FN31pr');
  final km = GreatCircle.distanceKm(a, b);
  final distance =
      '${km.round()} km · ${(km / GreatCircle.kmPerMile).round()} mi';
  await tester.ensureVisible(_valueText(distance));
  expect(_valueText(distance), findsOneWidget, reason: 'distance $distance');
  expect(
    _valueText('${GreatCircle.initialBearing(a, b).round() % 360}°'),
    findsOneWidget,
  );
}

Future<void> _bandTool(WidgetTester tester, S s) async {
  const key = Key('band-frequency');
  await _enter(tester, key, '7.030');
  final forty = AmateurBands.bandFor(7.030, IaruRegion.region1)!;
  expect(find.text(s.toolsBandsInBand(forty.name)), findsOneWidget);
  // 7.250 MHz is outside 40 m in region 1 and inside it in region 2.
  await _enter(tester, key, '7.250');
  expect(AmateurBands.bandFor(7.250, IaruRegion.region1), isNull);
  expect(find.text(s.toolsBandsOutOfBand), findsOneWidget);
  await dismissKeyboard(tester);
  await tapHittable(tester, find.text(s.toolsBandsRegionLabel(2)), 'region 2');
  final region2 = AmateurBands.bandFor(7.250, IaruRegion.region2)!;
  expect(find.text(s.toolsBandsInBand(region2.name)), findsOneWidget);
  await _enter(tester, key, 'x');
  expect(find.text(s.toolsBandsInvalidFrequency), findsOneWidget);
}

Future<void> _speedTool(WidgetTester tester, S s) async {
  String ms(double v) => '${v.round()} ms';
  expect(_valueText(ms(CwSpeed(wpm: 20).ditMs)), findsOneWidget);
  final slider = find.byType(Slider).first;
  await tester.drag(slider, const Offset(2000, 0));
  await settle(tester);
  expect(_valueText('60 WPM'), findsOneWidget);
  expect(_valueText(ms(CwSpeed(wpm: 60).ditMs)), findsOneWidget);
  await tapHittable(
    tester,
    find.text(s.toolsSpeedFarnsworth),
    'Farnsworth switch',
  );
  expect(find.byType(Slider), findsNWidgets(2));
  expect(
    _valueText(ms(CwSpeed(wpm: 60, farnsworthWpm: 10).wordGapMs)),
    findsOneWidget,
    reason: 'overall speed starts at half the character speed',
  );
}

Future<void> _rstTool(WidgetTester tester, S s) async {
  expect(_valueText('599'), findsOneWidget);
  await tapFirstHittable(
    tester,
    find.widgetWithText(ChoiceChip, '3'),
    'readability 3',
  );
  expect(_valueText('399'), findsOneWidget);
  expect(find.text(rstReadability(s, 3)), findsOneWidget);
  final seven = find.widgetWithText(ChoiceChip, '7');
  await tester.ensureVisible(seven.first);
  await tester.pump();
  await tester.tap(seven.first);
  await settle(tester);
  expect(_valueText('379'), findsOneWidget);
}

Future<void> _clockTool(WidgetTester tester) async {
  final utc = RegExp(r'^\d\d:\d\d:\d\dZ$');
  final finder = find.byWidgetPredicate(
    (w) => w is SelectableText && utc.hasMatch(w.data ?? ''),
  );
  expect(finder, findsOneWidget);
  final before = shownText(tester, finder);
  await waitFor(
    tester,
    () => shownText(tester, finder) != before,
    'the UTC clock ticks',
    timeout: const Duration(seconds: 5),
  );
}

Future<void> _listen(WidgetTester tester, S s) async {
  await tapTooltip(tester, s.listenTitle);
  expect(find.byType(ListenScreen), findsOneWidget);
  // Not started: the microphone (and its permission prompt) stays closed.
  expect(find.text(s.listenStart), findsWidgets);
  await tapTooltip(tester, s.listenSettings);
  expect(find.byType(BottomSheet), findsOneWidget);
  await tester.tapAt(const Offset(8, 8)); // dismiss on the barrier
  await settle(tester);
  expect(find.byType(BottomSheet), findsNothing);
  await goBack(tester);
  expect(find.byType(ListenScreen), findsNothing);
}

/// The handbook's playback sheet: maximum speed and Farnsworth spacing.
Future<void> _playbackSettings(WidgetTester tester, S s) async {
  await tapTooltip(tester, s.referencePlaybackSettings);
  final sheet = find.byType(BottomSheet);
  expect(sheet, findsOneWidget);
  await tester.drag(
    find.descendant(of: sheet, matching: find.byType(Slider)).first,
    const Offset(2000, 0),
  );
  await settle(tester);
  expect(find.text(s.referenceWpmValue('40')), findsWidgets);
  await tapHittable(
    tester,
    find.descendant(of: sheet, matching: find.text(s.referenceFarnsworth)),
    'Farnsworth',
  );
  expect(
    find.descendant(of: sheet, matching: find.text(s.referenceEffectiveSpeed)),
    findsOneWidget,
  );
  await tester.tapAt(const Offset(8, 8));
  await settle(tester);
  expect(find.byType(BottomSheet), findsNothing);
}
