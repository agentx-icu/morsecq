// Shared harness of the layout sweep: device profiles (window size, safe
// areas, keyboard), text scalers, fonts, and the checks every scene runs
// after each change. Scenes: layout_sweep_test.dart (screens) and
// layout_overlays_test.dart (dialogs, sheets, menus, result states).
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/training/training_settings.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';
import 'package:morsecq/ui/common/app_bar_title.dart';
import 'package:morsecq/ui/common/field_label.dart' show kMinShrunkFontSize;
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:morsecq/ui/theme.dart';

import '../../integration_test/support/seed_data.dart';
import '../learn/helpers/fake_playback.dart';
import '../learn/helpers/test_controller.dart';
import '../support/test_app.dart' show settle;

/// A real multilingual font: the test font's square glyphs make Latin text
/// ~1.8x too wide, so without one the sweep is skipped.
const kSweepFont = String.fromEnvironment('MORSECQ_MATRIX_FONT');
const _mono = String.fromEnvironment('MORSECQ_MATRIX_MONO_FONT');
const _serif = String.fromEnvironment('MORSECQ_MATRIX_SERIF_FONT');
const bool kSweepSkip = kSweepFont == '';

/// Every family the app or the platform typography asks for gets a real
/// font, so nothing silently falls back to the square test glyphs.
Future<void> loadSweepFonts() async {
  if (kSweepSkip) return;
  Future<void> load(String family, String path) async {
    final bytes = ByteData.sublistView(File(path).readAsBytesSync());
    await (FontLoader(family)..addFont(Future.value(bytes))).load();
  }

  for (final family in const [
    'Roboto',
    // Material's iOS / macOS typography.
    'CupertinoSystemText',
    'CupertinoSystemDisplay',
    '.SF UI Text',
    '.SF UI Display',
    '.AppleSystemUIFont',
  ]) {
    await load(family, kSweepFont);
  }
  await load('monospace', _mono.isEmpty ? kSweepFont : _mono);
  await load('serif', _serif.isEmpty ? kSweepFont : _serif);
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}

/// A device: logical window size, its safe-area insets and, for the
/// keyboard profile, the soft keyboard's height.
typedef SweepProfile = ({
  String name,
  Size size,
  FakeViewPadding insets,
  double keyboard,
});

const kSweepProfiles = <SweepProfile>[
  (
    name: 'iPhone SE',
    size: Size(320, 568),
    insets: FakeViewPadding(top: 20),
    keyboard: 0,
  ),
  (
    name: 'iPhone SE landscape',
    size: Size(568, 320),
    insets: FakeViewPadding.zero,
    keyboard: 0,
  ),
  (
    name: 'desktop minimum',
    size: Size(360, 640),
    insets: FakeViewPadding.zero,
    keyboard: 0,
  ),
  (
    name: 'iPhone',
    size: Size(390, 844),
    insets: FakeViewPadding(top: 47, bottom: 34),
    keyboard: 0,
  ),
  (
    name: 'iPhone keyboard',
    size: Size(390, 844),
    insets: FakeViewPadding(top: 47, bottom: 34),
    keyboard: 336,
  ),
  (
    name: 'iPhone landscape',
    size: Size(844, 390),
    insets: FakeViewPadding(left: 47, right: 47, bottom: 21),
    keyboard: 0,
  ),
  (
    name: 'Android',
    size: Size(412, 915),
    insets: FakeViewPadding(top: 24, bottom: 24),
    keyboard: 0,
  ),
  (
    name: 'iPad',
    size: Size(768, 1024),
    insets: FakeViewPadding(top: 24, bottom: 20),
    keyboard: 0,
  ),
  (
    name: 'iPad landscape',
    size: Size(1024, 768),
    insets: FakeViewPadding(top: 24, bottom: 20),
    keyboard: 0,
  ),
  (
    name: 'desktop',
    size: Size(1280, 800),
    insets: FakeViewPadding.zero,
    keyboard: 0,
  ),
  (
    name: 'desktop large',
    size: Size(1920, 1080),
    insets: FakeViewPadding.zero,
    keyboard: 0,
  ),
];

/// Linear text scales up to iOS's largest accessibility size, plus a
/// nonlinear scaler like Android 14's (small text grows more than large).
final kSweepScalers = <({String name, TextScaler scaler})>[
  for (final f in const [1.0, 1.3, 2.0, 3.1])
    (name: '$f', scaler: TextScaler.linear(f)),
  (name: 'nonlinear', scaler: const _NonlinearScaler()),
];

class _NonlinearScaler extends TextScaler {
  const _NonlinearScaler();

  @override
  double scale(double fontSize) => fontSize + math.max(8, 28 - fontSize);

  @override
  double get textScaleFactor => 2.0;

  @override
  bool operator ==(Object other) => other is _NonlinearScaler;

  @override
  int get hashCode => 0x5ca1e;
}

/// The scaler the current configuration applies; the harness's MaterialApp
/// builder installs it (see [sweepBuilder]).
TextScaler _scaler = TextScaler.noScaling;

/// MaterialApp builder for sweep hosts: applies the configuration's scaler.
Widget sweepBuilder(BuildContext context, Widget? child) => MediaQuery(
  data: MediaQuery.of(context).copyWith(textScaler: _scaler),
  child: child!,
);

typedef SceneBuilder =
    Widget Function(TestTraining t, FakeLearnPlaybackFactory p);
typedef ScenePrepare = Future<void> Function(WidgetTester tester);

/// Drives a screen into the state to sweep (a dialog open, a result shown).
typedef ScreenPrepare =
    Future<void> Function(
      WidgetTester tester,
      TestTraining t,
      FakeLearnPlaybackFactory p,
    );

/// Sweeps one screen hosted the way the app hosts routes. [shown] must
/// match in every configuration (the scene did not close or expire);
/// [refresh] re-opens a transient scene (a snackbar) before each check.
Future<Set<String>> sweepScreen(
  WidgetTester tester,
  Locale locale,
  SceneBuilder build, {
  ScreenPrepare? prepare,
  Future<void> Function(TestTraining t)? setup,
  TrainingSettings settings = kShortSettings,
  Finder Function(WidgetTester tester)? shown,
  ScreenPrepare? refresh,
  UiStyle style = UiStyle.modern,
}) async {
  final t = await TestTraining.create(
    progress: TrainerProgress(currentLesson: 8, dailyGoalChars: 30),
    settings: settings,
  );
  addTearDown(t.controller.dispose);
  await setup?.call(t);
  final playback = FakeLearnPlaybackFactory();
  return sweep(
    tester,
    () async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: locale,
          builder: sweepBuilder,
          theme: MorsecqTheme.light(style: style),
          home: build(t, playback),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await prepare?.call(tester, t, playback);
    },
    shown: shown,
    refresh: refresh == null ? null : () => refresh(tester, t, playback),
  );
}

/// Sweeps the whole app on seeded progress, after [open] navigates. The
/// app's own MaterialApp reads the platform text scale, so this host only
/// runs the linear scalers.
Future<Set<String>> sweepApp(
  WidgetTester tester,
  String localeTag, [
  ScenePrepare? open,
  Finder Function(WidgetTester tester)? shown,
]) async {
  final dir = await tester.runAsync(
    () => Directory.systemTemp.createTemp('morsecq_layout_'),
  );
  addTearDown(() => dir!.deleteSync(recursive: true));
  await tester.runAsync(
    () => seedTrainingProgress(dir!.path, anchor: seedAnchor(DateTime.now())),
  );
  return sweep(
    tester,
    () async {
      await tester.pumpWidget(
        MorsecqApp(
          learningStore: LocalLearningStore(root: () async => dir!.path),
          localeStore: InMemoryKeyValueStore({
            LocaleController.storageKey: localeTag,
          }),
        ),
      );
      await settle(tester);
      await open?.call(tester);
    },
    shown: shown,
    platformScaleOnly: true,
  );
}

/// Opens Me, then the tile with [icon].
Future<void> openFromMe(WidgetTester tester, IconData icon) async {
  await openTab(tester, kShellDestinations.length - 1);
  final tile = find.ancestor(
    of: find.byIcon(icon),
    matching: find.byType(ListTile),
  );
  await tester.ensureVisible(tile.first);
  await tester.tap(tile.first);
  await settle(tester);
}

/// Selects shell destination [index] in the rail or bottom bar.
Future<void> openTab(WidgetTester tester, int index) async {
  await tester.tap(find.byIcon(kShellDestinations[index].icon).last);
  await settle(tester);
}

String _clip(String s) => s.length > 48 ? '${s.substring(0, 48)}…' : s;

String _label(RenderParagraph node) {
  final plain = node.text.toPlainText();
  final icon = plain.runes.every((r) => r >= 0xE000 && r <= 0xF8FF);
  return icon ? 'icon' : '"${_clip(plain)}"';
}

/// On-stage elements matching [test], following the finder's on-stage
/// rules (covered opaque routes, inactive IndexedStack children and
/// Offstage subtrees are skipped).
///
/// Walked by hand: the finder's own walk asserts on lazy-list children that
/// are kept alive but not laid out. Inside lazy lists every laid-out child
/// is visited; [visibleRect] then drops what the viewport clips.
List<Element> _onstage(bool Function(Element element) test, [Element? root]) {
  final out = <Element>[];
  void visit(Element element) {
    if (test(element)) out.add(element);
    if (element is SliverMultiBoxAdaptorElement) {
      element.visitChildren((child) {
        final box = child.renderObject;
        if (box is RenderBox && box.hasSize) visit(child);
      });
    } else {
      element.debugVisitOnstageChildren(visit);
    }
  }

  visit(root ?? WidgetsBinding.instance.rootElement!);
  return out;
}

bool _isText(Element e) =>
    e.widget is RichText &&
    e.renderObject is RenderParagraph &&
    e.renderObject!.attached &&
    (e.renderObject! as RenderBox).hasSize;

/// On-stage, laid-out paragraphs.
List<RenderParagraph> _onstageText([Element? root]) => [
  for (final e in _onstage(_isText, root)) e.renderObject! as RenderParagraph,
];

/// [local] (in [box]'s coordinates) as painted on screen: clipped by every
/// ancestor's paint clip and the screen, or null when nothing of it shows
/// (clipped away, or under a fully transparent ancestor).
Rect? visibleRect(RenderBox box, Rect local, Size screen) {
  final transform = box.getTransformTo(null);
  // A viewport gives children it does not paint (scrolled away) a zero
  // transform, which maps every rect to NaN.
  if (transform.determinant() == 0) return null;
  var rect = MatrixUtils.transformRect(transform, local);
  if (!rect.isFinite) return null;
  rect = rect.intersect(Offset.zero & screen);
  RenderObject child = box;
  for (var node = box.parent; node != null; node = node.parent) {
    if (node is RenderOpacity && node.opacity == 0) return null;
    if (node is RenderAnimatedOpacity && node.opacity.value == 0) return null;
    if (node is RenderSliverOpacity && node.opacity == 0) return null;
    if (node is RenderSliverAnimatedOpacity && node.opacity.value == 0) {
      return null;
    }
    final clip = node.describeApproximatePaintClip(child);
    if (clip != null) {
      rect = rect.intersect(
        MatrixUtils.transformRect(node.getTransformTo(null), clip),
      );
    }
    if (rect.width <= 0.5 || rect.height <= 0.5) return null;
    child = node;
  }
  return rect;
}

/// The painted boxes of each text line (not the paragraph's whole box,
/// which includes blank space around centred or wrapped lines).
List<Rect> _lineRects(RenderParagraph node, Size screen) {
  final length = node.text.toPlainText().length;
  if (length == 0) return const [];
  final boxes = node.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: length),
  );
  final own = Offset.zero & node.size;
  return [
    for (final box in boxes)
      if (visibleRect(node, box.toRect().intersect(own), screen)
          case final Rect r)
        r,
  ];
}

double _fontSize(InlineSpan span) {
  double? size = span.style?.fontSize;
  span.visitChildren((child) {
    size ??= child.style?.fontSize;
    return size == null;
  });
  return size ?? 14;
}

/// The rendered glyph size of [node]: its scaled font size times any 2-D
/// scale (FittedBox) between it and the screen.
double effectiveFontSize(RenderParagraph node) {
  final m = node.getTransformTo(null);
  final sx = math.sqrt(
    m.entry(0, 0) * m.entry(0, 0) + m.entry(1, 0) * m.entry(1, 0),
  );
  return node.textScaler.scale(_fontSize(node.text)) * sx;
}

/// Visible text an ellipsis or line limit cut off.
void scanTruncated(Size screen, Set<String> out) {
  for (final node in _onstageText()) {
    if (node.didExceedMaxLines && _lineRects(node, screen).isNotEmpty) {
      out.add('truncated ${_label(node)}');
    }
  }
}

/// Text inside bottom navigation / app bars.
Set<RenderObject> _bottomBarText() => {
  for (final bar in _onstage(
    (e) =>
        e.widget is NavigationBar ||
        e.widget is BottomAppBar ||
        e.widget is BottomNavigationBar,
  ))
    ..._onstageText(bar),
};

/// Visible text under a system inset, and text shrunk below the floor.
/// [covered] paragraphs are exempt from the inset check (a bottom
/// navigation bar the open keyboard covers, as on every platform).
void scanVisible(
  Size screen,
  List<Rect> unsafe,
  Set<String> out, {
  Set<RenderObject> covered = const {},
}) {
  for (final node in _onstageText()) {
    if (node.text.toPlainText().trim().isEmpty) continue;
    final lines = _lineRects(node, screen);
    if (lines.isEmpty) continue;
    for (final line in covered.contains(node) ? const <Rect>[] : lines) {
      for (final strip in unsafe) {
        final overlap = line.intersect(strip);
        if (overlap.width > 1 && overlap.height > 1) {
          out.add('under a system inset ${_label(node)}');
        }
      }
    }
    final m = node.getTransformTo(null);
    final shrunk = m.entry(0, 0).abs() < 0.999 || m.entry(1, 0).abs() > 0.001;
    final size = effectiveFontSize(node);
    if (shrunk && size < kMinShrunkFontSize) {
      out.add('shrunk to ${size.toStringAsFixed(1)} px ${_label(node)}');
    }
  }
}

/// With every scroll view at its end, text still under the current route's
/// FAB can never be uncovered; a FAB label must also stay in its button.
void scanFab(Size screen, Set<String> out) {
  for (final fab in _onstage((e) => e.widget is FloatingActionButton)) {
    // A FAB under a dialog or sheet is covered by it, not covering it.
    if (ModalRoute.of(fab)?.isCurrent == false) continue;
    final fabBox = fab.renderObject! as RenderBox;
    final fabRect = visibleRect(fabBox, Offset.zero & fabBox.size, screen);
    if (fabRect == null) continue;
    final inside = _onstageText(fab).toSet();
    for (final node in _onstageText()) {
      for (final line in _lineRects(node, screen)) {
        if (inside.contains(node)) {
          if (!fabRect.inflate(1).contains(line.topLeft) ||
              !fabRect.inflate(1).contains(line.bottomRight)) {
            out.add('FAB label outside its button ${_label(node)}');
          }
          continue;
        }
        final overlap = line.intersect(fabRect);
        if (overlap.width > 1 && overlap.height > 1) {
          out.add('hidden under the FAB ${_label(node)}');
        }
      }
    }
  }
}

/// App bar titles drawn taller than the toolbar or outside the bar.
Iterable<String> titlesOutsideToolbar(WidgetTester tester) sync* {
  Rect rectOf(RenderBox box) => MatrixUtils.transformRect(
    box.getTransformTo(null),
    Offset.zero & box.size,
  );
  for (final title in _onstage((e) => e.widget is AppBarTitle)) {
    final text = _onstageText(title);
    Element? bar;
    title.visitAncestorElements((a) {
      if (a.widget is AppBar) bar = a;
      return bar == null;
    });
    final barBox = bar?.renderObject;
    if (text.isEmpty || barBox is! RenderBox) continue;
    final rect = rectOf(text.first);
    final barRect = rectOf(barBox);
    if (rect.height > kToolbarHeight + 0.5 ||
        rect.top < barRect.top - 0.5 ||
        rect.bottom > barRect.bottom + 0.5) {
      yield 'title "${(title.widget as AppBarTitle).text}" outside the bar';
    }
  }
}

/// Moves every on-stage vertical scroll view to its start or end, pumping
/// until extents and positions are stable (lazy lists grow as they build).
Future<bool> scrollAll(WidgetTester tester, {required bool toEnd}) async {
  for (var round = 0; round < 8; round++) {
    var moved = false;
    // Collected first: jumping relayouts lists the finder would walk.
    final states = tester
        // skipOffstage: the on-stage walk asserts on kept-alive list
        // children that are not laid out.
        .stateList<ScrollableState>(
          find.byType(Scrollable, skipOffstage: false),
        )
        .toList();
    for (final state in states) {
      if (!state.mounted) continue;
      final box = state.context.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final position = state.position;
      if (state.widget.axis != Axis.vertical ||
          !position.hasContentDimensions) {
        continue;
      }
      final target = toEnd
          ? position.maxScrollExtent
          : position.minScrollExtent;
      if ((position.pixels - target).abs() > 0.5) {
        position.jumpTo(target);
        moved = true;
      }
    }
    if (!moved) return true;
    await tester.pump(const Duration(milliseconds: 200));
  }
  return false;
}

List<Rect> _strips(Size size, EdgeInsets i, {required bool top}) => <Rect>[
  if (top) Rect.fromLTWH(0, 0, size.width, i.top),
  if (!top) Rect.fromLTWH(0, size.height - i.bottom, size.width, i.bottom),
  Rect.fromLTWH(0, 0, i.left, size.height),
  Rect.fromLTWH(size.width - i.right, 0, i.right, size.height),
].where((r) => !r.isEmpty).toList();

/// Whether a scene's state finder matches. The finder's on-stage walk can
/// assert on kept-alive, not laid-out list children; that tree is still
/// the scene, so it counts as seen.
bool _seen(Finder finder) {
  try {
    return finder.evaluate().isNotEmpty;
  } on AssertionError {
    return true;
  }
}

/// Pumps the scene, then for every profile × scaler resizes the live
/// window (as rotation, a desktop drag or a settings change does) and runs
/// every check at the top and at the end of all scroll views.
Future<Set<String>> sweep(
  WidgetTester tester,
  Future<void> Function() pumpRoot, {
  Finder Function(WidgetTester tester)? shown,
  Future<void> Function()? refresh,
  bool platformScaleOnly = false,
}) async {
  final problems = <String>{};
  var where = 'open';
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final first = details.exceptionAsString().split('\n').first;
    final source = RegExp(
      r'lib/[\w/]+\.dart:\d+',
    ).firstMatch(details.toString())?.group(0);
    problems.add('$where: $first ${source ?? ''}');
  };
  try {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    _scaler = TextScaler.noScaling;
    await pumpRoot();
    for (final s in kSweepScalers) {
      if (platformScaleOnly) {
        // The app's own MaterialApp only reads the platform's linear scale.
        if (s.name == 'nonlinear') continue;
        tester.platformDispatcher.textScaleFactorTestValue = s.scaler.scale(1);
      } else {
        _scaler = s.scaler;
      }
      for (final profile in kSweepProfiles) {
        where = '${profile.name}@${s.name}';
        final size = profile.size;
        tester.view.physicalSize = size;
        tester.view.viewPadding = profile.insets;
        tester.view.padding = profile.insets;
        tester.view.viewInsets = FakeViewPadding.zero;
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        var settledTop = await scrollAll(tester, toEnd: false);
        if (refresh != null) {
          await refresh();
          settledTop = await scrollAll(tester, toEnd: false) && settledTop;
        }
        if (profile.keyboard > 0) {
          // A soft keyboard only opens for a focused text field: focus the
          // first visible one, or skip the keyboard profile. The keyboard
          // covers the home indicator, so the bottom padding goes to zero.
          final fields = _onstage(
            (e) =>
                e.widget is EditableText &&
                // Not behind a dialog, sheet or menu: the modal barrier
                // keeps the user from focusing it.
                ModalRoute.of(e)?.isCurrent != false &&
                e.renderObject is RenderBox &&
                (e.renderObject! as RenderBox).hasSize &&
                visibleRect(
                      e.renderObject! as RenderBox,
                      Offset.zero & (e.renderObject! as RenderBox).size,
                      size,
                    ) !=
                    null,
          );
          if (fields.isEmpty) continue;
          await tester.showKeyboard(
            find.byWidget(fields.first.widget, skipOffstage: false),
          );
          tester.view.padding = FakeViewPadding(
            left: profile.insets.left,
            top: profile.insets.top,
            right: profile.insets.right,
          );
          tester.view.viewInsets = FakeViewPadding(bottom: profile.keyboard);
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 300));
          settledTop = await scrollAll(tester, toEnd: false);
        }
        final found = <String>{};
        // A lazy list may build the state's widget only further down.
        var stateSeen = shown == null || _seen(shown(tester));
        final insets = EdgeInsets.fromLTRB(
          profile.insets.left,
          profile.insets.top,
          profile.insets.right,
          // The home indicator sits under an open keyboard.
          math.max(profile.insets.bottom, profile.keyboard),
        );
        if (!settledTop) found.add('scroll did not settle at the top');
        found.addAll(titlesOutsideToolbar(tester));
        scanTruncated(size, found);
        scanVisible(size, _strips(size, insets, top: true), found);
        if (!await scrollAll(tester, toEnd: true)) {
          found.add('scroll did not settle at the end');
        }
        scanTruncated(size, found);
        scanVisible(
          size,
          _strips(size, insets, top: false),
          found,
          covered: profile.keyboard > 0 ? _bottomBarText() : const {},
        );
        scanFab(size, found);
        stateSeen = stateSeen || _seen(shown(tester));
        if (!stateSeen) found.add('scene state lost');
        problems.addAll(found.map((p) => '$where: $p'));
        if (profile.keyboard > 0) {
          FocusManager.instance.primaryFocus?.unfocus();
          tester.view.viewInsets = FakeViewPadding.zero;
          await tester.pump(const Duration(milliseconds: 300));
        }
      }
    }
    _scaler = TextScaler.noScaling;
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  } finally {
    FlutterError.onError = previous;
    _scaler = TextScaler.noScaling;
  }
  return problems;
}
