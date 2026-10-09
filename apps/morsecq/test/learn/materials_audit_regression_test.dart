import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/material_practice.dart';
import 'package:morsecq/training/material_store.dart';
import 'package:morsecq/training/receive_recording.dart';
import 'package:morsecq/ui/learn/materials/material_editor_screen.dart';
import 'package:morsecq/ui/learn/materials/material_file_gateway.dart';
import 'package:morsecq/ui/learn/materials/materials_screen.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

void main() {
  testWidgets('an oversized library export reports failure without a file', (
    tester,
  ) async {
    final t = await TestTraining.create();
    addTearDown(t.controller.dispose);
    final text = 'CQ${' ' * 600000}';
    final analysis = MaterialImport.analyze(text, MaterialKind.text);
    for (var i = 0; i < 2; i++) {
      await t.controller.upsertMaterial(
        MaterialImport.create(
          id: 'large-$i',
          title: 'Large $i',
          kind: MaterialKind.text,
          text: text,
          analysis: analysis,
          now: t.controller.now(),
        ),
      );
    }
    final files = FakeMaterialFileGateway();
    await tester.pumpWidget(
      Provider<MaterialFileGateway>.value(
        value: files,
        child: l10nApp(
          home: MaterialsScreen(
            controller: t.controller,
            playback: FakeLearnPlaybackFactory(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(en.materialsExportJson));
    await tester.pumpAndSettle();
    expect(files.saved, isEmpty);
    expect(find.text(en.materialsExportFailed), findsOneWidget);
    expect(await t.controller.loadMaterials(), hasLength(2));
  });

  testWidgets('the latest text must be previewed before it can be saved', (
    tester,
  ) async {
    final t = await TestTraining.create();
    addTearDown(t.controller.dispose);
    await tester.pumpWidget(
      l10nApp(
        home: MaterialEditorScreen(
          controller: t.controller,
          initialTitle: 'Audit text',
          initialText: 'CQ',
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey('material-text')),
      'CQ 你好',
    );
    await tester.pump();
    expect(find.text(en.materialsPreviewUnsupported('你 好')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('material-save')));
    await tester.pumpAndSettle();
    expect(await t.controller.loadMaterials(), isEmpty);
    expect(find.text(en.materialsPreviewUnsupported('你 好')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('material-save')));
    await tester.pumpAndSettle();
    expect((await t.controller.loadMaterials()).single.originalText, 'CQ 你好');
  });

  test(
    'editing a material retains the running drill and earlier mistake',
    () async {
      final t = await TestTraining.create(
        progress: TrainerProgress(currentLesson: 42),
        settings: kShortSettings,
      );
      addTearDown(t.controller.dispose);
      final original = MaterialImport.create(
        id: 'material-audit',
        title: 'Custom text',
        kind: MaterialKind.text,
        text: 'CQ',
        analysis: MaterialImport.analyze('CQ', MaterialKind.text),
        now: t.controller.now(),
      );
      await t.controller.upsertMaterial(original);
      final session = t.controller.startMaterialSession(
        original,
        learnedOnly: true,
      )!;
      await t.controller.upsertMaterial(
        original.copyWith(originalText: 'DE', normalizedItems: ['DE']),
      );
      while (!session.isComplete) {
        expect(session.currentDrill.text, 'CQ');
        session.submit('BAD');
      }
      await t.controller.recordReceiveSession(session);
      expect((await t.controller.loadMaterials()).single.originalText, 'DE');
      expect(
        t.controller.progress.history.single.sourceRef,
        'material:material-audit',
      );
      expect(t.controller.progress.mistakeNotebook.pending.single.target, 'CQ');
      expect(t.controller.currentLesson, 42);
    },
  );
}
