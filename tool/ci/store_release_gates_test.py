"""Store wrapper regressions with fake build tools; no Flutter or credentials."""
import base64
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[2]


class StoreReleaseGatesTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name)
        for name in ("build_all.sh", "tool/build_ios_store.sh", "tool/ci/common.sh",
                     "tool/ci/check_version_tag.sh", "apps/morsecq/pubspec.yaml"):
            target = self.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(REPO / name, target)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "commands.log"
        self.env = {**os.environ, "PATH": f"{self.bin}:{os.environ['PATH']}",
                    "TEST_LOG": str(self.log), "GITHUB_REF_TYPE": "branch",
                    "GITHUB_REF_NAME": "master"}
        self.command("dart", 'echo "dart $*" >> "$TEST_LOG"\n')
        self.command("codesign", 'echo "codesign $*" >> "$TEST_LOG"\n')
        self.command("flutter", '''echo "flutter $*" >> "$TEST_LOG"
mkdir -p build/ios/ipa build/ios/archive/MorseCQ.xcarchive/Products/Applications/MorseCQ.app
printf 'test fixture' > build/ios/ipa/morsecq.ipa
''')

    def command(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env bash\nset -euo pipefail\n" + body)
        path.chmod(0o755)

    def store(self, *args):
        return subprocess.run(["bash", str(self.root / "tool/build_ios_store.sh"), *args],
                              env=self.env, capture_output=True, text=True)

    def test_store_export_and_actual_product_name_are_verified(self):
        result = self.store()
        self.assertEqual(result.returncode, 0, result.stderr)
        log = self.log.read_text()
        self.assertIn("flutter build ipa --release --export-method app-store", log)
        self.assertIn("codesign --verify --deep --strict --verbose=2", log)
        self.assertIn("MorseCQ.xcarchive/Products/Applications/MorseCQ.app", log)

    def test_store_rejects_unsigned_mode_and_export_overrides_before_build(self):
        for args in (("--no-codesign",), ("--export-method=ad-hoc",),
                     ("--export-method", "development"),
                     ("--export-options-plist", "ad-hoc.plist"),
                     ("--export-options-plist=ad-hoc.plist",),
                     ("--debug",), ("--profile",)):
            with self.subTest(args=args):
                result = self.store(*args)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(self.log.exists())

    def test_missing_export_does_not_reuse_stale_ipa(self):
        old = self.root / "apps/morsecq/build/ios/ipa/stale.ipa"
        old.parent.mkdir(parents=True)
        old.write_bytes(b"old build")
        self.command("flutter", "exit 0\n")
        result = self.store()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("expected exactly one non-empty App Store IPA", result.stderr)
        self.assertFalse(old.exists())

    def test_codesign_failure_fails_store_build(self):
        self.command("codesign", "exit 1\n")
        result = self.store()
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("signed App Store IPA:", result.stdout)

    def test_general_ios_release_requires_explicit_unsigned_opt_in(self):
        script = str(self.root / "build_all.sh")
        result = subprocess.run(["bash", script, "--platform", "ios", "--mode", "release"],
                                env=self.env, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("build_ios_store.sh", result.stderr)
        self.assertFalse(self.log.exists())
        result = subprocess.run(["bash", script, "--platform", "ios", "--mode", "release",
                                 "--allow-unsigned-ios"],
                                env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("flutter build ios --release --no-codesign", self.log.read_text())

    def signing_step(self, ref_type, values=()):
        text = (REPO / ".github/workflows/builds.yml").read_text()
        block = text.split("      - name: Prepare release signing\n", 1)[1]
        block = block.split("        run: |\n", 1)[1].split("      - name:", 1)[0]
        script = "\n".join(line[10:] for line in block.splitlines())
        names = ("ANDROID_KEYSTORE_BASE64", "ANDROID_KEYSTORE_PASSWORD",
                 "ANDROID_KEY_ALIAS", "ANDROID_KEY_PASSWORD")
        env = {**self.env, **dict.fromkeys(names, ""),
               "GITHUB_REF_TYPE": ref_type, "GITHUB_ENV": str(self.root / "github_env"),
               "RUNNER_TEMP": str(self.root)}
        env.update(dict(zip(names, values)))
        return subprocess.run(["bash", "-euo", "pipefail", "-c", script],
                              env=env, capture_output=True, text=True)

    def test_android_tag_missing_or_partial_signing_fails(self):
        for values in ((), ("fixture",)):
            with self.subTest(values=values):
                result = self.signing_step("tag", values)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse((self.root / "github_env").exists())

    def test_android_branch_missing_signing_explicitly_opts_into_test_key(self):
        result = self.signing_step("branch")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("MORSECQ_ALLOW_DEBUG_SIGNING=1", (self.root / "github_env").read_text())

    def test_android_tag_with_all_signing_values_never_enables_debug_key(self):
        values = (base64.b64encode(b"nonsecret test fixture").decode(), "test", "test", "test")
        result = self.signing_step("tag", values)
        self.assertEqual(result.returncode, 0, result.stderr)
        env = (self.root / "github_env").read_text()
        self.assertIn("MORSECQ_ANDROID_KEYSTORE=", env)
        self.assertNotIn("MORSECQ_ALLOW_DEBUG_SIGNING", env)

    def test_gradle_signing_gate_runs_as_release_task_not_configuration(self):
        text = (REPO / "apps/morsecq/android/app/build.gradle.kts").read_text()
        config = text.split("    buildTypes {", 1)[1].split("val verifyMorsecqReleaseSigning", 1)[0]
        self.assertNotIn("throw GradleException", config)
        self.assertIn('morsecqAllowDebugSigning -> signingConfigs.getByName("debug")', config)
        self.assertIn("else -> null", config)
        task = text.split('tasks.register("verifyMorsecqReleaseSigning")', 1)[1]
        self.assertIn("doLast {", task)
        self.assertIn("tasks.configureEach", task)
        self.assertIn('name == "preReleaseBuild"', task)
        self.assertIn('name == "assembleRelease"', task)
        self.assertIn('name == "bundleRelease"', task)
        self.assertIn("dependsOn(verifyMorsecqReleaseSigning)", task)
        self.assertIn("(!morsecqAllowDebugSigning || taggedBuild)", task)


if __name__ == "__main__":
    unittest.main()
