import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/ui/pages/chat_page.dart';
import 'package:morsecq/ui/pages/groups_page.dart';
import 'package:morsecq/ui/pages/learn_page.dart';
import 'package:morsecq/ui/pages/me_page.dart';
import 'package:morsecq/ui/responsive.dart';

const _labels = [
  LearnPage.title,
  ChatPage.title,
  GroupsPage.title,
  MePage.title,
];

const _descriptions = {
  LearnPage.title: LearnPage.description,
  ChatPage.title: ChatPage.description,
  GroupsPage.title: GroupsPage.description,
  MePage.title: MePage.description,
};

Future<void> _pumpAt(WidgetTester tester, Size logicalSize) async {
  tester.view.physicalSize = logicalSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MorsecqApp());
  await tester.pumpAndSettle();
}

/// Only the selected destination's page is visible in the IndexedStack, so
/// its description appearing exactly once is the switch signal.
void _expectSelected(String label) {
  expect(find.text(_descriptions[label]!), findsOneWidget);
  for (final other in _labels.where((l) => l != label)) {
    expect(find.text(_descriptions[other]!), findsNothing);
  }
}

void main() {
  group('AppShell at phone width', () {
    testWidgets('renders a bottom NavigationBar with four destinations', (
      tester,
    ) async {
      await _pumpAt(tester, const Size(390, 844));
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      for (final label in _labels) {
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      }
      _expectSelected(LearnPage.title);
    });

    testWidgets('tapping a destination switches the page', (tester) async {
      await _pumpAt(tester, const Size(390, 844));
      for (final label in _labels.skip(1)) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();
        _expectSelected(label);
      }
    });
  });

  group('AppShell at desktop width', () {
    testWidgets('renders a NavigationRail with four destinations', (
      tester,
    ) async {
      await _pumpAt(tester, const Size(1280, 800));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      for (final label in _labels) {
        expect(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      }
      _expectSelected(LearnPage.title);
    });

    testWidgets('tapping a rail destination switches the page', (tester) async {
      await _pumpAt(tester, const Size(1280, 800));
      for (final label in _labels.skip(1)) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();
        _expectSelected(label);
      }
    });
  });

  test('breakpoint is exactly 600 logical pixels', () {
    expect(layoutClassForWidth(599), LayoutClass.compact);
    expect(layoutClassForWidth(600), LayoutClass.expanded);
    expect(layoutClassForWidth(kCompactMaxWidth), LayoutClass.expanded);
  });
}
