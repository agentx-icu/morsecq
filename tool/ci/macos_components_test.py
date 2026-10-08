import plistlib
import tempfile
from pathlib import Path
import subprocess
import unittest
from macos_components import configure_components


class MacInstallerComponentsTest(unittest.TestCase):
    def test_root_is_selected_by_path_and_children_are_not_relocated(self):
        entries = [
            {"RootRelativeBundlePath": "MorseCQ.app/Contents/Frameworks/privacy.bundle"},
            {"RootRelativeBundlePath": "MorseCQ.app", "ChildBundles": [
                {"RootRelativeBundlePath": "Contents/Frameworks/framework.bundle"}]},
        ]
        result = configure_components(entries)
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["RootRelativeBundlePath"], "MorseCQ.app")
        self.assertFalse(result[0]["BundleIsRelocatable"])
        self.assertTrue(result[0]["BundleHasStrictIdentifier"])
        self.assertFalse(result[0]["ChildBundles"][0]["BundleIsRelocatable"])
        self.assertNotIn("BundleIsRelocatable", entries[1])

    def test_missing_or_duplicate_root_is_rejected(self):
        for entries in [[], [{"RootRelativeBundlePath": "MorseCQ.app"}] * 2]:
            with self.assertRaises(ValueError):
                configure_components(entries)

    def test_cli_replaces_valid_component_plist(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "components.plist"
            path.write_bytes(plistlib.dumps([{"RootRelativeBundlePath": "MorseCQ.app"}]))
            subprocess.run(["python3", str(Path(__file__).with_name("macos_components.py")), str(path)], check=True)
            result = plistlib.loads(path.read_bytes())
            self.assertFalse(result[0]["BundleIsRelocatable"])


if __name__ == "__main__":
    unittest.main()
