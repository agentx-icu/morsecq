[简体中文](./WINDOWS_DISTRIBUTION.zh-CN.md)

# Windows distribution in China

## Target channels

1. Microsoft Store: the preferred official store, using MSIX and Partner Center.
2. Website and Gitee: the official download entry that does not depend on store review, offering the Windows ZIP/MSI, SHA256SUMS, release notes and privacy/support pages.
3. WinGet: submit the manifest once the GitHub Release is published and its SHA256 checksums are verified.
4. Chocolatey: a complementary community package manager, using the stable MSI download URL and checksum.
5. Tencent Software Center, 360 Software Manager and similar: mainly listings or partnerships; never the only official download source.

## Current repository artifacts

- CI target: Windows x64.
- Build: Flutter Windows release.
- Packaging: WiX v3 produces `morsecq-X.Y.Z-windows-x64.msi`, plus a ZIP.
- Templates: `packaging/templates/winget/` and `packaging/templates/chocolatey/`.
- Metadata: must be rendered from the same version's `SHA256SUMS`; never submit placeholders or a mutable `latest` link.

## Blockers before listing

- The Windows MSI has no Authenticode signature yet; for the Microsoft Store, MSIX with Partner Center verification fits better.
- Install, upgrade, uninstall and data-retention tests are needed on a Windows machine.
- Confirm the app icon, publisher name, privacy policy, support URL and Chinese screenshots.
- Choose a stable domain for the official download page and make sure the privacy/support pages are reachable over public HTTPS.

## Security requirements

- Never commit certificates, private keys, signing passwords or store credentials to the repository.
- Do not recommend an unsigned MSI as the official installer; unsigned packages are for internal testing only.
- Publish only immutable URLs with their SHA256 for each version; never overwrite published assets.
