import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/app_services.dart';
import 'package:morsecq/i18n/key_value_store.dart';
import 'package:morsecq/i18n/locale_controller.dart';
import 'package:morsecq/notifications/testing/fake_badge_api.dart';
import 'package:morsecq/notifications/testing/fake_local_notifications_api.dart';
import 'package:morsecq_chat_api/testing.dart';

/// The cross-cutting wiring `AppScope` builds: a language change must reach
/// the OS-facing surfaces (here the notification API; the tray is covered by
/// the desktop tests).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late FakeIdentityService identity;
  late FakeChatService chat;
  late LocaleController locale;
  late FakeLocalNotificationsApi api;
  late AppServices services;
  var disposed = false;

  setUp(() async {
    disposed = false;
    tempDir = await Directory.systemTemp.createTemp('morsecq_services_');
    identity = FakeIdentityService(
      connectDelay: Duration.zero,
      dataDirectoryPath: tempDir.path,
    );
    chat = FakeChatService(selfPublicKey: 'F' * 64);
    locale = LocaleController(InMemoryKeyValueStore());
    api = FakeLocalNotificationsApi();
    services = AppServices(
      identity: identity,
      chat: chat,
      locale: locale,
      notificationApis: NotificationApis(
        notifications: api,
        badge: FakeBadgeApi(),
      ),
    );
  });

  tearDown(() async {
    if (!disposed) await services.dispose();
    locale.dispose();
    await identity.dispose();
    await chat.dispose();
    await tempDir.delete(recursive: true);
  });

  test('a language change after start refreshes the notification strings',
      () async {
    services.start();
    await pumpEventQueue();
    expect(api.refreshStringsCalls, 0);

    await locale.setLocale(const Locale('zh'));
    await pumpEventQueue();
    expect(api.refreshStringsCalls, 1);

    await locale.setLocale(null); // back to following the system
    await pumpEventQueue();
    expect(api.refreshStringsCalls, 2);
  });

  test('after dispose a language change reaches nothing', () async {
    services.start();
    await pumpEventQueue();
    await services.dispose();
    disposed = true;

    await locale.setLocale(const Locale('zh'));
    await pumpEventQueue();
    expect(api.refreshStringsCalls, 0);
  });
}
