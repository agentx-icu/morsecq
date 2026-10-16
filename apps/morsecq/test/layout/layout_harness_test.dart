// Structural checks of the layout harness itself. Unlike the sweep they
// need no real fonts, so they run in every widget-test pass.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'layout_harness.dart';

const _screen = Size(390, 844);

Future<Set<String>> _truncated(WidgetTester tester, Widget body) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _screen;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: body)),
    ),
  );
  final found = <String>{};
  scanTruncated(_screen, found);
  return found;
}

/// Text that wraps to two lines inside a box one line high.
Widget _clamped({TextOverflow? overflow}) => SizedBox(
  width: 150,
  height: 20,
  child: Text('Two lines of words', overflow: overflow),
);

void main() {
  testWidgets('flags text a clamped box cuts off without a line limit', (
    tester,
  ) async {
    final found = await _truncated(tester, _clamped());
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Two lines of words'),
    );
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(found.single, startsWith('clipped'));
  });

  testWidgets('flags a line that may not wrap faded at the edge', (
    tester,
  ) async {
    final found = await _truncated(
      tester,
      const SizedBox(
        width: 150,
        child: Text(
          'Fading line',
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
      ),
    );
    expect(found.single, startsWith('clipped'));
  });

  testWidgets('flags a line clamped to half its height', (tester) async {
    final found = await _truncated(
      tester,
      const SizedBox(
        width: 150,
        height: 7,
        child: Text('Short', style: TextStyle(fontSize: 14)),
      ),
    );
    expect(found.single, startsWith('clipped'));
  });

  testWidgets('accepts a clamp that only trims line leading', (tester) async {
    final found = await _truncated(
      tester,
      const SizedBox(
        width: 150,
        height: 16,
        child: Text('Short', style: TextStyle(fontSize: 14)),
      ),
    );
    expect(found, isEmpty);
  });

  testWidgets('flags a faded line even when only leading is cut', (
    tester,
  ) async {
    final found = await _truncated(
      tester,
      const SizedBox(
        width: 150,
        height: 16,
        child: Text(
          'Short',
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
    expect(found.single, startsWith('clipped'));
  });

  testWidgets('accepts fitting, visible-overflow and hidden text', (
    tester,
  ) async {
    final found = await _truncated(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 150, child: Text('Fits in one line')),
          _clamped(overflow: TextOverflow.visible),
          Opacity(opacity: 0, child: _clamped()),
        ],
      ),
    );
    expect(found, isEmpty);
  });

  group('seenScene', () {
    Future<void> pump(WidgetTester tester, {required bool withDialog}) =>
        tester.pumpWidget(
          MaterialApp(
            home: withDialog ? const AlertDialog() : const SizedBox(),
          ),
        );

    testWidgets('a walk that asserts still needs the scene to be there', (
      tester,
    ) async {
      final finder = _AssertingWalk(AlertDialog);
      expect(finder.evaluate, throwsA(isA<AssertionError>()));
      await pump(tester, withDialog: false);
      expect(seenScene(finder), isFalse);
      await pump(tester, withDialog: true);
      expect(seenScene(finder), isTrue);
    });

    testWidgets('an ordinary finder is evaluated directly', (tester) async {
      await pump(tester, withDialog: true);
      expect(seenScene(find.byType(AlertDialog)), isTrue);
      expect(seenScene(find.byType(SimpleDialog)), isFalse);
    });
  });
}

/// Matches by type, but its on-stage walk asserts the way the framework's
/// does on kept-alive, not laid-out lazy-list children.
final class _AssertingWalk extends Finder {
  _AssertingWalk(this.type);

  final Type type;

  @override
  String get description => 'type "$type"';

  @override
  Iterable<Element> get allCandidates =>
      throw AssertionError('kept-alive child without a layout');

  @override
  Iterable<Element> findInCandidates(Iterable<Element> candidates) =>
      candidates.where((element) => element.widget.runtimeType == type);
}
