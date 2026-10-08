import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'app_features.dart';
import 'fake_backend_factory.dart';
import 'real_backend_factory.dart';

/// `--dart-define=MORSECQ_FAKE_BACKEND=true` forces the in-memory backend even
/// when the Tox-backed one is available. Handy for UI work without a node.
const bool kForceFakeBackend = bool.fromEnvironment('MORSECQ_FAKE_BACKEND');

/// Builds the services the UI depends on. `main.dart` picks an implementation
/// through [resolveBackendFactory]; widget tests construct a
/// [FakeBackendFactory] directly.
abstract class BackendFactory {
  const BackendFactory();

  /// Short human-readable name, surfaced on the Me → About section so it is
  /// obvious when the app is running without a real Tox node.
  String get label;

  /// False when this factory cannot produce services right now (for the real
  /// backend: [prepare] has not run or failed); [resolveBackendFactory] then
  /// falls back to the fake.
  bool get isAvailable;

  /// Asynchronous setup that must finish before the synchronous factory
  /// methods are usable (directories, preferences, native library). The fake
  /// needs nothing; the real backend builds its Tox node here. Idempotent.
  Future<void> prepare() async {}

  IdentityService createIdentityService();

  /// The chat façade. Receives the identity service because the real backend
  /// shares one Tox node between the two.
  ChatService createChatService(IdentityService identity);

  /// Release everything [createIdentityService] / [createChatService] built.
  Future<void> disposeServices({
    required IdentityService identity,
    required ChatService chat,
  }) => chat.dispose();
}

/// Chooses the backend for this launch: the fake when forced by dart-define
/// or when the Tox backend fails to prepare (e.g. `libtim2tox_ffi` missing in
/// a dev build), otherwise the Tox-backed one. The offline build
/// ([AppFeatures.chat] false) never constructs the Tox backend, so the native
/// library is not loaded (the iOS store build does not even bundle it): its
/// in-memory services are never connected and no identity is created. Must
/// be awaited in `main()` after `WidgetsFlutterBinding.ensureInitialized()`.
Future<BackendFactory> resolveBackendFactory(AppFeatures features) async {
  if (!features.chat) return FakeBackendFactory(label: kOfflineBackendLabel);
  if (kForceFakeBackend) return FakeBackendFactory();
  final real = RealBackendFactory();
  await real.prepare();
  if (real.isAvailable) return real;
  return FakeBackendFactory();
}
