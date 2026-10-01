import 'dart:convert';

import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import '../adapters/key_value_store.dart';
import 'message_mapper.dart';

/// Native keeps unanswered friend applications only in process memory.
/// Retain their wording and arrival time until accepted or dismissed locally.
class FriendRequestStore {
  FriendRequestStore(this._store, {required String accountPrefix})
    : _key = 'morsecq_pending_friend_requests_$accountPrefix';

  final KeyValueStore _store;
  final String _key;

  List<FriendRequest> get pending {
    final result = <FriendRequest>[];
    for (final raw in _store.getStringList(_key) ?? const <String>[]) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) continue;
        final key = decoded['publicKey'];
        final message = decoded['message'];
        final timestamp = decoded['receivedAt'];
        if (key is! String ||
            message is! String ||
            timestamp is! int ||
            !ConversationIds.publicKey.hasMatch(key)) {
          continue;
        }
        result.add(
          FriendRequest(
            publicKey: key,
            message: message,
            receivedAt: DateTime.fromMicrosecondsSinceEpoch(timestamp),
          ),
        );
      } on FormatException {
        continue;
      } on ArgumentError {
        // A damaged timestamp must not prevent other requests from loading.
        continue;
      }
    }
    return result;
  }

  Future<void> save(List<FriendRequest> pending) => _store.setStringList(_key, [
    for (final request in pending)
      jsonEncode({
        'publicKey': request.publicKey,
        'message': request.message,
        'receivedAt': request.receivedAt.microsecondsSinceEpoch,
      }),
  ]);
}
