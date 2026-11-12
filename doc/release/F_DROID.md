[简体中文](F_DROID.zh-CN.md)

# F-Droid main-repository preparation

Status on **2026-11-12**: submission materials are prepared in this checkout. No F-Droid issue or merge request has been submitted, and MorseCQ is not listed in the official repository. The owner chose to prepare the official route and defer submission until eligible.

## Eligibility

The [inclusion policy](https://f-droid.org/docs/Inclusion_Policy/#quality-control) normally requires at least three months of active development. Exceptions include evidence of existing users, an author already maintaining other F-Droid apps, or an event-specific application.

The first application commit is dated 2026-09-30. The owner reported no other users, so an existing-user exception has not been established. **2026-12-30 is only the earliest three-month date based on that history**, not an acceptance or publication date. Recheck maintenance activity, exceptions and the current policy before submitting.

## Prepared files

- `fastlane/metadata/android/en-US/` and `zh-CN/`: title, summary, description, changelog, existing app icon and six authentic Android screenshots per language.
- `tool/fdroid/icu.agentx.morsecq.yml`: candidate fdroiddata recipe for a universal APK with upstream version code `2`, min SDK 24, target SDK 36 and armv7/arm64/x86_64 support.
- `tool/fdroid/icu.agentx.morsecq/remove-upstream-signing.patch`: removes the multiline signing assignment before fdroidserver strips the remaining signing configuration. It is applied only in the F-Droid source checkout.
- `tool/fdroid/srclibs/ogg.yml` and `vorbis.yml`: proposed source-library records, in addition to fdroiddata's existing Flutter, Opus and FLAC records.
- `tool/fdroid/MERGE_REQUEST.md`: submission draft with outstanding checks left open.

The source commit in the recipe is a preparation snapshot. Before submission, publish a reviewed release containing the Fastlane files, then update the recipe's full commit hash, version and changelog. Do not move an existing release tag. F-Droid maintainers may prefer upstream Git submodules instead of the two new source-library records.

## Source-built audio dependencies

`flutter_soloud` 4.1.7 bundles precompiled codec libraries. The recipe removes them before scanning and uses its existing Xiph build script to rebuild them during the build phase. The script's strip-tool path is changed from the macOS host directory to the F-Droid Linux host directory. Codec functionality is retained; `NO_XIPH_LIBS` is not used.

| Dependency | Pinned source commit |
| --- | --- |
| Flutter 3.41.9 | `00b0c91f06209d9e4a41f71b7a512d6eb3b9c694` |
| Ogg | `db5c7a49ce7ebda47b15b78471e78fb7f2483e22` |
| Vorbis | `84c023699cdf023a32fa4ded32019f194afcdad0` |
| Opus | `c79a9bd1dd2898cd57bb793e037d58c937555c2c` |
| FLAC | `9547dbc2ddfca06a70ea937dbb605bbe78ea5f90` |

NDK is pinned to `28.2.13676358`. Keep the Pub package path and codec pins in sync if the dependency version changes. Pub cache is placed inside the checked-out project so F-Droid can scan it. Official Flutter SDK binaries remain subject to F-Droid's documented SDK exception.

## Verification and remaining work

Using fdroidserver 2.4.5, `readmeta`, `rewritemeta` and `lint -f` passed against the official category configuration. The signing patch was exercised with fdroidserver's actual signing-removal function.

On macOS arm64, all 24 codec shared libraries were rebuilt from the pinned sources for four ABIs. ELF architecture, matching SONAMEs, available shared-library dependencies and 64-bit 16 KB load alignment passed. Detailed local evidence is in `build/fdroid/source-codec-validation.json` and `build/fdroid/metadata-validation.json`.

The full F-Droid Linux build-server build, source-built APK integration and device runtime have **not** been verified. Before opening the inclusion MR, run the complete recipe and scanner in the official Linux environment, inspect the final APK, and exercise installation, audio, microphone permission denial and data persistence.

The candidate uses F-Droid signing. It does not claim reproducibility against the existing upstream APK, which uses prebuilt codec libraries. Decide and verify the signing/reproducible-build path before the first accepted build; different channel signatures do not provide an in-place update path between one another. Keep private signing files out of the submission.

## Submission procedure after eligibility is established

Follow the [current contribution guide](https://gitlab.com/fdroid/fdroiddata/-/blob/master/CONTRIBUTING.md) and [quick start](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/):

1. Publish the upstream metadata and a reviewed release, refresh all recipe pins, and recheck duplicate entries and requests.
2. In a public fdroiddata fork, copy the recipe to `metadata/icu.agentx.morsecq.yml`, the patch to `metadata/icu.agentx.morsecq/`, and the two new library records to `srclibs/`.
3. In the official Linux build environment, run `fdroid readmeta`, `fdroid rewritemeta icu.agentx.morsecq`, `fdroid lint -f icu.agentx.morsecq` and `fdroid build -v -l icu.agentx.morsecq`. Resolve scanner findings and inspect actual artifact metadata.
4. Complete the submission draft using fresh evidence and open `New app: MorseCQ`. A submitted or merged MR is not a published application; verify the subsequent official build, signing and repository entry separately.
