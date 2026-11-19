import plistlib
from pathlib import Path
import struct
import sys
import tempfile
import unittest
from unittest.mock import patch
import warnings
import zipfile

from release_preflight import (LOCALES, check_android_native, check_android_manifest,
                               check_apple, check_native_directory, main)


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
        xml = '''<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="icu.agentx.morsecq" android:versionCode="2" android:versionName="1.0.1"><uses-sdk android:minSdkVersion="24" android:targetSdkVersion="36"/><uses-permission android:name="android.permission.RECORD_AUDIO"/><uses-feature android:name="android.hardware.microphone" android:required="false"/><application android:debuggable="false"/></manifest>'''
        with_audio_settings = xml.replace('<application',
            '<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/><application')
        self.assertEqual(check_android_manifest(xml, 36)['package'], 'icu.agentx.morsecq')
        self.assertIn('android.permission.MODIFY_AUDIO_SETTINGS',
                      check_android_manifest(with_audio_settings, 36)['permissions'])
        for bad in [xml.replace('RECORD_AUDIO', 'INTERNET'), xml.replace('required="false"', 'required="true"'), xml.replace('debuggable="false"', 'debuggable="true"')]:
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                check_android_manifest(bad, 36)

    def test_android_manifest_preserves_package_uid_and_full_version_code(self):
        manifest = '''<manifest xmlns:android="http://schemas.android.com/apk/res/android"
            package="icu.agentx.morsecq" android:versionName="1.0.1" android:versionCode="2" {attribute}>
            <uses-sdk android:minSdkVersion="24" android:targetSdkVersion="36"/>
            <uses-permission android:name="android.permission.RECORD_AUDIO"/>
            <uses-feature android:name="android.hardware.microphone" android:required="false"/>
            <application/>
        </manifest>'''
        def inspect(attribute):
            return check_android_manifest(manifest.format(attribute=attribute), 36,
                                          expected_version='1.0.1+2')

        normal = inspect('')
        for zero in ('0', '0x0', '0x00000000'):
            with self.subTest(zero=zero):
                self.assertEqual(normal, inspect(f'android:versionCodeMajor="{zero}"'))
        for attribute, message in [
            ('android:sharedUserId="icu.agentx.other"', 'sharedUserId'),
            ('android:versionCodeMajor="1"', 'versionCodeMajor'),
            ('android:versionCodeMajor="0x1"', 'versionCodeMajor'),
        ]:
            with self.subTest(attribute=attribute), self.assertRaisesRegex(ValueError, message):
                inspect(attribute)

    def test_androidx_private_receiver_permission_must_be_signature_scoped(self):
        xml = '<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="icu.agentx.morsecq" android:versionCode="2" android:versionName="1.0.1"><uses-sdk android:minSdkVersion="24" android:targetSdkVersion="36"/><uses-permission android:name="android.permission.RECORD_AUDIO"/><permission android:name="icu.agentx.morsecq.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION" android:protectionLevel="0x2"/><uses-permission android:name="icu.agentx.morsecq.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION"/><uses-feature android:name="android.hardware.microphone" android:required="false"/><application/></manifest>'
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

    def test_windows_canonical_elf_snapshot_must_match_target_cpu(self):
        (self.root / 'morsecq.exe').write_bytes(pe())
        snapshot = self.root / 'data/app.so'
        snapshot.parent.mkdir()
        snapshot.write_bytes(elf(machine=62))
        self.assertEqual(len(check_native_directory(self.root, 'windows', 'x86_64')), 2)
        snapshot.write_bytes(elf(machine=183))
        with self.assertRaisesRegex(ValueError, 'architecture'):
            check_native_directory(self.root, 'windows', 'x86_64')
        snapshot.write_bytes(b'corrupt')
        with self.assertRaisesRegex(ValueError, 'ELF'):
            check_native_directory(self.root, 'windows', 'x86_64')

    def test_windows_zip_snapshot_wrong_architecture_is_rejected(self):
        archive = self.root / 'windows.zip'
        with zipfile.ZipFile(archive, 'w') as z:
            z.writestr('morsecq/morsecq.exe', pe())
            z.writestr('morsecq/data/app.so', elf(machine=183))
        with self.assertRaisesRegex(ValueError, 'architecture'):
            check_native_directory(archive, 'windows', 'x86_64')
        with zipfile.ZipFile(archive, 'w') as z:
            z.writestr('morsecq/morsecq.exe', pe())
            z.writestr('morsecq/data/app.so', elf(machine=62))
        self.assertEqual(len(check_native_directory(archive, 'windows', 'x86_64')), 2)

    def test_installed_payload_matches_every_final_zip_file(self):
        from release_preflight import check_installed_payload
        archive = self.root / 'windows.zip'
        installed = self.root / 'installed with spaces'
        installed.mkdir()
        with zipfile.ZipFile(archive, 'w') as z:
            z.writestr('morsecq/morsecq.exe', pe())
            z.writestr('morsecq/data/flutter_assets/FontManifest.json', b'[]')
        (installed / 'morsecq.exe').write_bytes(pe())
        with self.assertRaisesRegex(ValueError, 'Missing installed file'):
            check_installed_payload(installed, archive)
        asset = installed / 'data/flutter_assets/FontManifest.json'
        asset.parent.mkdir(parents=True)
        asset.write_bytes(b'[]')
        self.assertEqual(len(check_installed_payload(installed, archive)), 2)
        asset.write_bytes(b'changed')
        with self.assertRaisesRegex(ValueError, 'Installed file differs'):
            check_installed_payload(installed, archive)
        asset.write_bytes(b'[]')
        (installed / 'unexpected.dll').write_bytes(pe())
        with self.assertRaisesRegex(ValueError, 'Unexpected installed files'):
            check_installed_payload(installed, archive)

    def test_installed_payload_requires_an_executable_file_not_a_directory(self):
        from release_preflight import check_installed_payload
        archive = self.root / 'windows.zip'
        with zipfile.ZipFile(archive, 'w') as z:
            z.writestr('morsecq/morsecq.exe/', b'')
        with self.assertRaisesRegex(ValueError, 'missing morsecq.exe'):
            check_installed_payload(self.root, archive)

    def test_windows_release_requires_app_local_crt_next_to_runner(self):
        from release_preflight import check_windows_runtime
        records = [{'path': 'morsecq/morsecq.exe'}]
        with self.assertRaisesRegex(ValueError, 'app-local MSVC'):
            check_windows_runtime(records)
        for name in ['msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll']:
            records.append({'path': 'morsecq/' + name})
        self.assertEqual(len(check_windows_runtime(records)), 3)
        records[-1]['path'] = 'morsecq/subdirectory/vcruntime140_1.dll'
        with self.assertRaisesRegex(ValueError, 'app-local MSVC'):
            check_windows_runtime(records)

    def test_installed_payload_rejects_unsafe_or_duplicate_zip_entries(self):
        from release_preflight import check_installed_payload
        archive = self.root / 'windows.zip'
        for names in [('morsecq/../escape',), ('morsecq/morsecq.exe', 'morsecq/morsecq.exe')]:
            with self.subTest(names=names):
                with warnings.catch_warnings(), zipfile.ZipFile(archive, 'w') as z:
                    warnings.simplefilter('ignore', UserWarning)
                    for name in names:
                        z.writestr(name, b'fixture')
                with self.assertRaisesRegex(ValueError, 'Unsafe or duplicate'):
                    check_installed_payload(self.root, archive)

    def test_apple_requires_app_manifest_and_rejects_collected_data(self):
        app = self.root / 'MorseCQ.app'
        app.mkdir()
        (app / 'Info.plist').write_bytes(plistlib.dumps({'CFBundleIdentifier': 'icu.agentx.morsecq', 'CFBundleVersion': '2', 'CFBundleShortVersionString': '1.0.1', 'NSMicrophoneUsageDescription': 'Decode Morse', 'MinimumOSVersion': '14.0'}))
        with self.assertRaisesRegex(ValueError, 'PrivacyInfo'):
            check_apple(app, 'ios', inspect_native=False)
        (app / 'PrivacyInfo.xcprivacy').write_bytes(plistlib.dumps({'NSPrivacyTracking': False, 'NSPrivacyCollectedDataTypes': [{'NSPrivacyCollectedDataType': 'bad'}], 'NSPrivacyAccessedAPITypes': []}))
        with self.assertRaisesRegex(ValueError, 'collection'):
            check_apple(app, 'ios', inspect_native=False)

    def ios_fixture(self):
        app = self.root / 'Runner.app'
        app.mkdir()
        usage = {'NSMicrophoneUsageDescription': 'Decode Morse'}
        (app / 'Info.plist').write_bytes(plistlib.dumps({
            **usage, 'CFBundleIdentifier': 'icu.agentx.morsecq',
            'CFBundleShortVersionString': '1.0.1', 'CFBundleVersion': '2',
            'MinimumOSVersion': '14.0', 'UIDeviceFamily': [1, 2],
        }))
        (app / 'PrivacyInfo.xcprivacy').write_bytes(plistlib.dumps({'NSPrivacyTracking': False}))
        (app / 'Runner').write_bytes(b'\xcf\xfa\xed\xfe')
        for locale in LOCALES:
            strings = app / f'{locale}.lproj/InfoPlist.strings'
            strings.parent.mkdir()
            strings.write_bytes(plistlib.dumps(usage))
        return app

    def test_ios_requires_the_declared_deployment_minimum(self):
        app = self.ios_fixture()
        plist = app / 'Info.plist'
        info = plistlib.loads(plist.read_bytes())
        for minimum in [None, '16.0', '13.0', '14.bad']:
            updated = dict(info)
            if minimum is None:
                updated.pop('MinimumOSVersion')
            else:
                updated['MinimumOSVersion'] = minimum
            plist.write_bytes(plistlib.dumps(updated))
            with self.subTest(minimum=minimum), self.assertRaisesRegex(ValueError, 'iOS minimum'):
                check_apple(app, 'ios', inspect_native=False)

    def test_ios_keeps_iphone_and_ipad_in_the_built_device_family(self):
        app = self.ios_fixture()
        plist = app / 'Info.plist'
        info = plistlib.loads(plist.read_bytes())
        info.pop('UIDeviceFamily')
        for family in [None, [1], [2], [1, 1], [True, 2], '1,2']:
            change = {} if family is None else {'UIDeviceFamily': family}
            plist.write_bytes(plistlib.dumps({**info, **change}))
            with self.subTest(family=family), self.assertRaisesRegex(ValueError, 'UIDeviceFamily'):
                check_apple(app, 'ios', inspect_native=False)
        plist.write_bytes(plistlib.dumps({**info, 'UIDeviceFamily': [2, 1]}))
        self.assertEqual(check_apple(app, 'ios', inspect_native=False)['device_family'], [1, 2])

    def test_ios_rejects_legacy_simulator_slice_in_arm64_device_binary(self):
        app = self.ios_fixture()
        commands = '''Runner (architecture arm64):
Load command 2
    cmd LC_BUILD_VERSION
    platform 2
    minos 14.0
Runner (architecture x86_64):
Load command 2
    cmd LC_VERSION_MIN_IPHONEOS
    version 12.0
'''
        with patch('release_preflight.run', side_effect=['arm64 x86_64', commands]), \
                self.assertRaisesRegex(ValueError, 'unexpected iOS architectures'):
            check_apple(app, 'ios')

    def test_ios_checks_minimum_ios_of_every_embedded_macho(self):
        app = self.ios_fixture()
        framework = app / 'Frameworks/Future.framework/Future'
        framework.parent.mkdir(parents=True)
        framework.write_bytes(b'\xcf\xfa\xed\xfe')
        modern = ('Load command 2\n cmd LC_BUILD_VERSION\n cmdsize 32\n'
                  ' platform 2\n minos {minimum}\n sdk 26.5\n ntools 1\n tool 3\n version 1267.0\n')
        legacy = ('Load command 2\n cmd LC_VERSION_MIN_IPHONEOS\n cmdsize 16\n'
                  ' version 13.0\n sdk 26.5\n')
        for bad, message in [(modern.format(minimum='16.0'), r'Future.+16\.0.+14\.0'),
                             (modern.format(minimum='14.0').replace('platform 2', 'platform 7'), 'iOS'),
                             ('Load command 2\n cmd LC_UUID\n', 'iOS')]:
            outputs = ['arm64', bad, 'arm64', modern.format(minimum='14.0')]
            with self.subTest(bad=bad), patch('release_preflight.run', side_effect=outputs), \
                    self.assertRaisesRegex(ValueError, message):
                check_apple(app, 'ios')
        outputs = ['arm64', legacy, 'arm64', modern.format(minimum='14.0')]
        with patch('release_preflight.run', side_effect=outputs):
            report = check_apple(app, 'ios')
        self.assertEqual(report['minimum_os']['app_minimum'], '14.0.0')
        self.assertEqual([entry['architecture_minima'] for entry in report['binaries']],
                         [['13.0.0'], ['14.0.0']])

    def test_apple_release_preflight_refuses_an_older_built_app(self):
        pubspec = self.root / 'apps/morsecq/pubspec.yaml'
        pubspec.parent.mkdir(parents=True)
        pubspec.write_text('version: 1.0.2+3\n')
        app = self.ios_fixture()
        args = ['release_preflight.py', '--output', str(self.root / 'ios.json'),
                'apple', str(app), '--platform', 'ios']
        with patch('release_preflight.__file__', str(self.root / 'tool/ci/release_preflight.py')), \
                patch.object(sys, 'argv', args), \
                patch('release_preflight.run', side_effect=['arm64', 'platform IOS\n']):
            with self.assertRaisesRegex(ValueError, 'Apple artifact version 1.0.1\\+2 differs from pubspec version 1.0.2\\+3'):
                main()

if __name__ == '__main__':
    unittest.main()
