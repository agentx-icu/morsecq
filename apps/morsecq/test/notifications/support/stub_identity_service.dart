import 'dart:async';

import 'package:morsecq_chat_api/morsecq_chat_api.dart';

/// Minimal [IdentityService] for lifecycle / banner tests: counts
/// `connect()` calls and lets the test drive [connectionStatus] directly.
/// Everything else is unreachable and falls through to [noSuchMethod].
final class StubIdentityService implements IdentityService {
  StubIdentityService({Identity? identity, this.connectError})
    : _current = identity ?? Identity(toxId: 'F' * 76, displayName: 'Me');

  Identity? _current;
  int connectCalls = 0;

  /// When set, `connect()` throws it.
  Object? connectError;

  ConnectionStatus _status = ConnectionStatus.offline;
  final StreamController<ConnectionStatus> _statuses =
      StreamController<ConnectionStatus>.broadcast();

  void setStatus(ConnectionStatus status) {
    _status = status;
    _statuses.add(status);
  }

  /// Simulates "no identity loaded yet".
  void clearIdentity() => _current = null;

  Future<void> dispose() => _statuses.close();

  @override
  Identity? get current => _current;

  @override
  ConnectionStatus get connectionStatus => _status;

  @override
  Stream<ConnectionStatus> get connectionChanges => _statuses.stream;

  @override
  Future<void> connect() async {
    connectCalls++;
    final Object? error = connectError;
    if (error != null) throw error;
  }

  @override
  Future<void> disconnect() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not stubbed');
}
