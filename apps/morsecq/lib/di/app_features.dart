/// Build-time product features (`--dart-define`).
///
/// `MORSECQ_CHAT=false` builds the App Store distribution for iOS: a purely
/// offline Morse trainer. No identity is created, nothing connects to the
/// Tox network, and the Chat / Groups destinations, the community-guidelines
/// gate, notifications and the connection banner do not exist. Learning runs
/// on the local learning profile (the guest profile of chat builds). Every
/// other build keeps chat. See `doc/release/APP_STORE.md`.
class AppFeatures {
  const AppFeatures({this.chat = true});

  /// Chat over Tox: identity, contacts, groups, notifications.
  final bool chat;

  /// What this binary was built with.
  static const AppFeatures fromEnvironment = AppFeatures(
    chat: bool.fromEnvironment('MORSECQ_CHAT', defaultValue: true),
  );
}
