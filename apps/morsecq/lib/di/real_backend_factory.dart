import 'package:flutter/foundation.dart';
import 'package:morsecq_chat/morsecq_chat.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'backend_factory.dart';

/// Tox-backed services from `packages/morsecq_chat`.
///
/// This file is the ONLY place in the app that imports `morsecq_chat`
/// (everything else depends on the `morsecq_chat_api` contract). Building the
/// backend is asynchronous (application-support directory, shared
/// preferences, native library lookup), so [prepare] runs in `main()` before
/// the widget tree exists; the synchronous factory methods then hand out the
/// services the backend already holds.
final class RealBackendFactory extends BackendFactory {
  RealBackendFactory({ChatLogger? logger})
    : _logger = logger ?? CallbackChatLogger(_debugPrintRecord);

  final ChatLogger _logger;
  MorsecqChatBackend? _backend;

  /// Set when [prepare] failed; `resolveBackendFactory` falls back to the
  /// fake and surfaces this on the Me → About section through the label.
  Object? lastError;

  @override
  String get label => 'Tox (Tim2Tox)';

  @override
  bool get isAvailable => _backend != null;

  @override
  Future<void> prepare() async {
    if (_backend != null) return;
    try {
      _backend = await MorsecqChatBackend.create(logger: _logger);
    } catch (error, stack) {
      lastError = error;
      _logger.error('Tox backend unavailable', error, stack);
    }
  }

  MorsecqChatBackend get _ready {
    final backend = _backend;
    if (backend == null) {
      throw StateError(
        'RealBackendFactory.prepare() has not completed successfully',
      );
    }
    return backend;
  }

  @override
  IdentityService createIdentityService() => _ready.identity;

  @override
  ChatService createChatService(IdentityService identity) => _ready.chat;

  @override
  Future<void> disposeServices({
    required IdentityService identity,
    required ChatService chat,
  }) async {
    final backend = _backend;
    _backend = null;
    await backend?.dispose();
  }

  static void _debugPrintRecord(ChatLogRecord record) {
    if (!kDebugMode) return;
    final suffix = record.error == null ? '' : ' — ${record.error}';
    debugPrint('[chat/${record.level.name}] ${record.message}$suffix');
  }
}
