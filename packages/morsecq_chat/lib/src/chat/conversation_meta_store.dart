import '../adapters/key_value_store.dart';

/// Per-identity conversation metadata the UI owns and Tim2Tox does not:
/// pinned conversations, drafts, hidden (deleted) conversations, and the
/// group invites queued for friends that were offline.
///
/// Keys are suffixed with the identity's 16-char account prefix — the same
/// scoping as `Tim2ToxPreferencesAdapter`, so `clear()` on either wipes both.
class ConversationMetaStore {
  ConversationMetaStore(this._store, {required String accountPrefix})
      : _prefix = accountPrefix;

  final KeyValueStore _store;
  final String _prefix;

  static const _kPinned = 'morsecq_pinned_conversations';
  static const _kHidden = 'morsecq_hidden_conversations';
  static const _kDraftPrefix = 'morsecq_draft';
  static const _kQueuedInvites = 'morsecq_queued_group_invites';

  String _scoped(String key) => _prefix.isEmpty ? key : '${key}_$_prefix';

  Set<String> _set(String key) =>
      _store.getStringList(_scoped(key))?.toSet() ?? <String>{};

  Future<void> _setSet(String key, Set<String> value) =>
      _store.setStringList(_scoped(key), value.toList()..sort());

  // ---- pinned --------------------------------------------------------------

  Set<String> get pinned => _set(_kPinned);

  bool isPinned(String conversationId) => pinned.contains(conversationId);

  Future<void> setPinned(String conversationId, bool value) {
    final s = pinned;
    if (value) {
      s.add(conversationId);
    } else {
      s.remove(conversationId);
    }
    return _setSet(_kPinned, s);
  }

  // ---- hidden (deleted until the next message) ------------------------------

  Set<String> get hidden => _set(_kHidden);

  Future<void> hide(String conversationId) =>
      _setSet(_kHidden, hidden..add(conversationId));

  Future<void> unhide(String conversationId) {
    final s = hidden;
    if (!s.remove(conversationId)) return Future<void>.value();
    return _setSet(_kHidden, s);
  }

  // ---- drafts ---------------------------------------------------------------

  String draft(String conversationId) =>
      _store.getString(_scoped('${_kDraftPrefix}_$conversationId')) ?? '';

  Future<void> setDraft(String conversationId, String text) {
    final key = _scoped('${_kDraftPrefix}_$conversationId');
    return text.isEmpty ? _store.remove(key) : _store.setString(key, text);
  }

  // ---- queued group invites (friend was offline) ----------------------------

  /// `groupId\tfriendPublicKey` entries.
  Set<String> get queuedInvites => _set(_kQueuedInvites);

  Future<void> queueInvite(String groupId, String friendPublicKey) =>
      _setSet(_kQueuedInvites, queuedInvites..add('$groupId\t$friendPublicKey'));

  Future<void> dequeueInvite(String groupId, String friendPublicKey) {
    final s = queuedInvites;
    if (!s.remove('$groupId\t$friendPublicKey')) return Future<void>.value();
    return _setSet(_kQueuedInvites, s);
  }

  /// Group ids with an invite waiting for [friendPublicKey].
  List<String> queuedGroupsFor(String friendPublicKey) => [
        for (final e in queuedInvites)
          if (e.endsWith('\t$friendPublicKey')) e.substring(0, e.indexOf('\t')),
      ];

  /// Forgets everything about one conversation.
  Future<void> forget(String conversationId) async {
    await setPinned(conversationId, false);
    await setDraft(conversationId, '');
    await unhide(conversationId);
  }

  /// Removes every key of this identity.
  Future<void> clear() async {
    if (_prefix.isEmpty) return;
    final suffix = '_$_prefix';
    for (final k in _store.keys().where((k) => k.endsWith(suffix)).toList()) {
      await _store.remove(k);
    }
  }
}
