import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/main.dart';
import 'package:morsecq/training/local_learning_store.dart';
import 'package:morsecq/ui/shell/app_shell.dart';
import '../support/test_app.dart';

void main() {
  testWidgets(
    'default installation opens learning without an account or chat',
    (tester) async {
      final root = Directory.systemTemp.createTempSync('morsecq_first_launch_');
      addTearDown(() => root.deleteSync(recursive: true));
      tester.view.physicalSize = const Size(540, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MorsecqApp(
          learningStore: LocalLearningStore(root: () async => root.path),
        ),
      );
      await settle(tester);
      expect(find.byType(AppShell), findsOneWidget);
      final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(nav.destinations.length, 3);
      expect(find.text('Continue lesson'), findsOneWidget);
      expect(find.text('Create identity'), findsNothing);
      expect(
        find.byKey(const ValueKey('legacy-learning-import')),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
      await settle(tester);
    },
  );
}
