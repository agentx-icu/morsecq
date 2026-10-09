"""Regression tests for the version/tag release gate."""
from pathlib import Path
import os
import re
import subprocess
import unittest


SCRIPT = Path(__file__).with_name("check_version_tag.sh")
SPEC = Path(__file__).resolve().parents[2] / "apps/morsecq/pubspec.yaml"
FULL_VERSION = re.search(r"^version:\s*(\d+\.\d+\.\d+\+\d+)$", SPEC.read_text(), re.M)[1]
TAG = "v" + FULL_VERSION.split("+")[0]
STALE_TAG = "v0.2.0" if TAG != "v0.2.0" else "v0.0.0"


class VersionTagTest(unittest.TestCase):
    def run_gate(self, *args, **env):
        merged = os.environ.copy()
        merged.update(env)
        return subprocess.run(
            ["bash", str(SCRIPT), *args],
            text=True,
            capture_output=True,
            env=merged,
        )

    def test_current_tag_passes(self):
        result = self.run_gate(TAG)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"{FULL_VERSION} -> {TAG}", result.stderr)

    def test_stale_tag_fails(self):
        result = self.run_gate(STALE_TAG)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(f"must match app version {TAG}", result.stderr)

    def test_github_tag_environment_is_checked(self):
        result = self.run_gate(GITHUB_REF_TYPE="tag", GITHUB_REF_NAME=STALE_TAG)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(f"must match app version {TAG}", result.stderr)

    def test_branch_without_tag_only_validates_version(self):
        result = self.run_gate(GITHUB_REF_TYPE="branch", GITHUB_REF_NAME="master")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"release tag should be {TAG}", result.stderr)


if __name__ == "__main__":
    unittest.main()
