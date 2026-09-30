import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/fake_backend_factory.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/ui/account/backup_file_gateway.dart';
import 'package:morsecq/ui/account/identity_card.dart';
import 'package:morsecq/ui/pages/chat_page.dart';
import 'package:morsecq/ui/pages/groups_page.dart';
import 'package:morsecq/ui/pages/learn_page.dart';
import 'package:morsecq/ui/pages/me_page.dart';
import 'package:morsecq/ui/pages/reference_page.dart';
import 'package:morsecq/ui/reference/reference_screen.dart';
import 'package:morsecq/ui/responsive.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:morsecq_chat_api/testing.dart';

import 'account/test_app.dart';

/// The harness renders in English (no override, default test locale).
final S en = lookupS(const Locale('en'));

final List<String> _labels = [
  LearnPage.title(en),
  ChatPage.title(en),
  GroupsPage.title(en),
  ReferencePage.title(en),
  MePage.title(en),
];

/// One widget that only the selected destination's page renders. The
/// placeholder pages show their description; the Me page shows the identity
/// card.
final Map<String, Finder> _pageMarkers = {
  LearnPage.title(en): find.text(LearnPage.description(en)),
  ChatPage.title(en): find.text(ChatPage.description(en)),
  GroupsPage.title(en): find.text(GroupsPage.description(en)),
  ReferencePage.title(en): find.byType(ReferenceScreen),
  MePage.title(en): find.byType(IdentityCard),
};

/// The shell renders only behind the startup gate, so every test boots the
/// app with a ready (plain, already-created) fake identity.
Future<void> _pumpAt(WidgetTester tester, Size logicalSize) async {
  tester.view.physicalSize = logicalSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final identity = FakeIdentityService.withProfile(
    identity: Identity(
      toxId: FakeIdentityService.toxIdForSeed(1),
      displayName: 'Shell Tester',
    ),
    connectDelay: Duration.zero,
    dataDirectoryPath: freshDataDirectory(),
  );
  await tester.pumpWidget(
    MorsecqApp(
      backend: FakeBackendFactory(identityService: identity),
      backupFiles: FakeBackupFileGateway(),
    ),
  );
  await settle(tester);
}

/// Only the selected destination's page is visible in the IndexedStack, so
/// its marker appearing exactly once is the switch signal.
void _expectSelected(String label) {
  expect(_pageMarkers[label]!, findsOneWidget);
  for (final other in _labels.where((l) => l != label)) {
    expect(_pageMarkers[other]!, findsNothing);
  }
}

void main() {
  group('AppShell at phone width', () {
    testWidgets('renders a bottom NavigationBar with five destinations', (
      tester,
    ) async {
      await _pumpAt(tester, kPhoneSize);
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
      _expectSelected(LearnPage.title(en));
    });

    testWidgets('tapping a destination switches the page', (tester) async {
      await _pumpAt(tester, kPhoneSize);
      for (final label in _labels.skip(1)) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await settle(tester);
        _expectSelected(label);
      }
    });
  });

  group('AppShell at desktop width', () {
    testWidgets('renders a NavigationRail with five destinations', (
      tester,
    ) async {
      await _pumpAt(tester, kDesktopSize);
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
      _expectSelected(LearnPage.title(en));
    });

    testWidgets('tapping a rail destination switches the page', (tester) async {
      await _pumpAt(tester, kDesktopSize);
      for (final label in _labels.skip(1)) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text(label),
          ),
        );
        await settle(tester);
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
