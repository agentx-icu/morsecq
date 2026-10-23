from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import unittest
import zipfile
from release_preflight_test import elf, pe

CI = Path(__file__).parent
MANIFEST = '<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="icu.agentx.morsecq" android:versionCode="2"><uses-sdk android:minSdkVersion="24" android:targetSdkVersion="36"/><uses-permission android:name="android.permission.RECORD_AUDIO"/><uses-feature android:name="android.hardware.microphone" android:required="false"/><application/></manifest>'

class StrictPackagerTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.ci = self.root / 'tool/ci'
        self.ci.mkdir(parents=True)
        for name in ['common.sh', 'package_artifacts.sh', 'release_preflight.py', 'macos_runtime.py', 'release_size_budget.py']:
            shutil.copy(CI / name, self.ci / name)
        app = self.root / 'apps/morsecq'
        app.mkdir(parents=True)
        (app / 'pubspec.yaml').write_text('version: 1.0.1+2\n')
        self.env = {'PATH': os.environ['PATH'], 'MORSECQ_DISTRIBUTION': '1'}

    def invoke(self, target):
        return subprocess.run(['bash', str(self.ci / 'package_artifacts.sh'), '--target', target], env=self.env, capture_output=True, text=True)

    def test_windows_strict_rejects_wrong_architecture_before_signing(self):
        release = self.root / 'apps/morsecq/build/windows/x64/runner/Release'
        release.mkdir(parents=True)
        (release / 'morsecq.exe').write_bytes(pe(machine=0xaa64))
        self.env['MORSECQ_WINDOWS_CERT_SHA1'] = '01' * 20  # Synthetic test input.
        result = self.invoke('windows')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('architecture', result.stderr)

    def test_android_strict_requires_explicit_inspection_tools(self):
        self.env['MORSECQ_ANDROID_UPLOAD_CERT_SHA256'] = '01' * 32
        result = self.invoke('android')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('MORSECQ_BUNDLETOOL_JAR', result.stderr)

    def test_android_strict_rejects_4k_payload_before_signing_or_copying(self):
        tools = self.root / 'bin'
        tools.mkdir()
        analyzer = tools / 'apkanalyzer'
        analyzer.write_text('#!/bin/sh\ncat <<\'XML\'\n' + MANIFEST + '\nXML\n')
        analyzer.chmod(0o755)
        java = tools / 'java'
        java.write_text('#!/bin/sh\ncase "$*" in\n *manifest*) cat <<\'XML\'\n' + MANIFEST + '\nXML\n;;\n *) echo PAGE_ALIGNMENT_16K;;\nesac\n')
        java.chmod(0o755)
        jar = tools / 'bundletool.jar'
        jar.write_bytes(b'fixture')
        self.env.update({'PATH': str(tools) + os.pathsep + self.env['PATH'], 'MORSECQ_BUNDLETOOL_JAR': str(jar), 'MORSECQ_APKANALYZER': str(analyzer), 'MORSECQ_ANDROID_UPLOAD_CERT_SHA256': '01' * 32})
        outputs = self.root / 'apps/morsecq/build/app/outputs'
        apk = outputs / 'flutter-apk/app-release.apk'
        aab = outputs / 'bundle/release/app-release.aab'
        for path in [apk, aab]:
            path.parent.mkdir(parents=True)
            with zipfile.ZipFile(path, 'w', compression=zipfile.ZIP_DEFLATED) as z:
                prefix = 'lib/' if path == apk else 'base/lib/'
                z.writestr(prefix + 'arm64-v8a/libflutter.so', elf(alignment=0x1000))
        result = self.invoke('android')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('16 KB', result.stderr)
        self.assertFalse((self.root / 'dist/android/morsecq-1.0.1-android.apk').exists())

    def test_development_packager_rejects_final_android_bytes_over_existing_budget(self):
        self.env['MORSECQ_DISTRIBUTION'] = '0'
        outputs = self.root / 'apps/morsecq/build/app/outputs'
        apk = outputs / 'flutter-apk/app-release.apk'
        aab = outputs / 'bundle/release/app-release.aab'
        for path in (apk, aab):
            path.parent.mkdir(parents=True)
            path.write_bytes(b'fixture, not a built app')
        with apk.open('wb') as stream:
            stream.truncate(100 * 1024 * 1024 + 1)
        result = self.invoke('android')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('size budget', result.stderr)
        evidence = self.root / 'build/evidence/android-size-budget.json'
        self.assertIn('"outcome": "failed"', evidence.read_text())

if __name__ == '__main__':
    unittest.main()
