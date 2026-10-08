import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/desktop/desktop.dart';
import 'package:morsecq/desktop/testing/testing.dart';
import 'package:morsecq/l10n/generated/s.dart';

/// Language handling of the desktop shell: `updateStrings(S)` relabels the
/// tray menu, tooltip and window title; the product name stays untranslated.
/// The functional tests live in `desktop_shell_controller_test.dart`.
final S en = lookupS(const Locale('en'));
final S zh = lookupS(const Locale('zh'));

({DesktopShellController controller, FakeWindowApi window, FakeTrayApi tray})
_shell({TargetPlatform platform = TargetPlatform.linux, S? strings}) {
  final window = FakeWindowApi();
  final tray = FakeTrayApi();
  final controller = DesktopShellController(
    config: DesktopShellConfig(
      store: InMemoryKeyValueStore(),
      platform: platform,
      persistDebounce: Duration.zero,
    ),
    window: window,
    tray: tray,
    screen: FakeScreenApi(const [Rect.fromLTWH(0, 0, 1920, 1040)]),
    strings: strings,
  );
  return (controller: controller, window: window, tray: tray);
}

void main() {
  test('English labels by default (pinned), plural tooltip', () async {
    final h = _shell(strings: en);
    await h.controller.initialize();
    expect(h.tray.menu.first.label, 'Hide MorseCQ');
    expect(h.tray.menu[1].label, 'Sound on');
    expect(h.tray.menu.last.label, 'Quit MorseCQ');

    expect(h.tray.tooltip, 'MorseCQ');
    expect(h.window.title, 'MorseCQ');
  });

  test('updateStrings relabels the menu, tooltip and title', () async {
    final h = _shell(platform: TargetPlatform.macOS, strings: en);
    await h.controller.initialize();
    await h.controller.flushTrayUpdates();
    var notified = 0;
    h.controller.addListener(() => notified++);

    h.controller.updateStrings(zh);
    await h.controller.flushTrayUpdates();

    expect(notified, 1);
    expect(h.controller.strings.localeName, 'zh');
    expect(h.tray.menu.first.label, zh.desktopTrayHide('MorseCQ'));
    expect(h.tray.menu.first.label, '隐藏 MorseCQ');
    expect(h.tray.menu[1].label, zh.desktopTraySoundOn);
    expect(h.tray.menu.last.label, '退出 MorseCQ');
    expect(h.tray.tooltip, 'MorseCQ');
    // The product name itself is never translated.
    expect(h.window.title, contains('MorseCQ'));
    expect(h.tray.title, '');

    // Visibility relabelling keeps the new language.
    await h.controller.hideToTray();
    await h.controller.flushTrayUpdates();
    expect(h.tray.menu.first.label, '显示 MorseCQ');
  });

  test('the same language again is a no-op', () async {
    final h = _shell(strings: en);
    await h.controller.initialize();
    await h.controller.flushTrayUpdates();
    final trayCalls = h.tray.calls.length;
    final windowCalls = h.window.calls.length;
    var notified = 0;
    h.controller.addListener(() => notified++);

    h.controller.updateStrings(lookupS(const Locale('en')));
    await h.controller.flushTrayUpdates();

    expect(notified, 0);
    expect(h.tray.calls.length, trayCalls);
    expect(h.window.calls.length, windowCalls);
  });

  test('before initialize and on mobile: state only', () async {
    final h = _shell(platform: TargetPlatform.android, strings: en);
    h.controller.updateStrings(zh);
    await h.controller.initialize();
    await h.controller.flushTrayUpdates();

    expect(h.controller.trayMenu.first.label, zh.desktopTrayShow('MorseCQ'));
    expect(h.controller.windowTitle, 'MorseCQ');
    expect(h.window.calls, isEmpty);
    expect(h.tray.calls, isEmpty);
  });

  test('a controller built without strings follows currentS()', () {
    // The constructor default is currentS(), which with no LocaleController
    // resolves the platform locale and must always yield a shipped locale.
    final h = _shell();
    expect(
      S.supportedLocales.map((l) => l.toString()),
      contains(h.controller.strings.localeName),
    );
    h.controller.dispose();
  });
}
