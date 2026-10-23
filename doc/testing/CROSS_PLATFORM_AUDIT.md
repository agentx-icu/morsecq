[简体中文](./CROSS_PLATFORM_AUDIT.zh-CN.md)

# Cross-platform audit and fixes — 2026-10-22

Scope: Android, iOS/iPadOS, macOS, Windows and Linux. This takes over the
read-only audit at `3629d16` and rechecks causes against this repository; old
agent conclusions are not treated as runtime evidence. No RTK or Claude tools
or review were used. Shared package differences are pinned through
`tool/shared_sync.dart`, preserving each product's existing training features.

Local profile: Flutter 3.41.9 / Dart 3.11.5, macOS 27.0.1 (26A434), arm64,
macOS SDK 26.4. Release app is universal (arm64/x86_64), 57.0 MB. Native UI was
1100×760 logical pixels at Retina scale, English/dark; close-to-tray was changed
for the check and restored to its original off choice. No Windows/Linux or
mobile hardware run is implied by these Mac checks.

## Rechecked findings

| Audit ID | Result and evidence |
| --- | --- |
| D-1 P1 | Fixed in code: live `IsStatusNotifierHostRegistered` over bounded `gdbus`, rechecked before hiding. Missing/failed host falls back to a real close. Controller regression passes. GNOME without an extension and a host disappearing while hidden still need Linux checks. |
| D-2 P1 | Fixed: AppKit reopen shows the original window and notifies Dart. Last-window auto-termination is off; explicit quit remains in the controller. Native release check kept one PID and the Me page after hide/reopen. |
| D-3 P1 | Fixed: support-directory OS lock is acquired before settings/learning open and held until process death. Authenticated loopback activation queues an early request; minimized windows restore. Separate-process regression covers activation and SIGKILL recovery on this Mac. Windows/Linux native behavior remains untested. |
| D-4 P1 | Fixed: closing defaults to quit; Me exposes and persists the tray choice in all ten locales. Widget check and native release on/off checks pass. |
| D-5 P1 | Fixed declarations and policy: Android backup/transfer includes only `morsecq/guest/` and `settings.json`, for both rule formats. Static tests pass. Actual cloud restore/transfer is needs device; the OS settings and 25 MB cloud quota apply. |
| D-6 P2 | Fixed: no sound menu appears without an audio owner callback. This avoids a misleading independent mute setting; training/reference retain their working controls. Regression passes. |
| D-7 P2 | Fixed: future progress/settings versions are rejected before field decoding, atomic recovery and controller defaulting. Newer primary and backup files cannot be overwritten. Recovery copies are retained. UI explains update recovery. Telegraph recall already had a write guard; the new codec rejection strengthens its read behavior. Real file/controller tests pass. |
| D-8 P2 | Fixed: calendar arithmetic uses civil dates, weekday rows follow the localized week start, and tooltip time honors the system setting. Berlin DST, Sunday-first and 12/24-hour regressions cover the fixes. |
| D-9 P2 | Fixed: 24 px bounded, lower-luminance lamp replaces the full-page strobe; reduced-motion mode is steady and does not subscribe to key transitions. Settings warns before enabling. Shared widget and settings tests pass. This does not constitute a photosensitivity medical assessment. |
| D-10 P2 | Partial: cancelable framework exit waits for local saves/bounds, cancels on errors/timeout; native Mac Cmd-Q exits. Immediate checkpointing continues. Windows WM_QUERYENDSESSION/session end and forced termination cannot be claimed from this hook; native bridge/device verification remains to do. |
| D-11 P2 | Fixed: DEB/RPM declare `pulseaudio-utils`; tar users are documented. Missing `parecord`/`pactl` has a typed localized recovery message. Controller tests pass; installed Linux packages need verification. |
| D-12 P2 | Partial: Dart split-debug-info plus available dSYM/PDB are archived; bounded on-device diagnostics omit exception messages and are exported only by an explicit Me action. Rotation/redaction tests pass. Installed/upgrade smoke for all five artifacts and native-crash collection remain to do. Mac release bundle launch is not installer evidence. |
| D-13 P2 | Partial: latent mute binding uses Cmd/Ctrl+Shift+M, leaving native Cmd+M free. Alphabet cards and rows support secondary-click; rows have a visible mnemonic action. Pointer regressions pass. App-wide menu wiring and reliable attached-keyboard hints on tablets remain to do. |
| D-14 P2 | Partial: tag builds require owner Android keys; actual APK/AAB matching non-debug certificates are checked (four verifier regressions). Windows Authenticode and Apple distribution signing/notarization require credentials. Compatibility Mac/visionOS opt-out is recorded but must be applied by the owner in App Store Connect. |
| D-15 P2 | Fixed assets: macOS 36 px at 18 pt, Linux 64 px, Windows existing multi-frame ICO. Generator and size/alpha tests pass; Linux fractional-scale visual check remains needs device. |
| D-16 P2 | Fixed: vibrator presence is probed separately; unavailable devices cannot enable the setting and receive an explanation. Fake-capability settings regression passes; real iPad/tablet haptics remains needs device. |
| D-17 P2 | Fixed: no default camera-torch plugin is linked. Optional `TorchApi` injection remains; default reports unavailable. Sink tests pass and the lockfile no longer contains `torch_light`. Final mobile package inspection remains to do. |
| D-18 P2 | Draft store answers, compatibility availability decision and explicit release size/start targets are now in the bilingual store guide. Only the Mac bundle size was measured; console approval and startup budgets are not claimed as verified. |

## Checklist disposition

`verified` below names the bounded evidence, never untested platform behavior.
`to do` is an identified implementation/process gap; `needs device` requires the
specified OS/hardware. No store acceptance is inferred.

| ID | Status | Evidence / next check |
| --- | --- | --- |
| L1, L2, L4, L7 | verified by automated layout | Width-based layouts, screens and overlays across safe-area/keyboard profiles. Actual-font sweep: 775 passed (real fonts). |
| L3 | verified in widget resize; needs device | State-preserving resize sweep; real mobile rotation and desktop monitor removal still require native checks. |
| L5 | verified for rectangular keyboard sweep; needs device | iPad floating/split keyboard and desktop touch keyboard not exercised. |
| L6 | verified declarations | Android no orientation lock; iPhone three/iPad four supported orientations and no full-screen-only flag. |
| L8 | needs device / to do | Fold hinge placement needs foldable testing and any required separating-pane adaptation. |
| D1, D2 | verified in tests | Ten ARBs, explicit new translator notes, real-font text-scale matrix; Bold Text/RTL native checks remain outside evidence (no RTL locale ships). |
| D3, D5 | verified assets; needs device | Tray resolution and launcher format tests; native fractional scaling not measured. |
| D4 | needs device | Mixed-DPI monitor movement/removal on Windows, Retina/non-Retina on Mac. |
| D6 | statistical text verified; full audit remains | Existing statistics backgrounds are preserved; foreground text uses actual luminance to meet 4.5:1 across five styles/light/dark, all buckets and 101 ramp positions. Full-app/composited/native high-contrast validation remains. |
| D7 | verified in widget tests | Reduced-motion flash has no key-rate listener. |
| I1 | statistics targets verified; app-wide audit remains | Visible chart selectors/menu rows and character-detail cells have real targets at least 48 logical px, with actual menu/character edge taps and 320 px/3.1× German grid coverage. Small painted chart cells retain their original hit regions; other controls still need measured coverage. |
| I2 | partial / to do | Reference search binds primary+K only on its selected, current route, with editor/IME and repeat guards; 18 real keyboard-event widget regressions cover five platform semantics and responsive navigation. Native menus and physical tablet keyboard/assistive input validation remain. |
| I3 | verified in tests | Text submission uses IME-safe submission; keying focus/pointer/keyboard suites pass. Native CJK IME remains needs device. |
| I4 | verified declarations/tests | PopScope drill guard and predictive-back manifest; native back gestures need device. |
| I5 | chart semantics verified; native qualification needs device | Existing calendar/session/confusion details are available through localized standard selectors, keyboard focus and actual semantics actions. VoiceOver, TalkBack, Narrator and Orca still need complete native-flow validation. |
| I6 | verified in tests | Civil-date DST and system time/week formatting regressions. |
| I7 | verified in tests | Pointer cancellation releases keys; mnemonic secondary-click and visible row action. |
| I8 | not applicable | No incoming verified links or protocol handlers; outgoing website links use OS browser. |
| I9 | verified in tests; needs device | Clipboard plain text, import copies and anchored sharing; installed cross-app access remains native. |
| B1, B2 | verified in tests; bounded native Mac | Resource-specific lifecycle, immediate writes, queued saves and cancelable exit barrier. No forced-exit guarantee. |
| B3 | needs device | Activity/process death with a picker open; supported committed state already reopens in store tests. |
| B4 | verified declarations/tests | No background audio/FGS claim; existing iOS grace-task bridge, wake-lock cleanup. Sleep/audio-route behavior needs device. |
| B5 | verified separate-process Mac test; needs device | Lock, activation, crash replacement; Windows/Linux launch twice and native multi-window checks outstanding. |
| B6 | not applicable | No network transfers/jobs; local result commit IDs retain existing retry coverage. |
| B7 | verified in tests | Future schema preservation and actual controller refusal; legacy fixtures remain covered. |
| B8 | not applicable | Account-free offline app has no sync/conflict service. |
| P1 | verified source tests; to do packaged mobile | Optional microphone, unchanged purpose strings; Mac release entitlements inspected separately. |
| P2, P3 | verified unit/widget paths; needs device | Permission denial, absent input, unavailable vibrator and missing Linux tools degrade visibly; revoke while capturing remains native. |
| P4 | to do | Owner privacy declarations and shipped-SDK required-reason manifests must match final signed artifacts. |
| P5 | verified rules; needs device | Backup policy reflects source; Android backup/restore/transfer and iOS restore must be exercised. |
| P6 | verified source/tests; needs device | Selected materials copied to local storage; security-scoped installed share/picker behavior remains native. |
| P7 | deliberate policy | Ordinary local learning screens may appear in OS snapshots; no identity secrets, remote privacy surface or screenshot-blocking promise. |
| P8 | not applicable | No purchases or entitlements. |
| P9 | draft / to do | No accounts/UGC service; store answers and availability actions require owner console checks. |
| M1, M2 | needs device | Silent switch, call/Siri interruption, wired/Bluetooth route changes on iOS/Android. |
| M3 | not applicable | No camera feature; default torch plugin removed. |
| M4, M5 | verified in tests; needs device | WAV/PCM processing and bounded streaming suites; low storage and cross-OS installed export remain native. |
| M6 | not applicable | No notifications. |
| M7 | verified capability path; needs device | Vibrator unavailable and microphone absent paths; real optional hardware checks remain. |
| M8 | not applicable | No screen/system-audio capture or remote-input feature. |
| W1 | verified math/fakes; needs device | Normal bounds retained through maximize/full-screen/minimize; Wayland refusal and monitor changes remain native. |
| W2 | verified controller tests and Mac release actions; needs device | Close/reopen/quit observed on Mac; GNOME no tray and Windows session end remain. |
| W3 | verified source/store tests | Per-OS support directory and atomic serialization; unusual volumes/long paths remain needs device. |
| W4 | partial / to do | Mac universal release builds; installer/upgrade, Windows signing and Apple notarization/availability outstanding. |
| F1 | needs device | Frame pacing at 90/120 Hz and mixed refresh. |
| F2 | size-budget hard gates implemented; startup needs device | Existing APP_STORE per-architecture artifact/payload limits are enforced on final bytes with retained reports; boundary/oversize and owner-IPA refusal regressions pass. Exact-head artifact results are recorded in the PR. Cold ≤5s / warm ≤2s to usable Learn still needs the release device matrix. |
| F3 | verified lifecycle tests; needs device | Wake-lock/background cleanup; power/thermal device measurements outstanding. |
| X1, X3, X4, X7 | needs device | Device matrix and interrupted-flow plan below; no simulator result is promoted to hardware evidence. |
| X2 | verified actual-font sweep | 775 passed (real fonts); dimensions and detectors documented in TEST_PYRAMID. |
| X5 | verified pins | Shared fixes ported without overwriting existing DitMesh feature differences; sync gate passes. |
| X6 | partial / to do | All-platform release workflow exists; only local Mac release build/run exercised, no installed-upgrade claim. |
| X8 | not applicable to remote service | No Internet bootstrap/service; loopback IPC is tested locally and rejects unauthenticated tokens. |
| X9 | partial / to do | App-owned Dart diagnostics now use fixed events/type and internally captured code coordinates/PCs; raw supplied stacks, release error forwarding and catch-log bypasses are excluded. Rotation/copy/legacy-log, early-storage and product-policy regressions pass. Capture-point stacks do not reconstruct the original exception. Native crashes, worker isolates and matching shipped-build symbolication remain to do / need device. |


## X9 Dart diagnostics boundary — 2026-10-23

| Item | Status | Evidence / remaining work |
| --- | --- | --- |
| Framework/runtime error exits | verified policy tests | Hooks install before startup without storage; release does not forward raw Flutter details and reports runtime errors handled, preventing the embedding stderr fallback. Debug framework/test observers remain active. |
| Private-content exclusion | verified synthetic regressions | Exception messages and caller-supplied stack text are not persisted. Only the recorder's own VM code coordinates/numeric AOT metadata are selected. Synthetic paths/content are absent from current/rotated/copied logs; legacy raw files are replaced. |
| Retention and exclusive ownership | verified unit tests | At most two 256 KiB files; initialization retries after unavailable storage. Hook installation opens no shared store; main retains owner-before-file initialization. Reports before file availability cannot be retained. |
| Catch-log parity | verified product-policy tests | Actual preference-save failures, null/explicit shell sinks and the shared audio/wake failures preserve debug observability and emit no raw release console text. Identical shared patches are coordinated with DitMesh; only their pins move. |
| Shipped-build/native coverage | to do / needs device | On iOS, Android, macOS, Windows and Linux, install the final artifact and trigger synthetic framework, async/native-bridge and native errors; confirm marker absence in OS logs and the exported bundle, then symbolize against that artifact's archived symbols. Native reporter integration, worker-isolate forwarding and original-error stack reconstruction are not completed by this patch. |

`Diagnostics product-policy regressions` runs with Dart product constants and an explicit release-mode assertion in Analyze CI. This checks code paths under the test runner; it is not evidence of an installed AOT release. No SDK, telemetry endpoint, account, credential or permission is added. See [retention and startup details](../operations/BUILD_AND_DEPLOY.md).

## Statistics detail alternatives (I1/I2/I5/D6)

The existing calendar, accuracy trend and confusion heatmap keep their painted
charts and pointer selection. A visible standard selector offers the same local
snapshot entries and updates the same selected-detail state. It supports Tab,
Enter and arrow navigation, localized menu labels/selected values and standard
semantics actions; no network, permission or new statistics feature is added.
Replacing a snapshot dismisses an old menu so its coordinates cannot select a
different record. The existing heat legend now wraps its labels while preserving
the colour sequence at large text sizes.

Thirteen new regressions cover first/last keyboard selection and exact detail
data, semantics actions, real 48 px menu-edge hits, 320 px/3.1× German text,
pointer-state equivalence, empty data and stale-menu cancellation. Character
cells now retain a real 48 px minimum target; narrow/large-text grid and straight
edge hits are tested. Text on the unchanged statistical background palette uses
the first qualifying theme foreground by actual luminance, with opaque black or
white only when no theme text passes 4.5:1. All five styles in light/dark, every
bucket and 101 ramp positions are measured. The full statistics suite still
passes. These controls provide an accessible
equivalent path; they do not enlarge each 8–18 px calendar or 30 px heatmap cell,
or certify a system screen reader. This is MorseCQ product UI: DitMesh has no
corresponding statistics screen, so X5 does not call for adding one there.

## Verification

- Root analysis: zero issues; tool analyzer, complexity, import, UI-literal and shared-sync gates pass.
- `tool/test_pyramid.sh --level unit`: all five packages and tool suites pass.
- The earlier complete application suite passed 1163 tests with 753 default real-font layout skips. The final expanded run passed 1177 with 753 skips; two new Android time-format tests hit the framework debug-variable restoration invariant after their behavior assertions. Replacing that setup with TargetPlatformVariant passed all four tests in that file; unchanged tests were not rerun again.
- Actual-font layout sweep: 775 passed (real fonts). Fonts: NotoSansCJK-Regular.ttc from the upstream noto-cjk repository, system Menlo and Songti; font artifacts remain local build outputs.
- `TZ=Europe/Berlin flutter test .../stats_model_test.dart` passes; system 12/24 and Sunday-first widgets are covered.
- Signing verifier: four tests; screenshot-import, release-asset and Apple cache packaging regressions are run locally.
- `flutter build macos --release --split-debug-info=build/symbols/macos`: 57.0 MB universal release. Native GUI hide/reopen kept PID and Me page; tray-off close exited 0; Cmd-Q left no process. `window_manager.destroy` can emit an engine-response-handle warning during termination; no data-loss inference is made from the process exit.

## Final validation update

- Future training progress/settings, materials/audio documents and telegraph recall are refused before writable controller defaults. Primary and backup are checked independently, so a current primary cannot rotate over a newer backup. General application preference KV data is outside this training-schema protection.
- Exit flush, minimized restore, authenticated instance activation, SIGKILL lock recovery and update-recovery messages have local regressions. The final Berlin DST run passed 15 tests.
- Shared pins reference clean DitMesh commit `7d45e048fd786b1779d98d6a78bec4b658a8ea60`, preserving pre-existing product learning features by file.
- Python regressions passed: signing 4, screenshot import 19, release assets 7, Apple cache 4, components 3, runtime 9. The Apple C++ fixtures initially encountered an incompatible default CommandLineTools MacOSX27.0 SDK/Xcode linker pair. Running only those commands with `SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.4.sdk` passed; system configuration was not changed.
- Logs are local ignored outputs under `build/xplat-verification/` and `apps/morsecq/build/xplat-*.log`. The final release build succeeded at 57.0 MB; native close/reopen evidence has the bounded scope stated above.

## Device and release follow-up

Linux GNOME without a tray extension: launch twice, hide/close, remove the host,
then relaunch; install DEB/RPM on a clean PulseAudio/PipeWire image and start
Listen. Windows: launch twice while minimized/hidden, mixed-DPI monitor removal,
close/tray/Cmd-equivalent quit and actual logoff/shutdown with a pending write.
Android: backupnow/restore and device transfer; deny/revoke microphone; process
death during file selection. iOS/iPad: backup restore, floating/split keyboard,
VoiceOver and actual vibrator absence. Foldables: separating hinge and posture
changes. Media: wired/Bluetooth disconnects, incoming calls and silent controls.
All targets: install prior signed release, create progress, upgrade and inspect
actual packaged permissions, architectures and final signatures. Native crashes,
120 Hz pacing, startup time and store console settings remain explicit gaps.


Installed Windows MSI CI now checks final-file hashes, visible launch/graceful close, missing-DLL repair and uninstall. See [current store readiness](../release/STORE_READINESS.md#installed-windows-msi-evidence) for scope and owner/device boundaries; earlier local-Mac-only statements above are historical. Native signing, standard-user and previous-version upgrade are still not verified.
