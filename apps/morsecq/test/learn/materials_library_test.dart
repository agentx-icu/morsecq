import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/material_store.dart';
import 'package:morsecq/ui/learn/materials/material_editor_screen.dart';
import 'package:morsecq/ui/learn/materials/material_file_gateway.dart';
import 'package:morsecq/ui/learn/materials/materials_screen.dart';
import 'package:morsecq/ui/learn/receive/receive_drill_screen.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_playback.dart';
import 'helpers/l10n.dart';
import 'helpers/test_controller.dart';

/// A picker that fails the way a platform plugin can.
final class _BrokenPicker implements MaterialFileGateway {
  @override
  Future<PickedFile?> pick({required int maxBytes}) async =>
      throw const FileSystemException('denied');

  @override
  Future<bool> save(
    Uint8List bytes, {
    required String fileName,
    required String mimeType,
    Rect? shareOrigin,
  }) async => true;
}

TrainingMaterial _material(
  String id,
  String title,
  String text, {
  List<String> tags = const [],
  int minutesAgo = 0,
}) => MaterialImport.create(
  id: id,
  title: title,
  kind: MaterialKind.wordList,
  text: text,
  analysis: MaterialImport.analyze(text, MaterialKind.wordList),
  now: kTestNow.subtract(Duration(minutes: minutesAgo)),
  tags: tags,
);

Future<(TestTraining, MaterialFileGateway)> _pump(
  WidgetTester tester, {
  List<TrainingMaterial> materials = const [],
  MaterialFileGateway? gateway,
  int lesson = 10,
}) async {
  tester.view.physicalSize = const Size(430, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final t = await TestTraining.create(
    progress: TrainerProgress(currentLesson: lesson),
  );
  addTearDown(t.controller.dispose);
  for (final m in materials) {
    await t.controller.upsertMaterial(m);
  }
  final g = gateway ?? FakeMaterialFileGateway();
  await tester.pumpWidget(
    Provider<MaterialFileGateway>.value(
      value: g,
      child: l10nApp(
        home: MaterialsScreen(
          controller: t.controller,
          playback: FakeLearnPlaybackFactory(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (t, g);
}

List<String> _titles(WidgetTester tester, List<String> candidates) {
  final shown = [
    for (final c in candidates)
      if (find.text(c).evaluate().isNotEmpty) c,
  ];
  shown.sort(
    (a, b) => tester
        .getTopLeft(find.text(a))
        .dy
        .compareTo(tester.getTopLeft(find.text(b)).dy),
  );
  return shown;
}

Future<void> _menu(WidgetTester tester, int row, String item) async {
  await tester.tap(find.byTooltip(en.materialsActions).at(row));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item).last);
  await tester.pumpAndSettle();
}

final _library = [
  _material('a', 'Calls', 'CQ DE K1ABC', tags: ['contest'], minutesAgo: 30),
  _material('b', 'Words', 'RADIO HEAR', minutesAgo: 20),
  _material('c', 'Names', 'PARIS TOM', minutesAgo: 10),
];
const _all = ['Calls', 'Words', 'Names'];

void main() {
  testWidgets('search matches titles, tags and text; newest first', (
    tester,
  ) async {
    await _pump(tester, materials: _library);
    expect(_titles(tester, _all), ['Names', 'Words', 'Calls']);
    final search = find.widgetWithText(TextField, en.materialsSearch);
    await tester.enterText(search, 'CONTEST');
    await tester.pump();
    expect(_titles(tester, _all), ['Calls'], reason: 'by tag, any case');
    await tester.enterText(search, 'hear');
    await tester.pump();
    expect(_titles(tester, _all), ['Words'], reason: 'by original text');
    await tester.enterText(search, 'nam');
    await tester.pump();
    expect(_titles(tester, _all), ['Names'], reason: 'by title');
    await tester.enterText(search, '   ');
    await tester.pump();
    expect(_titles(tester, _all), hasLength(3));
  });

  testWidgets('favourites sort first and can be shown alone', (tester) async {
    final (t, _) = await _pump(tester, materials: _library);
    await tester.tap(find.byTooltip(en.materialsFavorite).last);
    await tester.pumpAndSettle();
    expect(_titles(tester, _all).first, 'Calls');
    expect(
      (await t.controller.loadMaterials())
          .firstWhere((m) => m.id == 'a')
          .favorite,
      isTrue,
    );
    await tester.tap(find.text(en.materialsFavoritesOnly));
    await tester.pumpAndSettle();
    expect(_titles(tester, _all), ['Calls']);
    await tester.tap(find.byTooltip(en.materialsUnfavorite));
    await tester.pumpAndSettle();
    expect(_titles(tester, _all), isEmpty);
  });

  testWidgets('delete asks first', (tester) async {
    final (t, _) = await _pump(tester, materials: _library);
    await _menu(tester, 0, en.materialsDelete);
    expect(find.text(en.materialsDeleteBody('Names')), findsOneWidget);
    await tester.tap(find.text(en.actionCancel));
    await tester.pumpAndSettle();
    expect(await t.controller.loadMaterials(), hasLength(3));
    await _menu(tester, 0, en.materialsDelete);
    await tester.tap(find.widgetWithText(FilledButton, en.materialsDelete));
    await tester.pumpAndSettle();
    expect(
      (await t.controller.loadMaterials()).map((m) => m.id),
      unorderedEquals(['a', 'b']),
    );
    expect(find.text('Names'), findsNothing);
  });

  testWidgets('edit opens the editor on the material', (tester) async {
    await _pump(tester, materials: _library);
    await _menu(tester, 1, en.materialsEdit);
    final editor = tester.widget<MaterialEditorScreen>(
      find.byType(MaterialEditorScreen),
    );
    expect(editor.existing!.id, 'b');
  });

  testWidgets('practising everything runs a drill titled by the material', (
    tester,
  ) async {
    await _pump(tester, materials: _library);
    await _menu(tester, 2, en.materialsPractise);
    await tester.tap(find.text(en.materialsPracticeAll));
    await tester.pumpAndSettle();
    final drill = tester.widget<ReceiveDrillScreen>(
      find.byType(ReceiveDrillScreen),
    );
    expect(drill.title, 'Calls');
    expect(drill.session.countsTowardLesson, isFalse);
  });

  testWidgets('learned-only practice with nothing learned says so', (
    tester,
  ) async {
    await _pump(
      tester,
      lesson: 1,
      materials: [_material('x', 'Hard', 'XYZ\nQJV')],
    );
    await tester.tap(find.text('Hard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.materialsPracticeLearnedPartial(2)));
    await tester.pumpAndSettle();
    expect(find.byType(ReceiveDrillScreen), findsNothing);
    expect(find.text(en.materialsPracticeNothing), findsOneWidget);
  });

  group('file problems are explained, nothing changes', () {
    testWidgets('a file over the size limit', (tester) async {
      final (t, _) = await _pump(
        tester,
        gateway: FakeMaterialFileGateway(
          pickResult: PickedFile(
            'big.txt',
            Uint8List(MaterialLimits.maxBytes + 1),
          ),
        ),
      );
      await tester.tap(find.byTooltip(en.materialsImport));
      await tester.pumpAndSettle();
      expect(find.text(en.materialsProblemTooLarge), findsOneWidget);
      expect(await t.controller.loadMaterials(), isEmpty);
    });

    testWidgets('a file that is not UTF-8 text', (tester) async {
      await _pump(
        tester,
        gateway: FakeMaterialFileGateway(
          pickResult: PickedFile('bad.txt', Uint8List.fromList([0xff, 0xfe])),
        ),
      );
      await tester.tap(find.byTooltip(en.materialsImport));
      await tester.pumpAndSettle();
      expect(find.text(en.materialsImportNotUtf8), findsOneWidget);
      expect(find.byType(MaterialEditorScreen), findsNothing);
    });

    testWidgets('a picker that fails', (tester) async {
      await _pump(tester, gateway: _BrokenPicker());
      await tester.tap(find.byTooltip(en.materialsImport));
      await tester.pumpAndSettle();
      expect(find.text(en.materialsImportFailed), findsOneWidget);
    });

    testWidgets('a cancelled pick does nothing', (tester) async {
      await _pump(tester);
      await tester.tap(find.byTooltip(en.materialsImport));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(MaterialEditorScreen), findsNothing);
    });

    testWidgets('a text export that fails', (tester) async {
      final gateway = FakeMaterialFileGateway()
        ..saveError = const FileSystemException('read-only');
      await _pump(tester, materials: _library, gateway: gateway);
      await _menu(tester, 0, en.materialsExportTxt);
      expect(find.text(en.materialsExportFailed), findsOneWidget);
      expect(gateway.saved, isEmpty);
    });

    testWidgets('a cancelled text export says nothing', (tester) async {
      final gateway = FakeMaterialFileGateway(saveResult: false);
      await _pump(tester, materials: _library, gateway: gateway);
      await _menu(tester, 0, en.materialsExportTxt);
      expect(find.text(en.materialsExported(1)), findsNothing);
    });
  });

  group('MaterialFileGateway', () {
    testWidgets('falls back to the platform gateway without a provider', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox());
      final context = tester.element(find.byType(SizedBox));
      expect(
        MaterialFileGateway.of(context),
        isA<PlatformMaterialFileGateway>(),
      );
    });

    test('an empty export is refused before any dialog', () async {
      await expectLater(
        const PlatformMaterialFileGateway().save(
          Uint8List(0),
          fileName: 'x.txt',
          mimeType: 'text/plain',
        ),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
