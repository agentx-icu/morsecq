import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]


class PyramidTest(unittest.TestCase):
    def test_ios_timeout_restarts_only_the_selected_simulator_before_retry(self):
        with tempfile.TemporaryDirectory(prefix="morsecq-ios-timeout-") as temp:
            root = Path(temp)
            scripts = root / "tool/ci"
            scripts.mkdir(parents=True)
            runner = scripts / "run_integration_tests.sh"
            shutil.copy(REPO / "tool/ci/run_integration_tests.sh", runner)
            suite = root / "apps/morsecq/integration_test"
            suite.mkdir(parents=True)
            (suite / "launch_test.dart").touch()
            programs = {
                "gtimeout": 'echo "bounded $*"\nshift 2\nexec "$@"',
                "xcrun": 'echo "device $*"',
                "flutter": (
                    'if [[ ! -f attempted ]]; then touch attempted; exit 124; fi\n'
                    'exit "$RETRY_RESULT"'
                ),
            }
            for name, body in programs.items():
                program = root / name
                program.write_text("#!/usr/bin/env bash\n" + body + "\n")
                program.chmod(0o755)

            for retry_result in (0, 124):
                with self.subTest(retry_result=retry_result):
                    (suite.parent / "attempted").unlink(missing_ok=True)
                    result = subprocess.run(
                        ["bash", str(runner), "--ci-ios-simulator", "fixture-udid"],
                        env={
                            **os.environ,
                            "PATH": f"{root}:{os.environ['PATH']}",
                            "RETRY_RESULT": str(retry_result),
                        },
                        text=True,
                        capture_output=True,
                    )
                    self.assertEqual(result.returncode, int(retry_result != 0), result.stderr)
                    events = [
                        line for line in result.stdout.splitlines() if line.startswith("bounded ")
                    ]
                    self.assertEqual(len(events), 4, result.stdout)
                    self.assertIn("flutter test integration_test/launch_test.dart -d fixture-udid", events[0])
                    self.assertIn("xcrun simctl shutdown fixture-udid", events[1])
                    self.assertIn("xcrun simctl bootstatus fixture-udid -b", events[2])
                    self.assertEqual(events[0], events[3])
                    summary = "PASS (retried)" if retry_result == 0 else "FAIL"
                    self.assertIn(f"{summary} launch_test.dart", result.stdout)

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
