import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../../training/atomic_json_file.dart';

/// One bookmarked message: a reference only (profile is implied by the
/// file's directory). Unlike a training material it holds no copy of the
/// text, so clearing the conversation's history removes it too.
@immutable
final class MessageBookmark {
  const MessageBookmark({
    required this.conversationId,
    required this.messageId,
    required this.timestamp,
  });

  final String conversationId;
  final String messageId;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'conversationId': conversationId,
    'messageId': messageId,
    'timestamp': timestamp.toUtc().toIso8601String(),
  };

  static MessageBookmark? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final c = json['conversationId'];
    final m = json['messageId'];
    final t = DateTime.tryParse(json['timestamp'] as String? ?? '');
    if (c is! String || m is! String || t == null) return null;
    return MessageBookmark(conversationId: c, messageId: m, timestamp: t);
  }
}

/// Resolves the bookmark store of the current profile (provided by the app
/// scope, which knows the identity's data directory).
typedef BookmarksResolver = Future<MessageBookmarks> Function();

/// Local message bookmarks of one profile (functional spec §10.1), in
/// `<dataDirectory>/chat/bookmarks.json`. Writes are serialised and atomic.
class MessageBookmarks extends ChangeNotifier {
  MessageBookmarks._(this._file);

  /// Store for [dataDirectory]; one instance per directory so every screen
  /// of a profile sees the same state, and profiles never share one.
  static MessageBookmarks forDirectory(String dataDirectory) =>
      _instances.putIfAbsent(
        dataDirectory,
        () => MessageBookmarks._(
          AtomicJsonFile(File(p.join(dataDirectory, 'chat', 'bookmarks.json'))),
        ),
      );

  /// In-memory store for tests and stub identities.
  @visibleForTesting
  factory MessageBookmarks.memory() => MessageBookmarks._(null);

  static final Map<String, MessageBookmarks> _instances = {};

  /// In-memory fallbacks, one per chat service (so isolated screens and
  /// tests never share bookmarks across sessions).
  static final Expando<MessageBookmarks> _fallbacks = Expando();

  /// The current profile's loaded store; an in-memory one when the app
  /// provides no resolver (isolated screens, tests).
  static Future<MessageBookmarks> of(BuildContext context) async {
    BookmarksResolver? resolve;
    try {
      resolve = context.read<BookmarksResolver?>();
    } on ProviderNotFoundException {
      resolve = null;
    }
    final MessageBookmarks store;
    if (resolve != null) {
      store = await resolve();
    } else {
      Object key;
      try {
        key = context.read<ChatService>();
      } on ProviderNotFoundException {
        key = context;
      }
      store = _fallbacks[key] ??= MessageBookmarks._(null);
    }
    await store.load();
    return store;
  }

  final AtomicJsonFile? _file;
  final List<MessageBookmark> _items = <MessageBookmark>[];
  Future<void>? _loading;
  Future<void> _writes = Future<void>.value();

  List<MessageBookmark> get items => List.unmodifiable(_items);

  Future<void> load() =>
      _file == null ? Future<void>.value() : _loading ??= _load();

  Future<void> _load() async {
    final file = _file;
    if (file == null) return;
    try {
      final json = await file.read();
      final list = json?['bookmarks'];
      if (list is List) {
        _items
          ..clear()
          ..addAll(
            list.map(MessageBookmark.fromJson).whereType<MessageBookmark>(),
          );
      }
    } on Object {
      // An unreadable file starts empty; the next write replaces it.
    }
    notifyListeners();
  }

  bool contains(String conversationId, String messageId) => _items.any(
    (b) => b.conversationId == conversationId && b.messageId == messageId,
  );

  List<MessageBookmark> inConversation(String conversationId) =>
      _items.where((b) => b.conversationId == conversationId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  Future<void> toggle(String conversationId, String messageId, DateTime at) {
    if (contains(conversationId, messageId)) {
      _items.removeWhere(
        (b) => b.conversationId == conversationId && b.messageId == messageId,
      );
    } else {
      _items.add(
        MessageBookmark(
          conversationId: conversationId,
          messageId: messageId,
          timestamp: at,
        ),
      );
    }
    return _save();
  }

  /// Clearing a conversation's history invalidates its bookmarks.
  Future<void> removeConversation(String conversationId) {
    final before = _items.length;
    _items.removeWhere((b) => b.conversationId == conversationId);
    return before == _items.length ? Future<void>.value() : _save();
  }

  /// Drops bookmarks of messages that no longer exist.
  Future<void> removeMissing(String conversationId, Set<String> missing) {
    final before = _items.length;
    _items.removeWhere(
      (b) =>
          b.conversationId == conversationId && missing.contains(b.messageId),
    );
    return before == _items.length ? Future<void>.value() : _save();
  }

  Future<void> _save() {
    notifyListeners();
    final file = _file;
    if (file == null) return Future<void>.value();
    final snapshot = <String, Object?>{
      'v': 1,
      'bookmarks': [for (final b in _items) b.toJson()],
    };
    final write = _writes.then((_) => file.write(snapshot));
    _writes = write.catchError((Object _) {});
    return write;
  }
}
