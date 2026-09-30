import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/desktop/desktop.dart';
import 'package:morsecq/desktop/testing/testing.dart';
import 'package:morsecq/di/fake_backend_factory.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/ui/account/backup_file_gateway.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import 'package:provider/provider.dart';

import '../account/test_app.dart';

/// Regression: `main()` hands the initialised desktop shell to `AppScope`,
/// which used to expose it through a plain `Provider`. `DesktopShellController`
/// is a `ChangeNotifier`, so provider's debug type check threw on every
/// debug launch on macOS / Linux / Windows — a path no hermetic test
/// exercised because they all pass `desktopShell: null`. Found by
/// `integration_test/app_launch_test.dart`.
void main() {
  testWidgets('AppScope accepts a live DesktopShellController', (
    tester,
  ) async {
    final controller = DesktopShellController(
      config: DesktopShellConfig(
        store: InMemoryKeyValueStore(),
        platform: TargetPlatform.macOS,
        persistDebounce: Duration.zero,
      ),
      window: FakeWindowApi(),
      tray: FakeTrayApi(),
      screen: FakeScreenApi(const [Rect.fromLTWH(0, 0, 1920, 1040)]),
      strings: lookupS(const Locale('en')),
    );
    addTearDown(controller.dispose);

    tester.view.physicalSize = kDesktopSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MorsecqApp(
        backend: FakeBackendFactory(identityService: seededIdentityService()),
        backupFiles: FakeBackupFileGateway(),
        desktopShell: controller,
      ),
    );
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(AppShell), findsOneWidget);
    final provided = tester
        .element(find.byType(AppShell))
        .read<DesktopShellController?>();
    expect(provided, same(controller));
  });
}
