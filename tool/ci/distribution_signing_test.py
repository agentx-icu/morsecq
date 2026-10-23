from pathlib import Path
import subprocess
import unittest
from distribution_signing import verify_apple_identity

TEAM = 'ABCDE12345'

class DistributionSigningTest(unittest.TestCase):
    def test_expected_developer_id_requires_team_runtime_and_authority(self):
        report = f'Authority=Developer ID Application: Owner ({TEAM})\nTeamIdentifier={TEAM}\nCodeDirectory flags=0x10000(runtime)\n'
        verify_apple_identity(report, TEAM, 'macos')
        for bad in [report.replace(TEAM, 'OTHER12345'), report.replace('Developer ID Application', 'Apple Development'), report.replace('(runtime)', ''), 'Signature=adhoc\n' + report]:
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                verify_apple_identity(bad, TEAM, 'macos')

    def test_ios_export_requires_distribution_authority(self):
        verify_apple_identity(f'Authority=Apple Distribution: Owner ({TEAM})\nTeamIdentifier={TEAM}\n', TEAM, 'ios')
        with self.assertRaises(ValueError):
            verify_apple_identity(f'Authority=Apple Development: Owner ({TEAM})\nTeamIdentifier={TEAM}\n', TEAM, 'ios')

    def test_explicit_distribution_refuses_missing_owner_material(self):
        script = Path(__file__).with_name('package_artifacts.sh')
        for target in ['macos', 'windows', 'android', 'ios', 'linux']:
            result = subprocess.run(['bash', str(script), '--target', target], env={'PATH': '/usr/bin:/bin', 'MORSECQ_DISTRIBUTION': '1'}, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('distribution', result.stderr.lower())

if __name__ == '__main__':
    unittest.main()
