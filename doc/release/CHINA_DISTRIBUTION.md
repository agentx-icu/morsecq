[简体中文](./CHINA_DISTRIBUTION.zh-CN.md)

# China distribution checklist

This checklist prepares MorseCQ 1.0.1+2 for distribution in China. The package name is `icu.agentx.morsecq`, the app name is MorseCQ, and its purpose is account-free, offline Morse code training.

## Recommended order

1. Android: Huawei, Xiaomi, OPPO, vivo, Tencent MyApp.
2. Windows: Microsoft Store (MSIX) and direct downloads from the website/Gitee.
3. Linux: deepin/UOS, then evaluate Kylin, openKylin and Flathub.
4. iOS: the mainland China App Store, which must use an individual Apple Developer team, not the existing company team.

## Android submission material

- Package name: `icu.agentx.morsecq`
- Version: `1.0.1+2`, Git tag `v1.0.1`
- Suggested category: Education; Tools/Reference as an alternative. Do not choose "Communication": the app provides no chat or network service.
- Permissions: only `RECORD_AUDIO`, and the microphone feature is started by the user; the microphone hardware feature is marked optional.
- Network: the release Android manifest declares no INTERNET permission; learning data, settings, materials and recordings stay on the device.
- Data safety: no account, ads or analytics SDK; state that microphone audio is used only for live decoding, and declare whether recordings are kept according to the actual implementation.
- Package: a release-signed AAB/APK, never the debug key; keep the release signing key fixed and safe.
- Assets: app icon `apps/morsecq/icon/app_icon_1024.png`; Chinese screenshots in `doc/screenshots/android/zh/`.
- Privacy, support and terms: `site/zh-CN/privacy.md`, `site/zh-CN/support.md`, `site/zh-CN/terms.md`. Confirm these pages are deployed at public HTTPS addresses before submitting.

Suggested store copy (submitted in Chinese; English meaning):

- Short description: Offline Morse code training: from hearing K/M to Koch copying, sending and review.
- Long description: MorseCQ is an account-free, offline Morse code learning tool. Koch lessons, copying, sending, spaced review, simulated QSOs, a reference manual, a two-way translator, Chinese telegraph codes, live microphone decoding and amateur radio tools help beginners and enthusiasts practise systematically. Learning data stays on the device, with no ads, analytics or chat services.

## Mainland China compliance

- Before offering an internet information service in mainland China or listing through a mainland distribution platform, confirm the app filing (APP 备案) entity, the access provider/distribution platform and the filing display requirements.
- Confirm separately whether the domain and server behind the privacy/support pages need an ICP filing; an ICP filing is not an app filing.
- Education apps may require extra material from the authorities; the actual operating entity and legal counsel confirm this before submission.
- For the China iOS storefront, App Store Connect also checks ICP filing information; games, news, publishing, religion and similar categories need additional licences. MorseCQ should not be declared as a game or a communication service; the store review decides the final category.

## Signing and release gates

- An Android release needs all four signing values: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
- Without signing, only debug builds explicitly labelled for testing can be made; they cannot be uploaded to a store.
- Never commit keys, certificates, profiles, passwords or account configuration to Git.
- The `icu.agentx.morsecq` record under the existing company Apple team is not used for this project's individual release; prepare a separate individual team first for an individual iOS release.
