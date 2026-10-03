import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq_chat/src/chat/message_mapper.dart';
import 'package:morsecq_chat/src/chat/pending_message_status.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:tim2tox_dart/models/chat_message.dart' as t2t;
import 'package:tim2tox_dart/utils/offline_message_queue_persistence.dart';

void main() {
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

  test('failed and cancelled rows map to their own statuses', () {
    final now = DateTime.utc(2026);
    t2t.ChatMessage row({bool failed = false, bool cancelled = false}) =>
        t2t.ChatMessage(
          msgID: 'id',
          fromUserId: 'me',
          text: 'CQ',
          timestamp: now,
          isSelf: true,
          isFailed: failed,
          isCancelled: cancelled,
        );
    expect(MessageMapper.statusOf(row(failed: true)), MessageStatus.failed);
    expect(
      MessageMapper.statusOf(row(cancelled: true)),
      MessageStatus.cancelled,
    );
    // A cancelled row whose queue item outlived it (a crash between the two
    // writes) is still cancelled: the drain drops that item.
    final mapper = MessageMapper(
      selfKey: 'SELF',
      selfName: 'me',
      nameOf: (_) => null,
      isQueued: (_, _) => true,
    );
    expect(
      mapper.map(row(cancelled: true), conversationId: 'c2c_PEER').status,
      MessageStatus.cancelled,
    );
  });
}
