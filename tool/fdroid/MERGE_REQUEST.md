# New app: MorseCQ

Preparation draft, 2026-11-12. The owner deferred submission until the inclusion criteria are met. This file has not been posted to F-Droid. Refresh the release revision, validation and checklist before use.

## App

- Application ID: `icu.agentx.morsecq`
- License: GPL-3.0-only
- Source: https://github.com/agentx-icu/morsecq
- Website: https://agentx-icu.github.io/morsecq/
- Issues: https://github.com/agentx-icu/morsecq/issues

MorseCQ is an offline Morse code trainer with Koch lessons, guided recognition and sending practice, independent copying, spaced review, simulated radio exchanges, reference and translation, microphone decoding and a local recorded-audio workbench. It distinguishes assisted exercises from independent mastery. It requires no account or learning backend and keeps progress and recordings locally.

The English and Chinese upstream Fastlane metadata contain an existing app icon and six authentic Android screenshots per language.

## Packaging

The candidate builds a universal APK with Flutter 3.41.9 and NDK 28.2.13676358. It removes flutter_soloud's prebuilt codecs, scans the project-local Pub cache, and rebuilds Ogg/Vorbis/Opus/FLAC from pinned source. Two source-library definitions and an upstream signing-configuration patch accompany the metadata.

Local checks: fdroidserver 2.4.5 metadata parsing/formatting/lint passed. All 24 codec libraries were rebuilt for four ABIs on macOS; ELF architectures, SONAMEs, shared-library dependencies and 64-bit 16 KB alignment passed. Linux build-server execution, complete APK integration and device runtime remain unverified.

No upstream reproducibility claim is made. Review the signing path before the first accepted build. The current universal output keeps upstream version codes; it avoids Flutter's ABI-specific version offsets. An ABI split can be considered with verified versioning.

## Checks to complete before opening the MR

- [ ] Establish policy eligibility using current maintenance history or an applicable exception. The first app commit is 2026-09-30; no other users were reported on 2026-11-12.
- [ ] Publish the Fastlane files and a reviewed upstream release, and update the metadata's full commit and version.
- [ ] Recheck existing F-Droid entries, requests and merge requests.
- [ ] Confirm source/dependency/license and anti-feature findings from the full scanner run.
- [ ] Run the full official Linux build and inspect the final APK.
- [ ] Test installation, audio, permission denial, persistence and the intended update/signing path.
- [ ] Resolve CI findings and adapt source-library/submodule and ABI-split choices to maintainer feedback.
- [ ] Fill the current fdroiddata MR template with actual evidence.

Opening or merging an MR does not establish publication. Follow the official build, signing and repository entry separately.
