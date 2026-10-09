#!/usr/bin/env python3
"""Render third-party package metadata for a published MorseCQ release.

The repository deliberately keeps package-manager files as templates because
release checksums are unknown until CI builds the tagged artifacts. Render the
templates from the SHA256SUMS file produced by verify_release_assets.sh:

  python3 tool/release/generate_distribution_metadata.py \
      --version 1.0.0 --release-date YYYY-MM-DD \
      --sha256sums dist/SHA256SUMS --output-dir dist/packaging

Use --allow-placeholders only for a local preview. A placeholder render must
never be submitted to a package manager.
"""
from __future__ import annotations

import argparse
import re
import shutil
import sys
from datetime import date
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
TEMPLATE_ROOT = REPO_ROOT / "packaging" / "templates"
ICON_SOURCE = REPO_ROOT / "apps/morsecq/linux/icons/hicolor/256x256/apps/morsecq.png"
VERSION_RE = re.compile(r"\A\d+\.\d+\.\d+\Z")
SHA256_RE = re.compile(r"\A[0-9a-fA-F]{64}\Z")

ASSETS = {
    "linux": "morsecq-{version}-linux-x86_64.tar.gz",
    "macos": "morsecq-{version}-macos-{macos_arch}.zip",
    "windows_msi": "morsecq-{version}-windows-x64.msi",
}

TEMPLATES = {
    Path("homebrew/morsecq.rb.template"): Path("homebrew/morsecq.rb"),
    Path("flathub/io.github.agentx_icu.morsecq.yml.template"): Path("flathub/io.github.agentx_icu.morsecq.yml"),
    Path("flathub/io.github.agentx_icu.morsecq.metainfo.xml.template"): Path("flathub/io.github.agentx_icu.morsecq.metainfo.xml"),
    Path("snap/snapcraft.yaml.template"): Path("snap/snapcraft.yaml"),
    Path("winget/AgentX.MorseCQ.locale.en-US.yaml.template"): Path("winget/AgentX.MorseCQ.locale.en-US.yaml"),
    Path("winget/AgentX.MorseCQ.installer.yaml.template"): Path("winget/AgentX.MorseCQ.installer.yaml"),
    Path("winget/AgentX.MorseCQ.version.yaml.template"): Path("winget/AgentX.MorseCQ.version.yaml"),
    Path("chocolatey/morsecq.nuspec.template"): Path("chocolatey/morsecq.nuspec"),
    Path("chocolatey/tools/chocolateyinstall.ps1.template"): Path("chocolatey/tools/chocolateyinstall.ps1"),
}

# These support files are copied alongside the rendered manifests so a
# submission checkout has the launcher and desktop entry it references.
SUPPORT_FILES = {
    Path("flathub/morsecq-wrapper"): Path("flathub/morsecq-wrapper"),
    Path("flathub/io.github.agentx_icu.morsecq.desktop"): Path("flathub/io.github.agentx_icu.morsecq.desktop"),
    Path("snap/morsecq-launcher"): Path("snap/morsecq-launcher"),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", required=True, help="numeric release version, for example 1.0.0")
    parser.add_argument("--release-date", required=True, help="actual release date in YYYY-MM-DD form")
    parser.add_argument("--sha256sums", type=Path, help="SHA256SUMS generated for the same release tag")
    parser.add_argument("--output-dir", type=Path, required=True, help="directory to receive rendered metadata")
    parser.add_argument(
        "--macos-arch",
        choices=("universal2", "arm64", "x86_64"),
        default="universal2",
        help="macOS architecture in the release asset name (default: universal2)",
    )
    parser.add_argument(
        "--allow-placeholders",
        action="store_true",
        help="render marker values when --sha256sums is omitted (preview only)",
    )
    return parser.parse_args()


def read_checksums(path: Path | None, *, version: str, macos_arch: str, allow_placeholders: bool) -> dict[str, str]:
    names = {key: value.format(version=version, macos_arch=macos_arch) for key, value in ASSETS.items()}
    missing = {key: f"REPLACE_WITH_SHA256_{key.upper()}" for key in names}
    if path is None:
        if allow_placeholders:
            return missing
        raise SystemExit("--sha256sums is required unless --allow-placeholders is set")
    if not path.is_file():
        raise SystemExit(f"checksum manifest does not exist: {path}")
    parsed: dict[str, str] = {}
    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.strip()
        if not line:
            continue
        fields = line.split()
        if len(fields) != 2 or not SHA256_RE.fullmatch(fields[0]):
            raise SystemExit(f"invalid SHA256SUMS line {number}: {raw!r}")
        if fields[1] in parsed:
            raise SystemExit(f"duplicate checksum entry on line {number}: {fields[1]}")
        parsed[fields[1]] = fields[0].lower()
    result: dict[str, str] = {}
    absent: list[str] = []
    for key, asset in names.items():
        digest = parsed.get(asset)
        if digest is None:
            absent.append(asset)
        else:
            result[key] = digest
    if absent and not allow_placeholders:
        raise SystemExit("checksum manifest is missing required asset(s): " + ", ".join(absent))
    for key in names:
        result.setdefault(key, missing[key])
    return result


def context(version: str, macos_arch: str, checksums: dict[str, str], release_date: str) -> dict[str, str]:
    assets = {key: value.format(version=version, macos_arch=macos_arch) for key, value in ASSETS.items()}
    return {
        "VERSION": version,
        "TAG": f"v{version}",
        "MACOS_ARCH": macos_arch,
        "MACOS_ASSET": assets["macos"],
        "MACOS_SHA256": checksums["macos"],
        "LINUX_ASSET": assets["linux"],
        "LINUX_SHA256": checksums["linux"],
        "WINDOWS_MSI_ASSET": assets["windows_msi"],
        "WINDOWS_MSI_SHA256": checksums["windows_msi"],
        "RELEASE_DATE": release_date,
    }


def render(text: str, values: dict[str, str]) -> str:
    for key, value in values.items():
        text = text.replace("{{" + key + "}}", value)
    leftovers = sorted(set(re.findall(r"\{\{[^{}]+\}\}", text)))
    if leftovers:
        raise ValueError("unknown template placeholder(s): " + ", ".join(leftovers))
    return text


def write_rendered(output_dir: Path, values: dict[str, str]) -> list[Path]:
    written: list[Path] = []
    for source_rel, destination_rel in TEMPLATES.items():
        source = TEMPLATE_ROOT / source_rel
        destination = output_dir / destination_rel
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(render(source.read_text(encoding="utf-8"), values), encoding="utf-8")
        written.append(destination)
    for source_rel, destination_rel in SUPPORT_FILES.items():
        source = TEMPLATE_ROOT / source_rel
        destination = output_dir / destination_rel
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
        written.append(destination)
    for directory in ("flathub", "snap"):
        destination = output_dir / directory / "morsecq.png"
        shutil.copy2(ICON_SOURCE, destination)
        written.append(destination)
    return written


def main() -> int:
    args = parse_args()
    if not VERSION_RE.fullmatch(args.version):
        raise SystemExit("--version must be numeric X.Y.Z (without a leading v)")
    try:
        if date.fromisoformat(args.release_date).isoformat() != args.release_date:
            raise ValueError
    except ValueError:
        raise SystemExit("--release-date must be a valid YYYY-MM-DD date") from None
    checksums = read_checksums(args.sha256sums, version=args.version, macos_arch=args.macos_arch, allow_placeholders=args.allow_placeholders)
    values = context(args.version, args.macos_arch, checksums, args.release_date)
    written = write_rendered(args.output_dir, values)
    print(f"Rendered {len(written)} package metadata files for GitHub release {values['TAG']} into {args.output_dir}")
    if any(value.startswith("REPLACE_WITH_SHA256_") for value in checksums.values()):
        print("WARNING: placeholders were rendered; do not submit these files", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
