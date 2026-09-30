import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/training/training_controller.dart';
import 'package:morsecq/training/training_controller_host.dart';
import 'package:morsecq/training/training_settings_store.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

/// Just enough [IdentityService] for the host: a switchable current identity
/// and its change stream. Everything else throws through [noSuchMethod].
final class _SwitchableIdentity implements IdentityService {
  Identity? _current;
  final StreamController<Identity?> _changes =
      StreamController<Identity?>.broadcast(sync: true);

  @override
  Identity? get current => _current;

  @override
  Stream<Identity?> get identityChanges => _changes.stream;

  void switchTo(Identity? identity) {
    _current = identity;
    _changes.add(identity);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not stubbed');
}

Identity _identity(String key) =>
    Identity(toxId: key.padRight(76, '0'), displayName: key);

TrainingController _controller() => TrainingController(
      progressStore: InMemoryTrainerStore(),
      settingsStore: InMemoryTrainingSettingsStore(),
    );

bool _isDisposed(TrainingController c) {
  try {
    c.addListener(() {});
    return false;
  } on FlutterError {
    return true;
  }
}

void main() {
  late _SwitchableIdentity identity;
  late List<Completer<TrainingController>> loads;
  late TrainingControllerHost host;

  setUp(() {
    identity = _SwitchableIdentity();
    loads = [];
    host = TrainingControllerHost(
      identity,
      factory: (_) {
        final c = Completer<TrainingController>();
        loads.add(c);
        return c.future;
      },
    );
  });

  test('caches one controller per identity and shares it', () async {
    identity.switchTo(_identity('A'));
    final f1 = host.controller();
    final f2 = host.controller();
    expect(loads, hasLength(1));
    final c = _controller();
    loads.single.complete(c);
    expect(await f1, same(c));
    expect(await f2, same(c));
    expect(_isDisposed(c), isFalse);
    await host.dispose();
    expect(_isDisposed(c), isTrue, reason: 'the host owns it');
  });

  test('a load that completes after dispose is disposed, not cached',
      () async {
    identity.switchTo(_identity('A'));
    final pending = host.controller();
    await host.dispose();
    final late = _controller();
    loads.single.complete(late);
    await expectLater(pending, throwsStateError);
    expect(_isDisposed(late), isTrue, reason: 'nobody else owns it');
    await expectLater(host.controller(), throwsStateError);
  });

  test('a load for the previous identity is disposed when the identity '
      'switches during it', () async {
    identity.switchTo(_identity('A'));
    final forA = host.controller();
    identity.switchTo(_identity('B'));
    final forB = host.controller();
    expect(loads, hasLength(2));

    final staleA = _controller();
    loads.first.complete(staleA);
    await expectLater(forA, throwsStateError);
    expect(_isDisposed(staleA), isTrue);

    final freshB = _controller();
    loads.last.complete(freshB);
    expect(await forB, same(freshB));
    expect(_isDisposed(freshB), isFalse);
    // The cache holds B, not the stale A.
    expect(await host.controller(), same(freshB));
    await host.dispose();
    expect(_isDisposed(freshB), isTrue);
  });

  test('identity change after caching rebuilds on the next request',
      () async {
    identity.switchTo(_identity('A'));
    final forA = host.controller();
    final a = _controller();
    loads.single.complete(a);
    expect(await forA, same(a));

    identity.switchTo(_identity('B'));
    expect(_isDisposed(a), isTrue);
    final forB = host.controller();
    expect(loads, hasLength(2));
    final b = _controller();
    loads.last.complete(b);
    expect(await forB, same(b));
    await host.dispose();
  });

  test('no identity is an error', () async {
    await expectLater(host.controller(), throwsStateError);
    expect(loads, isEmpty);
    await host.dispose();
  });
}
