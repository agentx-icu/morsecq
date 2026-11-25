[简体中文](./DISTRIBUTION_PACKAGING.zh-CN.md)

# Third-party distribution metadata

MorseCQ's CI creates immutable, versioned GitHub Release assets. The files in
`packaging/templates/` are intentionally templates: checksums are not known
until a tagged build completes, so a template must never be submitted directly
to Homebrew, Flathub, Snap Store, WinGet or Chocolatey.

## Release checklist

Package managers download from the public release, so nothing is rendered or
submitted until the release is published with its final assets and checksums.

1. Create and push tag `vX.Y.Z` matching the three-part version in
   `apps/morsecq/pubspec.yaml` (the build workflow rejects a mismatch).
2. Wait for the draft GitHub Release and all ten platform assets.
3. Signing outside CI happens now, while the release is still a draft: the
   owner signs and notarizes the macOS archives with Developer ID, and signs
   the Windows MSI with Authenticode once a certificate is available. Replace
   only the assets that changed, in the draft.
4. Download the final assets, verify them and regenerate `SHA256SUMS`:

   ```sh
   bash tool/ci/verify_release_assets.sh dist vX.Y.Z
   ```

   Upload this `SHA256SUMS` over the one CI attached to the draft. CI's
   manifest describes the unsigned binaries; publishing it next to signed
   ones would publish wrong checksums.
5. Publish the release. Its download URLs are public only from now on;
   metadata rendered from a draft must not be submitted.
6. Render metadata from the final manifest. The default architecture is the
   universal2 macOS archive; pass `--macos-arch arm64` or `x86_64` when the
   release contains a single-architecture pair (the Homebrew cask then
   declares that architecture):

   ```sh
   python3 tool/release/generate_distribution_metadata.py \
     --version X.Y.Z \
     --release-date YYYY-MM-DD \
     --sha256sums dist/SHA256SUMS \
     --macos-arch universal2 \
     --output-dir dist/packaging
   ```

   The command writes ready-to-review files for Homebrew, Flathub, Snap,
   WinGet and Chocolatey, plus each package's support files and icon. The
   release date is required from the caller and must be the actual GitHub
   release date. It fails if a required checksum is absent. Use
   `--allow-placeholders` only to inspect a local preview; placeholders must
   not be published. Rendered package directories are self-contained; run a
   native build from the relevant directory (for example,
   `cd dist/packaging/snap && snapcraft`).

7. Review each generated file against the package manager's current schema and
   contribution policy. The Flathub file is explicitly a binary demo and is
   not submission-ready: Flathub requires source builds for this project.
   Replace its archive module with an offline source build, then verify the
   final source checksum and native runtime dependencies. The Snap file is
   also untested; validate the core24/GNOME extension runtime before changing
   its `grade: devel` to `stable`.
8. Submit each generated file through the package manager's normal review
   process. Keep package-manager repositories separate from this repository;
   this project only owns the templates and rendering tool.

## Artifact mapping

- Homebrew Cask: macOS `.zip` (`MorseCQ.app`)
- Flathub and Snap: Linux x86_64 `.tar.gz` bundle
- WinGet and Chocolatey: Windows x64 `.msi`

All URLs point to `https://github.com/agentx-icu/morsecq/releases/download/vX.Y.Z/`.
Do not replace a release URL with a mutable branch, a “latest” URL, or a
checksum copied from another version.

## Policy references

- [Snapcraft platforms](https://ubuntu.com/docs/snapcraft/9/reference/platforms/)
  requires `platforms` for core24; the template follows its amd64 form.
- [Snapcraft GNOME extension](https://ubuntu.com/docs/snapcraft/9/reference/extensions/gnome-extension/)
  supplies the GTK/GLib desktop runtime used by the template.
- [Flathub requirements](https://docs.flathub.org/docs/for-app-authors/requirements)
  prohibit precompiled application binaries in a normal submission; the
  checked-in Flatpak file is therefore labelled a binary demo only.
