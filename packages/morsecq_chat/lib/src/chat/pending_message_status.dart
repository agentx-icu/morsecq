import 'package:tim2tox_dart/models/chat_message.dart';
import 'package:tim2tox_dart/utils/offline_message_queue_persistence.dart';

import 'message_mapper.dart';

/// The durable outbox is authoritative after history reload: Tim2Tox clears
/// historical `isPending` flags on load even when their queue items survive.
class PendingMessageStatus {
  const PendingMessageStatus(this.queue);

  final OfflineMessageQueuePersistence queue;

  bool isQueued(ChatMessage message, String conversationId) {
    if (!message.isSelf) return false;
    final peer = ConversationIds.peerOf(conversationId);
    final key = ConversationIds.isGroup(conversationId) ? 'group:$peer' : peer;
    return queue.getMessages(key).any((item) {
      final id = item.msgID;
      if (id != null && id.isNotEmpty) return message.msgID == id;
      // Older queues predate durable message ids; match their shared enqueue
      // timestamp and content within this conversation only.
      return item.timestamp.millisecondsSinceEpoch ==
              message.timestamp.millisecondsSinceEpoch &&
          item.text == message.text &&
          item.contentKind == message.contentKind;
    });
  }
}
