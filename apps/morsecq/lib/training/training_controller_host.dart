import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:provider/provider.dart';

import '../ui/learn/learn_scope.dart';
import 'training_controller.dart';

/// One [TrainingController] per identity for the whole app.
///
/// The Learn tab and the "training defaults" page reached from the Me page
/// must share the same controller: two instances writing the same
/// `progress.json` / `settings.json` would silently overwrite each other.
/// The host caches the controller by identity public key and rebuilds it
/// when the identity changes (logout / restore / delete).
class TrainingControllerHost {
  TrainingControllerHost(this._identity) {
    _sub = _identity.identityChanges.listen(_onIdentity);
  }

  final IdentityService _identity;
  StreamSubscription<Identity?>? _sub;
  String? _key;
  Future<TrainingController>? _pending;
  TrainingController? _current;

  /// Resolves (and caches) the controller for the current identity. Matches
  /// `LearnPage.controllerFactory`'s signature so it can be handed straight
  /// to the Learn tab.
  Future<TrainingController> controllerFor(BuildContext context) =>
      controller();

  Future<TrainingController> controller() {
    final identity = _identity.current;
    if (identity == null) {
      return Future<TrainingController>.error(
        StateError('training requires an identity'),
      );
    }
    if (_key == identity.publicKey && _pending != null) return _pending!;
    _dropCurrent();
    _key = identity.publicKey;
    final future = LearnScope.controllerForIdentity(_identity).then((c) {
      _current = c;
      return c;
    });
    _pending = future;
    return future;
  }

  /// Reads the host from the widget tree when one is provided, else falls
  /// back to a fresh per-identity controller (tests, isolated screens).
  static Future<TrainingController> fromContext(BuildContext context) {
    final host = context.read<TrainingControllerHost?>();
    if (host != null) return host.controllerFor(context);
    return LearnScope.controllerForIdentity(context.read<IdentityService>());
  }

  void _onIdentity(Identity? identity) {
    if (identity?.publicKey != _key) _dropCurrent();
  }

  void _dropCurrent() {
    _current?.dispose();
    _current = null;
    _pending = null;
    _key = null;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _dropCurrent();
  }
}
