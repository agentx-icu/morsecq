import 'package:flutter/foundation.dart';

import '../i18n/key_value_store.dart';

/// Whether the user accepted the current privacy policy, persisted in the
/// app's no-backup storage on release Android.
///
/// Only the Android build gates the app on it: the mainland stores (Huawei,
/// Xiaomi, OPPO, vivo, Honor, Tencent) require a first-run accept / decline
/// choice before the app opens. Apple and the desktop platforms keep the
/// policy reachable under Me > Privacy and permissions.
///
/// Bump [currentVersion] when the policy changes materially so a stale
/// acceptance re-prompts on the next launch.
class PrivacyConsent extends ChangeNotifier {
  PrivacyConsent({KeyValueStore? store})
    : _store = store ?? InMemoryKeyValueStore() {
    _accepted = _store.getString(storageKey) == currentVersion;
  }

  /// Settings-store key under which the accepted policy version is kept.
  static const String storageKey = 'privacy.consent';

  /// The policy version this build presents. Increment on a material change.
  static const String currentVersion = '2';

  final KeyValueStore _store;
  bool _accepted = false;
  bool _disposed = false;
  Future<void> _pending = Future<void>.value();

  bool get accepted => _accepted;

  /// Persists the acceptance of [currentVersion], then publishes it. A failed
  /// save leaves [accepted] false and returns the error to the caller.
  Future<void> accept() {
    final operation = _pending.then((_) async {
      if (_accepted) return;
      await _store.setString(storageKey, currentVersion);
      _accepted = true;
      if (!_disposed) notifyListeners();
    });
    _pending = operation.catchError((Object error) {});
    return operation;
  }

  /// Background and quit barriers wait for the acceptance write.
  Future<void> flush() async {
    Future<void> pending;
    do {
      pending = _pending;
      await pending;
    } while (!identical(pending, _pending));
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
