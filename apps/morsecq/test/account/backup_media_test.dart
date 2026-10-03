import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/account/backup_file_gateway.dart';
import 'package:morsecq/ui/pages/me_page.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:morsecq_chat_api/testing.dart';
import 'package:path/path.dart' as p;

import 'test_app.dart';

final S en = lookupS(const Locale('en'));

Future<void> _export(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(MePage.title(en)),
    ),
  );
  await settle(tester);
  await tester.ensureVisible(find.text(en.accountExportBackup));
  await settle(tester);
  await tester.tap(find.text(en.accountExportBackup));
  await settle(tester);
}

/// Puts a saved recording where the workbench keeps them: the identity
/// root beside its backed-up data directory.
Future<void> _saveRecording(FakeIdentityService identity) async {
  final data = await identity.dataDirectory();
  final root = p.dirname(data);
  final file = File(p.join(root, 'media', 'recordings', 'rec_a.wav'))
    ..createSync(recursive: true)
    ..writeAsBytesSync(List<int>.filled(2048, 1));
  // Only referenced saved recordings count (the same rule as the export);
  // the working recording never does.
  final working = File(p.join(root, 'media', 'recordings', 'current.wav'))
    ..writeAsBytesSync(List<int>.filled(4096, 1));
  final doc = File(p.join(data, BackupMedia.materialsDoc))
    ..createSync(recursive: true)
    ..writeAsStringSync(
      '{"v":1,"materials":[{"id":"x","file":"media/recordings/rec_a.wav"}]}',
    );
  addTearDown(() {
    for (final f in [file, working, doc]) {
      if (f.existsSync()) f.deleteSync();
    }
  });
}

void main() {
  late FakeIdentityService identity;
  late FakeBackupFileGateway files;

  setUp(() {
    identity = seededIdentityService();
    files = FakeBackupFileGateway();
  });

  testWidgets('no recordings: export asks nothing', (tester) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _export(tester);
    expect(find.text(en.accountBackupMediaTitle), findsNothing);
    expect(files.saved, hasLength(1));
  });

  testWidgets('saved recordings: the learner opts in or out', (tester) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _saveRecording(identity);
    await _export(tester);
    expect(find.text(en.accountBackupMediaTitle), findsOneWidget);
    expect(find.text(en.accountBackupMediaBody(1, '0.0')), findsOneWidget);
    // The default action leaves the recordings out.
    await tester.tap(find.byKey(const ValueKey('backup-without-media')));
    await settle(tester);
    expect(files.saved, hasLength(1));

    await tester.tap(find.text(en.accountExportBackup));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('backup-include-media')));
    await settle(tester);
    expect(files.saved, hasLength(2));
  });

  testWidgets('cancelling the question exports nothing', (tester) async {
    await pumpApp(tester, identity: identity, backupFiles: files);
    await _saveRecording(identity);
    await _export(tester);
    await tester.tap(find.text(en.actionCancel));
    await settle(tester);
    expect(files.saved, isEmpty);
  });
}
