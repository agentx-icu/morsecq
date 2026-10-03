[简体中文](./2026-09-30-morsecq-plan.zh-CN.md)

> This is a translation. The Chinese file `2026-09-30-morsecq-plan.zh-CN.md` is the original; where the two disagree, the Chinese text is authoritative.

# MorseCQ — Cross-platform Morse Code App: Project Plan

> Status: v0.3 (2026-09-30). This document is the founding plan for MorseCQ. It was first drafted in the toxee repository (reusing its code facts) and is now maintained together with the `agentx-icu/morsecq` repository. toxee's documentation convention is EN/zh-CN pairs; this draft was initially issued in Chinese only.
>
> Review history is in the "Change log" at the end.

## 0. One sentence

**MorseCQ**: a cross-platform app to "learn Morse and chat in Morse". On first launch it creates a Tox identity (no server, no phone number); training and chat then share that identity: training progress is saved per identity, and one-to-one and group chat go over the Tox P2P network, reusing the Tim2Tox communication stack that toxee has already polished. On the wire a message is plain text that any Tim2Tox client (including toxee) can read; the MorseCQ side plays it back as "dits and dahs" at whatever speed the listener chooses.

## 1. Project naming

### 1.1 Decision: **MorseCQ** (settled 2026-09-30)

- Repository `https://github.com/agentx-icu/morsecq`, GPL-3.0.
- Dart package prefixes `morse_*` (pure engine) / `morsecq_*` (app side); Bundle ID `icu.agentx.morsecq`.
- Display name vs identifiers (2026-10-01): every user-visible name is **MorseCQ** (Android label, iOS display name, macOS `MorseCQ.app`, Linux/Windows window titles and `.desktop` / installer names, docs). Identifiers stay lowercase `morsecq` so existing profiles keep working: package names, bundle id, Linux/Windows binaries, data directories, notification channel ids, Windows `ProductName` (path_provider derives `%APPDATA%\icu.agentx\morsecq` from it). The macOS pkg renames a pre-existing `/Applications/morsecq.app` to `MorseCQ.app`.
- Suggested store title "MorseCQ: Morse Code Chat & Trainer"; Chinese sub-name 「滴答」 ("tick-tock").
- The first candidate, Morsee, was dropped because Google Play already has an app of that name (`com.wisteriastone.morsecode`).

### 1.2 Candidate record at the time (2026-09-30, store-name collisions checked by web search, not a trademark search)

| Candidate | Origin / pronunciation | Same-name app in stores | Trade-offs |
|---|---|---|---|
| **CQCQ** (first choice) | A radio call is literally "CQ CQ CQ"; the name is its own rhythm dah-di-dah-dit dah-dah-di-dah; read "see-queue see-queue" | None found (only many unrelated apps starting with CQ: mixers, brokerages, political news) | Strongest brand feel, memorable, clean package name `icu.agentx.cqcq`; downside: no "morse" in the name, so the store title must be "CQCQ: Morse Code Chat & Trainer" for search; CQ is an amateur-radio magazine name, trademark needs checking |
| **MorseCQ** | Morse + CQ, one word | None found | Most descriptive, search-friendly; weaker brand feel than CQCQ |
| **CQ Morse** | Same, two words | None found | Most literal, but a generic word combination with weak trademark protection, easily drowned among Morse apps |
| **CQ Dit** / **DitCQ** | CQ + dot (dit) | None found | Playful dot/dash flavour, short; "Dit" means nothing to non-enthusiasts |
| **CQtox** | CQ + Tox, points straight at the P2P base, same family as toxee | None found, but sounds like the Tox client qTox | Friendly to the Tox community, unexplained to ordinary users |
| **CQ Wave** | CQ + radio wave | None found | Nice imagery, Chinese 「电波」 reads well; rather generic |

Confirmed taken, no longer considered: Morsenger (Play), CQ Key (App Store, brokerage two-factor; also a hardware brand of the same name), CQNet (App Store, drone management), Morse Chat (iOS + Android, and a direct competitor: server-room-based Morse chat).

Suggested Chinese sub-name unchanged: **「滴答」**; if CQCQ were chosen, 「呼叫呼叫」 ("calling, calling") would also work.

To do: after naming, check GitHub `agentx-icu/<name>`, exact App Store / Play names, the domain (`<name>.app`) and trademark databases. This session's GitHub access covered only toxee, so this was not verified.

### 1.3 Competitor note

Morse Chat (digital.dong.morsechat) already offers "rooms by speed + private chat + seven kinds of keys" for Morse chat over a central server. MorseCQ's differentiators must be stated clearly: **Tox P2P, no server, no phone/e-mail registration, interoperability with the toxee ecosystem, training and chat in one app**.

## 2. Product definition

### 2.1 Target users

1. People who want to learn Morse code systematically (amateur-radio exam candidates, hobbyists, cipher/emergency enthusiasts).
2. People who, having learned it, want to "really use it": message friends in Morse, practise sending and receiving in a group.
3. Privacy-sensitive users: no account server, no phone number, P2P is enough.

### 2.2 Three modules

All modules are used under the same Tox identity (product decision, 2026-09-30): the identity is created on first launch, training progress is persisted per identity and is backed up / migrated together with the identity file.

| Module | Core capabilities | Needs network? |
|---|---|---|
| **Training** | Koch-method character course, Farnsworth spacing, copy drills, send drills (straight key / iambic paddle), real-time decode feedback, confusion matrix, spaced repetition, daily goals | No; fully offline once the identity exists |
| **C2C chat** | Add friends by Tox ID / QR code, Morse messages (plain text on the wire; receiver plays them as audio/vibration/flash at its chosen speed), "listen first, then reveal" practice mode, history, offline queue | Yes, Tox P2P, no account server |
| **Group chat** | Create / invite / join by chat_id, Morse messages in groups, member list, automatic re-join after restart, CQ-call style "radio channel" play | Yes, Tox NGC groups |

### 2.3 Interoperability with toxee

In v1 a Morse message on the wire **is plain text**, with no metadata attached (reason: §3.1 item 5 — Tim2Tox's `cloudCustomData` is stored locally only and never goes on the wire). toxee users receive readable text; MorseCQ regenerates the rhythm at the listener's configured speed on receipt. This matches Morse-training convention — the listener listens at their own speed, which is part of the Farnsworth method anyway.

"Hearing the other party's real fist (recorded keying)" is a v2 feature and depends on upstream Tim2Tox adding a "message annotation" carried on the wire (§5.2, second layer).

### 2.4 Explicitly out of scope (v1)

- Voice/video calls (no ToxAV).
- Server push. Tox has no offline server; messages are received only when both sides are online. Offline messages rely on the Tim2Tox Dart-side queue replaying when the peer comes online. The UI must make this clear.
- Multiple accounts online at once (Tim2Tox singleton model, same as toxee).
- Transmitting recorded keying, real-time keying (v2, see §5.2 / §5.5).

## 3. Technology choices and architecture decisions

### 3.1 Key facts (from a survey of toxee mainline `5a1cebe` and the tim2tox submodule pin `9d4245a`, 2026-09-30)

1. `tim2tox_dart` (`third_party/tim2tox/dart`, GPL-3.0) depends at package level on `tencent_cloud_chat_sdk: any` (**not pinned**) and `tencent_cloud_chat_common ^4.1.0+1`; `FfiChatService` itself imports `tencent_cloud_chat_sdk`'s `native_library_manager`, `tim_message_manager`, `tim_group_manager`, etc. You cannot "take Tim2Tox without the Tencent SDK" unless upstream splits it first; and toxee's `pubspec_overrides` pin must be copied verbatim, otherwise `any` drifts.
2. `FfiChatService` (about 13k lines) already provides the communication capabilities MorseCQ needs: account (`init/login`, synchronous `getSelfToxId()`, `updateSelfProfile`), friends (`addFriend/acceptFriendRequest/getFriendList/removeFriend`), C2C (`sendTextWithResult(peerId, text, {cloudCustomData, clientMessageID})`, `sendFile`), groups (`createGroup(name, {groupType: 'group'|'conference'})`, `joinGroup`, `acceptGroupInvite`, `sendGroupTextWithResult(groupId, text, {clientMessageID})`, `quitGroup`), history (`loadHistory/clearC2CHistory/clearGroupHistory`), a connection-status stream, `startPolling()`, and a Dart-side offline message queue (replayed automatically when the peer comes online, returning pending rows).
3. Constructing `FfiChatService` only requires injecting `ExtendedPreferencesService` (including the Draft / GroupIdentity / AccountScoped variants, about 60 methods in total), `LoggerService`, `BootstrapService` and `ScratchFileService`; `EventBusProvider` / `ConversationManagerProvider` belong to the FakeUIKit side and are not needed for option B. Interfaces are defined in `tim2tox/dart/lib/interfaces/`.
4. The only parts of toxee that are **genuinely portable** are `lib/models/`, the `startup_outcome` / `startup_step` types, and the three adapters `logger` / `bootstrap` / `shared_prefs` (about 1.1k lines). `StartupSessionUseCase`, `LoginUseCase`, `AccountService` and `StartupGate` are all coupled through `SessionRuntimeCoordinator` / `FakeUIKit` / Tencent providers — **the flow can be copied, the code cannot**.
5. **`cloudCustomData` does not go on the wire.** The `FfiChatService.sendText` documentation states explicitly "NOT sent over Tox — the peer never sees the quote"; it only lands on the local `ChatMessage` and the offline-queue row; `sendGroupTextWithResult` does not even take the parameter. toxee uses it for reply quotes, so quotes never reach the peer either — that is a pre-existing gap in toxee itself.
6. State of custom packets: `Tim2ToxSdkPlatform.createCustomMessage`'s send path wraps the data as `__custom__:` **text** and rejects anything exceeding a single fragment; the only truly lossless custom packet is native `tim2tox_ffi_send_c2c_custom` → `tox_friend_send_lossless_packet` (packet ID 184; the ID has been **submitted** to the zoff99 registry, no confirmation seen). On the Dart side only `Tim2ToxFfi.sendC2CCustomNative / sendGroupCustomNative` have native bindings; `FfiChatService` has no corresponding method. Group custom packets are rejected outright for the legacy Conference type. **There is no lossy packet send API at all** (only a receive callback is registered).
7. Length: text is fragmented at `TOX_MAX_MESSAGE_LENGTH − 50 = 1322` bytes, but fragments arrive as separate messages on the receiver; a lossless custom packet over the Tox limit fails immediately with `ERR_SDK_MSG_BODY_SIZE_LIMIT`, **no fragmentation**.
8. Headless feasibility: `init / login / startPolling` go through `_ffi` only, and `avIterate` has an empty stub when ToxAV is off. But two places go hard through the Tencent bindings: `quitGroup` (`NativeLibraryManager.registerPort` + `bindings.DartQuitGroup`) and offline group-invite replay (`TIMGroupManager.instance.inviteUserToGroup`); both require `setNativeLibraryName('tim2tox_ffi')` and the Tencent bindings being able to load `libtim2tox_ffi`. Without `Tim2ToxSdkPlatform` installed, the three callbacks `clearHistoryMessage` / `groupQuitNotification` / `groupChatIdStored` are silently dropped (toxee `HYBRID_ARCHITECTURE.md` §4.3); the pull-based compensation is `syncGroupIdentitiesFromNative()`. **No existing test runs in headless mode**: tim2tox `auto_tests` use `TIMManager.instance.initSDK` and check `Tim2ToxSdkPlatform`; toxee unit tests only construct a bare `FfiChatService` without logging in or sending/receiving.
9. Native library: `tool/ci/build_tim2tox.sh` covers Linux x86_64 / Windows x64 (arm64 experimental) / macOS x86_64+arm64 / Android arm64-v8a / iOS arm64; a `--no-toxav` switch already exists — with it, opus 1.5.2 and libvpx 1.15.2 are not needed. tim2tox's own `build.sh` defaults to `BUILD_FFI=ON` and can also produce the shared library. Minimum OS versions per toxee `doc/reference/PLATFORM_SUPPORT.md`: macOS 10.15, Windows 10, Android API 21, iOS 13.
10. Audio: the `flutter_pcm_sound` toxee uses supports **Android / iOS / macOS** only (toxee itself restricts it to mobile); Windows / Linux have no ready-made sidetone solution. Other reusable packages: `qr_flutter`, `mobile_scanner`, `flutter_secure_storage`, `provider`. No haptics package.
11. `tim2tox_dart` depends on `path_provider` / `shared_preferences`, so `morsecq_chat` tests must use the Flutter test binding and mock the `path_provider` channel (toxee's `ffi_chat_service_group_invite_queue_test.dart` does exactly that), not plain `dart test`.

### 3.2 Four options

| Option | Approach | Pros | Cost |
|---|---|---|---|
| A. Fork toxee | Copy all of toxee (Tencent UIKit + FakeUIKit + dual-path hybrid architecture) and add Morse features on top | Chat runs on day one | Inherits ~100k lines, the patch flow, `BinaryReplacementHistoryHook` and other dual-path invariants; Morse UX is boxed in by UIKit bubbles; hard to slim down under the complexity guard |
| **B. Tim2Tox engine + own UI (recommended, with "variant B" as the baseline)** | Depend on `tim2tox_dart`, use only `FfiChatService`; **still call `setNativeLibraryName('tim2tox_ffi')`** (the two hard dependencies in item 8 need it), but do not install `Tim2ToxSdkPlatform`, do not start FakeUIKit, do not pull in UIKit component packages; all chat UI is drawn for the Morse use case | A single data path; UI designed entirely for Morse; no UIKit patches | The Tencent SDK remains a compile-time dependency (reuse toxee's `bootstrap_deps` and patch flow); `quitGroup` and offline group-invite replay must be re-routed through `Tim2ToxFfi` or upstream must add APIs; the three silently dropped callbacks need `syncGroupIdentitiesFromNative()` as a fallback; a headless two-instance test must be built in-house |
| C. Bind the C layer `tim2tox_ffi.h` directly | Write a separate thin Dart binding | Zero Tencent dependency | Rewrites 13k lines of Dart (offline queue, history, group re-join, file transfer); not worth it |
| D. Upstream split into `tim2tox_core` | In the Tim2Tox repository, split the UIKit-independent parts into a standalone package and add "message annotation on the wire", "Dart-side custom packet API" and "lossy packet API" | Cleanest long-term; toxee benefits too (reply quotes finally reach the peer) | A separate upstream project; the "message annotation" part is a prerequisite for MorseCQ v2 recorded keying but **does not block v1** |

**Decision: variant B as the baseline, track D in parallel.** v1 chat depends only on existing Tim2Tox capabilities (plain-text messages + existing groups/friends/offline queue), so track D's progress does not gate M1–M3. Once track D's deliverables (message annotation, Dart-side custom packet API, lossy API) land, v2's recorded keying and real-time keying can start. If the M0 spike proves the headless route does not work even as variant B, fall back to option A.

### 3.3 Target architecture (option B variant)

```
┌──────────────────────── apps/morsecq (Flutter) ───────────────────────┐
│  ui/learn        ui/chat (c2c + group)       ui/account   ui/settings  │
│  ─────────────── state layer: provider (same as toxee) ───────────────  │
├──────────────┬──────────────────┬──────────────────┬──────────────────┤
│ morse_core   │ morse_trainer    │ morse_io         │ morsecq_chat      │
│ pure Dart    │ pure Dart        │ platform audio/  │ Tim2Tox façade    │
│ alphabet/    │ Koch/Farnsworth  │ haptics/flash    │ FfiChatService   │
│ codec/timing │ SRS/progress/    │ flutter_soloud   │ + account/startup │
│ /decoder     │ stats            │ HapticFeedback   │   /login          │
│ CN code (P4) │                  │ torch/screen     │ + adapter impls   │
│              │                  │ flash            │                   │
├──────────────┴──────────────────┴──────────────────┴──────────────────┤
│ third_party/tim2tox (submodule) → libtim2tox_ffi (c-toxcore, --no-toxav)│
└─────────────────────────────────────────────────────────────────────────┘
```

- `morse_core` / `morse_trainer` do not depend on Flutter, can be tested with plain `dart test`, and are the basis for future Web/CLI reuse.
- `morsecq_chat` is the **only** package that touches `tim2tox_dart` and the Tencent SDK: account creation/restore, startup use case, login use case, friends, conversations and message streams all live inside it, exposing only `MorseChatService` upward. An import allow-list script in CI forbids `tencent_cloud_chat*` / `tim2tox_dart` imports in `apps/` and the other packages.
- **Single build target**: training requires an identity too, so the app always ships with `morsecq_chat` and the native library; the startup gate (identity exists / create / unlock) sits in front of the shell, and both the training and chat pages are behind it. During the M1 internal test the chat entry may be hidden, but the identity flow must already work.
- Mono-repo with multiple packages (`melos` optional, not required); CI keeps toxee's strict `flutter analyze` lints, `check_complexity.dart` (500-line hard gate) and the five-platform native build scripts.

### 3.4 Licence (decision needed)

Tim2Tox and toxee are both GPL-3.0; as long as MorseCQ links Tim2Tox it must be GPL-3.0 compatible. **GPLv3 has a known conflict with the App Store terms** (FSF position; VLC was once pulled over this), and "a source link on the About page" does not resolve it. Options: ① accept the risk and ship (many GPL apps are on the store without guarantees); ② dual-license MorseCQ's own code (GPL-3.0 + an additional licence permitting store distribution), though the Tim2Tox part stays GPL; ③ add an App Store distribution exception to Tim2Tox (same organisation). Recommendation: ③ + ②, settled in M0. iOS store listing must not be an acceptance gate for any time-boxed milestone (see §6).

## 4. Training module design

### 4.1 Morse engine (`morse_core`)

- Alphabet: ITU international Morse (A–Z, 0–9, punctuation), common prosigns (AR, SK, BT, SOS, etc.). Chinese telegraph code (4-digit table, about 7000 common characters) goes to P4; table size and lookup need separate evaluation.
- Timing standard (PARIS method): `dit = 1200 / WPM` milliseconds; dah = 3 dit; intra-character gap 1 dit; inter-character 3 dit; inter-word 7 dit. Farnsworth: character speed and effective speed are decoupled; only inter-character/inter-word gaps are stretched.
- The encoder outputs `List<MorseElement>` (on/off with duration), so the audio, vibration and flash renderers share one timeline.
- Decoder: input is a sequence of key down/up timestamps. **Dit length is estimated by two-cluster clustering** (split key-down durations into short/long clusters and take the short cluster's mean; do not use the overall median — in text heavy in O, 0, T the median lands on a dah). Decision thresholds sit at the midpoint of the nominal values: **dot/dash threshold 2×dit; intra-/inter-character gap threshold 2×dit; inter-character/inter-word threshold 5×dit**; this still decides correctly under ±30% jitter. In Farnsworth mode inter-character/inter-word gaps are artificially stretched, so the gap thresholds adapt to the observed gap distribution rather than fixed multiples. A "confidence" value accompanies each decision; the UI uses it for real-time correction hints.
- All logic has golden-case tests: exact millisecond sequences of standard sentences at 5/12/20/25 WPM; a lower bound on decoder accuracy for synthetic sequences with ±20%/±35% jitter; one set each for Farnsworth and non-Farnsworth.

### 4.2 Training method

- **Koch method**: start with the two characters K and M, character speed fixed at 18–20 WPM (Farnsworth effective speed adjustable 5–10 WPM), lesson accuracy ≥ 90% unlocks the next character; order follows the common LCWO sequence.
- **Copy practice**: random character groups → common words → callsigns → short QSO dialogues; answers by keyboard input or tapping; per-character accuracy and a "confusion matrix" (e.g. S/H, B/6) are tracked.
- **Sending**: on-screen straight key (single key) and paddle (left dot, right dash, Iambic B); on desktop the space bar / left-right Ctrl or an external keyboard; decode results are shown in real time with rhythm diagnostics such as "dot too long / inter-character gap too short".
- **Spaced repetition (SRS)**: weighted sampling of low-accuracy characters; daily goals and streaks.
- **Progress storage**: local SQLite or JSON (`path_provider`), no cloud; JSON export supported.

### 4.3 Sound and feel (`morse_io`)

- Sidetone: adjustable 600–800 Hz sine, 5 ms attack/release envelope against clicks. **First choice `flutter_soloud`** (covers Android / iOS / macOS / Windows / Linux, low latency); `flutter_pcm_sound` covers only three platforms and is a mobile-only fallback. Key-to-sound latency target < 30 ms, measured on all five platforms in M0.
- Vibration: `HapticFeedback` / `vibration` on iOS/Android (poor duration precision, auxiliary only); desktop has no vibration and uses screen flash instead.
- Flash: screen flash on all platforms; optional torch (`torch_light`) on mobile.
- Audio session: iOS needs the `AVAudioSession` playback category so the sidetone sounds even with the mute switch on; Android uses the `USAGE_GAME` low-latency attribute.

### 4.4 Appearance styles (approved 2026-10-01)

- Modern Calm is the default and Restore Defaults style; retain Classic Brass, Night Radio, Paper Handbook, and Fresh Cartoon as alternatives, preserving saved choices. English and Chinese README concepts match their language and the Modern Calm product screenshots. [Approved visual concepts](../designs/ui-styles-2026-10-01/README.md) and the [implementation plan](./2026-10-01-ui-styles-implementation.md) record the scope.
- Me → Appearance and the Learn header shortcut open one chooser: local previews, independent System / Light / Dark mode, explicit Apply, and staged Restore Defaults. Persist one device-level record alongside language and window settings.
- Shared themes cover the shell, training, chat, groups, reference, and account screens. New styles adjust the learning hierarchy and control geometry; changing appearance preserves navigation, drafts, training state, audio timing, and keyboard/touch keying.
- Validate both phone and desktop layouts, large text, contrast, persistence failures, and simultaneous settings writes. This session uses independent Codex review; the user disabled Claude review.

## 5. Communication module design

### 5.1 Account and friends

- **Rewritten** inside `morsecq_chat` (copy the flow of toxee's `StartupSessionUseCase` / `LoginUseCase` / `AccountService`, not the code): generate a Tox identity on first launch → optional password-encrypted `.tox` → auto-login → wait for connection.
- Adding friends: type a Tox ID, scan a code (`mobile_scanner`), show a QR code (`qr_flutter`).
- First launch must prompt to back up the Tox identity file (toxee's TODOS already lists "lost identity = lost trust" as the number-one risk; MorseCQ learns from that directly).
- **"Me" (note to self, 2026-10-01)**: after an account is created, Contacts starts with a "me" entry showing the own display name; messages sent to it are stored on the device only and never sent — a drafts box, a practice partner, a place for notes. The guarantee lives in **tim2tox's `FfiChatService`** (the transport toxee and MorseCQ share): text and files to the own public key become delivered local rows, and typing, control signals, reactions, receipts and the group-invite queue all short-circuit for self; entries an older build parked in the offline queue are reconciled locally. The MorseCQ contract gains `ChatService.selfConversationId` and `Conversation.isSelf`. The conversation cannot be deleted (2026-10-02): `deleteConversation` refuses it with `ChatException('self_conversation')` and changes nothing, and the list offers no Delete for it (no menu item, no delete swipe, on phone and desktop alike); its notes are emptied only by the explicit, confirmed "Clear history" inside the conversation. toxee's app-level wiring (conversation list, UIKit contacts) is a separate follow-up.

### 5.2 Morse messages: two-layer design

**Layer one (v1, delivered in M2/M3, no upstream dependency): plain text.**

- C2C uses `sendTextWithResult(peerId, text)`, groups use `sendGroupTextWithResult(groupId, text)`; `text` is the decoded plain text. Any Tim2Tox client can read it.
- The receiver generates the playback sequence at the **listener's** configured character speed / Farnsworth speed / tone. The sender's speed is not transmitted — a deliberate product choice consistent with training convention.
- A single plain-text message is kept within 1322 bytes to avoid fragmentation (fragments arrive as separate messages); the UI shows remaining bytes in the input area.

**Layer two (v2, depends on track D "message annotation on the wire"): recorded keying.**

- Upstream change: add a "message annotation" type to the Tim2Tox control frame (T2TC, ID 184), correlated by `clientMessageID`; the receiver merges it into the matching `ChatMessage.cloudCustomData` **instead of** rendering it as a separate bubble. This also fixes toxee's existing gap where reply quotes do not go on the wire, so it is a win-win for upstream.
- MorseCQ puts `{"morsee":{"v":1,"wpm":15,"fw":8,"keyed":true,"t":"<base64 varint timing>"}}` in the annotation; the timing is quantised in dit units and varint-encoded, total payload ≤ 1.2 KB (custom packets have no fragmentation; exceeding the limit is an immediate error).
- Old clients ignore unknown annotation keys; Conference-type groups cannot carry custom packets, so annotations are available only in C2C and NGC groups.

### 5.3 Morse-specific chat UI

- Bubbles show three layers: dot/dash symbols / plain text / play button; "training mode" hides the plain text by default, revealing it after listening and scoring the attempt.
- Input area has three modes: keyboard text (auto-encoded), straight key, paddle; pre-listen before sending.
- Conversation list: unread, pinned and drafts are maintained by `morsecq_chat` itself (not via FakeUIKit); drafts can reuse Tim2Tox's `DraftPreferencesService`.
- Preserve edits made during sending and serialize draft saves across reopened editors. Earlier local history remains reachable even when timestamps tie; older pages and new messages preserve the reading position. Follow new messages only near the bottom or after an explicit send, otherwise show a new-message entry. Clear history requires confirmation and affects only this device.

### 5.4 Groups

- Default `groupType: 'group'` (NGC), keeping chat_id persistence and re-join after restart (the mapping-recovery mechanism in toxee `doc/reference/GROUP_CHAT_GUIDE` carries over as is).
- Conference is kept only as a compatibility switch for old clients, not as a primary UI entry; the UI must indicate that v2 annotations are unavailable on Conference.
- `quitGroup` and offline group-invite replay must be confirmed in the M0 spike to work via the Tencent-binding path under variant B (`setNativeLibraryName` is already called); otherwise re-route through `Tim2ToxFfi` or have upstream add APIs.
- Play: group = "channel", with a "CQ" quick call and "net practice" (taking turns sending, automatic in-group scoring, P4).

### 5.5 Real-time keying (v2, optional)

- Goal: the other party hears your keying in near real time.
- Lossless custom packets are ordered reliable transport; one delayed packet blocks every keying event behind it (head-of-line blocking), and over a TCP relay the RTT alone can exceed a 200 ms jitter buffer. **A lossy packet API is therefore very likely needed** — a new FFI/Dart API in track D that must respect Tim2Tox's byte-level ABI matching constraint. Prototype with lossless + jitter buffer first to quantify latency, then decide whether to go lossy.

### 5.6 Mobile considerations (mobile compatibility is a hard requirement)

- Background: toxee keeps the iOS connection warm for a few minutes via the `voip` + `audio` background modes (`MOBILE_BACKGROUND.md`), but MorseCQ has no ToxAV and **cannot honestly declare the `voip` background mode**, so the iOS background window will be shorter; Android power-saving policies vary by vendor. Keep the foreground-service / local-notification strategy and state clearly in the product that "you receive only while online".
- The paddle on a touch screen needs ≥ 48 dp hot zones and multi-touch; desktop keyboard shortcuts are a separate input implementation, and both need their own tests.

## 6. Milestones and effort

Effort uses the **CC-day** unit from toxee `TODOS.md` (one working day with Claude Code collaboration, roughly 8–15 person-days).

| Milestone | Deliverables | Acceptance gate | Effort |
|---|---|---|---|
| **M0a Repository and CI** | New repository skeleton (two build targets), copy toxee's `bootstrap_deps` / `check_complexity` / `analysis_options` / `build_tim2tox.sh --no-toxav`, five-platform CI (incl. macOS/Windows runners and iOS signing), `morse_core` codec + golden tests, licence decision | Five-platform CI green; `morse_core` tests pass | 3–4 CC-days |
| **M0b Communication spike** | ① Variant B headless: `setNativeLibraryName` + bare `FfiChatService`, two instances log in, add friends, exchange text, create an NGC group and exchange messages, `quitGroup`, offline queue replay — all without Platform/FakeUIKit, as a repeatable test on the Flutter test binding + mock path_provider; ② `flutter_soloud` sidetone latency < 30 ms on five platforms; ③ the `--no-toxav` library loads correctly through the Dart bindings; ④ submit a "message annotation on the wire" RFC draft to Tim2Tox | If ① and ③ pass, variant B stands; otherwise fall back to option A and re-estimate | 3–4 CC-days |
| **M1 Identity + training MVP** | Identity create/password/backup/restore (the account part of `morsecq_chat`, depends on M0b conclusions), Koch course, copy practice, sending (straight key/paddle), decoder, per-identity progress and SRS, settings; chat entry hidden for the internal test | Runs on five platforms; decoder jitter and Farnsworth tests pass; training progress intact after identity reinstall/restore | 9–11 CC-days |
| **M2 One-to-one chat** | Identity create/backup/restore, add friends, plain-text Morse messages, chat UI, history, offline queue, basic local notifications | Interoperates with toxee; offline replay works; mobile background strategy in place | 8–10 CC-days |
| **M3 Group chat** | Create/invite/join by chat_id, group Morse messages, member list, re-join after restart | Three instances on three platforms interoperate; group restored after process kill and restart | 5–6 CC-days |
| **M4 Polish and release** | Chinese telegraph code, i18n (ten UI locales; en/zh docs), accessibility, packaging (Play / msix / dmg / AppImage; iOS per §3.4 decision) | Installable packages; crash-rate and latency metrics met (**excluding** store review outcome) | 6–8 CC-days |
| **Track D (parallel upstream)** | `tim2tox_core` split RFC, message annotation on the wire, Dart-side custom packet API, lossy packet API | Does not block M1–M4; prerequisite for v2 | Separate |
| **v2** | Recorded keying (§5.2 layer two), real-time keying (§5.5), group net practice | Depends on track D landing | Separate |

v1 totals about **33–42 CC-days**, roughly **260–630 person-days** at this repository's 8–15× ratio. M1 before M2 is deliberate: the learning module has no network dependency, the lowest risk, and validates user value earliest; all communication uncertainty is absorbed in M0b.

## 7. Risks and mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Variant B headless does not work (Tencent binding load, `quitGroup`, invite replay, the three silently dropped callbacks) | Baseline option invalid | First M0b spike item; `syncGroupIdentitiesFromNative()` fallback; re-route the two hard dependencies through `Tim2ToxFfi`; last resort is option A |
| Tencent SDK as an implicit compile dependency (`tencent_cloud_chat_sdk: any` unpinned) | Version drift, patch maintenance | Copy toxee's `pubspec_overrides` pin and `PATCH_MAINTENANCE` flow verbatim; remove entirely after the track D split |
| Five-platform native build (NDK / iOS framework / vcpkg) | The build chain is toxee's heaviest operational burden | Reuse `tool/ci/build_tim2tox.sh --no-toxav`, `build_android_ffi.sh`, `build_ios_sim_ffi.sh` as is |
| GPL-3.0 vs App Store conflict | iOS listing blocked | Pick one of three in §3.4, settled in M0a; iOS listing is not in any time-boxed acceptance gate |
| No ready-made sidetone on Windows/Linux; `flutter_soloud` latency or clicks | Core of the training experience | Measure on five platforms in M0b; fallback is a thin hand-written miniaudio FFI layer |
| Users do not understand P2P "no receipt while offline" | Bad reviews and churn | First-launch education, prominent online status, "pending" marker on offline messages (Tim2Tox already returns pending rows) |
| iOS background window shorter than toxee's (no `voip` mode) | Low mobile online rate | Set the expectation "open the app to receive"; explore whether the `audio` background mode with sidetone is compliant |
| Identity file loss | Unrecoverable | Mandatory backup wizard on first launch (export encrypted `.tox` + QR code/file) |
| Decoder too intolerant of beginners' rhythm | Frustration | Midpoint thresholds + two-cluster dit estimate + graded confidence; training mode allows a "lenient" setting |
| Upstream track D progress out of our control | v2 features delayed | v1 does not depend on track D at all; same organisation maintains it, we can submit PRs ourselves |
| Complexity spiralling | Repeating toxee's large-file problem | Enable the 500-line hard gate and baseline ratchet from day one; import allow-list script locks Tencent/Tim2Tox types inside `morsecq_chat` |

## 8. Quality and process

- Static: strict `flutter analyze` lints (toxee's `analysis_options.yaml`), `check_complexity.dart`, import allow-list script.
- Unit tests: pure-Dart tests for `morse_core` / `morse_trainer` covering timing golden values, decoder jitter, Farnsworth adaptive thresholds, Koch unlock logic, SRS sampling distribution.
- Integration: **in-house** headless two-instance test (Flutter test binding + mock `path_provider`, produced in M0b); tim2tox `auto_tests` cannot be reused directly because they depend on `TIMManager.initSDK` and `Tim2ToxSdkPlatform`; the UI layer borrows toxee's MCP real-widget driving approach (`MORSECQ_L3_TEST` switch).
- Review: every change goes "draft → codex second opinion → apply → proceed"; when codex is unavailable, declare the skip explicitly and record the debt (as this document does — see the change log).
- Mobile compatibility: the default review question on every PR is "does mobile hit this too?"; desktop-only implementations must name the corresponding mobile implementation or state the gap.

## 9. Decisions needed from you

1. **Project name**: accept MorseCQ (Chinese sub-name 「滴答」)? Or choose from the candidates / something else.
2. **Licence and iOS listing** (§3.4): accept the risk / dual-license own code / add a store exception to Tim2Tox.
3. ~~Whether the training module must work without an account~~ **Settled (2026-09-30): training also requires an identity.** Impact: drop the learn build target; identity flow becomes a prerequisite of M1; training progress is persisted per identity and migrates with the `.tox` backup.
4. **Whether v1 accepts "sender speed not transmitted"** (§5.2 layer one). If it must be transmitted, v1 has to wait for track D's message annotation and M2 becomes gated on upstream progress.
5. **Chinese telegraph code** priority: this draft puts it at P4; if the target users are mainly Chinese-speaking, it could move to right after M1.
6. New repository location: suggested `agentx-icu/morsecq`, same organisation as toxee.

## 10. Next steps (to execute immediately after decisions)

1. Create the repository `agentx-icu/morsecq`, initialise `apps/morsecq` (two entry points) + four package skeletons + the `third_party/tim2tox` submodule (same pin as toxee).
2. Port toxee's `tool/bootstrap_deps.dart`, `pubspec_overrides` pin, `tool/check_complexity.dart`, `tool/ci/build_tim2tox.sh` (default `--no-toxav`), `analysis_options.yaml`, `tool/install_git_hooks.sh`.
3. Land the `morse_core` codec and golden tests (independent of any Tim2Tox conclusion; can run in parallel with the spike).
4. Run the four M0b spike items, write the conclusions back into §3.2 of this document, and decide between variant B and option A.
5. Submit the "message annotation on the wire" RFC to Tim2Tox (also fixing toxee's gap where reply quotes do not go on the wire).

## 11. Multi-agent parallel development orchestration (in effect from 2026-09-30)

The user directed multi-agent parallel development. Principles: **split along package boundaries; agents couple only through committed public API contracts**; the orchestrator first writes the contract skeletons by hand (`throw UnimplementedError()`), then dispatches in parallel; in shared files (the root `pubspec.yaml`'s `workspace:` list) each agent may only append its own line; agents do not commit — the orchestrator integrates wave by wave, runs the full gates and commits.

| Wave | Agent | Output directory | Depends on |
|---|---|---|---|
| 0 (orchestrator) | — | Root workspace, shared lints, `morse_core` public API skeleton | — |
| 1 | core | `packages/morse_core` implementation + golden tests | Skeleton |
| 1 | trainer | `packages/morse_trainer` (Koch/Farnsworth/drill bank/scoring/SRS/progress, pure Dart) | Skeleton types; tests inject explicit data, no dependency on the core implementation |
| 1 | io | `packages/morse_io` (`flutter_soloud` sidetone, haptics, flash, straight-key/paddle state machines, key widgets) | Skeleton types; all plugin calls hidden behind injectable interfaces |
| 1 | scaffold | `tool/check_complexity.dart`, `tool/import_guard.dart`, CI, `apps/morsecq` shell, `CLAUDE.md`, README | — |
| 1.5 (orchestrator) | — | `packages/morsecq_chat_api`: pure-Dart contract (`IdentityService`, `ChatService`, models), shared dependency of both the UI and implementation sides | — |
| 2 | chat | `packages/morsecq_chat`: tim2tox submodule, `bootstrap_deps` port, `Tim2ToxIdentityService` / `Tim2ToxChatService` implementing the contract, headless two-instance test scaffolding | Contract package |
| 2 | learn-ui | `apps/morsecq/lib/ui/learn`: course/copy/send pages, wired to trainer + io | Wave 1 |
| 2 | account-ui | Startup gate, identity create/unlock/backup pages, Me page, provider assembly (`lib/di`), developed against the contract + `FakeIdentityService` | Contract package |
| 2 | chat-ui | Conversation list, one-to-one chat, friends, group pages, Morse bubbles and three-mode input, `FakeChatService` | Contract package; morse_io playback/keying ready |
| 3 | native-ci | `tool/ci/build_tim2tox.sh` (default `--no-toxav`), five-platform packaging scripts, `.github/workflows/native.yml`, platform bundling, `doc/operations/BUILD_AND_DEPLOY` | Needs runners with toolchains; cannot be verified in this container |
| 3 | reference-ui | `ui/reference`: alphabet/punctuation/prosign/Q-code/CW abbreviation handbook, two-way translator, `MorsePatternText` | core, io |
| 3 | stats-ui | `ui/stats`: course/accuracy/streak overview, trend charts, character grid, confusion heat-map, practice calendar (CustomPainter, no chart library) | trainer |
| 3 | dsp + listen-ui | `packages/morse_dsp` (Goertzel, auto-tune, envelope gate, `AudioMorseDecoder`, pure Dart) + `ui/listen` (`record` microphone stream) | core |
| 3 | desktop-shell | `lib/desktop`: window bounds persistence, close-to-tray, tray menu, shortcut intents (all no-ops on mobile) | — |
| 3 | notifications | `lib/notifications` + `lib/lifecycle`: local notifications (with Morse pattern), badge, foreground/background coordination, iOS background strategy without `voip` | Contract package |
| 3 | l10n | `l10n.yaml`, `app_en.arb` / `app_zh.arb`, `LocaleController`, `tool/strings_to_arb.dart` migration tool | Reads each `*_strings.dart` |

From wave 3 on, per the user's instruction "code only, no build, no test": agents run only the analyzer for static checks; tests are written to disk as files and left for a later consolidated run.

At the end of each wave the orchestrator runs: `dart pub get`, `flutter analyze` on all packages, `dart run tool/check_complexity.dart`, `dart run tool/import_guard.dart`, `flutter test` on all packages, then commits and pushes to `master` (the repository's default branch).

## Change log

- **2026-10-01** — At the user's request, changed the default and Restore Defaults appearance to Modern Calm, preserved explicit saved choices, localized the English README product concept, and unified product screenshots in Modern Calm.

- **2026-10-01** — Added §4.4 after the user approved all four new styles, requested the design-artifact commit, and authorized development in a new worktree. Classic Brass remains the default; appearance and brightness are independent device settings.

- **2026-09-30 v0.1** Initial draft. Code facts come from a survey of toxee mainline (`5a1cebe`) and the tim2tox submodule pin `9d4245a` (the submodule was not initialised in this container; tim2tox files were read via their GitHub raw content). **codex review not performed**: this container has no codex executable; per the working agreement the skip is declared explicitly and recorded as debt.
- **2026-09-30 v0.2** Applied the 15 findings of an independent reviewer agent (self-check in place of codex; codex review still owed). Two blocking-level findings: `cloudCustomData` does not go on the wire, and group messages do not accept the parameter → §2.3/§5.2 rewritten as the two-layer "v1 plain text + v2 upstream message annotation" design. Major-level: `flutter_pcm_sound` covers only three platforms → sidetone first choice becomes `flutter_soloud`; headless has two places going hard through Tencent bindings and no existing tests → decision changed to "variant B as baseline" with in-house headless tests; toxee's portable layer shrinks to about 1.1k lines; Platform custom messages are really `__custom__:` text, the packet ID is only "submitted" for registration; custom packets have no fragmentation, payload ≤ 1.2 KB; decode thresholds changed to midpoint values + two-cluster dit estimate + Farnsworth adaptation; GPL-3.0 vs App Store conflict escalated to a decision item and removed from acceptance gates; `morsecq_chat` absorbs the account/startup layer, a learn build target is added, M0 is split into M0a/M0b, person-day conversion added. Minor-level: `build.sh` can produce the shared library, `--no-toxav` already exists, the iOS background window is shorter without `voip`, real-time keying very likely needs a lossy API, `loadHistory` naming, the interfaces the constructor actually needs, `tencent_cloud_chat_sdk: any` unpinned, `morsecq_chat` tests need the Flutter binding.
- **2026-09-30 v0.3** Named morsecq (repository `agentx-icu/morsecq`); product decision "training also requires an identity" → learn build target dropped, M1 becomes "identity + training", training progress persisted per identity; new §11 multi-agent parallel development orchestration. Document moved from the toxee repository to this repository. Per the user's instruction, no codex review in this session.
- **2026-09-30 v0.3.1** Write-back of the wave 2 chat agent's implementation conclusions: §3.1 item 8 needs an addition — Tim2Tox's offline group-invite replay goes through `TIMGroupManager.inviteUserToGroup`, which requires `TIMManager.initSDK` (installing a second inbound path); morsecq does not call it. Instead, `morsecq_chat` maintains its own offline invite queue in its `ConversationMetaStore` and calls `DartInviteUserToGroup` directly when the friend is online. Also: `tim2tox_dart`'s package-level dependency `tencent_cloud_chat_common` is satisfied with an empty stub (`third_party/stubs/`) so no UIKit components are pulled in; the Tim2Tox polling path cannot distinguish `failed` from `sent` (`MessageStatus.failed` currently never occurs) → added to track D; `flutter_secure_storage` needs `^11` (9.x's `win32 ^5` conflicts with `share_plus`).
- **2026-09-30 v0.3.2** Integration-phase decisions: ① `BackendFactory` gains an asynchronous `prepare()`; `main()` awaits the real backend first, and when the native library is missing or Tox node startup fails it automatically falls back to the in-memory fake backend and shows a backend label on the About page. ② The shell changes to five destinations (Learn / Chat / Groups / Reference / Me); the translator is entered from the handbook's top bar and shares the playback settings. ③ Notifications: on Windows the native toast from `flutter_local_notifications` 22.x covers it, no in-app fallback needed; iOS declares only the `audio` background mode (toxee actually declares `audio`+`fetch`, not the `voip` written in §5.6 of this document — understanding corrected). ④ The native build disables sqlite by default (`--with-sqlite` restores toxee's desktop behaviour); on macOS a bare `libtim2tox_ffi.dylib` is placed into `Contents/Frameworks`. ⑤ App-level preferences (language, window position) live in `<application support>/settings.json`; per-identity data (training progress) lives in `IdentityService.dataDirectory()`.
- **2026-09-30 v0.3.3** Waves 2/3 fully integrated and pushed to `master`. New `TrainingControllerHost`: exactly one `TrainingController` per identity; the Learn page and the Me page's training-settings route share the same instance (avoiding two writers to the same `progress.json`); `LearnScope` disposes only controllers it created itself. The reference handbook's SoLoud player is now created lazily on first playback (building inside the shell's `IndexedStack` no longer touches the audio engine). CI gains `strings_to_arb --check`. Repository-wide analyzer, complexity, import guard and ARB sync checks all pass; per the user's instruction tests and builds were not run this round (test files are on disk: core 71, trainer 91, io 55, chat 33, chat_api 36, app about 300 cases pending execution).
- **2026-09-30 v0.3.4** Documentation only: added this English translation (`2026-09-30-morsecq-plan.md`, the default file that links point to) alongside the Chinese original, following the bilingual `X.md` + `X.zh-CN.md` convention shared with toxee; language links added as the first line of both files. No content changes to the plan itself.
- **2026-09-30 v0.3.5** UI localisation completed on toxee's scheme: gen-l10n with one ARB per locale (class `S`), system-locale resolution that is script/region aware and data-driven over the shipped ARB set, a language catalog driving the picker, and `currentS()`/`StringsResolver` for code without a `BuildContext`. Every surface (notifications and tray included) now reads `S`; all `*_strings.dart` const classes were deleted; reference content (Q-codes, CW abbreviations, mnemonics) lives in per-language data tables. Documentation is bilingual (English default + zh-CN) with a new `doc/i18n/ADDING_A_LANGUAGE` guide. Adding a language = a new ARB (+ optional catalog entry and plist declaration).
- **2026-09-30 v0.3.6** First full test run (second session, orchestrator + 7 agents by directory ownership). Baseline: 739 tests across the 7 packages/app, 32 red (`morsecq_chat` 1, app 31); all green afterwards, gates unchanged. Product bugs found by the tests, all fixed at the cause: ① `Tim2ToxChatService` stale-session race — a refresh in flight on a detached session repopulated the lists `_bindSession(null)` had just emptied (`_isCurrent` guard after every await in the friends/groups parts and the tick); ② teardown ordering around `await StreamSubscription.cancel()`: its root-zone future never resumes inside `flutter_test`'s FakeAsync, so the code after it (timer cancel in `ConnectionBannerPolicy`, controller disposal in `TrainingControllerHost`, microphone release in `ListenController`) never ran in widget tests and could be delayed in production — timers and synchronous teardown now happen before the first await, `AppServices.dispose()` starts every child's teardown in parallel; ③ `ListenController.stop()` is re-entrant (the framework delivers `hidden` then `paused` back to back and asked the microphone source to stop twice); ④ `niceAxis` bounds are snapped like the ticks (binary drift `3 × 0.2`); ⑤ `StatsScreen._reload` used an arrow `setState` returning a Future (debug assertion, also hit by pull-to-refresh on phones); ⑥ `strings_to_arb.findKeyCollision` ignored the same key declared in two files. Test corrections: finders scoped to the chart painters / `ReferenceEntryTile`, lifecycle walk `inactive → hidden → paused`, `learn_home` now encodes the v0.3.3 shared-controller rule, `me_page` asserts the real training-settings screen, `strings_to_arb_test` resolves the SDK `dart` instead of `Platform.resolvedExecutable` (`flutter_tester` under `flutter test`, the 4 × 30 s timeouts), `initializeDateFormatting` for `DateFormat` in pure tests. CI: the first GitHub Actions runs were red — `analyze.yml` only on the Tests step (same failures); `native.yml` 4/8 green, macOS failed in libsodium configure because `build_macos()` exported the raw `xcrun -f clang` binary without `SDKROOT`/`-isysroot` (fixed, plus configure-failure diagnostics), linux-aarch64 / windows-arm64 failed because Flutter 3.41.9 ships no arm64 archives for those OSes (the two rows now install only Dart 3.11.5 via `setup-dart`; the script stages its headers into a `FLUTTER_ROOT`-shaped shim). First real macOS arm64 `libtim2tox_ffi.dylib` built on a Mac (4.1 MB, static libsodium, links only libc++/libSystem). §3.3 diagram and §10 now say `apps/morsecq`. Codex review (`codex-mac`, gpt-6-sol xhigh) on the whole diff: first round NEEDS-CHANGES (5 major + 1 minor on the test fixes, 1 major + 4 minor on native CI), all applied — per-session tick marker instead of the bool `_polling` (a rebind was starved of its initial refresh), `_ensureCurrent` after every await in chat mutations, per-iteration currency check in the queued-invite flush, race regression tests, `NotificationCenter`/`AppServices`/fake backend release everything before the first await, `TrainingControllerHost` generation token so a load completing after dispose or an identity switch disposes its controller instead of caching it (+5 tests), native cache key carries the Flutter/Dart pins, `MORSECQ_DART_SDK_DIR` override precedence, `.h`+`.c` header check, whitespace guard on the Apple sysroot. Second round found `forget()` still unguarded between its three writes and `setPinned`/`setDraft` republishing after an await (fixed: `_forgetMeta` with a check between writes, original-session capture; regression test parks the pinned write), plus a timing-based race test (now awaits the hold signal). Final: 750 tests green; third round APPROVE (no remaining unguarded metadata write or publish after an await in `morsecq_chat`). Post-push CI: `analyze.yml` green for the first time; `native.yml` 8/8 native targets green, `flutter build` green on Windows and macOS, Linux app build failed on a missing `libsecret-1-dev` (added with `libayatana-appindicator3-dev` to the job and the docs), then on `alsa/asoundlib.h` for `flutter_soloud` (`libasound2-dev`).
- **2026-09-30 v0.3.7** Native smoke test run for real (macOS arm64, single process, reaches the DHT) and two defects fixed at the cause. ① The B variant dropped every custom native callback: the patched SDK's `NativeLibraryManager.customCallbackHandler` is set only by `Tim2ToxSdkPlatform`, so `friendAddResult` never reached `FfiChatService.addFriend`'s completer and every friend request returned "timed out waiting for native result" after 30 s, success or failure. New `engine/native_callbacks.dart` (`NativeCustomCallbacks`) owns the hook: `friendAddResult` → completer, the `DartNotifyGroup*` family → live session (session-scoped like toxee), `groupChatIdStored`/`groupTypeStored` → `syncGroupIdentitiesFromNative()`, `clearHistoryMessage` ignored; installed by `Tim2ToxEngine.start`, detached in `stop`, removed in `dispose`. §3.1 item 8's "three silently dropped callbacks" reading was incomplete — the drop covered all of them, `friendAddResult` included. ② The test peer address `kPeerToxId` had a wrong checksum (`tox_friend_add` refused it with `TOX_ERR_FRIEND_ADD_BAD_CHECKSUM`); the fake FFI never validated it. Also: the remaining serial-await teardown chains in `morsecq_chat` (identity service, chat service and its parts, engine `stop`/`dispose`) and `FakeIdentityService` now release synchronously before the first await (HANDOVER §7.6). Smoke test: passes in ~10 s; 45 unit tests, 410 app tests, gates green. iOS: minimum raised to 14.0 (`file_picker_darwin` 2.1.2), `tool/build_ios_ffi.sh` built the device + simulator XCFramework on the Mac and `pod install` succeeded for iOS and macOS (both `Podfile.lock` files committed). Finding: the vendored `tencent_cloud_chat_sdk` podspecs depend on `TXIMSDK_Plus_iOS_XCFramework` / `TXIMSDK_Plus_Mac` and the plugin's Swift sources import it, so the Apple bundles link Tencent's native IM SDK although morsecq never calls it (toxee ships the same); dropping it needs a tim2tox patch on the plugin's Swift side, recorded in HANDOVER §7. App icons: `tool/gen_app_icons.dart` (same drawing family as the tray icons) writes every platform icon set and the 1024 store master. Track D: the "message annotation on the wire" RFC is drafted (bilingual) in `doc/rfcs/2026-09-30-tim2tox-message-annotation.md`, not yet filed upstream. Chinese telegraph code (P4, §9 item 5): `morse_core` gained `ChineseTelegraphCode` (encode / decode / transliterate, mainland 1983 and Taiwan codebooks, tables generated from Unicode Unihan 18.0 `kMainlandTelegraph` / `kTaiwanTelegraph` by `tool/gen_telegraph_table.dart`, Unicode licence) and the translator keys Chinese characters as four-digit groups with a codebook toggle; handbook page and inbound decoding in chat remain open.
- **2026-09-30 v0.3.8** Tencent native SDK removed from every bundle: `tool/bootstrap_deps.dart` now applies morsecq's overlay `third_party/overlays/tencent_cloud_chat_sdk/` (`tool/vendor_overlay.dart`) after tim2tox's patches — no-op plugin classes for iOS / macOS / Android / Windows, the `TXIMSDK_Plus_*` / `HydraAsync` pods, `imsdk-plus` AAR, `libdart_native_imsdk.so` and `ImSDK.dll` gone, `overlay_sha256` in the vendor state. Verified: both `Podfile.lock` files free of Tencent pods, macOS release build (65 MB) launches with the stub and loads `libtim2tox_ffi.dylib`; a UI-only Android debug APK built on the Mac carries no `com.tencent.imsdk` class or library; the Linux / macOS / Windows CI app builds passed with the overlay (`5101913`). Risk §7 "Tencent SDK as an implicit compile dependency" shrinks to the Dart bindings. Android adaptive icon layers added to `tool/gen_app_icons.dart`. The message-annotation RFC was filed upstream as agentx-icu/tim2tox#20 (§10 item 5 done).
- **2026-09-30 v0.3.9** Test pyramid completed and product screenshots automated (third session; macOS first, other platforms next). ① `apps/morsecq/integration_test/`: `app_launch_test.dart` runs the app's own `main()` on the real platform (fake backend via dart-define) and clicks through onboarding → five tabs → a lesson drill → add friend + send → translator → Me; `screenshots_test.dart` walks 17 scenes × en/zh on seeded fakes and captures the Flutter layer (`RepaintBoundary.toImage` — Flutter 3.41.9's `integration_test` has native screenshots only on Android/iOS), frames travel in `reportData` to `test_driver/integration_test.dart`. ② `tool/screenshots/capture.sh` orchestrates per platform (device pick, `flutter drive`, completeness + distinctness check, publish to `doc/screenshots/<platform>/<locale>/`); `tool/test_pyramid.sh` runs gates → unit → widget → e2e; opt-in `e2e.yml` on a macOS runner; docs `doc/testing/TEST_PYRAMID.md`, `doc/screenshots/README.md`, `tool/screenshots/README.md` (all bilingual). ③ Bugs the top tier found and fixed at the cause: every debug launch on desktop threw at first frame (`AppScope` provided the `DesktopShellController` ChangeNotifier through a plain `Provider`; now `ChangeNotifierProvider`, regression test `test/di/app_scope_desktop_shell_test.dart`); the add-friend sheet tripped a semantics assertion on dismissal on macOS and iOS alike (a `Tooltip` in the Tox-ID field's suffix slot, laid out with a negative height by the shrinking sheet; the scan action is now a labelled button below the field on mobile, desktop keeps its hint line); the accuracy-trend chart skipped a session label (`1 2 3 5 6 7`) and painted the caption over the last tick (integer stride + caption row, `labelledIndices` test). ④ `FakeChatService.addFakeGroupMember` test hook so seeded groups have members. Committed frames: macOS (1280×768 @1x), iPhone 16 Plus and iPad Pro 11 simulators and the Android emulator (@2x), 34 each; the launch test passes on macOS, iOS and Android (Android UI-only build via `ORG_GRADLE_PROJECT_morsecqAllowMissingFfi=true`). Linux / Windows still to capture with the same pipeline.
- **2026-10-01 v0.3.10** All 8 findings of codex review B on the screenshot / pyramid branch fixed (integration-test harness), plus two product defects fixed at the cause. ① Shared audio engine: every `SidetoneSink` ran its own `init`/`deinit` on the one SoLoud singleton, and whichever sink started the engine shut it down on dispose — leaving a drill and opening send practice right away, or chat playback alongside the reference player, silenced the sinks still in use (and two overlapping `init`s make flutter_soloud 4.1.7 rebuild the engine); one Dart path on every platform, so mobile is hit too. Fix: `EngineLeases` in `morse_io` (a per-engine, serialized lease count); each `FlutterSoloudApi` holds one lease and only the last release stops an engine we started; `SidetoneSink.dispose` is single-flight and waits for an in-flight `prepare`, a failed `prepare` gives its lease back and can be retried; `DevicePlaybackFactory` disposes a sidetone it drops. Tests: `engine_leases_test.dart` and new gated cases in `sidetone_sink_test.dart`. ② `tool/screenshots/capture.sh` resolved a relative `MORSECQ_SHOT_STAGING` (what CI passes) from `apps/morsecq/` in `flutter drive` but verified it from the repo root, so CI captures could never pass; it is now absolute (native `pwd -W` form on Windows). ③ Harness: `settle()` tolerates only the `pumpAndSettle` timeout; every capture asserts its screen and seeded content and taps only hittable targets; the window is calibrated on the Flutter view (`window_manager` sizes the outer frame — the earlier macOS 1280×768 was the title bar eating 32 px; now a true 1280×800), a mismatch fails on Linux/Windows; out-of-range knobs throw; the launch test clears the fake identity's default data root and taps the friend by its stable key; seeded timestamps all derive from `seedAnchor()` (never in the future); without an audio device the drill falls back to the flash and the capture waits for it to go dark. ④ `e2e.yml` gains Linux (xvfb) and Windows jobs.

- **2026-10-01** — Implemented the eight layout-audit fixes: draft ownership and write order, older history and reading continuity, clear confirmation, keyboard-safe group forms, scaled reference cards, compact Classic lessons, and visible stacked appearance previews. See the bilingual layout-review implementation plan.

- **2026-10-01** — Layout-fix validation completed at UI revision `1a4b9db471827b067abd267c50aa6a8b9b1c2bd6`: independent diff review, Analyze CI (533 app tests passed, one conditional skip), and all three desktop E2E jobs passed. Refreshed the six-platform bilingual Modern Calm gallery through the official pipeline; Linux/Windows provenance is E2E run 36836332406.

- **2026-10-01** — Integrate the advancing master persistence implementation into the layout-fix branch. Keep both draft concurrency protection and identity/background durability; add the overlapping-route same-key restore regression and revalidate the merged UI before delivery.

- **2026-10-01** — Compose durability now shares committed/error state across reopened editors. Background and identity flushes wait for queued writes; failed drafts remain retryable without another edit, while replacement invalidates their cache. Regression coverage includes restoring with a disposed failed editor and reverting to previously saved text behind a pending write.

- **2026-10-01** — Integrated layout/persistence verification passed all 594 app tests (one existing skip), analyzer and project gates; independent merge review found no remaining blockers.

- **2026-10-01** — Revalidated the integrated layout/durability changes: 594 app tests passed with one existing skip; Analyze and three desktop E2E jobs passed at UI revision `0a83b325f8d9533340b851cf40672d129d4991fd`. Refreshed the complete 204-frame Modern Calm gallery, with Linux/Windows imported from run 36839181762. The user requested title-free versions of all six concept boards; English and Chinese README images retain their respective UI language.

- **2026-10-01** — Added the "me" (note-to-self) conversation: Contacts starts with the own display name and its messages stay on the device. At the user's request the never-on-the-wire guarantee lives in tim2tox's `FfiChatService` (toxee needs it too); morsecq adds only the contract and UI. Plan and code were reviewed by Codex.

- **2026-10-01** — Display-name rename to MorseCQ on all platforms (see §1.1 for what is renamed and which identifiers stay lowercase); product-name prose in this plan now reads MorseCQ (earlier change-log entries kept verbatim). Why: the user asked for one product name everywhere; keeping identifiers avoids orphaning existing Tox profiles and settings.

- **2026-10-02** — The "me" conversation can no longer be deleted (user requirement). Previously Delete (swipe left or the row menu) emptied all its notes while keeping the row; now the contract, the Tim2Tox transport and the fake all refuse `deleteConversation` for it with `self_conversation` before changing anything, and the conversation list drops Delete from its menu and swipe on every platform. "Clear history" inside the conversation remains the explicit way to empty it. No new user-facing string: the UI never reaches the refusal.

- **2026-10-03** — Expanded interface languages from English/Simplified Chinese to ten locales by adding Traditional Chinese, Japanese, Korean, German, French, Spanish, Portuguese and Russian. Each added ARB translates all 562 messages; documentation remains English/Simplified Chinese only. Apple language declarations and mobile/desktop language tests follow the shipped set. Long review-status labels wrap on narrow screens. See [the language expansion plan](./2026-10-03-interface-languages.md).
