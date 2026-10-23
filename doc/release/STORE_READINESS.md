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
| Apple App Store / iOS + iPadOS / territories unconfirmed | Preparation route: signed export via `tool/build_ios_store.sh`; CI unsigned IPA only establishes compilation and payload checks | R: verified team/app record and agreements, distribution profile, processed build, privacy labels/report, export questionnaire, ratings, listing/support/privacy URLs. C: trader/territory information. Rehearse first lesson, microphone denial and file import without a review login. |
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
| iOS/iPadOS: existing distribution identity and App Store provisioning profile | Apple Developer Certificates, Identifiers & Profiles and the owner's Xcode signing/export configuration for `icu.agentx.morsecq` | Keep private keys in the owner's keychain and profiles in Xcode's managed storage; invoke `tool/build_ios_store.sh` locally with export options. Never commit a `.p12` or password. Blocks the signed exported-IPA checks and device installation. |
| macOS direct download: existing Developer ID Application / Installer identities, notarization profile | Apple Developer certificates, the signing Mac's Keychain Access and the owner's existing `notarytool` keychain profile | Configure `MORSECQ_MACOS_APPLICATION_IDENTITY`, `MORSECQ_MACOS_INSTALLER_IDENTITY`, `MORSECQ_APPLE_TEAM_ID`, `MORSECQ_NOTARY_PROFILE` on the signing host. Identity names/profile name are references, not key material. Blocks trusted PKG/ZIP signing, notarization and Gatekeeper qualification. |
| Google Play: existing upload key, upload and delivery certificate SHA-256 | Owner's existing upload keystore; Play Console app's App integrity / App signing certificate pages. Upload and Play-distribution certificates may differ | Owner configures the four existing GitHub Actions signing secrets under repository Settings → Secrets and variables → Actions. Put the non-secret upload fingerprint in Actions variable `ANDROID_UPLOAD_CERT_SHA256`; local strict packaging uses `MORSECQ_ANDROID_UPLOAD_CERT_SHA256`. Blocks tagged Android signing/identity checks and signed upgrades; do not upload a key to this repository. |
| Windows direct / hosted MSI: existing trusted signing certificate | Owner's certificate provider and signing host certificate store; obtain its thumbprint locally with certificate-management tools | Configure `MORSECQ_WINDOWS_CERT_SHA1` as the reference to an accessible existing key and use Windows SDK `signtool.exe`. Blocks trusted final PE/MSI signing. CI development-MSI installation does not establish trust or SmartScreen reputation. No certificate purchase is performed. |
| Microsoft Store: product/package identity and package-model choice | Owner's Partner Center product record / Product identity | Record public identity fields after choosing hosted MSI vs MSIX; MSIX support remains a separate implementation. Hosted MSI also needs an owner-controlled immutable versioned HTTPS URL and final hash. Blocks Store-specific packaging/listing; no CA certificate purchase is required merely for Store MSIX submission. |
| Apple / Play / Microsoft: privacy, ratings, listing assets, review notes | Owner's App Store Connect App Privacy / App Review, Play Console App content, and Partner Center submission forms; use the repository's app/SDK inventory and current policy pages as evidence | Owner completes forms in the console. Supply rights-cleared localized text/screenshots and verify public support/privacy URLs without signing in. No review login is needed for this account-free app. Blocks submission; ten UI languages do not prove ten listing translations. |
| Linux / additional stores and mainland Android, if selected | Owner selects supported distro/session, signing/update trust and actual channel. Use that channel's publisher portal for identity, filing applicability and any permissions | Keep signing keys in the chosen owner-managed secret store. Blocks that specific channel until its package/sandbox/update evidence exists. Flathub manifest authorship/submission stays a human task; no new submission package is generated here. |
| Every selected release: signed previous build and device access | Owner's release archive / store test track and physical-device or clean-system lab | Record version/build, SHA-256, signer and installation results. Blocks previous-release upgrade, protected hardware/runtime and ordinary-user qualification. A same-version MSI repair is a separate test. |

## Installed Windows MSI evidence

`tool/ci/test_windows_installer.ps1` is a required step in the existing Windows release-build job. It installs the final MSI into a path containing spaces, compares **every file** against the final ZIP (assets included), checks PE/AOT architecture, requires a visible window and a graceful fresh-profile close, removes the engine DLL, repairs and rechecks/relaunches, then uninstalls and rejects a remaining executable/process. MSI operations have bounded waits; failure logs, installed/repaired inventories and `result.json` are retained under `evidence-windows/windows-installed` even on failure. The report binds MSI/ZIP SHA-256 to those actions. The [Microsoft command-line contract](https://learn.microsoft.com/en-us/windows/win32/msi/standard-installer-command-line-options) supplies quiet/no-restart/logging semantics.

This script refuses non-GitHub-hosted runners, existing MorseCQ processes and existing app support/cache directories derived from Windows KnownFolder paths and the installed executable's version resources. It does not redirect user data by changing `APPDATA`, erase a profile or change app persistence. The CI runner is disposable and may be elevated; it is not evidence for a standard-user, pristine OS, signed owner build, minimum OS or previous-version upgrade. Windows execution results belong to the exact-head PR jobs; other platforms' installed checks remain in the device matrix.

| ID | Status | Evidence / remaining boundary |
| --- | --- | --- |
| W4, X6 / Windows MSI | automated installed gate; exact-head result in PR | Actual install → file/CPU verification → visible launch/graceful quit → missing-DLL repair/relaunch → uninstall; logs and artifact hashes retained. Trusted signing, standard-user and prior-version upgrade remain owner/device work. |
| X5 | parity recorded | This change tests the Windows MSI route. macOS/Linux installers and mobile store-delivered upgrades still require their own installed matrix; existing payload gates are retained on all five platforms. |
| B2, W2 | behavior unchanged; smoke exercises default close | The fresh-profile close-to-tray default is false; failure to quit fails the test. Forced termination only cleans a failed test and cannot count as graceful exit evidence. No training/session layer changes. |

## Local validation record

macOS 27.0.1 arm64, Flutter3.41.9, Xcode SDK26.4: release build57.0MB; 15 native Mach-O modules all provide arm64+x86_64, nine privacy manifests and ten purpose localizations inspected. The first preflight rejected Xcode-injected `get-task-allow=true`; disabling base-entitlement injection for Release produced a passing signed-entitlement report. Real PKG/ZIP packaging and re-extracted ZIP preflight passed. Android release APK74.6MB/AAB55.1MB: 30 native modules across the three declared ABIs, merged manifest and16KB ELF/ZIP/AAB config checks passed. These locally debug-signed Android artifacts are not distribution builds.

Python payload/distribution/signing/site regressions plus existing release/runtime/component suites:47passed (51 including cache regressions), using both JDK17.0.17 and Temurin17.0.20+8; platform/localization widgets:18passed; root/tool analyzers and complexity/import/shared/UI gates passed. Signed owner exports, Windows/Linux/iOS host runs and installed upgrades remain open; CI result is recorded in the PR separately.

Exact local artifacts (rebuilds change hashes):

| Artifact | SHA-256 |
| --- | --- |
| APK | `655e74e1de6e1c003044dd1edeacdec655baebff84de190e4a7095a0f37301c0` |
| AAB | `2f4ba0945a8a13f4c8fd58e390ad18c103970dfc63ce7eb493d4e18b8d7df4c2` |
| macOS PKG | `45d6f25d8bb566210fe83cebe5cd4c91a9ce1536568ff478e1d56f292c0409c0` |
| macOS ZIP | `c38db09036d497289e8595cbaad7db68cdf43c4200a22fb494cc43b7607b01a2` |

The existing public `/morsecq/privacy/` and `/morsecq/support/` returned HTTP404 on2026-10-23; `/morsecq/privacy.html` returned200 despite a successful Pages deployment. Jekyll had no explicit page permalinks. Explicit English/Chinese slash permalinks now match the app links, and PR Pages builds must inspect all six rendered policy/support routes before deployment. The current live404 remains a submission blocker until the existing merge-triggered Pages deployment is verified by GET; no new privacy URL/contact or store record was invented.

Independent review follow-up: local strict Windows/Android packagers now run the same payload gates before signing/copying; Android explicitly requires its bundletool/apkanalyzer paths. Three entry-point negative tests pass. A real copied Mac release app with one signed resource modified was rejected by the new recursive codesign check; the original package passed. A real strict Android packaging attempt passed payload inspection and then refused its Debug certificate.

AAB integrity now uses JDK17 `JarFile`: read every payload entry to EOF, require one consistent valid leaf signer, reject unsigned/tampered/duplicate entries and missing bundle structure, and pin the owner certificate for distribution. PR Android builds retain a real AAB signature report; development verification permits the test key, while tagged/local distribution checks reject Debug. The real local AAB and a manifest-last copy both passed the previous text gate and the new verifier on JDK17.0.17/17.0.20+8 (175 signed entries); no JDK-specific failure of these MorseCQ artifacts was observed. Five real signed-JAR regressions include manifest-last acceptance and unsigned/tampered/duplicate/invalid-structure rejection; the old gate accepted the invalid-structure fixture.
