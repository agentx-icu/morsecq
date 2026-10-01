import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq_chat/morsecq_chat.dart';
import 'package:morsecq_chat/src/chat/friend_request_store.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';

import 'helpers/fakes.dart';

void main() {
  test(
    'malformed request timestamps do not hide valid persisted requests',
    () async {
      final store = MemoryKeyValueStore();
      final requests = FriendRequestStore(store, accountPrefix: 'SELF');
      await requests.save([
        FriendRequest(
          publicKey: kPeerKey,
          message: 'CQ',
          receivedAt: DateTime.utc(2026),
        ),
      ]);
      const key = 'morsecq_pending_friend_requests_SELF';
      await store.setStringList(key, [
        ...store.getStringList(key)!,
        jsonEncode({
          'publicKey': kSelfKey,
          'message': 'bad',
          'receivedAt': 9223372036854775807,
        }),
      ]);
      expect(requests.pending.single.message, 'CQ');
    },
  );
}
