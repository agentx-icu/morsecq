#!/usr/bin/env python3
"""Inspect built release payloads. This is artifact evidence, not store approval."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import plistlib
import re
import struct
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile

from macos_runtime import MACHO_MAGICS, check_bundle

ANDROID = '{http://schemas.android.com/apk/res/android}'
ABIS = {'arm64-v8a': (2, 183), 'armeabi-v7a': (1, 40), 'x86_64': (2, 62)}
PERMISSIONS = {'android.permission.RECORD_AUDIO', 'android.permission.VIBRATE', 'android.permission.WAKE_LOCK'}
LOCALES = ['en', 'zh-Hans', 'zh-Hant', 'ja', 'ko', 'de', 'fr', 'es', 'pt', 'ru']


def run(command):
    return subprocess.run([str(x) for x in command], check=True, capture_output=True, text=True, timeout=120).stdout


def digest(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def elf_info(data):
    if data[:4] != b'\x7fELF' or len(data) < 52 or data[5] not in (1, 2) or data[4] not in (1, 2):
        raise ValueError('Invalid ELF payload')
    endian = '<' if data[5] == 1 else '>'
    bits = data[4]
    machine = struct.unpack_from(endian + 'H', data, 18)[0]
    if bits == 2:
        offset = struct.unpack_from(endian + 'Q', data, 32)[0]
        size, count = struct.unpack_from(endian + 'HH', data, 54)
    else:
        offset = struct.unpack_from(endian + 'I', data, 28)[0]
        size, count = struct.unpack_from(endian + 'HH', data, 42)
    minimum_size = 56 if bits == 2 else 32
    if size < minimum_size or not count or offset + size * count > len(data):
        raise ValueError('Invalid ELF program headers')
    loads = []
    for index in range(count):
        pos = offset + index * size
        if struct.unpack_from(endian + 'I', data, pos)[0] != 1:
            continue
        if bits == 2:
            values = struct.unpack_from(endian + 'IIQQQQQQ', data, pos)
            file_offset, address, alignment = values[2], values[3], values[7]
        else:
            values = struct.unpack_from(endian + 'IIIIIIII', data, pos)
            file_offset, address, alignment = values[1], values[2], values[7]
        loads.append((file_offset, address, alignment))
    if not loads:
        raise ValueError('ELF has no PT_LOAD segments')
    return bits, machine, loads


def check_android_native(path, expected_abis, *, apk):
    records, seen = [], set()
    with zipfile.ZipFile(path) as archive, Path(path).open('rb') as raw:
        for entry in archive.infolist():
            match = re.fullmatch(r'(?:[^/]+/)?lib/([^/]+)/[^/]+\.so', entry.filename)
            if not match:
                continue
            abi = match[1]
            seen.add(abi)
            data = archive.read(entry)
            bits, machine, loads = elf_info(data)
            if (bits, machine) != ABIS.get(abi):
                raise ValueError(f'{entry.filename}: ELF disagrees with directory ABI')
            if bits == 2 and any(alignment < 16384 or alignment & (alignment - 1) or offset % alignment != address % alignment for offset, address, alignment in loads):
                raise ValueError(f'{entry.filename}: PT_LOAD is not 16 KB compatible')
            if apk and bits == 2 and entry.compress_type == zipfile.ZIP_STORED:
                raw.seek(entry.header_offset)
                header = raw.read(30)
                name_length, extra_length = struct.unpack_from('<HH', header, 26)
                data_offset = entry.header_offset + 30 + name_length + extra_length
                if data_offset % 16384:
                    raise ValueError(f'{entry.filename}: uncompressed ZIP payload is not 16 KB aligned')
            records.append({'path': entry.filename, 'abi': abi, 'sha256': hashlib.sha256(data).hexdigest(), 'compressed': entry.compress_type != zipfile.ZIP_STORED, 'load_alignment': [v[2] for v in loads]})
    if seen != expected_abis:
        raise ValueError(f'Native ABI inventory {sorted(seen)} != declared {sorted(expected_abis)}')
    return records


def check_android_manifest(xml, target_sdk):
    root = ET.fromstring(xml)
    sdk, app = root.find('uses-sdk'), root.find('application')
    if root.get('package') != 'icu.agentx.morsecq' or not root.get(ANDROID + 'versionCode'):
        raise ValueError('Unexpected package identity or missing version code')
    if sdk is None or int(sdk.get(ANDROID + 'minSdkVersion', '0')) != 24 or int(sdk.get(ANDROID + 'targetSdkVersion', '0')) != target_sdk:
        raise ValueError('Final minimum / target SDK disagrees with declared release policy')
    if app is None or app.get(ANDROID + 'debuggable', 'false') != 'false' or app.get(ANDROID + 'testOnly', 'false') != 'false':
        raise ValueError('Debug / test-only application is not a release payload')
    permissions = {p.get(ANDROID + 'name') for p in root if p.tag.startswith('uses-permission')}
    allowed = set(PERMISSIONS)
    private_receiver = 'icu.agentx.morsecq.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
    for declaration in root.findall('permission'):
        if declaration.get(ANDROID + 'name') == private_receiver and re.fullmatch(r'(?:signature|0x0*2|2)', declaration.get(ANDROID + 'protectionLevel', '')):
            allowed.add(private_receiver)
    if not permissions <= allowed or 'android.permission.RECORD_AUDIO' not in permissions:
        raise ValueError(f'Unexpected merged permissions: {sorted(permissions)}')
    features = {f.get(ANDROID + 'name'): f.get(ANDROID + 'required', 'true') for f in root.findall('uses-feature')}
    if features.get('android.hardware.microphone') != 'false' or features.get('android.hardware.camera') == 'true':
        raise ValueError('Optional hardware became required by the merged manifest')
    return {'package': root.get('package'), 'version_code': root.get(ANDROID + 'versionCode'), 'permissions': sorted(permissions), 'features': features, 'target_sdk': target_sdk}


def check_native_directory(root, platform, architecture):
    root = Path(root)
    if root.is_file() and root.suffix == '.zip':
        with tempfile.TemporaryDirectory() as folder, zipfile.ZipFile(root) as archive:
            # Only our own packaged artifacts are accepted; reject escaping entries.
            for item in archive.namelist():
                if not (Path(folder) / item).resolve().is_relative_to(Path(folder).resolve()):
                    raise ValueError('ZIP member escapes extraction directory')
            archive.extractall(folder)
            return check_native_directory(Path(folder), platform, architecture)
    records = []
    for path in sorted(Path(root).rglob('*')):
        if path.is_symlink() and (not path.exists() or not path.resolve().is_relative_to(root.resolve())):
            raise ValueError(f'Dangling or external payload symlink: {path}')
        if not path.is_file():
            continue
        with path.open('rb') as stream:
            header = stream.read(4)
        if platform == 'windows' and path.suffix.lower() in ('.dll', '.exe'):
            data = path.read_bytes()
            if header[:2] != b'MZ' or len(data) < 64:
                raise ValueError(f'Invalid PE payload: {path}')
            offset = struct.unpack_from('<I', data, 60)[0]
            if data[offset:offset + 4] != b'PE\0\0' or offset + 6 > len(data):
                raise ValueError(f'Invalid PE headers: {path}')
            machine = struct.unpack_from('<H', data, offset + 4)[0]
            actual = {0x8664: 'x86_64', 0xaa64: 'arm64', 0x14c: 'x86'}.get(machine)
        elif (platform == 'windows' and path.name == 'app.so' and path.parent.name == 'data'
              and (path.parent.parent / 'morsecq.exe').is_file()):
            # Flutter Windows uses ELF for its canonical AOT snapshot, including in ZIPs.
            bits, machine, _ = elf_info(path.read_bytes())
            actual = {(2, 62): 'x86_64', (2, 183): 'arm64'}.get((bits, machine))
        elif platform == 'linux' and (header == b'\x7fELF' or '.so' in path.name or path.name == 'morsecq'):
            bits, machine, _ = elf_info(path.read_bytes())
            actual = {(2, 62): 'x86_64', (2, 183): 'arm64'}.get((bits, machine))
        else:
            continue
        if actual != architecture:
            raise ValueError(f'{path}: native architecture {actual} != {architecture}')
        records.append({'path': str(path.relative_to(root)), 'architecture': actual, 'sha256': digest(path)})
    if not records:
        raise ValueError('No native payload found')
    return records


def check_installed_payload(root, archive_path):
    """Compare every final ZIP file with its installed counterpart, including assets."""
    root = Path(root).resolve()
    records, entries, seen = [], [], set()
    with zipfile.ZipFile(archive_path) as archive:
        for entry in archive.infolist():
            parts = entry.filename.rstrip('/').split('/')
            name = entry.filename.rstrip('/').casefold()
            if ('\\' in entry.filename or ':' in entry.filename or
                    any(part in ('', '.', '..') for part in parts) or
                    parts[0] != 'morsecq' or name in seen):
                raise ValueError(f'Unsafe or duplicate ZIP entry: {entry.filename}')
            seen.add(name)
            if not entry.is_dir():
                entries.append((entry, PurePosixPath(*parts[1:])))
        if not any(entry.filename == 'morsecq/morsecq.exe' for entry, _ in entries):
            raise ValueError('Final ZIP is missing morsecq.exe')
        for entry, relative in entries:
            installed = root.joinpath(*relative.parts)
            if not installed.is_file() or not installed.resolve().is_relative_to(root):
                raise ValueError(f'Missing installed file: {relative}')
            with archive.open(entry) as stream:
                expected = hashlib.file_digest(stream, 'sha256').hexdigest()
            if digest(installed) != expected:
                raise ValueError(f'Installed file differs from final ZIP: {relative}')
            records.append({'path': str(relative), 'sha256': expected})
        expected_files = {str(relative).casefold() for _, relative in entries}
        actual_files = {path.relative_to(root).as_posix().casefold()
                        for path in root.rglob('*') if path.is_file()}
        if actual_files - expected_files:
            raise ValueError(f'Unexpected installed files: {sorted(actual_files - expected_files)}')
    return records


def check_windows_runtime(records):
    paths = {PurePosixPath(record['path'].replace('\\', '/').lower()): record
             for record in records}
    runners = [path for path in paths if path.name == 'morsecq.exe']
    if len(runners) != 1:
        raise ValueError('Expected one Windows release runner')
    directory = runners[0].parent
    required = [directory / name for name in
                ['msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll']]
    if not all(path in paths for path in required):
        raise ValueError('Missing app-local MSVC runtime next to the release runner')
    return [paths[path] for path in required]


def check_apple(app, platform, *, inspect_native=True):
    app = Path(app).resolve()
    resources = app / 'Contents/Resources' if platform == 'macos' else app
    info_path = app / 'Contents/Info.plist' if platform == 'macos' else app / 'Info.plist'
    info = plistlib.loads(info_path.read_bytes())
    if info.get('CFBundleIdentifier') != 'icu.agentx.morsecq' or not info.get('CFBundleVersion') or not info.get('CFBundleShortVersionString'):
        raise ValueError('Unexpected Apple identity or missing build version')
    if not info.get('NSMicrophoneUsageDescription'):
        raise ValueError('Missing built microphone purpose string')
    if not (resources / 'PrivacyInfo.xcprivacy').is_file():
        raise ValueError('Missing app PrivacyInfo.xcprivacy')
    manifests = []
    for path in sorted(app.rglob('PrivacyInfo.xcprivacy')):
        manifest = plistlib.loads(path.read_bytes())
        if manifest.get('NSPrivacyTracking') is not False or manifest.get('NSPrivacyCollectedDataTypes', []) or manifest.get('NSPrivacyTrackingDomains', []):
            raise ValueError(f'{path}: SDK tracking / collection disagrees with no-collection policy')
        for api in manifest.get('NSPrivacyAccessedAPITypes', []):
            if not api.get('NSPrivacyAccessedAPIType') or not api.get('NSPrivacyAccessedAPITypeReasons'):
                raise ValueError(f'{path}: malformed required-reason declaration')
        manifests.append({'path': str(path.relative_to(app)), 'sha256': digest(path), 'required_reason_apis': manifest.get('NSPrivacyAccessedAPITypes', [])})
    report = {'bundle_id': info['CFBundleIdentifier'], 'version': info['CFBundleShortVersionString'], 'build': info['CFBundleVersion'], 'build_sdk': info.get('DTSDKName'), 'privacy_manifests': manifests}
    if not inspect_native:
        return report
    if platform == 'macos':
        run(['codesign', '--verify', '--deep', '--strict', app])
    for locale in LOCALES:
        path = resources / f'{locale}.lproj/InfoPlist.strings'
        # Xcode compiles strings to binary plists in the final application.
        try:
            localized = plistlib.loads(path.read_bytes())
        except plistlib.InvalidFileException:
            localized = plistlib.loads(run(['plutil', '-convert', 'xml1', '-o', '-', path]).encode())
        if not localized.get('NSMicrophoneUsageDescription'):
            raise ValueError(f'Missing microphone localization: {locale}')
    binaries, expected = [], {'arm64'} if platform == 'ios' else {'arm64', 'x86_64'}
    seen = set()
    for path in sorted(app.rglob('*')):
        if path.is_symlink() and (not path.exists() or not path.resolve().is_relative_to(app)):
            raise ValueError(f'Dangling or external Apple payload symlink: {path}')
        if not path.is_file() or path.resolve() in seen:
            continue
        seen.add(path.resolve())
        with path.open('rb') as stream:
            if stream.read(4) not in MACHO_MAGICS:
                continue
        architectures = set(run(['lipo', '-archs', path]).split())
        if not expected <= architectures:
            raise ValueError(f'{path}: missing expected Mach-O architectures {expected}')
        commands = run(['otool', '-arch', 'all', '-l', path])
        if platform == 'ios' and not (re.search(r'platform (?:2|IOS)\s', commands, re.I) or 'LC_VERSION_MIN_IPHONEOS' in commands):
            raise ValueError(f'{path}: not an iOS device binary')
        binaries.append({'path': str(path.relative_to(app)), 'architectures': sorted(architectures), 'sha256': digest(path)})
    if not binaries:
        raise ValueError('No Mach-O payload found')
    report['binaries'] = binaries
    if platform == 'macos':
        report['minimum_os'] = check_bundle(app)
        entitlements = plistlib.loads(run(['codesign', '-d', '--entitlements', ':-', app]).encode())
        for key in ['com.apple.security.app-sandbox', 'com.apple.security.device.audio-input', 'com.apple.security.files.user-selected.read-write', 'com.apple.security.network.client', 'com.apple.security.network.server']:
            if entitlements.get(key) is not True:
                raise ValueError(f'Missing signed functional entitlement: {key}')
        if entitlements.get('com.apple.security.get-task-allow'):
            raise ValueError('Release must not permit debugger task access')
        report['entitlements'] = entitlements
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True)
    sub = parser.add_subparsers(dest='kind', required=True)
    android = sub.add_parser('android')
    android.add_argument('apk', type=Path)
    android.add_argument('bundle', type=Path)
    android.add_argument('--bundletool', required=True)
    android.add_argument('--apkanalyzer', required=True)
    android.add_argument('--target-sdk', type=int, required=True)
    apple = sub.add_parser('apple')
    apple.add_argument('app', type=Path)
    apple.add_argument('--platform', choices=['ios', 'macos'], required=True)
    native = sub.add_parser('native')
    native.add_argument('root', type=Path)
    native.add_argument('--platform', choices=['windows', 'linux'], required=True)
    native.add_argument('--architecture', required=True)
    native.add_argument('--expected-zip', type=Path, help='Compare an installed directory with the final Windows ZIP')
    hashes = sub.add_parser('hashes')
    hashes.add_argument('root', type=Path)
    args = parser.parse_args()
    if args.kind == 'android':
        apk_xml = run([args.apkanalyzer, 'manifest', 'print', args.apk])
        bundle_xml = run(['java', '-jar', args.bundletool, 'dump', 'manifest', f'--bundle={args.bundle}', '--module=base'])
        apk_manifest = check_android_manifest(apk_xml, args.target_sdk)
        bundle_manifest = check_android_manifest(bundle_xml, args.target_sdk)
        if apk_manifest != bundle_manifest:
            raise ValueError('APK and bundle manifest identities / declarations disagree')
        config = run(['java', '-jar', args.bundletool, 'dump', 'config', f'--bundle={args.bundle}'])
        if 'PAGE_ALIGNMENT_16K' not in config:
            raise ValueError('AAB does not request 16 KB delivered-APK alignment')
        abis = set(ABIS)
        report = {'manifest': apk_manifest, 'apk_sha256': digest(args.apk), 'bundle_sha256': digest(args.bundle), 'apk_native': check_android_native(args.apk, abis, apk=True), 'bundle_native': check_android_native(args.bundle, abis, apk=False), 'bundle_alignment': 'PAGE_ALIGNMENT_16K'}
    elif args.kind == 'apple':
        report = check_apple(args.app, args.platform)
    elif args.kind == 'native':
        report = {'binaries': check_native_directory(args.root, args.platform, args.architecture)}
        if args.platform == 'windows':
            report['windows_runtime'] = check_windows_runtime(report['binaries'])
        if args.expected_zip:
            if args.platform != 'windows' or not args.root.is_dir():
                raise ValueError('--expected-zip requires an installed Windows directory')
            report['installed_files'] = check_installed_payload(args.root, args.expected_zip)
    else:
        report = {'artifacts': [{'name': p.name, 'sha256': digest(p), 'bytes': p.stat().st_size} for p in sorted(args.root.iterdir()) if p.is_file() and not p.name.startswith('.')]}
        if not report['artifacts']:
            raise ValueError('No final artifacts to hash')
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2) + '\n')
    print(f'Release payload preflight passed: {output}')


if __name__ == '__main__':
    main()
