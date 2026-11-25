[简体中文](./LINUX_DISTRIBUTION.zh-CN.md)

# Linux distribution in China

## Target channels

1. deepin App Store / UOS ecosystem: adapt first, submitting a `.deb` or the Linglong package the store requires.
2. Kylin, openKylin and other domestic distributions: verify compatibility and submit after the deepin package is stable.
3. Flathub: a complementary cross-distribution channel; the current binary demo template must become a source build.
4. Snap Store: kept as an international channel; first validate core24, the GNOME extension and strict confinement.

## deepin/UOS requirements

- Prepare a Linux package that installs, uninstalls and upgrades; CI currently produces DEB, RPM and tar.gz.
- deepin community submissions require complete app information, an app that runs correctly, and updates handled through the store's distribution mechanism.
- Do not update silently inside the store package or install an extra uninstaller; updates and removal belong to the system software centre.
- Before submitting, verify start-up, microphone, tray, file picking, upgrade and uninstall on a real deepin/UOS system or matching virtual machine.
- Keep the app icon, Chinese name, privacy policy, support address and GPL-3.0 licence information consistent.

## Current blockers

- The Flathub template is a binary demo and cannot be submitted to Flathub as is; it needs a reproducible source build.
- The Snap template still needs a native snapcraft check confirming audio, tray and file access under strict confinement.
- Packages for domestic distributions need install and rollback tests on real systems; passing cloud CI is not store acceptance.
