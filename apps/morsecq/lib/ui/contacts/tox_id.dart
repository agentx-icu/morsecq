import '../chat/chat_strings.dart';

/// Tox ID = 32-byte public key + 4-byte nospam + 2-byte checksum, hex.
const int kToxIdLength = 76;

/// NGC chat id = 32-byte public key, hex.
const int kChatIdLength = 64;

final RegExp _hex = RegExp(r'^[0-9A-Fa-f]+$');

/// Strips whitespace and a `tox:` URI prefix; upper-cases the hex.
String normalizeToxId(String raw) {
  String s = raw.trim();
  if (s.toLowerCase().startsWith('tox:')) s = s.substring(4);
  return s.replaceAll(RegExp(r'\s+'), '').toUpperCase();
}

bool isValidToxId(String value) =>
    value.length == kToxIdLength && _hex.hasMatch(value);

bool isValidChatId(String value) =>
    value.length == kChatIdLength && _hex.hasMatch(value);

/// Form-field validator for the add-friend sheet: null when valid, else the
/// message to show. [ownToxId] (when known) rejects adding yourself before a
/// round-trip to the backend.
String? validateToxIdInput(String? raw, {String? ownToxId}) {
  final String id = normalizeToxId(raw ?? '');
  if (!isValidToxId(id)) return ChatStrings.toxIdInvalid;
  if (ownToxId != null &&
      id.substring(0, kChatIdLength) ==
          normalizeToxId(ownToxId).substring(0, kChatIdLength)) {
    return ChatStrings.toxIdOwn;
  }
  return null;
}

String? validateChatIdInput(String? raw) =>
    isValidChatId(normalizeToxId(raw ?? '')) ? null : ChatStrings.chatIdInvalid;

/// `ABCD1234…` for lists and avatars.
String shortKey(String key, {int length = 8}) =>
    key.length > length ? '${key.substring(0, length)}…' : key;
