import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

import release_size_budget as sizes


class ReleaseSizeBudgetTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="release size budget ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def fixture(self, platform, *, boundaries=False):
        root = self.root / platform
        root.mkdir(exist_ok=True)
        limits = {
            "android": {".apk": 100, ".aab": 100},
            "ios": {".ipa": 150},
            "macos": {".pkg": 100, ".zip": None},
            "windows": {".msi": 150, ".zip": None},
            "linux": {".deb": 100, ".rpm": 100, ".tar.gz": None},
        }[platform]
        artifacts = []
        for extension, limit in limits.items():
            path = root / ("application" + extension)
            with path.open("wb") as stream:
                stream.truncate(limit * 1024 * 1024 if boundaries and limit else 7)
            artifacts.append(path)
        payload = None
        if platform != "android":
            payload = root / "payload"
            payload.mkdir(exist_ok=True)
            (payload / "program").write_bytes(b"program")
        return artifacts, payload, root / "size-budget.json"

    def test_actual_final_artifact_bytes_and_hash_change_with_the_file(self):
        artifacts, payload, output = self.fixture("ios")
        first = sizes.verify_sizes("ios", "arm64", artifacts, payload, output)
        self.assertEqual(first["artifacts"][0]["sha256"], hashlib.sha256(b"\0" * 7).hexdigest())
        artifacts[0].write_bytes(b"changed final bytes")
        second = sizes.verify_sizes("ios", "arm64", artifacts, payload, output)
        self.assertEqual(second["artifacts"][0]["bytes"], len(b"changed final bytes"))
        self.assertNotEqual(first["artifacts"][0]["sha256"], second["artifacts"][0]["sha256"])

    def test_existing_artifact_mib_budgets_accept_exact_boundary_and_reject_one_extra_byte(self):
        for platform in ("android", "ios", "macos", "windows", "linux"):
            artifacts, payload, output = self.fixture(platform, boundaries=True)
            with self.subTest(platform=platform):
                report = sizes.verify_sizes(platform, "fixture", artifacts, payload, output)
                self.assertEqual(report["outcome"], "passed")
                for limited in (item for item in report["artifacts"] if item["limit_bytes"] is not None):
                    path = next(path for path in artifacts if path.name == limited["name"])
                    self.assertEqual(limited["limit_bytes"], path.stat().st_size)
                    with path.open("ab") as stream:
                        stream.write(b"x")
                    with self.assertRaisesRegex(ValueError, "size budget"):
                        sizes.verify_sizes(platform, "fixture", artifacts, payload, output)
                    failed = json.loads(output.read_text())
                    self.assertEqual(failed["outcome"], "failed")
                    actual = next(item for item in failed["artifacts"] if item["name"] == path.name)
                    self.assertEqual(actual["bytes"], limited["limit_bytes"] + 1)
                    with path.open("r+b") as stream:
                        stream.truncate(limited["limit_bytes"])

    def test_existing_payload_mib_budgets_include_boundary_and_reject_one_extra_byte(self):
        for platform, limit in (("macos", 100), ("windows", 250), ("linux", 250)):
            artifacts, payload, output = self.fixture(platform)
            with (payload / "program").open("wb") as stream:
                stream.truncate(limit * 1024 * 1024)
            with self.subTest(platform=platform):
                report = sizes.verify_sizes(platform, "fixture", artifacts, payload, output)
                self.assertEqual(report["payload"]["bytes"], limit * 1024 * 1024)
                (payload / "extra").write_bytes(b"x")
                with self.assertRaisesRegex(ValueError, "size budget"):
                    sizes.verify_sizes(platform, "fixture", artifacts, payload, output)
                self.assertEqual(json.loads(output.read_text())["payload"]["bytes"], limit * 1024 * 1024 + 1)

    def test_payload_counts_all_files_and_link_text_without_following_directory_links(self):
        root = self.root / "payload"
        (root / "lib").mkdir(parents=True)
        (root / "lib/engine").write_bytes(b"native")
        (root / ".hidden").write_bytes(b"data")
        (root / "linked-lib").symlink_to("./lib", target_is_directory=True)
        measured = sizes.payload_bytes(root)
        self.assertEqual(measured["bytes"], 6 + 4 + len(b"./lib"))
        self.assertEqual(measured["regular_files"], 2)
        self.assertEqual(measured["symlinks"], 1)

    def test_payload_rejects_external_dangling_absolute_and_root_symlinks(self):
        root = self.root / "payload"
        root.mkdir()
        (root / "program").write_bytes(b"native")
        (self.root / "outside").write_bytes(b"outside")
        link = root / "bad"
        for target in ("../outside", "missing", str(root / "program")):
            link.symlink_to(target)
            with self.subTest(target=target), self.assertRaisesRegex(ValueError, "symlink"):
                sizes.payload_bytes(root)
            link.unlink()
        (self.root / "alias").symlink_to(root, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, "payload"):
            sizes.payload_bytes(self.root / "alias")

    def test_missing_duplicate_unexpected_and_linked_artifacts_fail_with_a_report(self):
        artifacts, payload, output = self.fixture("windows")
        unknown = self.root / "unexpected.ipa"
        unknown.write_bytes(b"unknown")
        linked = self.root / "linked.msi"
        linked.symlink_to(artifacts[0])
        for files in ([], artifacts[:1], [*artifacts, artifacts[0]], [*artifacts, unknown], [linked, artifacts[1]]):
            with self.subTest(files=files), self.assertRaises(ValueError):
                sizes.verify_sizes("windows", "fixture", files, payload, output)
            self.assertEqual(json.loads(output.read_text())["outcome"], "failed")

    def test_cli_rejects_oversize_final_artifact_and_retains_exact_report(self):
        artifacts, payload, output = self.fixture("ios")
        with artifacts[0].open("wb") as stream:
            stream.truncate(150 * 1024 * 1024 + 1)
        result = subprocess.run([sys.executable, str(Path(sizes.__file__)), "--platform", "ios",
                                 "--architecture", "arm64", "--artifacts", str(artifacts[0].parent),
                                 "--payload", str(payload), "--output", str(output)], capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("size budget", result.stderr)
        self.assertEqual(json.loads(output.read_text())["artifacts"][0]["bytes"], 150 * 1024 * 1024 + 1)


if __name__ == "__main__":
    unittest.main()
