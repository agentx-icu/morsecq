/// Contract between the morsecq UI and the chat backend.
///
/// The UI (apps/morsecq) depends ONLY on this package. The Tim2Tox-backed
/// implementation lives in `packages/morsecq_chat` and is the only package
/// allowed to import `tim2tox_dart` / the Tencent SDK (enforced by
/// tool/import_guard.dart). Tests use in-memory fakes from `testing.dart`.
///
/// Public API contract v0.1: extend freely, do not rename or remove without
/// updating every consumer.
library;

export 'src/backup_media.dart';
export 'src/chat_service.dart';
export 'src/identity_service.dart';
export 'src/message_search.dart';
export 'src/models.dart';
