import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("clean_apple_plugin_cache.sh")


class ApplePluginCacheTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.cache = Path(self.folder.name) / "pub cache"
        self.env = {**os.environ, "PUB_CACHE": str(self.cache)}

    def plugin(self, host="pub.dev", version="3.4.10"):
        folder = self.cache / "hosted" / host / f"flutter_soloud-{version}"
        folder.mkdir(parents=True, exist_ok=True)
        return folder

    def clean(self, platform):
        return subprocess.run(["bash", str(SCRIPT), platform], env=self.env,
                              text=True, capture_output=True)

    def test_removes_only_selected_generated_platform_across_hosts(self):
        for platform, other in (("macos", "ios"), ("ios", "macos")):
            with self.subTest(platform=platform):
                for host in ("pub.dev", "mirror.example"):
                    plugin = self.plugin(host)
                    for target in (platform, other):
                        generated = plugin / target / "cmake_build"
                        generated.mkdir(parents=True, exist_ok=True)
                        (generated / "CMakeCache.txt").write_text("stale cache")
                    (plugin / platform / "CMakeLists.txt").write_text("plugin source")
                unrelated = self.cache / "hosted/pub.dev/other_plugin/macos/cmake_build"
                unrelated.mkdir(parents=True, exist_ok=True)
                result = self.clean(platform)
                self.assertEqual(result.returncode, 0, result.stderr)
                for host in ("pub.dev", "mirror.example"):
                    plugin = self.plugin(host)
                    self.assertFalse((plugin / platform / "cmake_build").exists())
                    self.assertTrue((plugin / other / "cmake_build/CMakeCache.txt").exists())
                    self.assertEqual((plugin / platform / "CMakeLists.txt").read_text(), "plugin source")
                self.assertTrue(unrelated.exists())

    def test_empty_cache_cleanup_is_idempotent(self):
        for _ in range(2):
            result = self.clean("macos")
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.cache.exists())

    def test_invalid_platform_does_not_delete_generated_files(self):
        generated = self.plugin() / "macos/cmake_build"
        generated.mkdir(parents=True)
        result = self.clean("linux")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unsupported Apple platform", result.stderr)
        self.assertTrue(generated.exists())

    def test_removed_xcode_compiler_cache_reconfigures_after_cleanup(self):
        for platform in ("macos", "ios"):
            with self.subTest(platform=platform):
                source = self.plugin() / platform
                source.mkdir(parents=True)
                (source / "CMakeLists.txt").write_text(
                    "cmake_minimum_required(VERSION 3.15)\nproject(CacheRegression LANGUAGES CXX)\n")
                generated = source / "cmake_build"

                def configure():
                    return subprocess.run(["cmake", "-S", str(source), "-B", str(generated)],
                                          text=True, capture_output=True)

                first = configure()
                self.assertEqual(first.returncode, 0, first.stderr)
                cache = generated / "CMakeCache.txt"
                content, count = re.subn(r"^CMAKE_CXX_COMPILER:[^=]+=.*$",
                                        "CMAKE_CXX_COMPILER:FILEPATH=/removed/Xcode.app/usr/bin/clang++",
                                        cache.read_text(), flags=re.M)
                self.assertEqual(count, 1)
                cache.write_text(content)
                stale = configure()
                self.assertNotEqual(stale.returncode, 0)
                self.assertIn("/removed/Xcode.app", stale.stderr)
                result = self.clean(platform)
                self.assertEqual(result.returncode, 0, result.stderr)
                fresh = configure()
                self.assertEqual(fresh.returncode, 0, fresh.stderr)
                self.assertNotIn("/removed/Xcode.app", cache.read_text())


if __name__ == "__main__":
    unittest.main()
