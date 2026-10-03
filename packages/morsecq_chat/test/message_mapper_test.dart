import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq_chat/src/chat/message_mapper.dart';
import 'package:morsecq_chat/src/chat/pending_message_status.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:tim2tox_dart/models/chat_message.dart' as t2t;
import 'package:tim2tox_dart/utils/offline_message_queue_persistence.dart';

void main() {
  test('a failed queued send maps to failed, even while still queued', () {
    final queue = OfflineMessageQueuePersistence();
    final row = t2t.ChatMessage(
      msgID: 'f1',
      fromUserId: 'me',
      text: 'CQ',
      timestamp: DateTime.utc(2026),
      isSelf: true,
      isFailed: true,
    );
    queue.setCache({
      'PEER': [
        (
          kind: 'text',
          text: 'CQ',
          filePath: null,
          fileName: null,
          timestamp: DateTime.utc(2026),
          msgID: 'f1',
          cloudCustomData: null,
          contentKind: t2t.ChatMessageContentKind.normal,
        ),
      ],
    });
    final mapper = MessageMapper(
      selfKey: 'SELF',
      selfName: 'me',
      nameOf: (_) => null,
      isQueued: PendingMessageStatus(queue).isQueued,
    );
    expect(
      mapper.map(row, conversationId: 'c2c_PEER').status,
      MessageStatus.failed,
    );
  });

  test('rows without a native id get distinct ids per sender', () {
    final at = DateTime.utc(2026, 10, 3);
    t2t.ChatMessage row(String from) => t2t.ChatMessage(
      fromUserId: from,
      text: 'CQ',
      timestamp: at,
      isSelf: false,
      groupId: 'tox_1',
    );
    final mapper = MessageMapper(
      selfKey: 'SELF',
      selfName: 'me',
      nameOf: (_) => null,
    );
    final a = mapper.map(row('A' * 64), conversationId: 'group_tox_1');
    final b = mapper.map(row('B' * 64), conversationId: 'group_tox_1');
    expect(a.id, isNot(b.id));
    // Deterministic: the same row maps to the same id every time (and so
    // across restarts, unlike String.hashCode).
    expect(mapper.map(row('A' * 64), conversationId: 'group_tox_1').id, a.id);
    final action = t2t.ChatMessage(
      fromUserId: 'A' * 64,
      text: 'CQ',
      timestamp: at,
      isSelf: false,
      groupId: 'tox_1',
      contentKind: t2t.ChatMessageContentKind.action,
    );
    expect(MessageMapper.fallbackId(action), isNot(a.id));
  });

  test(
    'durable queue restores pending status for history and conversations',
    () {
      final queue = OfflineMessageQueuePersistence();
      final now = DateTime.utc(2026);
      final row = t2t.ChatMessage(
        msgID: 'pending-id',
        fromUserId: 'me',
        text: 'CQ',
        timestamp: now,
        isSelf: true,
        isPending: false, // Upstream normalizes this on history reload.
      );
      final item = (
        kind: 'text',
        text: 'CQ',
        filePath: null,
        fileName: null,
        timestamp: now,
        msgID: 'pending-id',
        cloudCustomData: null,
        contentKind: t2t.ChatMessageContentKind.normal,
      );
      queue.setCache({
        'PEER': [item],
        'group:tox_1': [item],
      });
      final mapper = MessageMapper(
        selfKey: 'SELF',
        selfName: 'me',
        nameOf: (_) => null,
        isQueued: PendingMessageStatus(queue).isQueued,
      );
      expect(
        mapper.map(row, conversationId: 'c2c_PEER').status,
        MessageStatus.pending,
      );
      expect(
        mapper.map(row, conversationId: 'group_tox_1').status,
        MessageStatus.pending,
      );
      expect(
        mapper.map(row, conversationId: 'c2c_OTHER').status,
        MessageStatus.sent,
      );
      queue.setCache({});
      expect(
        mapper.map(row, conversationId: 'c2c_PEER').status,
        MessageStatus.sent,
      );
    },
  );
}
