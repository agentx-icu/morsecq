import datetime
import hashlib
import importlib.util
from pathlib import Path
import plistlib
import subprocess
import tempfile
import unittest
from unittest.mock import patch


SOURCE = Path(__file__).with_name("ios_store_export.py")
spec = importlib.util.spec_from_file_location("ios_store_export", SOURCE)
store = importlib.util.module_from_spec(spec)
spec.loader.exec_module(store)


class IosStoreExportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="morsecq iOS export ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.certificate = b"test certificate bytes, not a signing identity"
        self.fingerprint = hashlib.sha1(self.certificate).hexdigest().upper()
        self.options = {"method": "app-store-connect", "destination": "export",
                        "signingStyle": "manual", "teamID": "ABCDE12345",
                        "signingCertificate": self.fingerprint,
                        "provisioningProfiles": {"icu.agentx.morsecq": "owner-profile"}}
        self.path = self.root / "ExportOptions.plist"
        self.built_info = {"CFBundleExecutable": "Runner", "DTSDKName": "iphoneos26.5", "DTXcode": "2660"}

    def options_check(self):
        self.path.write_bytes(plistlib.dumps(self.options))
        return store.export_options(self.path, "ABCDE12345", self.fingerprint)

    def profile(self):
        return {"UUID": "fixture", "TeamIdentifier": ["ABCDE12345"],
                "ExpirationDate": datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None)
                + datetime.timedelta(days=1), "DeveloperCertificates": [self.certificate],
                "Entitlements": {"application-identifier": "PREFIX.icu.agentx.morsecq",
                                 "com.apple.developer.team-identifier": "ABCDE12345",
                                 "get-task-allow": False}}

    def test_accepts_only_explicit_local_manual_export(self):
        self.assertEqual(self.options_check()["destination"], "export")
        for key, value in (("destination", "upload"), ("signingStyle", "automatic"),
                           ("method", "release-testing"), ("teamID", "OTHER12345"),
                           ("signingCertificate", "Apple Distribution")):
            with self.subTest(key=key):
                previous = self.options[key]
                self.options[key] = value
                with self.assertRaises(ValueError):
                    self.options_check()
                self.options[key] = previous

    def test_missing_export_destination_and_unreviewed_extra_profiles_rejected(self):
        self.options.pop("destination")
        with self.assertRaises(ValueError):
            self.options_check()
        self.options["destination"] = "export"
        self.options["provisioningProfiles"]["com.other.app"] = "other"
        with self.assertRaises(ValueError):
            self.options_check()

    def test_profile_matches_explicit_app_certificate_team_and_expiry(self):
        profile = self.profile()
        entitlement = dict(profile["Entitlements"])
        self.assertEqual(store.profile_evidence(profile, entitlement, "ABCDE12345", self.fingerprint)["uuid"], "fixture")
        with self.assertRaisesRegex(ValueError, "selected profile"):
            store.profile_evidence(profile, entitlement, "ABCDE12345", self.fingerprint, "wrong-profile")
        cases = [({"ProvisionedDevices": ["device"]}, "device"),
                 ({"ProvisionsAllDevices": True}, "enterprise"),
                 ({"ExpirationDate": datetime.datetime(2000, 1, 1)}, "expired"),
                 ({"TeamIdentifier": ["OTHER12345"]}, "team"),
                 ({"DeveloperCertificates": [b"other"]}, "certificate")]
        for update, message in cases:
            with self.subTest(message=message), self.assertRaises(ValueError):
                store.profile_evidence({**profile, **update}, entitlement, "ABCDE12345", self.fingerprint)

    def test_debug_wildcard_and_mismatched_application_entitlements_rejected(self):
        for key, value in (("get-task-allow", True), ("application-identifier", "PREFIX.*"),
                           ("application-identifier", "PREFIX.com.other.app"),
                           ("com.apple.developer.team-identifier", "OTHER12345")):
            with self.subTest(key=key, value=value):
                profile = self.profile()
                profile["Entitlements"][key] = value
                with self.assertRaises(ValueError):
                    store.profile_evidence(profile, profile["Entitlements"], "ABCDE12345", self.fingerprint)
        profile = self.profile()
        with self.assertRaises(ValueError):
            store.profile_evidence(profile, {**profile["Entitlements"], "application-identifier": "OTHER.icu.agentx.morsecq"},
                                   "ABCDE12345", self.fingerprint)

    def test_archive_and_export_commands_cannot_register_or_upload(self):
        archive, export = store.commands(self.root, self.root / "output", self.path)
        self.assertIn("CODE_SIGNING_ALLOWED=NO", archive)
        self.assertIn("archive", archive)
        self.assertIn("-exportArchive", export)
        for command in (archive, export):
            self.assertNotIn("-allowProvisioningUpdates", command)
            self.assertNotIn("-allowProvisioningDeviceRegistration", command)

    def test_store_toolchain_accepts_current_device_sdk_and_xcode(self):
        for sdk, xcode in (("iphoneos26.0", "2600"), ("iphoneos26.5", "2660"),
                           ("iphoneos26.1.1", "2611"), ("iphoneos27.0", "2700")):
            with self.subTest(sdk=sdk, xcode=xcode):
                store.verify_store_toolchain({"DTSDKName": sdk, "DTXcode": xcode})

    def test_store_toolchain_rejects_missing_malformed_or_old_metadata(self):
        bad_sdks = (None, "", 26, True, "iphoneos18.5", "iphoneos25.0", "iphoneos26",
                    "iphonesimulator26.0", "iphoneos26.0beta", "iphoneos26.0\n",
                    "iphoneos026.0", "iphoneos26..0", "iphoneos26.0.0.0")
        bad_xcodes = (None, "", 2600, True, "1640", "2599", "260", "02600",
                      "26.0", "2600beta", "2600\n", " 2600")
        for field, values in (("DTSDKName", bad_sdks), ("DTXcode", bad_xcodes)):
            for value in values:
                info = dict(self.built_info)
                info[field] = value
                with self.subTest(field=field, value=value), self.assertRaisesRegex(ValueError, "SDK|Xcode"):
                    store.verify_store_toolchain(info)
            info.pop(field)
            with self.subTest(field=field, missing=True), self.assertRaisesRegex(ValueError, "SDK|Xcode"):
                store.verify_store_toolchain(info)

    def test_invalid_archive_toolchain_prevents_export_in_both_modes(self):
        for unsigned in (True, False):
            for field, value in (("DTSDKName", "iphoneos18.5"), ("DTXcode", "1640")):
                self.options_check()
                output = self.root / f"bad-{unsigned}-{field}"
                calls = []
                def runner(command, **kwargs):
                    calls.append(command)
                    if "archive" in command:
                        app = output / "Runner.xcarchive/Products/Applications/Runner.app"
                        app.mkdir(parents=True)
                        (app / "Info.plist").write_bytes(plistlib.dumps({**self.built_info, field: value}))
                        (app / "Runner").write_bytes(b"\xcf\xfa\xed\xfe")
                        (app / "Runner").chmod(0o755)
                with self.subTest(unsigned=unsigned, field=field), patch.object(store, "run", side_effect=runner), \
                        patch.object(store, "inspect_export") as exported:
                    with self.assertRaisesRegex(ValueError, "SDK|Xcode"):
                        store.build(self.root, output, self.path, "ABCDE12345", self.fingerprint, unsigned)
                    self.assertEqual(len(calls), 3)
                    self.assertFalse(any("-exportArchive" in command for command in calls))
                    exported.assert_not_called()
                    self.assertFalse((output / "UNSIGNED-ARCHIVE.txt").exists())

    def test_exported_app_checks_toolchain_before_signature(self):
        (self.root / "ipa").mkdir()
        (self.root / "ipa/App.ipa").write_bytes(b"fixture, not a signed application")
        calls = []
        def runner(command, **kwargs):
            calls.append(command)
            if command[0] == "ditto":
                app = Path(command[-1]) / "Payload/Runner.app"
                app.mkdir(parents=True)
                (app / "Info.plist").write_bytes(plistlib.dumps({**self.built_info, "DTXcode": "1640"}))
                (app / "Runner").write_bytes(b"\xcf\xfa\xed\xfe")
                (app / "Runner").chmod(0o755)
        with patch.object(store, "run", side_effect=runner):
            with self.assertRaisesRegex(ValueError, "Xcode"):
                store.inspect_export(self.root, self.root, "ABCDE12345", self.fingerprint, "fixture")
        self.assertEqual([command[0] for command in calls], ["ditto"])
        self.assertFalse((self.root / "export-evidence/distribution.json").exists())

    def test_signing_authority_must_be_distribution_not_development(self):
        self.assertEqual(store.distribution_authority("Authority=Apple Distribution: Owner (ABCDE12345)\nAuthority=Apple Root CA"),
                         "Apple Distribution: Owner (ABCDE12345)")
        for display in ("Signature=adhoc", "Authority=Apple Development: Owner (ABCDE12345)", ""):
            with self.subTest(display=display), self.assertRaises(ValueError):
                store.distribution_authority(display)

    def test_existing_output_is_rejected_before_any_build_command(self):
        with patch.object(store, "run") as runner:
            with self.assertRaises(FileExistsError):
                store.build(self.root, self.root, None, None, None, True)
            runner.assert_not_called()

    def test_actual_signer_mismatch_cannot_produce_distribution_evidence(self):
        (self.root / "ipa").mkdir()
        (self.root / "ipa/App.ipa").write_bytes(b"fixture, not an exported application")
        def runner(command, **kwargs):
            result = subprocess.CompletedProcess(command, 0, stdout=b"", stderr=b"")
            if command[0] == "ditto":
                (Path(command[-1]) / "Payload/Runner.app").mkdir(parents=True)
            elif "--verbose=4" in command:
                result.stderr = "Authority=Apple Distribution: Owner (ABCDE12345)\nTeamIdentifier=ABCDE12345\n"
            elif "--entitlements" in command:
                result.stdout = plistlib.dumps(self.profile()["Entitlements"])
            elif command[:2] == ["security", "cms"]:
                result.stdout = plistlib.dumps(self.profile())
            elif "--extract-certificates" in command:
                Path(command[-2] + "0").write_bytes(b"different actual signer")
            return result
        with patch.object(store, "run", side_effect=runner), patch.object(store, "inspect_app"):
            with self.assertRaisesRegex(ValueError, "Actual exported app signer"):
                store.inspect_export(self.root, self.root, "ABCDE12345", self.fingerprint, "fixture")
        self.assertFalse((self.root / "export-evidence/distribution.json").exists())

    def test_wrapper_rejects_unreviewed_xcode_and_flutter_overrides(self):
        wrapper = SOURCE.parents[1] / "build_ios_store.sh"
        for argument in ("-allowProvisioningUpdates", "-allowProvisioningDeviceRegistration",
                         "--export-method=app-store", "CODE_SIGN_STYLE=Automatic"):
            with self.subTest(argument=argument):
                result = subprocess.run(["bash", str(wrapper), argument], capture_output=True, text=True)
                self.assertEqual(result.returncode, 2)
                self.assertIn("unrecognized arguments", result.stderr)

    def test_export_policy_is_snapshotted_before_commands(self):
        self.options_check()
        calls = []
        def runner(command, **kwargs):
            calls.append((command, kwargs.get("cwd")))
            if len(calls) == 1:
                self.options["destination"] = "upload"
                self.path.write_bytes(plistlib.dumps(self.options))
        output = self.root / "snapshot"
        with patch.object(store, "run", side_effect=runner), patch.object(store, "inspect_archive"), \
                patch.object(store, "inspect_export"):
            store.build(self.root, output, self.path, "ABCDE12345", self.fingerprint, False)
        archive, exported = calls[2][0], calls[3][0]
        self.assertIn(str(self.root / "apps/morsecq/ios/Runner.xcworkspace"), archive)
        self.assertEqual(calls[1][1], self.root / "apps/morsecq")
        snapshot = Path(exported[exported.index("-exportOptionsPlist") + 1])
        self.assertNotEqual(snapshot, self.path)
        self.assertEqual(plistlib.loads(snapshot.read_bytes())["destination"], "export")

    def test_nested_signed_targets_are_rejected_before_native_inspection(self):
        app = self.root / "Runner.app"
        (app / "PlugIns/Unreviewed.appex").mkdir(parents=True)
        (app / "Info.plist").write_bytes(plistlib.dumps(self.built_info))
        with patch.object(store, "run") as runner:
            with self.assertRaisesRegex(ValueError, "Additional signed targets"):
                store.inspect_app(self.root, app, self.root)
            runner.assert_not_called()

    def test_bundle_executable_must_be_present_contained_native_file(self):
        app = self.root / "Runner.app"
        app.mkdir()
        info = app / "Info.plist"
        (app / "Directory").mkdir()
        (self.root / "Outside").write_bytes(b"\xcf\xfa\xed\xfe")
        (app / "Link").symlink_to(self.root / "Outside")
        (app / "Text").write_bytes(b"not an executable")
        for entry in ("", ".", "..", "MissingRunner", "Directory", "Link", "Text"):
            info.write_bytes(plistlib.dumps({**self.built_info, "CFBundleExecutable": entry}))
            with self.subTest(entry=entry), patch.object(store, "run") as runner:
                with self.assertRaisesRegex(ValueError, "executable"):
                    store.inspect_app(self.root, app, self.root)
                runner.assert_not_called()
        (app / "Runner").write_bytes(b"\xcf\xfa\xed\xfe")
        (app / "Runner").chmod(0o755)
        info.write_bytes(plistlib.dumps(self.built_info))
        with patch.object(store, "run") as runner:
            store.inspect_app(self.root, app, self.root)
            runner.assert_called_once()

    def test_archive_rejects_unreviewed_sibling_application(self):
        applications = self.root / "Runner.xcarchive/Products/Applications"
        (applications / "Runner.app").mkdir(parents=True)
        (applications / "Other.app").mkdir()
        with patch.object(store, "inspect_app") as inspect:
            with self.assertRaisesRegex(ValueError, "exactly one"):
                store.inspect_archive(self.root, self.root)
            inspect.assert_not_called()

    def test_existing_distribution_identity_gate_accepts_legacy_authority(self):
        from distribution_signing import verify_apple_identity
        display = "Authority=iPhone Distribution: Owner (ABCDE12345)\nTeamIdentifier=ABCDE12345\n"
        verify_apple_identity(display, "ABCDE12345", "ios")
        self.assertEqual(store.distribution_authority(display), "iPhone Distribution: Owner (ABCDE12345)")
        profile = self.profile()
        self.assertEqual(store.profile_evidence(profile, profile["Entitlements"], "ABCDE12345", self.fingerprint)["application_identifier"],
                         "PREFIX.icu.agentx.morsecq")

    def test_archive_retains_only_contained_resolving_symbol_links(self):
        archive = self.root / "Runner.xcarchive"
        (archive / "Products/Applications/Runner.app").mkdir(parents=True)
        symbols = archive / "dSYMs"
        symbols.mkdir()
        (symbols / "Runner-symbols").write_bytes(b"real fixture content")
        (symbols / "internal.dSYM").symlink_to("Runner-symbols")
        with patch.object(store, "inspect_app") as inspect:
            store.inspect_archive(self.root, self.root)
            inspect.assert_called_once()
        (self.root / "outside-symbols").write_bytes(b"outside archive")
        link = symbols / "invalid.dSYM"
        for target in (self.root / "outside-symbols", symbols / "missing", symbols / "Runner-symbols"):
            link.symlink_to(target)
            with self.subTest(target=target), patch.object(store, "inspect_app") as inspect:
                with self.assertRaisesRegex(ValueError, "archive symlink"):
                    store.inspect_archive(self.root, self.root)
                inspect.assert_not_called()
            link.unlink()
        archive.rename(self.root / "real-archive")
        archive.symlink_to(self.root / "real-archive", target_is_directory=True)
        with patch.object(store, "inspect_app") as inspect:
            with self.assertRaisesRegex(ValueError, "real application archive"):
                store.inspect_archive(self.root, self.root)
            inspect.assert_not_called()

    def test_config_archive_and_export_failures_propagate_without_verification(self):
        # Real subprocess error propagation is exercised at each command boundary;
        # no mocked success is counted as a signed app or a native archive.
        for failing_call in (1, 2, 3, 4):
            self.options_check()
            output = self.root / str(failing_call)
            with self.subTest(call=failing_call), patch.object(store, "inspect_archive") as inspect:
                calls = []
                def runner(command, **kwargs):
                    calls.append(command)
                    if len(calls) == failing_call:
                        raise subprocess.CalledProcessError(17, command)
                with patch.object(store, "run", side_effect=runner), patch.object(store, "inspect_export") as exported:
                    with self.assertRaises(subprocess.CalledProcessError):
                        store.build(self.root, output, self.path, "ABCDE12345", self.fingerprint, False)
                    exported.assert_not_called()
                    self.assertEqual(len(calls), failing_call)
                    if failing_call <= 3:
                        inspect.assert_not_called()


if __name__ == "__main__":
    unittest.main()
