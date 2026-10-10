import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/main.dart';

const kPhoneSize = Size(540, 960);
const kDesktopSize = Size(1280, 800);

/// Lets real file I/O finish, then settles. A fixed number of real-time
/// steps was not enough on a busy disk: the learning store was still
/// loading, its spinner never settled and `pumpAndSettle` timed out. Keep
/// stepping (bounded) while an indeterminate progress indicator is shown.
Future<void> settle(WidgetTester tester) async {
  bool loading() => find
      .byWidgetPredicate((w) => w is ProgressIndicator && w.value == null)
      .evaluate()
      .isNotEmpty;
  await tester.runAsync(() async {
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    for (
      var i = 0;
      i < 12 || (loading() && DateTime.now().isBefore(deadline));
      i++
    ) {
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
