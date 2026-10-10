import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/ui/keying/key_setup_page.dart';
import 'package:morsecq/ui/learn/settings/training_settings_screen.dart';
import 'package:morsecq/ui/pages/offline_me_page.dart';
import 'package:morsecq/ui/settings/settings_routes.dart';
import 'package:provider/provider.dart';

import '../learn/helpers/l10n.dart';
import '../moderation/fake_url_launcher.dart';
import '../support/test_app.dart';

/// Records clipboard writes for the duration of one test.
List<String> _recordClipboard(WidgetTester tester) {
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

Future<void> _openMe(WidgetTester tester, {Size size = kPhoneSize}) async {
  await pumpApp(tester, size: size);
  await tester.tap(find.text(en.navMe).last);
  await settle(tester);
  expect(find.byType(OfflineMePage), findsOneWidget);
}

/// Drives [future] to completion: app futures may need frames and real I/O.
Future<T> _drive<T>(WidgetTester tester, Future<T> future) async {
  var done = false;
  late T value;
  unawaited(
    future.then((v) {
      value = v;
      done = true;
    }),
  );
  for (var i = 0; i < 20 && !done; i++) {
    await settle(tester);
  }
  expect(done, isTrue, reason: 'future did not complete');
  return value;
}

Future<TrainingController> _controller(WidgetTester tester) => _drive(
  tester,
  tester
      .element(find.byType(OfflineMePage))
      .read<TrainingControllerHost>()
      .controller(),
);

void main() {
  testWidgets('training defaults opens the shared controller settings', (
    tester,
  ) async {
    await _openMe(tester);
    final shared = await _controller(tester);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('offline-training-defaults')),
    );
    final screen = tester.widget<TrainingSettingsScreen>(
      find.byType(TrainingSettingsScreen),
    );
    expect(screen.controller, same(shared), reason: 'one controller app-wide');
  });

  testWidgets('keys opens the key profile list', (tester) async {
    await _openMe(tester);
    await tapVisible(tester, find.byKey(const ValueKey('offline-keys')));
    expect(find.byType(KeySetupPage), findsOneWidget);
    expect(find.text(en.keysStandardProfile), findsOneWidget);
  });

  testWidgets('clearing asks first; cancel keeps the learning data', (
    tester,
  ) async {
    await _openMe(tester);
    final c = await _controller(tester);
    await _drive(tester, c.setDailyGoal(77));
    await tapVisible(tester, find.byKey(const ValueKey('offline-clear')));
    expect(find.text(en.guestClearConfirm), findsOneWidget);
    await tester.tap(find.text(en.actionCancel));
    await settle(tester);
    expect(c.isDisposed, isFalse);
    expect(c.progress.dailyGoalChars, 77);
    expect(find.text(en.offlineCleared), findsNothing);
  });

  testWidgets('confirmed clearing resets learning and says so', (tester) async {
    await _openMe(tester);
    final before = await _controller(tester);
    await _drive(tester, before.setDailyGoal(77));
    await tapVisible(tester, find.byKey(const ValueKey('offline-clear')));
    await tester.tap(find.text(en.guestClearConfirm));
    await settle(tester);
    expect(find.text(en.offlineCleared), findsOneWidget);
    expect(before.isDisposed, isTrue);
    final after = await _controller(tester);
    expect(after, isNot(same(before)));
    expect(after.progress.dailyGoalChars, TrainerProgress().dailyGoalChars);
  });

  testWidgets('the source link is copied with a confirmation', (tester) async {
    final copied = _recordClipboard(tester);
    await _openMe(tester);
    await tapVisible(tester, find.text(kAboutSourceUrl));
    expect(copied, [kAboutSourceUrl]);
    expect(find.text(en.accountAboutSourceCopied), findsOneWidget);
  });

  group('site links', () {
    testWidgets('open in the browser, in English for English readers', (
      tester,
    ) async {
      final launcher = FakeUrlLauncher.install();
      await _openMe(tester);
      for (final key in ['about-privacy', 'about-terms', 'about-support']) {
        await tapVisible(tester, find.byKey(ValueKey(key)));
      }
      expect(launcher.launched, [kPrivacyPolicyUrl, kTermsUrl, kSupportUrl]);
    });

    testWidgets('without a browser the link is copied instead', (tester) async {
      final launcher = FakeUrlLauncher.install()..opens = false;
      final copied = _recordClipboard(tester);
      await _openMe(tester);
      await tapVisible(tester, find.byKey(const ValueKey('about-terms')));
      expect(launcher.launched, [kTermsUrl]);
      expect(copied, [kTermsUrl]);
      expect(find.text(en.aboutLinkFailed), findsOneWidget);
    });
  });

  group('app shell', () {
    testWidgets(
      'wide windows use a rail; tabs survive crossing the breakpoint',
      (tester) async {
        await pumpApp(tester, size: kDesktopSize);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        await tester.tap(find.text(en.navMe).last);
        await settle(tester);
        expect(find.byType(OfflineMePage), findsOneWidget);
        final element = tester.element(find.byType(OfflineMePage).first);
        expect(
          tester
              .widget<NavigationRail>(find.byType(NavigationRail))
              .selectedIndex,
          2,
        );

        // Narrow the window: the bar replaces the rail, the Me tab stays.
        tester.view.physicalSize = kPhoneSize;
        await settle(tester);
        expect(find.byType(NavigationRail), findsNothing);
        final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(bar.selectedIndex, 2);
        expect(tester.element(find.byType(OfflineMePage).first), same(element));
      },
    );

    testWidgets('selecting the current tab again changes nothing', (
      tester,
    ) async {
      await pumpApp(tester, size: kDesktopSize);
      await tester.tap(find.text(en.navLearn).last);
      await settle(tester);
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        0,
      );
    });
  });
}
