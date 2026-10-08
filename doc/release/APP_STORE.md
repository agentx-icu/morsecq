# Offline App Store build

MorseCQ opens offline learning immediately, with no registration or chat networking. Use the standard iOS release configuration; microphone access serves user-triggered live decoding. The bundle identifier is `icu.agentx.morsecq` and the first release is 1.0.0, build 1.

Run `bash tool/build_ios_store.sh` with the owner's Apple signing setup. Supply current iPhone/iPad screenshots through the [capture pipeline](../../tool/screenshots/README.md), public privacy/support URLs, complete store metadata and physical-device acceptance for local learning and learning-material file selection. The app declares no non-exempt application cryptography.

CI's unsigned IPA needs owner signing before device installation. App Store submission uses the signed store build. See the [build guide](../operations/BUILD_AND_DEPLOY.md) and [validation record](../VALIDATION.md).
