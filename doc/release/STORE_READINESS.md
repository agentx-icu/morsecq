[简体中文](STORE_READINESS.zh-CN.md)

# Store and distribution readiness — 2026-10-23

This audit applies the updated cross-platform checklist's store reference to
MorseCQ 1.0.1+2 (`icu.agentx.morsecq`), an offline education app without
accounts, ads, purchases, a UGC service or a network backend. Private imported
materials are local files. UI languages are en, zh-Hans, zh-Hant, ja, ko, de,
fr, es, pt and ru; this does not establish ten localized store listings.
Publisher accounts, territories, legal entity, listing IDs and reviewer decisions
have not been inspected. They must be supplied by the owner, never guessed.
The [previous 65-item audit](../testing/CROSS_PLATFORM_AUDIT.md) remains the
bounded UI/lifecycle evidence; the following replaces its store-readiness gaps.

## Channel matrix

“Existing” means a repository build/packaging route, not a published listing.
R = requirement for the selected route; C = conditional on the stated trigger;
A = optional programme. A route marked unselected is not certified or globally
inapplicable: its owner must choose it before implementation/submission.

| Channel / territory / package | Selection and current evidence | Remaining owner action |
| --- | --- | --- |
| GitHub development releases / owner-selected countries | Existing: Android APK/AAB, unsigned iOS IPA, macOS PKG/ZIP, Windows x64 MSI/ZIP, Linux x86_64 DEB/RPM/tar; ten assets and checksums, release drafts only | Record version/tag/artifact hashes, rights and countries; approve publication separately. Default Apple/Windows development packages are not Store or trusted distribution builds. |
| Apple App Store / iOS + iPadOS / territories unconfirmed | Preparation route: controlled local manual export via `tool/build_ios_store.sh`; CI also validates the same unsigned Xcode archive route, without account changes | R: verified team/app record and agreements, distribution profile, processed build, privacy labels/report, export questionnaire, ratings, listing/support/privacy URLs. C: trader/territory information. Rehearse first lesson, microphone denial and file import without a review login. |
| Native Mac App Store / macOS universal2 / territories unconfirmed | Unselected submission route; native app is sandboxed, but no Store-signed exported package or console evidence | Owner decides same-record macOS vs separate record; configure Store signing/packaging and Store updates, test sandbox microphone/import/export and prior-data upgrade. Developer ID PKG is a different route. |
| Developer ID direct download / macOS universal2 | Existing development PKG/ZIP; explicit distribution mode now signs nested code, verifies team/type, notarizes and staples the final deliverables | Supply verified identities/team/notary profile; run the owner-invoked path and retain Gatekeeper/download-quarantine, install and upgrade evidence. No real identity/notarization was exercised in this audit. |
| Compatible iOS app on Apple silicon Mac / Vision Pro | Previous decision is opt-out pending validation; native macOS already has a separate binary. Actual availability is unknown | Owner captures App Store Connect opt-out for both surfaces. If enabled or replaced on the same record, test plugins, hardware fallback and local progress/settings continuity. Native macOS build does not prove compatibility-iOS behavior. |
| Google Play / Android mobile armv7, arm64, x86_64 / territories unconfirmed | Preparation: AAB + matching APK, target 36/minimum 24, full native/manifest/alignment gate; tagged signatures must match owner upload SHA-256 | R: account/app identity, upload vs Play distribution certificates, Data safety/privacy, app access, ads/audience/rating, device catalog and delivered APKs. C: personal-account production access/closed testing; owner verifies current console conditions. Physical 16 KB image, signed update and Play review remain open. TV, XR, Wear and Automotive are not selected products. |
| Direct Windows download / x64 MSI + ZIP | Existing development path; CI and local distribution gates check all PE headers and Flutter's canonical `data/app.so` ELF AOT CPU; CI also checks final ZIP payload and MSI Template Summary. Opt-in signing verifies all included PE and installer signatures | Owner supplies certificate fingerprint, tests standard-user install/upgrade/uninstall and runtime dependencies. Rebuild/zip hashes cannot establish SmartScreen reputation. |
| Microsoft Store hosted MSI/EXE / PC-only non-game / territories unconfirmed | Candidate, not a submission route yet; MSI source exists | C: current policy 10.2.9 requires immutable versioned HTTPS URL, standalone offline/silent installer, trusted signatures on installer and every included PE. Reserve product, verify identity/rating/privacy and install lifecycle from the final URL. |
| Microsoft Store MSIX / x64 / territories unconfirmed | Unselected; no MSIX identity or package exists | Owner chooses this separately from MSI, supplies Partner Center identity, creates/tests capabilities, update path and WACK. Microsoft re-signs Store submissions; do not buy a CA certificate merely for Store MSIX submission. |
| Direct Linux / Ubuntu 24.04 baseline / x86_64 DEB,RPM,tar | Existing packaging; ELF machine inventory and declared media/tray dependencies; no distro-repository approval | Owner chooses supported distro/session matrix and signature/update trust; install on clean systems, test microphone/tray, upgrade and uninstall. RPM build alone does not prove other distro compatibility. |
| Flathub / Snap Store | Neither channel selected; no manifest/snap/listing generated | Owner chooses runtime/confinement, portals/interfaces, rights and update tests. Flathub currently reserves manifest authorship and submission/review interactions to humans; known AI material needs disclosure. This project PR is not a Flathub submission. Snap stable requires eligible confinement and actual interface grants. |
| Huawei AppGallery / mainland China Android APK | Unselected; detailed public review pages not readable | Owner checks current account, APK-specific guide, qualifications/filing applicability, privacy labels and console rules. HarmonyOS/quick apps are different targets. |
| Xiaomi / mainland China Android APK | Unselected; public listing rules inspected | Current guide calls for first-run privacy accept/reject and matching developer/contact/policy information. Current account-free app intentionally has no acceptance gate; implement a channel-specific flow only after owner selection and scoped design. |
| OPPO / mainland China Android APK | Unselected; public portal requires JavaScript | Owner obtains migrated review guide and confirms entity, qualifications, privacy/review access and territory requirements. A passing Play artifact does not certify it. |
| WinGet, Homebrew Cask, F-Droid, distro repositories | Unselected additional routes | Each needs its own source/licensing, identity, signatures, recipe/hash and installed update evidence. No submissions are generated here. |

## Checklist record

| ID | Status | Evidence |
| --- | --- | --- |
| P4 / Apple | verified payload checks; to do owner review | macOS app privacy manifest added and built; all bundled manifest declarations, ten microphone localizations and signed functional entitlements are inspected. SDK privacy/required-reason inventory is retained in JSON. Archive privacy report, required-SDK signatures, labels and real signed exports remain owner gates. No-collection source draft is not a completed form. |
| P4 / Play | verified gate; needs device / owner | Inspect final APK and AAB manifests, SDK/permissions/features, every native ABI and PT_LOAD, stored-APK ZIP alignment and bundle delivery alignment. Signature comparison pins the owner upload certificate and verifies AAB contents. Play-distributed certificate, console forms and 16 KB execution remain separate checks. |
| P8 | not applicable | No purchases, paid unlocks, billing SDK, subscriptions or entitlement server. Re-audit per channel/storefront if monetization is introduced. |
| P9 / accounts, login, UGC | not applicable | No account creation (including automatic/guest identity), third-party login, user-to-user communication or hosted posting. Local learning reset is not a server-account deletion claim. |
| P9 / audience, listings, rights | to do owner | Complete current Apple/Play/Microsoft questionnaires and listing locales, content/screenshot rights, publisher/trader fields and selected countries. Education does not automatically mean a Kids/Families category. No accessibility label may be claimed without testing its complete flow. |
| W4 / direct artifacts | partial | Development vs distribution policy is explicit. Missing-owner-material tests fail closed; wrong-team/debug certificates and incompatible payloads are rejected. Trusted signing/notarization and final installed upgrades require owner credentials/hosts. |
| W4 / stores | to do owner | Matrix distinguishes Mac Store/Developer ID, MSIX/hosted MSI, direct Linux/Flathub/Snap and domestic Android. No listing, submission, certificate purchase or account change was made. |
| X6 | verified local Mac payload; CI gate; needs installed hosts | Per-target release CI retains `evidence-*` reports with native-module SHA-256, identity/declarations and architecture data. Payload headers do not prove target-machine loading. Final clean install, previous-release upgrade and protected-feature tests remain required per channel. |

## Dated official policy evidence

Checked **2026-10-23**; re-open at the actual release. These are channel triggers,
not timeless numeric thresholds encoded by the test tools.

- [Apple submission SDK requirements](https://developer.apple.com/news/upcoming-requirements/): current mobile submissions require Xcode 26/SDK 26; deployment minimum is a different value. The project deployment minimum is iOS 14, a separate product value; the owner must recheck the current submission requirements at release. [Review 2.4.5](https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility) describes the Mac Store route. [Export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/) and [accessibility disclosures](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels/) still need console answers; no eligibility or rating was invented.
- [Play target API](https://support.google.com/googleplay/android-developer/answer/11926878): mobile new apps/updates require API 36 from 2026-08-31, with account-specific extension handling. [16 KB guidance](https://developer.android.com/guide/practices/page-sizes) currently states an update block from 2027-02-01; actual ELF/packaging support and a 16 KB runtime test are still required. [App content](https://support.google.com/googleplay/android-developer/answer/9859455) and [personal-account testing](https://support.google.com/googleplay/android-developer/answer/14151465) are owner-console work.
- [Microsoft policy 7.20](https://learn.microsoft.com/en-us/windows/apps/publish/store-policies#102-security), effective 2026-10-22, is the hosted MSI/EXE signing basis. [MSIX package requirements](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/app-package-requirements) describe the separate package path.
- [Flathub requirements](https://docs.flathub.org/docs/for-app-authors/requirements#generative-ai-policy) impose the human submission boundary above. [Snap confinement](https://snapcraft.io/docs/explanation/security/snap-confinement/) and [publishing](https://ubuntu.com/docs/snapcraft/9/how-to/publishing/publish-a-snap/) apply only if selected.
- Mainland checks: [Huawei index](https://developer.huawei.com/consumer/cn/doc/doccenter-submission/50000), [Xiaomi current guide](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322) (updated 2025-09-02), [OPPO entry](https://open.oppomobile.com/new/developmentDoc/info?id=10035). Huawei/OPPO detailed rules remain portal-only owner checks. [MIIT notice](https://www.miit.gov.cn/jgsj/xgj/wjfb/art/2023/art_dd783a581c9644a4aee10afa582811db.html) concerns APP internet-information-service providers; applicability to this offline product needs owner/channel confirmation, not a fabricated filing number.

## Owner evidence and release procedure

Before submission, keep a private release record with: publisher/role and accepted
agreements; download price; selected channel/territory/audience; bundle/package/store IDs;
version/build and prior release; expected signing fingerprints (upload and
store-delivery separately); exact artifact hashes and reports; public support and
privacy URLs tested unauthenticated; listing locale/assets/rights; review steps;
consent and installed-update evidence; console declarations; review status vs
publication status; release operator/track/staged-release decision and stop criteria.
No credentials, review passwords or private console captures belong in Git.

The repository's existing public site paths come from `site/_config.yml` and the
app's link configuration. The owner must verify their live URLs, developer/contact
identity and content before entering a store form; this audit does not invent a
privacy URL or legal contact. The review route needs no account: clean launch →
first lesson → Reference → Listen with grant/denial → import/export → Me reset.
Do not add a paid feature or online review backend just to fill a console field.

CI reports are retained independently from the ten release downloads; symbols are
separate artifacts. Rehearse a previous signed install with progress, update using
the selected channel, then check progress, microphone denial, file access and
uninstall/no orphan process. Retain the old build and backups for investigation;
halting rollout does not undo installed data migrations. Forward-fix data and
binaries; a downgrade needs the existing B7 tests and a separate signed update path.

## Owner materials and where to obtain them

Keep public identifiers, certificate fingerprints and redacted evidence in the release record. The entries below ask the owner to configure existing material in the indicated secure destination; do not send private keys, keystore files, passwords, tokens or unredacted console captures in chat, issues or Git. No account creation, permission expansion or submission is authorized by this checklist.

| Platform / material | Purpose and where the owner obtains it | Safe configuration / blocking step |
| --- | --- | --- |
| All selected channels: publisher, countries, audience, rights, previous version | The owner's developer-account profile and app records; legal/contact and screenshot/content rights from their own records | Record non-secret IDs and redacted decisions privately. Blocks choosing the submission route, listings and signed upgrade matrix; unselected channels remain conditional. |
| Apple: Team ID, bundle/app-record IDs, agreements | [Apple Developer account](https://developer.apple.com/account/) membership and Certificates, Identifiers & Profiles; App Store Connect app information and Agreements | `MORSECQ_APPLE_TEAM_ID` is a public identifier. Owner resolves agreements and identity mismatch; blocks signed iOS export and any Apple submission. |
| iOS/iPadOS: existing distribution identity and App Store provisioning profile | Apple Developer Certificates, Identifiers & Profiles and the owner's Xcode signing/export configuration for `icu.agentx.morsecq` | Keep private keys in the owner's keychain and existing profiles in Xcode's managed storage. Read the non-secret certificate SHA-1 from Keychain Access / `security find-identity -v -p codesigning`; configure `MORSECQ_IOS_CERT_SHA1` plus `MORSECQ_APPLE_TEAM_ID` on the signing host and select a local manual ExportOptions plist. Never commit a `.p12` or password. Blocks the signed exported-IPA checks and device installation. |
| macOS direct download: existing Developer ID Application / Installer identities, notarization profile | Apple Developer certificates, the signing Mac's Keychain Access and the owner's existing `notarytool` keychain profile | Configure `MORSECQ_MACOS_APPLICATION_IDENTITY`, `MORSECQ_MACOS_INSTALLER_IDENTITY`, `MORSECQ_APPLE_TEAM_ID`, `MORSECQ_NOTARY_PROFILE` on the signing host. Identity names/profile name are references, not key material. Blocks trusted PKG/ZIP signing, notarization and Gatekeeper qualification. |
| Google Play: existing upload key, upload and delivery certificate SHA-256 | Owner's existing upload keystore; Play Console app's App integrity / App signing certificate pages. Upload and Play-distribution certificates may differ | Owner configures GitHub Actions secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` under repository Settings → Secrets and variables → Actions. Put the non-secret upload fingerprint in Actions variable `ANDROID_UPLOAD_CERT_SHA256`; local strict packaging uses `MORSECQ_ANDROID_UPLOAD_CERT_SHA256`. Blocks tagged Android signing/identity checks and signed upgrades; do not upload a key to this repository. |
| Windows direct / hosted MSI: existing trusted signing certificate | Owner's certificate provider and signing host certificate store; obtain its thumbprint locally with certificate-management tools | Configure `MORSECQ_WINDOWS_CERT_SHA1` as the reference to an accessible existing key and use Windows SDK `signtool.exe`. Blocks trusted final PE/MSI signing. CI development-MSI installation does not establish trust or SmartScreen reputation. No certificate purchase is performed. |
| Windows bundled MSVC CRT: licensing evidence and servicing owner | License Terms in the actual Visual Studio installation (About dialog) and the [official license directory](https://visualstudio.microsoft.com/license-terms/); retain the terms for the exact toolchain edition/version | Owner confirms redistribution rights under the applicable terms and archives that evidence with the component notice/hashes. Blocks public redistribution approval; app-local CRT security updates are maintained through app releases, not a presumed global updater. No license is purchased or accepted here. |
| Microsoft Store: product/package identity and package-model choice | Owner's Partner Center product record / Product identity | Record public identity fields after choosing hosted MSI vs MSIX; MSIX support remains a separate implementation. Hosted MSI also needs an owner-controlled immutable versioned HTTPS URL and final hash. Blocks Store-specific packaging/listing; no CA certificate purchase is required merely for Store MSIX submission. |
| Apple / Play / Microsoft: privacy, ratings, listing assets, review notes | Owner's App Store Connect App Privacy / App Review, Play Console App content, and Partner Center submission forms; use the repository's app/SDK inventory and current policy pages as evidence | Owner completes forms in the console. Supply rights-cleared localized text/screenshots and verify public support/privacy URLs without signing in. No review login is needed for this account-free app. Blocks submission; ten UI languages do not prove ten listing translations. |
| Linux / additional stores and mainland Android, if selected | Owner selects supported distro/session, signing/update trust and actual channel. Use that channel's publisher portal for identity, filing applicability and any permissions | Keep signing keys in the chosen owner-managed secret store. Blocks that specific channel until its package/sandbox/update evidence exists. Flathub manifest authorship/submission stays a human task; no new submission package is generated here. |
| Every selected release: signed previous build and device access | Owner's release archive / store test track and physical-device or clean-system lab | Record version/build, SHA-256, signer and installation results. Blocks previous-release upgrade, protected hardware/runtime and ordinary-user qualification. A same-version MSI repair is a separate test. |

## Controlled iOS archive and local export

The former `flutter build ipa` entry delegated to Flutter 3.41.9, which adds Xcode's provisioning-update/device-registration flags when signing. It has been replaced by `tool/ci/ios_store_export.py`, reached through `tool/build_ios_store.sh`; arbitrary Flutter/Xcode overrides are rejected. No account change, upload or signed export was performed in this audit.

To validate the real archive without distribution material, run from the repository root:

```sh
bash tool/build_ios_store.sh --unsigned-archive --output build/ios/store-readiness/check-archive
```

The output directory must be new. The helper resolves the locked workspace dependencies, configures Flutter with `--no-codesign`, and runs `xcodebuild archive` with signing disabled and no automatic-provisioning/device-registration flags. It requires the declared main executable to be a contained executable Mach-O file, rejects extra `.app`/`.appex` targets in the archive or app until their profile policy is reviewed, then reuses the final iOS payload/privacy/localization gate. The archive gate rejects dangling, external or non-relocatable absolute links, including dSYM links; CI archives this evidence as a tarball to preserve bundle modes and valid internal symlinks; `UNSIGNED-ARCHIVE.txt` explicitly prevents mistaking it for a signed, store-submittable IPA.

[Apple's requirements effective 2026-04-28](https://developer.apple.com/news/upcoming-requirements/) require Xcode 26 or later and the iOS/iPadOS 26 SDK or later for App Store Connect uploads. The helper checks the actual built app's `Info.plist`: `DTSDKName` must be a complete `iphoneos` device SDK version at least 26, and `DTXcode` must be a valid four-digit Xcode version at least `2600`. Missing, malformed, simulator or older metadata fails closed in both unsigned preparation and owner export; a bad archive is rejected before the export command, and the exported IPA is checked again. The existing macOS 26 CI runner remains unchanged. The downloaded final #50 archive was rechecked with this gate: `iphoneos26.5` / `2660`, 14 arm64 images and ten privacy manifests passed; copies changed to SDK 18.5 or Xcode 16.4 were rejected. This validates the current toolchain floor, not owner signing or Store acceptance.

Only the owner on an already configured signing Mac may run a later local export:

```sh
bash tool/build_ios_store.sh --export-options /owner/local/ExportOptions.plist --output build/ios/store-readiness/owner-export
```

This requires the existing public `MORSECQ_APPLE_TEAM_ID` and certificate fingerprint `MORSECQ_IOS_CERT_SHA1` (or explicit `--team-id` / `--certificate-sha1`). The plist must set `method=app-store-connect`, `destination=export`, `signingStyle=manual`, the exact `teamID` and `signingCertificate` SHA-1, and exactly one `provisioningProfiles` mapping from `icu.agentx.morsecq` to the existing profile name/UUID. Upload, automatic signing, internal-only TestFlight exports and unknown targets fail closed. The validated plist is snapshotted before commands, so later edits cannot change an in-flight export into upload.

The actual exported app must pass the existing identity/signature gate plus exact signer fingerprint, trusted offline certificate chain, selected profile/team/app/certificate binding, profile expiry and non-debug entitlements. These checks do not create or renew identities/profiles, upload to App Store Connect, prove acceptance or qualify a device. Real owner-signed export and installed upgrade remain pending the existing owner material; do not send it to the agent or commit it.

| ID | Status | Evidence / boundary |
| --- | --- | --- |
| W4 / iOS | controlled preparation gate; owner export pending | Twenty policy/failure regressions, including built SDK/Xcode floor and refusal before export; actual unsigned archive in CI. Manual local export only; distribution identity/profile and device/Store qualification remain separate. |
| X6 / iOS | final archive payload inspected | Same native/privacy/purpose-localization checks as the existing unsigned IPA; unsigned archive is not a signed delivery or installed-device result. |

Local validation on 2026-10-23: Flutter 3.41.9 / Xcode 26.4.1 / iPhoneOS SDK 26.4 completed this unsigned archive route; 14 arm64 device Mach-O images and ten privacy manifests passed the existing payload gate. Runner and dSYM UUIDs matched (`290A4D7A-699C-3244-8E93-E4F3E0F2BDA5`). Twenty helper-policy regressions and the complete 96-test Python suite passed (the local CMake fixtures used the installed macOS 26.4 SDK). This does not establish owner-signed export or device installation.

## Installed Windows MSI evidence

A further artifact audit found a concrete runtime omission: the final #49 Windows ZIP (Builds run `39886425706`) contains no MSVC runtime DLLs, while `llvm-objdump -p` on its real `morsecq.exe` lists `MSVCP140.dll`, `VCRUNTIME140.dll` and `VCRUNTIME140_1.dll` imports. The Visual Studio-equipped runner can hide that omission. Following [Flutter's Windows ZIP instructions](https://docs.flutter.dev/platform-integration/windows/building#building-your-own-zip-file-for-windows), the Windows CMake install now obtains release CRTs from its target toolchain using `InstallRequiredSystemLibraries`, fails if those three are absent, and copies them beside the executable into both ZIP and MSI. Native inventories check their CPU/hashes; the installed smoke checks trusted Microsoft signatures and proves those modules plus the engine load from the installed payload, rather than the runner's global runtime. The owner-invoked strict signer also refuses any damaged/unsigned/non-Microsoft CRT before signing-tool lookup, rather than replacing its vendor signature with the owner's. A real signed CRT copy with modified code bytes is the Windows CI refusal regression; the original component is not altered.

The package retains a `licenses/MSVC-runtime.txt` notice with toolchain/target and component names plus official license references. [Microsoft's redistribution conditions](https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files) still require the owner to confirm applicable Visual Studio licensing and retain the exact toolchain's license terms in the release record; this implementation does not approve those rights. App-local CRT security updates must ship with application updates. No system-wide redistributable install, credential creation or public release occurs here.

The real installed check then found exit status `0xC000041D`: `window_manager` posts `WM_QUIT` while the runner still owns its window/controller. The implicit member destructor allowed a native controller callback to re-enter the partially destroyed controller. The runner now calls its existing `window.Destroy()` after the message loop and before `CoUninitialize`; `OnDestroy` clears the client controller pointer before native destruction, and font-change callbacks guard that pointer. The same strict install/repair/relaunch/uninstall smoke must demonstrate normal exit0; a failed or debugger-assisted run is not accepted as that evidence.


`tool/ci/test_windows_installer.ps1` is a required step in the existing Windows release-build job. It installs the final MSI into a path containing spaces, compares **every file** against the final ZIP (assets included), checks PE/AOT architecture, requires a visible window and a graceful fresh-profile close, removes the engine DLL, repairs and rechecks/relaunches, then uninstalls and rejects a remaining executable/process. MSI operations have bounded waits; failure logs, installed/repaired inventories and `result.json` are retained under `evidence-windows/windows-installed` even on failure. The report binds MSI/ZIP SHA-256 to those actions. The [Microsoft command-line contract](https://learn.microsoft.com/en-us/windows/win32/msi/standard-installer-command-line-options) supplies quiet/no-restart/logging semantics.

This script refuses non-GitHub-hosted runners, existing MorseCQ processes and existing app support/cache directories derived from Windows KnownFolder paths and the installed executable's version resources. It does not redirect user data by changing `APPDATA`, erase a profile or change app persistence. The CI runner is disposable and may be elevated; it is not evidence for a standard-user, pristine OS, signed owner build, minimum OS or previous-version upgrade. Windows execution results belong to the exact-head PR jobs; other platforms' installed checks remain in the device matrix.

| ID | Status | Evidence / remaining boundary |
| --- | --- | --- |
| W4, X6 / Windows MSI | automated installed gate; exact-head result in PR | Actual install → file/CPU verification → visible launch/graceful quit → missing-DLL repair/relaunch → uninstall; logs and artifact hashes retained. Trusted signing, standard-user and prior-version upgrade remain owner/device work. |
| X5 | parity recorded | This change tests the Windows MSI route. macOS installers, Linux RPM/Wayland and mobile store-delivered upgrades still require their own installed matrix; existing payload gates are retained on all five platforms. |
| B2, W2 | save/tray behavior retained; final exit path corrected | The fresh-profile close-to-tray default is false; failure to quit fails the test. Forced termination only cleans a failed test and cannot count as graceful exit evidence. No training/session layer changes. |

## Installed Linux DEB evidence

The previous clean-DEB check also exposed an unintended `libdartjni.so` → missing `libjvm.so` dependency. `path_provider_android` brings JNI transitively; the desktop implementations and app have no Java calls, and the generated Android registrar is guarded by `Platform.isAndroid`. The JNI package builds its optional desktop library only when a host JDK happens to be found. Linux/Windows now disable that optional CMake discovery before generated plugins; Android remains unchanged. A real upstream-CMake fixture reproduces host-JDK contamination, then proves the policy excludes unused JNI while another native asset still builds/installs. No bundled mandatory library is deleted or exempted from native inspection. A future desktop Java feature requires an explicit JVM runtime/dependency policy and installed qualification.

Flutter dynamically loads EGL/GL/GLES, so `dpkg-shlibdeps` alone does not establish those runtime dependencies. DEB now explicitly requires `libegl1`, `libgl1`, `libgles2` (RPM declares the matching x64 SONAMEs, without claiming RPM execution). The clean container checks exact loader SONAMEs, their files/CPU and dependency closures before the X11 harness can install graphics libraries.

A real installed close subsequently exposed a separate GTK/engine lifetime failure: after `WM_DELETE_WINDOW`, the visible installed PID aborted while cleaning compositor shaders without a current GL context. `window_manager 0.5.2` removes Flutter's default close handler and its destroy method synchronously closes the GTK window. The pinned Flutter engine's `fl_view.cc` close handler normally requests app exit; `fl_platform_handler.cc` handles `SystemNavigator.pop` by detaching application/window references and quitting `GApplication`, rather than first destroying the view while the loop still runs. This matches the same-version [upstream report](https://github.com/leanflutter/window_manager/issues/585), with the local source chain and real failure logs as primary evidence.

Only the final Linux `WindowManagerApi.destroy` now uses that official platform exit. The controller still awaits preferences, window bounds, learning-save listeners and cleanup, then destroys the tray before requesting exit. Close-to-tray still hides. Four real MethodChannel/controller regressions check the held-save boundary, cleanup-before-exit order and retained Windows/macOS routes. The fresh installed DEB must still exit0 without a debugger; this bounded path does not complete X9 or establish that every engine/native-crash scenario is fixed.

The Linux release-build job now installs the final DEB in an official Ubuntu 24.04 container, recording the image digest, package SHA-256 and OS/CPU. It resolves only the DEB's declared dependencies and checks every installed ELF with `ldd` before installing the X11 test harness, so harness packages cannot conceal a missing package dependency. The application entry is inspected without `LD_LIBRARY_PATH`; individual plugin DSOs use only the installed package's private `lib` directory to model the engine already loaded by the app. This private inspection setting is never exported to the real GUI process. The real GUI then runs as the image's existing `nobody` user with private XDG directories; no host desktop/data/service socket is mounted. The test compares installed program/launcher/desktop/icon files against the final package, checks ELF CPU, requires a visible closable window belonging to the installed executable PID and its bundled Flutter engine mapping, sends `WM_DELETE_WINDOW`, requires exit0 without a surviving launch-group process, and verifies program files are removed and the package no longer has installed registration after uninstall (apt remove may retain configuration state). Forced termination only cleans failures.

Evidence is retained at `evidence-linux/linux-installed`, including dependency closure before/after harness installation, loaded maps, window/process checks, package file hashes and logs on failure. This is a fresh Ubuntu 24.04 DEB/X11 software-rendered startup/close test. It does not qualify RPM, Wayland, hardware audio/tray, old-release upgrades or another distro/minimum OS. Distribution signing/update trust and those device paths remain separate owner/engineering work. Existing native-crash diagnostics (X9), application menus/tablet input and foldable adaptation remain the explicitly incomplete items in the 65-item audit; the installation gates do not complete them.

| ID | Status | Evidence / boundary |
| --- | --- | --- |
| W4, X6 / Linux DEB | automated installed gate; exact-head result in PR | Fresh-container final DEB install, ordinary-user GUI/PID/engine, graceful close, uninstall; image/package hashes retained. Other package/session/hardware/upgrade paths remain unverified. |
| X5 | parity recorded | Windows MSI and Ubuntu DEB now have installed gates. Mac/mobile/RPM and other native matrix rows retain their separate evidence requirements. |

## Local validation record

These measurements, hashes and original test counts are the historical #49 baseline before the CRT/installed-package follow-up. Current changes and exact-head CI evidence are tracked in [PR #50](https://github.com/agentx-icu/morsecq/pull/50); do not read the baseline counts as the final follow-up result.

macOS 27.0.1 arm64, Flutter3.41.9, Xcode SDK26.4: release build57.0MB; 15 native Mach-O modules all provide arm64+x86_64, nine privacy manifests and ten purpose localizations inspected. The first preflight rejected Xcode-injected `get-task-allow=true`; disabling base-entitlement injection for Release produced a passing signed-entitlement report. Real PKG/ZIP packaging and re-extracted ZIP preflight passed. Android release APK74.6MB/AAB55.1MB: 30 native modules across the three declared ABIs, merged manifest and16KB ELF/ZIP/AAB config checks passed. These locally debug-signed Android artifacts are not distribution builds.

Python payload/distribution/signing/site regressions plus existing release/runtime/component suites:47passed (51 including cache regressions), using both JDK17.0.17 and Temurin17.0.20+8; platform/localization widgets:18passed; root/tool analyzers and complexity/import/shared/UI gates passed. Signed owner exports, Windows/Linux/iOS host runs and installed upgrades remain open; CI result is recorded in the PR separately.

Exact local artifacts (rebuilds change hashes):

| Artifact | SHA-256 |
| --- | --- |
| APK | `655e74e1de6e1c003044dd1edeacdec655baebff84de190e4a7095a0f37301c0` |
| AAB | `2f4ba0945a8a13f4c8fd58e390ad18c103970dfc63ce7eb493d4e18b8d7df4c2` |
| macOS PKG | `45d6f25d8bb566210fe83cebe5cd4c91a9ce1536568ff478e1d56f292c0409c0` |
| macOS ZIP | `c38db09036d497289e8595cbaad7db68cdf43c4200a22fb494cc43b7607b01a2` |

The existing public `/morsecq/privacy/` and `/morsecq/support/` returned HTTP404 on2026-10-23; `/morsecq/privacy.html` returned200 despite a successful Pages deployment. Jekyll had no explicit page permalinks. Explicit English/Chinese slash permalinks now match the app links, and PR Pages builds must inspect all six rendered policy/support routes before deployment. This historical route blocker was resolved by the existing #49 merge-triggered Pages workflow. On 2026-10-23, a read-only unauthenticated GET recheck returned HTTP200 with the expected app content for all six English/Chinese privacy, terms and support slash routes. No deployment was initiated during this follow-up. The owner still needs to approve the legal/contact content and console declarations; URL reachability alone does not approve them. No new privacy URL/contact or store record was invented.

Independent review follow-up: local strict Windows/Android packagers now run the same payload gates before signing/copying; Android explicitly requires its bundletool/apkanalyzer paths. Three entry-point negative tests pass. A real copied Mac release app with one signed resource modified was rejected by the new recursive codesign check; the original package passed. A real strict Android packaging attempt passed payload inspection and then refused its Debug certificate.

AAB integrity now uses JDK17 `JarFile`: read every payload entry to EOF, require one consistent valid leaf signer, reject unsigned/tampered/duplicate entries and missing bundle structure, and pin the owner certificate for distribution. PR Android builds retain a real AAB signature report; development verification permits the test key, while tagged/local distribution checks reject Debug. The real local AAB and a manifest-last copy both passed the previous text gate and the new verifier on JDK17.0.17/17.0.20+8 (175 signed entries); no JDK-specific failure of these MorseCQ artifacts was observed. Five real signed-JAR regressions include manifest-last acceptance and unsigned/tampered/duplicate/invalid-structure rejection; the old gate accepted the invalid-structure fixture.
