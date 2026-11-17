import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]


class PyramidTest(unittest.TestCase):
    def test_e2e_shards_partition_discovered_files(self):
        with tempfile.TemporaryDirectory(prefix="morsecq-shards-") as temp:
            root = Path(temp)
            scripts = root / "tool/ci"
            scripts.mkdir(parents=True)
            runner = scripts / "run_integration_tests.sh"
            shutil.copy(REPO / "tool/ci/run_integration_tests.sh", runner)
            suite = root / "apps/morsecq/integration_test"
            suite.mkdir(parents=True)
            files = [f"{letter}_test.dart" for letter in "abcdefg"]
            for name in reversed(files):
                (suite / name).touch()
            (suite / "helper.dart").touch()
            flutter = root / "flutter"
            flutter.write_text('#!/usr/bin/env bash\nprintf "FILE %s\\n" "$2"\n')
            flutter.chmod(0o755)

            for shard in range(1, 4):
                with self.subTest(shard=shard):
                    result = subprocess.run(
                        [
                            "bash", "-c", 'export PATH="$1:$PATH"; shift; exec bash "$@"',
                            "test-shard", str(root), str(runner), "-d", "phone", "--shard",
                            f"{shard}/3",
                        ],
                        capture_output=True,
                        text=True,
                        check=False,
                    )
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertEqual(
                        [line for line in result.stdout.splitlines() if line.startswith("FILE ")],
                        [f"FILE integration_test/{name}" for name in files[shard - 1::3]],
                    )

    def test_e2e_discovers_every_file_and_reports_a_persistent_failure(self):
        with tempfile.TemporaryDirectory(prefix="morsecq-pyramid-") as temp:
            root = Path(temp)
            scripts = root / "tool"
            (scripts / "ci").mkdir(parents=True)
            shutil.copy(REPO / "tool/test_pyramid.sh", scripts)
            shutil.copy(REPO / "tool/ci/run_integration_tests.sh", scripts / "ci")
            suite = root / "apps/morsecq/integration_test"
            suite.mkdir(parents=True)
            (suite / "a_failure_test.dart").touch()
            (suite / "z_new_test.dart").touch()
            (suite / "helper.dart").touch()

            flutter = root / "flutter"
            flutter.write_text(
                '#!/usr/bin/env bash\n'
                'printf "called <%s> <%s> <%s> <%s>\\n" "$@"\n'
                '[[ "$2" != integration_test/a_failure_test.dart ]]\n',
                encoding="utf-8",
            )
            flutter.chmod(0o755)
            result = subprocess.run(
                [
                    "bash",
                    "-c",
                    'export PATH="$1:$PATH"; bash "$2" --level e2e --device "$3"',
                    "test-pyramid",
                    str(root),
                    str(scripts / "test_pyramid.sh"),
                    "test device",
                ],
                capture_output=True,
                text=True,
                check=False,
            )

        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertEqual(
            [line for line in result.stdout.splitlines() if line.startswith("called ")],
            [
                "called <test> <integration_test/a_failure_test.dart> <-d> <test device>",
                "called <test> <integration_test/a_failure_test.dart> <-d> <test device>",
                "called <test> <integration_test/z_new_test.dart> <-d> <test device>",
            ],
        )
        self.assertIn("FAIL a_failure_test.dart", result.stdout)
        self.assertIn("PASS z_new_test.dart", result.stdout)
