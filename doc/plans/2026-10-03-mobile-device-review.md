# Mobile-device review

**Goal:** find where phone and tablet characteristics (OS lifecycle, audio sessions, touch and screen size, platform policy) break MorseCQ on iOS/Android, and fix the real defects at their cause.

**Method:** four parallel reviews with disjoint file ownership (lifecycle/notifications, audio/haptics/microphone, touch/layout, platform config/storage), then a second wave for the fixes that crossed areas. Every fix was first reproduced by a failing unit or widget test (phone sizes, text scale, soft-keyboard insets and lifecycle states are simulated). Nothing here was run on a physical device; see "Device checks still owed".

## Fixed

### Lifecycle and notifications

| Finding | Mobile scenario | Fix |
|---|---|---|
| Cold-start notification tap lost | The tap fires during `NotificationCenter.start()`, before the startup gate (password unlock) lets `AppShell` subscribe | The latest unheard tap is held and handed to the first subscriber |
| Permission prompt from the background, repeated | Android 13+ `POST_NOTIFICATIONS` requested from a stopped activity on the first background post; denial not cached | Silent check first; prompt only in the foreground and at most once per session; concurrent posts share one pending prompt |
| iOS freezes the app ~5 s after backgrounding, cutting the flush | No `beginBackgroundTask` | Native channel `icu.agentx.morsecq/background_task` holds a task from background to resume/expiry |
| Open conversation still notifies; marked read while backgrounded | Nothing called `setActiveConversation`; mark-read ran regardless of foreground | `ConversationPresence` sets/clears the active conversation by route and tab visibility; mark-read waits for foreground (iOS `inactive` counts as foreground) |
| Notification tap pushes a duplicate screen | Tapping a notification for the conversation already open | `_openConversation` skips the push; friend-request / group-invite taps open the Chat / Groups tab |

### Audio, haptics, microphone

| Finding | Mobile scenario | Fix |
|---|---|---|
| Sidetone silent with the ring/silent switch on, muted on lock | flutter_soloud leaves the iOS session at SoloAmbient | `morse_io` sets `playback` + `mixWithOthers` and activates it before starting the engine (`audio_session`) |
| Tone dead after a call / Siri interruption | `SidetoneSink.on()` only changed the volume of a looping voice, which does not restart a stopped device | Every key-down resumes the device and replaces a lost voice; refused output is retried on the next key-down |
| App kept alive in the background | With `playback` and `UIBackgroundModes=audio`, the silent looping voice keeps iOS from suspending | On Android/iOS the sidetone stops its voice in the background; `audio` background mode removed |
| Bluetooth headset stuck in call profile after Listen | `record` leaves the session in `playAndRecord` | `RecordPcmSource.stop()` restores the playback session; a new capture waits for the restore |
| Auto-lock stops Listen / drills | No wakelock | Listen, receive drill and send practice keep the screen on only while active (`wakelock_plus`) |

### Touch and layout

| Finding | Mobile scenario | Fix |
|---|---|---|
| Rotation resets every tab | The page area moved between `Scaffold.body` and the rail `Row` at the 600 px breakpoint | `GlobalKey` keeps page state across the move |
| iPad landscape→portrait drops the open conversation | Two-pane collapse in Chat and Groups | Selected conversation reopens as a full-screen route after the frame (drafts survive through the shared draft writer) |
| Keyed composer taller than a landscape phone | 667×375 overflow, 85–148 px at 2× text | Compact pad (88 dp) under 500 px height; composer capped at 75 % and scrolls |
| Translator overflows / field under the soft keyboard | Portrait with keyboard, landscape, 2× text | `ReferenceMinHeight` gives a scaled minimum height and scrolls |
| Overflows at 320 px and 2× text | Navigation rail, conversation header, bytes-left, send-practice app bar, identity card | Scrollable rail, `Flexible` + ellipsis, icon-only switch with a semantic label |
| Leaving a drill loses the session silently | Android back / predictive back / iOS edge swipe | `DrillLeaveGuard` (`PopScope`) asks once there is progress; on iOS the edge swipe is disabled while guarded (Flutter behaviour) and the back button asks |

Touch keying itself needed no change: the paddles and straight key use raw `Listener`s (no gesture arena, no tap delay), handle two-finger squeeze, pointer cancel from system gestures and enclosing scroll views; new tests pin that.

### Platform config and storage

| Finding | Mobile scenario | Fix |
|---|---|---|
| Tox identity copied by Android cloud backup / device transfer | Default `allowBackup` | `allowBackup="false"`, `fullBackupContent="false"`, `data_extraction_rules.xml` (as toxee) |
| Tox identity in iCloud/iTunes backups | Application Support is backed up | `<appSupport>/morsecq` marked `isExcludedFromBackup` via a channel on every directory setup and before a restore |
| Play filters out devices without autofocus camera or mic | CAMERA / RECORD_AUDIO imply required features | `uses-feature … required="false"` |
| Permission prompts English only | Info.plist strings not localised | `InfoPlist.xcstrings` with all ten languages |
| `UIBackgroundModes=audio` unjustified (App Review 2.5.4) | Nothing plays in the background | Key removed; no background mode declared |
| iPad share popover detached from the button | Backup export from the wizard and the Me page | `sharePositionOrigin` from the tapped widget |
| Camera permission denied shows an English error code | mobile_scanner default error view | Localised `errorBuilder` (`chatScanQrPermissionDenied` / `chatScanQrCameraUnavailable`) |

## Not fixed (and why)

- **Screen readers cannot key** on the on-screen key: Morse keying has no meaningful semantic-tap equivalent.
- **Key legend hidden on iPad/Android with a hardware keyboard:** cosmetic; keyboard keying works.
- **"Open settings" buttons** for permanently denied mic/camera: needs a new dependency (`permission_handler`); the messages already point to system settings.
- **Resume does not re-bootstrap Tox** while the engine is running: toxcore re-pings known DHT nodes after a thaw; needs device evidence before changing.
- **Password-protected profile plaintext on disk while running:** belongs in tim2tox native savedata encryption (upstream).
- **`ITSAppUsesNonExemptEncryption`:** an export-compliance decision for the owner.
- **Bluetooth A2DP sidetone latency (150–250 ms):** inherent to the transport.

## Device checks still owed

iPhone: tone with the silent switch on; tone after a call, Siri, and another app's music; app suspends in the background; background flush completes; Listen and drills keep the screen awake; edge swipe is blocked in a drill with progress and the back button asks. Android 13+: notification permission prompt in the foreground only; predictive back on a drill; data-extraction rules (`adb shell bmgr`). iPad: share popover anchor; rotation with an open conversation.

## Change log

- **2026-10-03** — Initial review and fixes (four review agents, three fix agents; analyzer zero issues, import guard and complexity gate OK, all package and app tests green).
