# Offline App Store build

MorseCQ contains no registration, chat networking or non-exempt application cryptography. Every build is offline; no MORSECQ_CHAT define, Store.xcconfig or alternate Info.plist is needed.

Run `tool/build_ios_store.sh` with the owner signing setup. The bundle id remains `icu.agentx.morsecq`. Required permission: microphone for user-triggered live decoding. Provide current iPhone/iPad screenshots through the capture pipeline. Supply the public privacy/support URLs, verify local learning and imports on physical devices, and complete store metadata before uploading.

CI unsigned IPA packages require re-signing and are not App Store submissions. See [build guide](../operations/BUILD_AND_DEPLOY.md).
