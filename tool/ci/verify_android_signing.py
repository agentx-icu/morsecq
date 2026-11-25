"""Verify actual APK/AAB release certificates before tagged distribution."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


def verify_signing_reports(apk, bundle, expected=None):
    if re.search(r"CN\s*=\s*Android Debug(?:,|$)", apk + "\n" + bundle, re.I | re.M):
        raise ValueError("Android debug certificates must not enter a release")
    def fingerprints(report, pattern):
        values = {value.replace(":", "").lower() for value in re.findall(pattern, report, re.I)}
        if not values or any(not re.fullmatch(r"[0-9a-f]{64}", value) for value in values):
            raise ValueError("Missing or malformed signing certificate")
        return values
    apk_signers = fingerprints(apk, r"certificate SHA-256 digest:\s*([0-9a-f:]+)")
    bundle_signers = fingerprints(bundle, r"SHA256:\s*([0-9a-f:]+)")
    if expected is not None:
        expected = expected.replace(':', '').lower()
        if not re.fullmatch(r'[0-9a-f]{64}', expected) or apk_signers != {expected}:
            raise ValueError('Actual signing identity differs from expected owner upload certificate')
    if apk_signers != bundle_signers:
        raise ValueError("APK and App Bundle have different signing certificates")


def verify_bundle(path, expected=None):
    # JarFile verifies random-access entries independent of manifest ZIP order.
    # Read every entry to EOF before trusting its CodeSigners; console warning
    # text and keytool's certificate listing cannot establish payload integrity.
    verifier = Path(__file__).resolve().with_name('VerifyAndroidBundle.java')
    result = subprocess.run(['java', str(verifier), str(path), expected or '-',
                             'distribution' if expected else 'development'],
                            capture_output=True, text=True, timeout=120)
    if result.returncode:
        raise ValueError(f'AAB integrity verification failed: {result.stderr[-2000:]}')
    report = json.loads(result.stdout)
    return f"SHA256: {report['certificate_sha256']}\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk")
    parser.add_argument("bundle")
    parser.add_argument("--apksigner")
    parser.add_argument("--expected-sha256", required=True, help="Owner upload certificate; not the Play distribution certificate")
    args = parser.parse_args()
    signer = args.apksigner or shutil.which("apksigner")
    if not signer:
        sdk = Path(os.environ.get("ANDROID_HOME") or os.environ["ANDROID_SDK_ROOT"])
        signer = str(sorted((sdk / "build-tools").glob("*/apksigner"))[-1])
    apk = subprocess.run([signer, "verify", "--print-certs", args.apk],
                         check=True, capture_output=True, text=True).stdout
    bundle = verify_bundle(args.bundle, expected=args.expected_sha256)
    verify_signing_reports(apk, bundle, expected=args.expected_sha256)
    print("Verified matching non-debug APK / App Bundle certificates")


if __name__ == "__main__":
    main()
