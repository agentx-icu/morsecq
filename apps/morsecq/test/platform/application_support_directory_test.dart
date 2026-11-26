import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/lifecycle/application_support_directory.dart';
import 'package:path/path.dart' as p;

void main() {
  const flatpakId = 'io.github.agentx_icu.morsecq';
  const flatpak = {'FLATPAK_ID': flatpakId};
  late Directory dataHome;
  late Directory current;

  setUp(() async {
    dataHome = await Directory.systemTemp.createTemp();
    addTearDown(() => dataHome.delete(recursive: true));
    current = await Directory(p.join(dataHome.path, flatpakId)).create();
  });

  test(
    'Flatpak keeps the original support directory when both exist',
    () async {
      final original = await Directory(
        p.join(dataHome.path, 'icu.agentx.morsecq'),
      ).create();
      final support = await getMorseCqApplicationSupportDirectory(
        environment: flatpak,
        platformDirectory: () async => current,
      );
      expect(support.path, original.path);
    },
  );

  test('a fresh Flatpak uses the platform support directory', () async {
    final support = await getMorseCqApplicationSupportDirectory(
      environment: flatpak,
      platformDirectory: () async => current,
    );
    expect(support.path, current.path);
  });

  test('standard packages keep the provider directory', () async {
    await Directory(p.join(dataHome.path, 'icu.agentx.morsecq')).create();
    final support = await getMorseCqApplicationSupportDirectory(
      environment: const {},
      platformDirectory: () async => current,
    );
    expect(support.path, current.path);
  });

  test('Flatpak preserves a provider fallback or override', () async {
    await Directory(p.join(dataHome.path, 'icu.agentx.morsecq')).create();
    final fallback = await Directory(p.join(dataHome.path, 'morsecq')).create();
    final support = await getMorseCqApplicationSupportDirectory(
      environment: flatpak,
      platformDirectory: () async => fallback,
    );
    expect(support.path, fallback.path);
  });
}
