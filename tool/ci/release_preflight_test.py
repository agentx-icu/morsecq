import plistlib
from pathlib import Path
import struct
import tempfile
import unittest
import zipfile

from release_preflight import check_android_native, check_android_manifest, check_apple, check_native_directory


def elf(machine=183, alignment=0x4000):
    data = bytearray(120)
    data[:7] = b'\x7fELF\x02\x01\x01'
    struct.pack_into('<HHIQQQIHHHHHH', data, 16, 3, machine, 1, 0, 64, 0, 0, 64, 56, 1, 0, 0, 0)
    struct.pack_into('<IIQQQQQQ', data, 64, 1, 5, 0, 0, 0, 120, 120, alignment)
    return data


def pe(machine=0x8664):
    data = bytearray(128)
    data[:2] = b'MZ'
    struct.pack_into('<I', data, 60, 64)
    data[64:68] = b'PE\x00\x00'
    struct.pack_into('<H', data, 68, machine)
    return data


class ReleasePreflightTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def test_android_checks_every_module_and_matches_directory_abi(self):
        path = self.root / 'fixture.aab'
        with zipfile.ZipFile(path, 'w') as z:
            z.writestr('base/lib/arm64-v8a/libapp.so', elf())
            z.writestr('base/lib/arm64-v8a/libplugin.so', elf(machine=62))
        with self.assertRaisesRegex(ValueError, 'ABI'):
            check_android_native(path, {'arm64-v8a'}, apk=False)

    def test_android_rejects_4k_elf_even_when_compressed(self):
        path = self.root / 'fixture.apk'
        with zipfile.ZipFile(path, 'w', compression=zipfile.ZIP_DEFLATED) as z:
            z.writestr('lib/arm64-v8a/libflutter.so', elf(alignment=0x1000))
        with self.assertRaisesRegex(ValueError, '16 KB'):
            check_android_native(path, {'arm64-v8a'}, apk=True)

    def test_compressed_apk_needs_no_zip_alignment_but_stored_library_does(self):
        path = self.root / 'fixture.apk'
        for compression in [zipfile.ZIP_DEFLATED, zipfile.ZIP_STORED]:
            with zipfile.ZipFile(path, 'w', compression=compression) as z:
                z.writestr('lib/arm64-v8a/libapp.so', elf())
            if compression == zipfile.ZIP_STORED:
                with self.assertRaisesRegex(ValueError, 'ZIP'):
                    check_android_native(path, {'arm64-v8a'}, apk=True)
            else:
                self.assertEqual(len(check_android_native(path, {'arm64-v8a'}, apk=True)), 1)

    def test_android_merged_manifest_rejects_unexpected_access_and_debug(self):
        xml = '''<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="icu.agentx.morsecq" android:versionCode="2"><uses-sdk android:minSdkVersion="24" android:targetSdkVersion="36"/><uses-permission android:name="android.permission.RECORD_AUDIO"/><uses-feature android:name="android.hardware.microphone" android:required="false"/><application android:debuggable="false"/></manifest>'''
        self.assertEqual(check_android_manifest(xml, 36)['package'], 'icu.agentx.morsecq')
        for bad in [xml.replace('RECORD_AUDIO', 'INTERNET'), xml.replace('required="false"', 'required="true"'), xml.replace('debuggable="false"', 'debuggable="true"')]:
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                check_android_manifest(bad, 36)

    def test_androidx_private_receiver_permission_must_be_signature_scoped(self):
        xml = '<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="icu.agentx.morsecq" android:versionCode="2"><uses-sdk android:minSdkVersion="24" android:targetSdkVersion="36"/><uses-permission android:name="android.permission.RECORD_AUDIO"/><permission android:name="icu.agentx.morsecq.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION" android:protectionLevel="0x2"/><uses-permission android:name="icu.agentx.morsecq.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION"/><uses-feature android:name="android.hardware.microphone" android:required="false"/><application/></manifest>'
        for level in ['signature', '2', '0x2', '0x00000002']:
            check_android_manifest(xml.replace('protectionLevel="0x2"', f'protectionLevel="{level}"'), 36)
        with self.assertRaises(ValueError):
            check_android_manifest(xml.replace('protectionLevel="0x2"', 'protectionLevel="normal"'), 36)

    def test_windows_checks_plugin_machine_instead_of_directory_label(self):
        (self.root / 'morsecq.exe').write_bytes(pe())
        (self.root / 'plugin.dll').write_bytes(pe(machine=0xaa64))
        with self.assertRaisesRegex(ValueError, 'architecture'):
            check_native_directory(self.root, 'windows', 'x86_64')
        (self.root / 'plugin.dll').write_bytes(pe())
        self.assertEqual(len(check_native_directory(self.root, 'windows', 'x86_64')), 2)

    def test_linux_rejects_versioned_corrupt_library_and_dangling_symlink(self):
        (self.root / 'morsecq').write_bytes(elf(machine=62))
        library = self.root / 'libfoo.so.1'
        library.write_bytes(b'corrupt')
        with self.assertRaisesRegex(ValueError, 'ELF'):
            check_native_directory(self.root, 'linux', 'x86_64')
        library.unlink()
        library.symlink_to('missing.so.2')
        with self.assertRaisesRegex(ValueError, 'symlink'):
            check_native_directory(self.root, 'linux', 'x86_64')

    def test_windows_zip_payload_is_inspected_after_extraction(self):
        archive = self.root / 'windows.zip'
        with zipfile.ZipFile(archive, 'w') as z:
            z.writestr('morsecq/morsecq.exe', pe())
            z.writestr('morsecq/plugin.dll', pe(machine=0xaa64))
        with self.assertRaisesRegex(ValueError, 'architecture'):
            check_native_directory(archive, 'windows', 'x86_64')

    def test_apple_requires_app_manifest_and_rejects_collected_data(self):
        app = self.root / 'MorseCQ.app'
        app.mkdir()
        (app / 'Info.plist').write_bytes(plistlib.dumps({'CFBundleIdentifier': 'icu.agentx.morsecq', 'CFBundleVersion': '2', 'CFBundleShortVersionString': '1.0.1', 'NSMicrophoneUsageDescription': 'Decode Morse', 'MinimumOSVersion': '14.0'}))
        with self.assertRaisesRegex(ValueError, 'PrivacyInfo'):
            check_apple(app, 'ios', inspect_native=False)
        (app / 'PrivacyInfo.xcprivacy').write_bytes(plistlib.dumps({'NSPrivacyTracking': False, 'NSPrivacyCollectedDataTypes': [{'NSPrivacyCollectedDataType': 'bad'}], 'NSPrivacyAccessedAPITypes': []}))
        with self.assertRaisesRegex(ValueError, 'collection'):
            check_apple(app, 'ios', inspect_native=False)

if __name__ == '__main__':
    unittest.main()
