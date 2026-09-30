import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:morsecq_chat_api/testing.dart';

import 'backend_factory.dart';

/// In-memory services from `package:morsecq_chat_api/testing.dart`. No Tox
/// node, no disk: every launch starts from [IdentityState.none] unless a
/// pre-seeded [identityService] is passed (widget tests do that).
final class FakeBackendFactory extends BackendFactory {
  FakeBackendFactory({
    FakeIdentityService? identityService,
    ChatService Function(IdentityService identity)? chatService,
  }) : _identityService = identityService,
       _chatService = chatService;

  final FakeIdentityService? _identityService;
  final ChatService Function(IdentityService identity)? _chatService;

  @override
  String get label => 'In-memory fake (no network)';

  @override
  bool get isAvailable => true;

  @override
  IdentityService createIdentityService() =>
      _identityService ?? FakeIdentityService();

  @override
  ChatService createChatService(IdentityService identity) =>
      _chatService?.call(identity) ??
      // On a first run there is no identity yet; the fake falls back to its
      // own placeholder key, which only affects the `own_id` check.
      FakeChatService(selfPublicKey: identity.current?.publicKey);

  @override
  Future<void> disposeServices({
    required IdentityService identity,
    required ChatService chat,
  }) async {
    await chat.dispose();
    if (identity is FakeIdentityService) await identity.dispose();
  }
}
