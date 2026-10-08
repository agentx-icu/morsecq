import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/main.dart';

const kPhoneSize = Size(540, 960);
const kDesktopSize = Size(1280, 800);
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  });
  await tester.pumpAndSettle();
}

Future<void> pumpApp(WidgetTester tester, {Size size = kPhoneSize}) async {
  final root = Directory.systemTemp.createTempSync('morsecq_local_test_');
  addTearDown(() => root.deleteSync(recursive: true));
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MorsecqApp(learningStore: LocalLearningStore(root: () async => root.path)),
  );
  await settle(tester);
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await settle(tester);
}
