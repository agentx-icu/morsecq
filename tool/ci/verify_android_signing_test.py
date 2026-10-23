import unittest
from verify_android_signing import verify_signing_reports

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

if __name__ == "__main__":
    unittest.main()
