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
      // Follows the identity (first-run creation included) for the own key
      // and the note-to-self conversation.
      FakeChatService(identity: identity);

  @override
  Future<void> disposeServices({
    required IdentityService identity,
    required ChatService chat,
  }) async {
    // Start both teardowns before awaiting either: the identity fake owns a
    // connect timer that must be cancelled synchronously (AppScope.dispose
    // cannot wait for us), and a broadcast close may hand back a root-zone
    // future that FakeAsync never resumes.
    await Future.wait(<Future<void>>[
      chat.dispose(),
      if (identity is FakeIdentityService) identity.dispose(),
    ]);
  }
}
