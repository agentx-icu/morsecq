#!/usr/bin/env python3
"""Verify an owner's actual exported Apple identity; never infer it from env alone."""
import argparse
from pathlib import Path
import plistlib
import re
import subprocess


def verify_apple_identity(report, team, platform):
    if not re.fullmatch(r'[A-Z0-9]{10}', team):
        raise ValueError('Supply the verified owner Apple Team ID')
    authority = 'Developer ID Application:' if platform == 'macos' else 'Apple Distribution:'
    if ('Signature=adhoc' in report or f'TeamIdentifier={team}\n' not in report or
            not re.search(r'^Authority=' + re.escape(authority), report, re.M)):
        raise ValueError('Artifact is not signed by the expected distribution team / certificate type')
    if platform == 'macos' and '(runtime)' not in report:
        raise ValueError('Developer ID distribution requires hardened runtime')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('app')
    parser.add_argument('--team', required=True)
    parser.add_argument('--platform', choices=['ios', 'macos'], required=True)
    args = parser.parse_args()
    subprocess.run(['codesign', '--verify', '--deep', '--strict', args.app], check=True)
    result = subprocess.run(['codesign', '-d', '--verbose=4', args.app], capture_output=True, text=True, check=True)
    verify_apple_identity(result.stdout + result.stderr, args.team, args.platform)
    entitlements = subprocess.run(['codesign', '-d', '--entitlements', ':-', args.app], capture_output=True, check=True).stdout
    if plistlib.loads(entitlements).get('get-task-allow') or plistlib.loads(entitlements).get('com.apple.security.get-task-allow'):
        raise ValueError('Distribution export must not allow debugger attachment')
    if args.platform == 'ios':
        profile = subprocess.run(['security', 'cms', '-D', '-i', str(Path(args.app) / 'embedded.mobileprovision')], capture_output=True, check=True).stdout
        profile = plistlib.loads(profile)
        if (profile.get('TeamIdentifier') != [args.team] or 'ProvisionedDevices' in profile or
                profile.get('ProvisionsAllDevices') or profile.get('Entitlements', {}).get('get-task-allow') or
                profile.get('Entitlements', {}).get('application-identifier') != f'{args.team}.icu.agentx.morsecq'):
            raise ValueError('Export is not the expected App Store provisioning profile')
    print('Verified expected Apple distribution team and signature type')


if __name__ == '__main__':
    main()
