import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/startup/startup_controller.dart';
import 'package:morsecq/training/file_trainer_store.dart';
import 'package:morsecq/training/guest_profile.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:morsecq_chat_api/testing.dart';
import 'package:path/path.dart' as p;

Future<Directory> _tmp() async {
  final d = await Directory.systemTemp.createTemp('morsecq_guest_');
  addTearDown(() => d.delete(recursive: true));
  return d;
}

Future<void> _writeGuestProgress(String guestDir, int lesson) =>
    FileTrainerStore.inDataDirectory(
      guestDir,
    ).save(TrainerProgress(currentLesson: lesson));

void main() {
  group('GuestMigration', () {
    test('moves progress, records completion, retry is a no-op', () async {
      final root = await _tmp();
      final guest = p.join(root.path, 'guest');
      final identity = p.join(root.path, 'id');
      await _writeGuestProgress(guest, 7);
      final m = GuestMigration(
        guestDirectory: guest,
        identityDirectory: identity,
      );
      final now = DateTime(2026, 10, 3);
      expect(await m.run(identityKey: 'AB', now: now), MigrationOutcome.done);
      final moved = await FileTrainerStore.inDataDirectory(identity).load();
      expect(moved!.currentLesson, 7);
      expect(await Directory(p.join(guest, 'training')).exists(), isFalse);
      expect(
        await m.run(identityKey: 'AB', now: now),
        MigrationOutcome.alreadyDone,
      );
    });

    test(
      'an unreadable guest file fails before commit; guest data stays',
      () async {
        final root = await _tmp();
        final guest = p.join(root.path, 'guest');
        final identity = p.join(root.path, 'id');
        final file = File(p.join(guest, 'training', 'progress.json'));
        await file.create(recursive: true);
        await file.writeAsString('{broken');
        final m = GuestMigration(
          guestDirectory: guest,
          identityDirectory: identity,
        );
        await expectLater(
          m.run(identityKey: 'AB', now: DateTime(2026)),
          throwsA(anything),
        );
        expect(await file.exists(), isTrue, reason: 'guest data intact');
        expect(await Directory(p.join(identity, 'training')).exists(), isFalse);
      },
    );

    test(
      'an existing identity training dir is moved aside, never lost',
      () async {
        final root = await _tmp();
        final guest = p.join(root.path, 'guest');
        final identity = p.join(root.path, 'id');
        await _writeGuestProgress(guest, 4);
        await FileTrainerStore.inDataDirectory(
          identity,
        ).save(TrainerProgress(currentLesson: 20));
        await GuestMigration(
          guestDirectory: guest,
          identityDirectory: identity,
        ).run(identityKey: 'CD', now: DateTime(2026, 1, 1));
        final now = await FileTrainerStore.inDataDirectory(identity).load();
        expect(now!.currentLesson, 4);
        final aside = Directory(identity)
            .listSync()
            .whereType<Directory>()
            .where(
              (d) => p.basename(d.path).startsWith('training.before-guest'),
            );
        expect(aside, hasLength(1));
        final kept =
            jsonDecode(
                  File(
                    p.join(aside.single.path, 'progress.json'),
                  ).readAsStringSync(),
                )
                as Map<String, Object?>;
        expect(kept['currentLesson'], 20);
      },
    );
  });

  group('StartupController guest mode', () {
    late Directory root;
    late GuestStore store;
    late FakeIdentityService identity;
    var released = 0;

    StartupController controller() => StartupController(
      identity,
      guest: GuestHooks(
        store: store,
        releaseGuestController: () async => released++,
      ),
      now: () => DateTime(2026, 10, 3),
    );

    setUp(() async {
      root = await Directory.systemTemp.createTemp('morsecq_guest_start_');
      store = GuestStore(root: () async => p.join(root.path, 'guest'));
      identity = FakeIdentityService(
        connectDelay: Duration.zero,
        dataDirectoryPath: p.join(root.path, 'ids'),
      );
      released = 0;
    });
    tearDown(() => root.delete(recursive: true));

    test('guest mode is remembered across restarts', () async {
      final c = controller();
      await c.ensureStarted();
      expect(c.phase, StartupPhase.onboarding);
      await c.enterGuest();
      expect(c.phase, StartupPhase.guest);
      expect(c.guestMode.value, isTrue);
      expect(identity.current, isNull, reason: 'no Tox identity created');
      c.dispose();

      final again = controller();
      await again.ensureStarted();
      expect(again.phase, StartupPhase.guest);
      await again.leaveGuest();
      expect(again.phase, StartupPhase.onboarding);
      expect(await store.isActive(), isFalse);
      again.dispose();
    });

    test('a locked identity stays locked while learning as a guest', () async {
      identity = FakeIdentityService.withProfile(
        identity: Identity(toxId: 'A' * 76, displayName: 'Op'),
        password: 'pw',
        connectDelay: Duration.zero,
        dataDirectoryPath: p.join(root.path, 'ids'),
      );
      final c = controller();
      await c.ensureStarted();
      expect(c.phase, StartupPhase.locked);
      await c.enterGuest();
      expect(c.phase, StartupPhase.guest);
      expect(identity.current, isNull);
      await c.leaveGuest();
      expect(c.phase, StartupPhase.locked);
      c.dispose();
    });

    test('creating an identity from guest mode moves the progress', () async {
      final c = controller();
      await c.ensureStarted();
      await c.enterGuest();
      await _writeGuestProgress(await store.directory(), 9);
      await c.createIdentity(displayName: 'Op');
      expect(c.phase, StartupPhase.backupRequired);
      expect(c.migrationError, isNull);
      expect(released, 1, reason: 'guest controller flushed first');
      final dir = await identity.dataDirectory();
      final moved = await FileTrainerStore.inDataDirectory(dir).load();
      expect(moved!.currentLesson, 9);
      expect(await store.hasProgress(), isFalse);
      expect(c.guestMode.value, isFalse);
      c.dispose();
    });

    test('a failed migration keeps guest data and can be retried', () async {
      final c = controller();
      await c.ensureStarted();
      await c.enterGuest();
      final guestDir = await store.directory();
      final file = File(p.join(guestDir, 'training', 'progress.json'));
      await file.create(recursive: true);
      await file.writeAsString('{broken');
      await c.createIdentity(displayName: 'Op');
      expect(c.migrationError, isNotNull);
      expect(await file.exists(), isTrue);
      await _writeGuestProgress(guestDir, 5);
      await c.retryMigration();
      expect(c.migrationError, isNull);
      final moved = await FileTrainerStore.inDataDirectory(
        await identity.dataDirectory(),
      ).load();
      expect(moved!.currentLesson, 5);
      c.dispose();
    });
  });

  group('TrainingControllerHost guest profile', () {
    test('serves the guest controller only while guest mode is on', () async {
      final identity = FakeIdentityService(connectDelay: Duration.zero);
      final mode = ValueNotifier<bool>(false);
      var made = 0;
      final host = TrainingControllerHost(
        identity,
        guestMode: mode,
        guestFactory: () async {
          made++;
          final c = TrainingController(
            progressStore: InMemoryTrainerStore(),
            settingsStore: InMemoryTrainingSettingsStore(),
            profileKey: GuestProfile.profileKey,
          );
          await c.load();
          return c;
        },
      );
      await expectLater(host.controller(), throwsStateError);
      mode.value = true;
      final c = await host.controller();
      expect(c.profileKey, 'guest');
      expect(await host.controller(), same(c));
      mode.value = false;
      await expectLater(host.controller(), throwsStateError);
      expect(made, 1);
      await host.dispose();
    });
  });
}
