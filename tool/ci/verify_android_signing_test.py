from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import warnings
import zipfile
from verify_android_signing import verify_bundle, verify_signing_reports

CERT = "01" * 32
OTHER = "02" * 32

def apk(subject="CN=MorseCQ", digest=CERT):
    return f"Signer #1 certificate DN: {subject}\nSigner #1 certificate SHA-256 digest: {digest}\n"

def bundle(subject="CN=MorseCQ", digest=CERT):
    return f"Owner: {subject}\nSHA256: {digest}\n"

class AndroidSigningTest(unittest.TestCase):
    def test_same_release_signer_is_accepted(self):
        verify_signing_reports(apk(), bundle())

    def test_debug_certificate_is_rejected_on_either_artifact(self):
        for a, b in [(apk("CN=Android Debug, O=Android, C=US"), bundle()),
                     (apk(), bundle("CN=Android Debug, O=Android, C=US"))]:
            with self.assertRaises(ValueError):
                verify_signing_reports(a, b)

    def test_mismatched_signers_are_rejected(self):
        with self.assertRaises(ValueError):
            verify_signing_reports(apk(), bundle(digest=OTHER))

    def test_unexpected_owner_certificate_is_rejected(self):
        with self.assertRaises(ValueError):
            verify_signing_reports(apk(), bundle(), expected=OTHER)
        verify_signing_reports(apk(), bundle(), expected=CERT)

    def test_missing_or_malformed_certificates_are_rejected(self):
        for report in ["", "unverified", apk(digest="abcd")]:
            with self.assertRaises(ValueError):
                verify_signing_reports(report, bundle())


@unittest.skipUnless(shutil.which('java') and shutil.which('jarsigner') and shutil.which('keytool'), 'JDK 17 required')
class BundleIntegrityTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        cls.root = Path(cls.temp.name)
        cls.key = cls.root / 'fixture.p12'
        subprocess.run(['keytool', '-genkeypair', '-alias', 'fixture', '-keystore', str(cls.key),
                        '-storepass', 'fixture-password', '-keyalg', 'RSA', '-keysize', '2048',
                        '-validity', '30', '-dname', 'CN=Release fixture', '-noprompt'],
                       capture_output=True, check=True)

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def signed(self, *, bundle_structure=True):
        path = self.root / 'fixture.aab'
        with zipfile.ZipFile(path, 'w') as archive:
            archive.writestr('base/manifest/AndroidManifest.xml', b'signed payload')
            if bundle_structure:
                archive.writestr('BundleConfig.pb', b'bundle configuration')
        subprocess.run(['jarsigner', '-keystore', str(self.key), '-storepass',
                        'fixture-password', str(path), 'fixture'], capture_output=True, check=True)
        return path

    def test_manifest_last_self_signed_android_bundle_is_accepted(self):
        path = self.signed()
        with zipfile.ZipFile(path) as archive:
            entries = [(name, archive.read(name)) for name in archive.namelist()]
        with zipfile.ZipFile(path, 'w') as archive:
            for name, data in sorted(entries, key=lambda item: item[0] == 'META-INF/MANIFEST.MF'):
                archive.writestr(name, data)
        report = verify_bundle(path)
        self.assertIn('SHA256:', report)
        expected = report.split('SHA256: ', 1)[1].strip()
        self.assertEqual(verify_bundle(path, expected=expected), report)
        with self.assertRaisesRegex(ValueError, 'upload certificate'):
            verify_bundle(path, expected=OTHER)

    def test_unsigned_extra_entry_is_rejected(self):
        path = self.signed()
        with zipfile.ZipFile(path, 'a') as archive:
            archive.writestr('base/unsigned.txt', b'unauthenticated')
        with self.assertRaises(ValueError):
            verify_bundle(path)

    def test_tampered_signed_entry_is_rejected(self):
        path = self.signed()
        with zipfile.ZipFile(path) as archive:
            entries = {name: archive.read(name) for name in archive.namelist()}
        entries['base/manifest/AndroidManifest.xml'] = b'tampered'
        with zipfile.ZipFile(path, 'w') as archive:
            for name, data in entries.items():
                archive.writestr(name, data)
        with self.assertRaises((ValueError, subprocess.CalledProcessError)):
            verify_bundle(path)

    def test_signed_archive_without_bundle_structure_is_rejected(self):
        with self.assertRaises(ValueError):
            verify_bundle(self.signed(bundle_structure=False))

    def test_duplicate_payload_entry_is_rejected(self):
        path = self.signed()
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', UserWarning)
            with zipfile.ZipFile(path, 'a') as archive:
                archive.writestr('BundleConfig.pb', b'bundle configuration')
        with self.assertRaisesRegex(ValueError, 'Duplicate bundle entry'):
            verify_bundle(path)

if __name__ == "__main__":
    unittest.main()
