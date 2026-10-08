import hashlib
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("verify_release_assets.sh")
SPEC = Path(__file__).resolve().parents[2] / "apps/morsecq/pubspec.yaml"
VERSION = re.search(r"^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+", SPEC.read_text(), re.M)[1]
BASE = f"morsecq-{VERSION}"


def names(architecture="universal2"):
    return [f"{BASE}-linux-x86_64.{extension}" for extension in ("deb", "rpm", "tar.gz")] + [
        f"{BASE}-windows-x64.msi", f"{BASE}-windows-x64.zip",
        f"{BASE}-macos-{architecture}.pkg", f"{BASE}-macos-{architecture}.zip",
        f"{BASE}-android.apk", f"{BASE}-android.aab", f"{BASE}-ios-unsigned.ipa",
    ]


class ReleaseAssetsTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name)
        for name in names():
            (self.root / name).write_bytes(name.encode())

    def verify(self, tag=f"v{VERSION}"):
        return subprocess.run(["bash", str(SCRIPT), str(self.root), tag],
                              text=True, capture_output=True)

    def test_all_ten_assets_create_portable_matching_checksums(self):
        result = self.verify()
        self.assertEqual(result.returncode, 0, result.stderr)
        lines = (self.root / "SHA256SUMS").read_text().splitlines()
        self.assertEqual(len(lines), 10)
        for line, name in zip(lines, names()):
            digest, leaf = line.split("  ")
            self.assertEqual(leaf, name)
            self.assertEqual(digest, hashlib.sha256((self.root / name).read_bytes()).hexdigest())

    def test_single_architecture_pair_is_accepted(self):
        for architecture in ("arm64", "x86_64"):
            with self.subTest(architecture=architecture):
                for name in names("universal2")[5:7]:
                    (self.root / name).unlink(missing_ok=True)
                for name in names(architecture)[5:7]:
                    (self.root / name).write_bytes(b"native package")
                result = self.verify()
                self.assertEqual(result.returncode, 0, result.stderr)
                for name in names(architecture)[5:7]:
                    (self.root / name).unlink()

    def test_missing_or_empty_asset_preserves_existing_manifest(self):
        manifest = self.root / "SHA256SUMS"
        manifest.write_text("previous manifest\n")
        path = self.root / names()[0]
        for empty in (False, True):
            with self.subTest(empty=empty):
                if empty:
                    path.write_bytes(b"")
                else:
                    path.unlink()
                result = self.verify()
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Required release asset", result.stderr)
                self.assertEqual(manifest.read_text(), "previous manifest\n")

    def test_unexpected_file_or_second_mac_architecture_is_rejected(self):
        unexpected = self.root / "unexpected.txt"
        unexpected.write_text("unrelated")
        result = self.verify()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unexpected release asset", result.stderr)
        unexpected.unlink()
        for name in names("arm64")[5:7]:
            (self.root / name).write_bytes(b"extra package")
        result = self.verify()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("exactly one macOS architecture", result.stderr)

    def test_symlink_asset_is_rejected(self):
        path = self.root / names()[0]
        path.unlink()
        path.symlink_to(self.root / names()[1])
        result = self.verify()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Required release asset", result.stderr)

    def test_tag_must_match_current_app_version(self):
        result = self.verify("v0.0.0" if VERSION != "0.0.0" else "v1.0.0")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(f"must match app version v{VERSION}", result.stderr)
        self.assertFalse((self.root / "SHA256SUMS").exists())

    def test_checksum_manifest_directory_is_rejected(self):
        (self.root / "SHA256SUMS").mkdir()
        result = self.verify()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unexpected release asset", result.stderr)


if __name__ == "__main__":
    unittest.main()
