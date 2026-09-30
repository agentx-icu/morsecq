[简体中文](./README.zh-CN.md)

# morsecq_chat

Tim2Tox-backed implementation of [`morsecq_chat_api`](../morsecq_chat_api):
identity, friends, conversations, plain-text messages and groups over the Tox
P2P network. **This is the only package in the workspace allowed to import
`tim2tox_dart` or the Tencent Cloud Chat SDK** (`tool/import_guard.dart`
enforces it). The app talks to the contract; it touches this package only to
build the backend:

```dart
final backend = await MorsecqChatBackend.create(logger: CallbackChatLogger(myLog));
switch (await backend.identity.inspect()) {
  case IdentityState.none:   await backend.identity.create(displayName: 'W1AW', password: pw);
  case IdentityState.locked: await backend.identity.unlock(pw);
  case IdentityState.ready:  await backend.identity.open();
}
await backend.identity.connect();          // init → login → startPolling
backend.chat.conversationChanges.listen(...);
```

## Architecture (plan §3.2 "B variant")

```
apps/morsecq ──► morsecq_chat_api (contract) ◄── morsecq_chat
                                                  │  MorsecqChatBackend
                                                  ├─ Tim2ToxIdentityService   identity.json, tox_profile.tox, password verifier, backup
                                                  ├─ Tim2ToxChatService        friends / conversations / messages / groups (+ parts)
                                                  ├─ Tim2ToxEngine            one FfiChatService per connected session
                                                  ├─ adapters/                Tim2Tox host interfaces (prefs, bootstrap, scratch, logger)
                                                  └─ native/                  setNativeLibraryName('tim2tox_ffi')
                                                          │
                                third_party/tim2tox/dart  │  FfiChatService (Dart)  ──ffi──►  libtim2tox_ffi (c-toxcore, --no-toxav)
```

**One data path.** Unlike toxee's hybrid runtime, morsecq installs neither
`Tim2ToxSdkPlatform` nor the UIKit and never calls `TIMManager.initSDK`.
Everything flows `FfiChatService` → `Tim2ToxFfi` → `libtim2tox_ffi`, and the
service listens to `FfiChatService.messages` / polls `getFriendList`,
`getFriendApplications`, `knownGroups`, `getPendingGroupInvites` every
`pollInterval` (3 s). Because no `Tim2ToxSdkPlatform` is installed, the three
callbacks toxee documents as "silently dropped" (`clearHistoryMessage`,
`groupQuitNotification`, `groupChatIdStored`) are compensated by the pull-side
`syncGroupIdentitiesFromNative()`, which `Tim2ToxEngine.start` awaits after
`startPolling`.

### Identity lifecycle

| State | Meaning | Transition |
|---|---|---|
| `none` | no `tox_profile.tox` | `create()` (bootstrap instance mints the Tox ID, then is disposed) |
| `locked` | verifier holds a password **or** the file is Tox-encrypted | `unlock(pw)` |
| `ready` | plain profile, or unlocked this run | `connect()` / `disconnect()` |

Encryption at rest mirrors toxee's `AccountService`: with a password, the
profile is encrypted whenever the engine is **stopped** and plaintext while it
**runs** (Tox rewrites the savedata as it runs). `connect()` decrypts right
before `init`, `disconnect()` re-encrypts right after `uninit`. The PBKDF2-
HMAC-SHA256 verifier (`flutter_secure_storage`: Keychain / Keystore /
libsecret / DPAPI) is the authority on "has a password" — the file's
encryption state cannot be, since a crash mid-session leaves it plaintext.
`tox_pass_decrypt` is the second factor and the fallback for imported profiles.

On disk (`IdentityPaths`, under the platform application-support directory):

```
morsecq/identity/
  identity.json              display name, status, Tox ID, hasPassword
  profile/tox_profile.tox    Tox savedata
  data/chat_history/  data/offline_message_queue.json  data/file_recv/  data/avatars/  data/scratch/
  training/                  IdentityService.dataDirectory() — other modules' per-identity state
```

### Backup format (`exportBackup` / `importBackup`)

`BackupContainer`: a dependency-free, length-prefixed archive.

```
"MCQB" | version u8 = 1 | flags u8 (bit0: profile encrypted) | count u32
entry*: pathLen u16 | path (UTF-8, '/'-separated) | size u64 | bytes
```

Entries: `identity.json`, `tox_profile.tox` (encrypted with the identity
password when one is set), `training/<relative path>` for every file under
`dataDirectory()`. Paths are validated on decode (no `..`, no absolute paths,
no backslashes). `importBackup` replaces the current identity; an encrypted
profile requires the password (`wrong_password` otherwise) and carries it
over into the verifier so the restored identity unlocks with the same one.

### Messages

- `sendText` → `sendTextWithResult` (C2C) / `sendGroupTextWithResult` (group).
  Texts over `maxMessageBytes` (**1322**, `TOX_MAX_MESSAGE_LENGTH − 50`) throw
  `message_too_long`: Tim2Tox would fragment them into separate messages.
- Tim2Tox queues sends to an offline friend / not-yet-connected group and
  returns a `pending` row; the row is re-emitted on `messageEvents` as `sent`
  when the drain succeeds. Tim2Tox does not carry a distinct failure flag on
  this path (`_markPendingItemFailed` also flips `isPending: false`), so
  `failed` is not produced today — tracked for the upstream `tim2tox_core` split.
- `cloudCustomData` is **local only** in Tim2Tox (never sent over Tox); morsecq
  does not use it (plan §5.2 layer 1 is plain text).
- Conversations are derived: history ids ∪ friends ∪ groups, minus hidden
  (deleted) ones; unread from Tim2Tox's read barrier; pinned/draft/hidden from
  `ConversationMetaStore` (account-scoped keys in `shared_preferences`).

### What still goes through the Tencent bindings, and why

`FfiChatService` compiles against the (patched) Tencent SDK, and a few
operations reach Tox only through its `Dart*` compat exports, which
`libtim2tox_ffi` implements. `NativeLibrarySetup.ensure()` — called by
`MorsecqChatBackend.create()` before the first `FfiChatService` — runs
`setNativeLibraryName('tim2tox_ffi')` exactly as toxee's `LoggingBootstrap`
does, so those bindings load our library instead of `dart_native_imsdk`.

| Operation | Path | Note |
|---|---|---|
| `leaveGroup` | `FfiChatService.quitGroup` → `NativeLibraryManager.bindings.DartQuitGroup` | as in toxee |
| `groupMembers` | `GroupBindings.members` → `DartGetGroupMemberList` | same call tim2tox's platform makes; deduped by public key |
| `inviteToGroup` (friend online) | `GroupBindings.invite` → `DartInviteUserToGroup` | bypasses `TIMGroupManager`, whose wrapper refuses without `TIMManager.initSDK` |
| `inviteToGroup` (friend offline) | queued in `ConversationMetaStore`, sent when the friend comes online | Tim2Tox's own replay uses `TIMGroupManager` and therefore needs `initSDK`; ours does not |

`TIMManager.initSDK` is deliberately never called: it installs the SDK's own
native message listeners — the second inbound path toxee needs
`BinaryReplacementHistoryHook` to reconcile.

### `tencent_cloud_chat_common` stub

`tim2tox_dart`'s pubspec requires `tencent_cloud_chat_common` (a UIKit widget
package with a large plugin tree: TUICore, hive, audioplayers, …). Only
`Tim2ToxSdkPlatform` imports it, and nothing morsecq compiles reaches that
file. `third_party/stubs/tencent_cloud_chat_common` is an empty package that
satisfies pub; the root `pubspec_overrides.yaml` points at it. If a future
tim2tox change makes `FfiChatService` reach `Tim2ToxSdkPlatform`, compilation
fails loudly (missing imports) rather than silently pulling the UIKit in.
Remove the stub when upstream ships a UIKit-free `tim2tox_core` (plan §3.2 D).

## Bootstrap

```bash
export PATH=/home/user/flutter/bin:$PATH
dart run tool/bootstrap_deps.dart     # submodule → vendor SDK → patches → root pubspec_overrides.yaml
dart pub get                          # workspace root
flutter analyze packages/morsecq_chat
flutter test packages/morsecq_chat    # needs-native test skips itself without the library
dart run tool/bootstrap_deps.dart --offline-check-only   # CI: prove the tree matches the lock
```

`tool/bootstrap_deps.dart` (ported from toxee, UIKit branches removed):

1. `git submodule sync` / `update --init -- third_party/tim2tox` (pinned to
   the same commit toxee uses, `9d4245a`; nested c-toxcore submodules are not
   initialised — only the native build needs them).
2. Downloads `tencent_cloud_chat_sdk` per
   `third_party/tim2tox/tool/tencent_cloud_chat_sdk.lock.json` (8.9.7540+3,
   SHA-256 verified) into `third_party/tencent_cloud_chat_sdk/`.
3. Applies tim2tox's 22-patch series with tim2tox's own `apply_sdk_patches.dart`
   (patch 0001 adds `setNativeLibraryName`).
4. Writes the **root** `pubspec_overrides.yaml` (`tim2tox_dart`,
   `tencent_cloud_chat_sdk`, `tencent_cloud_chat_common` → paths) — a pub
   workspace reads overrides at the root only. State for `--offline-check-only`
   lives in `third_party/.vendor_state.json`.

Generated, never committed: `third_party/tencent_cloud_chat_sdk/`,
`third_party/.vendor_state.json` (both in `third_party/.gitignore`) and the
root `pubspec_overrides.yaml` (add it to the root `.gitignore`).

## Native library prerequisites

The Dart package compiles without it, but every runtime path needs
`libtim2tox_ffi` built **without ToxAV** (morsecq has no calls):

```bash
# from a toxee checkout with tool/ci/build_tim2tox.sh, or tim2tox's own build.sh
tool/ci/build_tim2tox.sh --no-toxav          # Linux x86_64 / Windows x64 / macOS x86_64+arm64 / Android arm64-v8a / iOS arm64
```

| Platform | Artefact and where `Tim2ToxFfi.open()` looks | Minimum OS |
|---|---|---|
| macOS | `libtim2tox_ffi.dylib` next to the executable, `../Frameworks/`, or `tim2tox/build/ffi/` | 10.15 |
| Linux | `libtim2tox_ffi.so` next to the executable or `../lib/` | — |
| Windows | `tim2tox_ffi.dll` next to the executable or `../lib/` | 10 |
| Android | `libtim2tox_ffi.so` in `jniLibs/<abi>/` (System.loadLibrary) | API 21 |
| iOS | `tim2tox_ffi.framework` embedded in the bundle | 13 |

Dev loops can pin an absolute path with
`MorsecqChatBackend.create(nativeLibraryPathOverride: ...)` (must be set before
the library is first opened). Mobile parity: the whole package is shared Dart;
nothing here is desktop-specific. `flutter_secure_storage` 11.x is used
because its Windows plugin depends on `win32 ^6`, the major the app's
`share_plus` needs.

## Tests

`flutter test packages/morsecq_chat` runs without the native library:

- `identity_service_test.dart` — inspect/create/unlock/open state machine,
  encryption-at-rest around connect/disconnect, verifier-vs-file authority,
  changePassword, backup export/import round trip, deleteIdentity (fake
  `ProfileCrypto`, in-memory secure store, fake `ChatEngine`).
- `chat_service_test.dart` — the real `FfiChatService` over a `Tim2ToxFfi`
  binding fake (Flutter test binding + mocked `path_provider` channel, as in
  toxee): offline send → `pending`, inbound → `received` + unread, conversation
  derivation/sorting, pinned/draft/delete persistence, group mapping, invite
  queueing, validation errors, session detach.
- `backup_container_test.dart`, `prefs_adapter_test.dart`,
  `password_verifier_test.dart` (RFC 7914 PBKDF2 vectors).

### Native smoke test (`@Tags(['needs-native'])`)

`test/native_smoke_test.dart` drives the real library single-process: create
identity → connect → reach the DHT → queue a send to an offline peer → create /
list members / leave a group (`DartGetGroupMemberList`, `DartQuitGroup`) →
disconnect. It skips itself when the library cannot be opened; in CI exclude it
explicitly with `flutter test --exclude-tags=needs-native`. On a dev machine:

```bash
tool/ci/build_tim2tox.sh --no-toxav                       # in toxee (or tim2tox build.sh)
TIM2TOX_FFI_LIB=/abs/path/to/libtim2tox_ffi.so \
  flutter test packages/morsecq_chat/test/native_smoke_test.dart
```

A two-peer exchange needs two processes (Tim2Tox's default singleton instance
model — multi-instance exists only for its own auto_tests): run the smoke
twice with different `IdentityPaths` roots and add each other's Tox ID, or
drive it against a toxee instance; that campaign is the M0b spike in the plan.
