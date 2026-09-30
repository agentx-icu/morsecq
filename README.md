# morsecq

**Talk in Morse code.** morsecq is a Morse code trainer and a serverless,
peer-to-peer Morse chat built on the [Tox](https://tox.chat) network. Learn the
code with structured lessons and keying drills, then key it to real people —
one-to-one or in group nets — with no server in the middle. It speaks the same
Tim2Tox wire protocol as its sibling project **toxee**, so the two interoperate.

## Status

**Pre-alpha.** The workspace, engine packages and app shell are being laid
down; there is no usable release yet. Expect breaking changes everywhere.

## Layout

This is a pub workspace (one `dart pub get` at the root resolves everything).

| Path | What |
|------|------|
| `packages/morse_core` | Pure-Dart Morse engine: alphabet, PARIS/Farnsworth timing, encoder, streaming key decoder |
| `packages/morse_trainer` | Pure-Dart pedagogy: lesson progression, scoring, practice scheduling |
| `packages/morse_io` | Flutter I/O: audio sidetone, haptics, touch + keyboard keying input |
| `packages/morsecq_chat` | Tox transport behind the `MorseChatService` façade (the only package that touches Tim2Tox) |
| `apps/morsecq` | The Flutter app: Material 3, responsive Learn / Chat / Groups / Me shell |
| `tool/` | Repository gates: 500-LOC complexity guard, import/layering guard |
| `doc/plans/` | Design and plan documents (方案) |

## Build prerequisites

- Flutter **3.41.9** stable (Dart 3.11) — the version CI pins.
- Platform toolchains for the targets you build: Xcode (iOS/macOS), Android SDK
  + JDK (Android), GTK 3 dev headers (Linux), Visual Studio C++ workload (Windows).
- For the chat package (arriving soon): a C/C++ toolchain, CMake and
  libsodium/opus/vpx to build the `libtim2tox_ffi` native library.

```bash
git clone https://github.com/agentx-icu/morsecq.git
cd morsecq
dart pub get
flutter analyze apps/morsecq
(cd apps/morsecq && flutter test)
(cd apps/morsecq && flutter run)
```

Conventions, gates and the working agreement are in [CLAUDE.md](CLAUDE.md).
The product and architecture plan is
[doc/plans/2026-09-30-morsecq-plan.zh-CN.md](doc/plans/2026-09-30-morsecq-plan.zh-CN.md).

## Licence

morsecq is free software, released under the **GNU General Public License
v3.0**. See [LICENSE](LICENSE). Copyright the morsecq contributors
(agentx-icu).
