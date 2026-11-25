import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/desktop/windows_tray_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('uses the actual registration result from the Windows runner', () async {
    const channel = MethodChannel('morsecq/windows_tray_icon');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    bool? registered = true;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'isAvailable');
      return registered;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    expect(await windowsTrayIconAvailable(), isTrue);
    registered = false;
    expect(await windowsTrayIconAvailable(), isFalse);
    registered = null;
    expect(await windowsTrayIconAvailable(), isFalse);
  });
}
