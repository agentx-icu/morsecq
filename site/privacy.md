---
layout: page
title: Privacy policy
permalink: /privacy/
lang: en
last_updated: 2026-10-07
---

[简体中文]({{ '/zh-CN/privacy/' | relative_url }}) · Last updated: {{ page.last_updated }}

This policy covers MorseCQ on every platform. MorseCQ ships in two forms:

- **The iOS / iPadOS App Store version is an offline trainer.** It has no chat
  and no account, and the app makes no network connection of its own.
- **The other builds** (Android, macOS, Linux, Windows and builds you make
  yourself from the source) add an optional peer-to-peer chat over the Tox
  network, described in "Chat builds" below.

## The short version

- **We collect nothing.** There is no MorseCQ server, no account system, no
  analytics, no advertising and no tracking, in any build. The developer
  never receives your progress, your settings or any identifier.
- **Your data stays on your device**, in the app's private storage.
- **There is no e-mail or in-app contact form.** Support goes through public
  GitHub issues (see Support); write there only what you want to be public.

## What is stored on your device (all builds)

| Data | Leaves the device? |
|---|---|
| Learning progress, plans, statistics, settings, key bindings | No |
| Practice materials and audio recordings you import or make | No (only where you export or share them yourself) |

Learning data is stored unencrypted in the app's private storage, which the
operating system protects (on iOS with Data Protection). MorseCQ never sends
it anywhere, but your device's own backup (iCloud Backup, or a computer
backup you make) may include the app's data, under your Apple account or on
your computer; we have no access to it. Me → Clear learning data (offline
version) or uninstalling the app deletes it from the device; copies in
earlier backups follow those backups' rules.

## Permissions (all builds)

- **Microphone** (optional): to decode Morse code you play or key nearby.
  Audio is analysed on the device in real time; it is never stored or sent
  anywhere unless you save a recording yourself.
- **Files**: importing a text, word list or WAV file uses the system file
  picker; files from a cloud provider are fetched by that provider, not by
  MorseCQ.

Links to this site and to the source code open in your browser, which loads
them from the internet.

## Chat builds (not the App Store version)

The chat is optional and peer to peer over the open Tox protocol:

| Data | Leaves the device? |
|---|---|
| Tox identity (key pair, Tox ID), generated on the device | Only your public Tox ID, when you share it |
| Display name and status message | Sent to your friends and to members of groups you join |
| Chat history, friends, groups, drafts, bookmarks | Messages go only to the friend or group you send them to |
| Backups | Only where you save or share the file |

- To find your friends the app joins the Tox distributed hash table through
  public bootstrap nodes run by volunteers. As in every peer-to-peer network,
  DHT nodes and the peers you connect to can see your **IP address** and
  **public key**; they cannot read your messages, which are end-to-end
  encrypted between devices. Use a VPN if you do not want peers to learn your
  IP address.
- The identity can be protected with a password (the profile is then
  encrypted on disk); chat history is stored unencrypted in the app's private
  storage.
- **Camera** (optional): only to scan a friend's Tox ID QR code, on the
  device. **Notifications** are posted locally by the app; there is no push
  server.
- Me → Delete identity removes the identity, chat history and contacts from
  the device. Messages you already sent stay on the recipients' devices.
- You can block anyone; blocking hides their messages, requests and invites
  on your device.

## Children

MorseCQ collects no personal data from anyone, children included. The chat
builds are not directed at children under 13.

## Changes

We will update this page when the app's data handling changes and show the
new date above.

## Contact

Use [GitHub issues]({{ site.support_url }}) — they are public, so do not post
private information there. See also [Support]({{ '/support/' | relative_url }}).
