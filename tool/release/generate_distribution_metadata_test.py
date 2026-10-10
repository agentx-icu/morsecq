#!/usr/bin/env python3
"""Regression tests for release metadata rendering."""
from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("generate_distribution_metadata.py")


class DistributionMetadataTest(unittest.TestCase):
    version = "1.0.0"
    assets = {
        "morsecq-1.0.0-linux-x86_64.tar.gz": "1" * 64,
        "morsecq-1.0.0-macos-universal2.zip": "2" * 64,
        "morsecq-1.0.0-windows-x64.msi": "3" * 64,
    }

    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.checksums = self.root / "SHA256SUMS"
        self.write_checksums()

    def write_checksums(self, extra: list[str] | None = None) -> None:
        lines = [f"{digest}  {name}" for name, digest in self.assets.items()]
        self.checksums.write_text("\n".join(lines + (extra or [])) + "\n", encoding="utf-8")

    def run_generator(self, *extra: str, checksums: Path | None = None) -> subprocess.CompletedProcess[str]:
        output = self.root / "out"
        args = [sys.executable, str(SCRIPT), "--version", self.version, "--release-date", "2026-10-09"]
        if checksums is not None:
            args += ["--sha256sums", str(checksums)]
        args += ["--output-dir", str(output), *extra]
        return subprocess.run(args, text=True, capture_output=True)

    def test_render_is_complete_and_copies_support_files(self) -> None:
        result = self.run_generator(checksums=self.checksums)
        self.assertEqual(result.returncode, 0, result.stderr)
        output = self.root / "out"
        self.assertTrue((output / "flathub/io.github.agentx_icu.morsecq.yml").is_file())
        self.assertTrue((output / "flathub/io.github.agentx_icu.morsecq.metainfo.xml").is_file())
        self.assertTrue((output / "flathub/morsecq.png").is_file())
        self.assertTrue((output / "snap/morsecq.png").is_file())
        for path in output.rglob("*"):
            if path.is_file():
                text = path.read_text(encoding="utf-8", errors="ignore")
                self.assertNotIn("{{", text, path)
                self.assertNotIn("REPLACE_WITH_SHA256", text, path)
        self.assertIn('date="2026-10-09"', (output / "flathub/io.github.agentx_icu.morsecq.metainfo.xml").read_text())

    def test_checksum_manifest_is_required_for_production(self) -> None:
        result = self.run_generator()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--sha256sums is required", result.stderr)

    def test_missing_and_duplicate_checksums_fail(self) -> None:
        missing = self.root / "missing.SHA256SUMS"
        missing.write_text(next(iter(self.assets.values())) + "  morsecq-1.0.0-linux-x86_64.tar.gz\n", encoding="utf-8")
        result = self.run_generator(checksums=missing)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing required asset", result.stderr)

        self.write_checksums(extra=[f"{'4' * 64}  morsecq-1.0.0-linux-x86_64.tar.gz"])
        result = self.run_generator(checksums=self.checksums)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("duplicate checksum", result.stderr)

    def test_placeholders_require_explicit_preview_flag(self) -> None:
        result = self.run_generator("--allow-placeholders")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("WARNING: placeholders", result.stderr)
        self.assertIn("REPLACE_WITH_SHA256", (self.root / "out/homebrew/morsecq.rb").read_text())


if __name__ == "__main__":
    unittest.main()
