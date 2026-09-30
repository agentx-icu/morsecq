import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:morsecq_chat_api/morsecq_chat_api.dart';

/// `identity.json`: the identity's durable profile fields.
///
/// Tox savedata also stores the name and status, but reading them requires an
/// initialised Tox instance, and the startup gate must know the Tox ID (to
/// scope preferences and the password verifier) before it decides whether to
/// prompt for a password. So the fields are mirrored here, written on every
/// change, and re-applied to Tox on every connect.
class IdentityRecord {
  const IdentityRecord({
    required this.toxId,
    required this.displayName,
    this.statusMessage = '',
    this.hasPassword = false,
  });

  final String toxId;
  final String displayName;
  final String statusMessage;

  /// Mirror of the password verifier's state, so `inspect()` can answer
  /// `locked` even when the secure store is temporarily unreadable.
  final bool hasPassword;

  Identity toIdentity() => Identity(
        toxId: toxId,
        displayName: displayName,
        statusMessage: statusMessage,
        hasPassword: hasPassword,
      );

  IdentityRecord copyWith({
    String? toxId,
    String? displayName,
    String? statusMessage,
    bool? hasPassword,
  }) =>
      IdentityRecord(
        toxId: toxId ?? this.toxId,
        displayName: displayName ?? this.displayName,
        statusMessage: statusMessage ?? this.statusMessage,
        hasPassword: hasPassword ?? this.hasPassword,
      );

  Map<String, Object?> toJson() => {
        'version': 1,
        'toxId': toxId,
        'displayName': displayName,
        'statusMessage': statusMessage,
        'hasPassword': hasPassword,
      };

  static IdentityRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    final toxId = json['toxId'];
    final name = json['displayName'];
    if (toxId is! String || toxId.isEmpty || name is! String) return null;
    return IdentityRecord(
      toxId: toxId.toUpperCase(),
      displayName: name,
      statusMessage: json['statusMessage'] as String? ?? '',
      hasPassword: json['hasPassword'] as bool? ?? false,
    );
  }

  Uint8List encode() =>
      Uint8List.fromList(utf8.encode(jsonEncode(toJson())));

  static IdentityRecord? decode(Uint8List bytes) {
    try {
      return fromJson(jsonDecode(utf8.decode(bytes)));
    } on FormatException {
      return null;
    }
  }

  static Future<IdentityRecord?> read(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return decode(await file.readAsBytes());
  }

  /// Atomic write: stage to `<path>.new`, fsync, rename over the original.
  Future<void> write(String path) async {
    final target = File(path);
    await target.parent.create(recursive: true);
    final stage = File('$path.new');
    await stage.writeAsBytes(encode(), flush: true);
    await stage.rename(target.path);
  }
}
