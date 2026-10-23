"""Verify actual APK/AAB release certificates before tagged distribution."""
import argparse
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
    bundle = subprocess.run(["keytool", "-J-Duser.language=en", "-printcert", "-jarfile", args.bundle],
                            check=True, capture_output=True, text=True).stdout
    verification = subprocess.run(["jarsigner", "-J-Duser.language=en", "-verify", args.bundle],
                                  check=True, capture_output=True, text=True).stdout
    if 'jar verified.' not in verification or 'unsigned entries' in verification:
        raise ValueError('AAB signature did not verify every entry')
    verify_signing_reports(apk, bundle, expected=args.expected_sha256)
    print("Verified matching non-debug APK / App Bundle certificates")


if __name__ == "__main__":
    main()
