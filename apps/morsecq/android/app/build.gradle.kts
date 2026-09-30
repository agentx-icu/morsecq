plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// morsecq: bundle libtim2tox_ffi
// ---------------------------------------------------------------------------
// The Tox backend is libtim2tox_ffi.so, staged per ABI into
// src/main/jniLibs/<abi>/ by tool/build_android_ffi.sh (jniLibs is gitignored,
// so a fresh clone has none). Gradle packages whatever sits there, so this file
// (a) packages only the ABIs that actually have the library — otherwise
// Flutter's default ABI set ships slices where DynamicLibrary.open() fails at
// runtime, (b) fails fast when none is staged instead of shipping an APK that
// crashes on first chat use, and (c) byte-scans the staged .so for the
// Tim2Tox auto_tests-only hooks, the last point before they land in an APK.
// (Modelled on toxee/android/app/build.gradle.kts.)
//
// Escape hatch for UI-only builds (--dart-define=MORSECQ_FAKE_BACKEND=true):
//   ./gradlew ... -PmorsecqAllowMissingFfi=true   or   MORSECQ_ALLOW_MISSING_FFI=1
val morsecqRepoRoot: File = rootProject.file("../../..")

// The forbidden symbol NAMES are read out of tool/ci/assert_no_test_hooks.sh so
// there is exactly one list to maintain; done in Kotlin (not by shelling out)
// because an Android build must work on a host with no bash.
fun morsecqForbiddenTestHookNames(): List<String> {
    val gate = File(morsecqRepoRoot, "tool/ci/assert_no_test_hooks.sh")
    if (!gate.isFile) {
        throw GradleException(
            "tool/ci/assert_no_test_hooks.sh is missing — cannot verify that the " +
                "staged libtim2tox_ffi.so carries no test-only hook."
        )
    }
    val pattern = Regex("^FORBIDDEN_[A-Z_]*=\"([^\"\$]+)\"", RegexOption.MULTILINE)
    val names = pattern.findAll(gate.readText()).map { it.groupValues[1] }.toList()
    if (names.isEmpty()) {
        throw GradleException(
            "no FORBIDDEN_* names parsed from tool/ci/assert_no_test_hooks.sh — " +
                "the gate's format changed and this check would silently pass."
        )
    }
    return names
}

// Export names are plain ASCII in the ELF .dynstr, so a byte scan finds them;
// it errs towards failing (also matches a non-exported occurrence).
fun morsecqAssertNoTestHooks(lib: File, forbidden: List<String>) {
    if (!lib.isFile) return
    val bytes = lib.readBytes()
    for (name in forbidden) {
        val needle = name.toByteArray(Charsets.US_ASCII)
        var i = 0
        outer@ while (i <= bytes.size - needle.size) {
            for (j in needle.indices) {
                if (bytes[i + j] != needle[j]) {
                    i++
                    continue@outer
                }
            }
            throw GradleException(
                "${lib.path} carries the TEST-ONLY tim2tox hook $name and must not be " +
                    "packaged. Rebuild with tool/build_android_ffi.sh (it passes " +
                    "-DTIM2TOX_ENABLE_TEST_HOOKS=OFF) or delete the staged artifact."
            )
        }
    }
}

fun morsecqIsUnitTestOnlyInvocation(taskNames: List<String>): Boolean {
    if (taskNames.isEmpty()) return false
    return taskNames.all { taskName ->
        val lowerName = taskName.lowercase()
        lowerName == "test" || lowerName.endsWith(":test") || lowerName.contains("unittest")
    }
}

val morsecqAllowMissingFfi: Boolean =
    (project.findProperty("morsecqAllowMissingFfi")?.toString() == "true") ||
        (System.getenv("MORSECQ_ALLOW_MISSING_FFI") == "1")

android {
    namespace = "icu.agentx.morsecq"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "icu.agentx.morsecq"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // morsecq: bundle libtim2tox_ffi — package exactly the ABIs that have it.
        val ffiAbis = file("src/main/jniLibs").listFiles()
            ?.filter { it.isDirectory && it.resolve("libtim2tox_ffi.so").exists() }
            ?.map { it.name }?.sorted() ?: emptyList()
        val packaging = !morsecqIsUnitTestOnlyInvocation(gradle.startParameter.taskNames)
        if (ffiAbis.isNotEmpty()) {
            ndk { abiFilters.addAll(ffiAbis) }
            if (packaging) {
                val forbidden = morsecqForbiddenTestHookNames()
                for (abi in ffiAbis) {
                    morsecqAssertNoTestHooks(file("src/main/jniLibs/$abi/libtim2tox_ffi.so"), forbidden)
                }
                logger.lifecycle("morsecq: packaging libtim2tox_ffi.so for ABIs $ffiAbis")
            }
        } else if (packaging && !morsecqAllowMissingFfi) {
            throw GradleException(
                "libtim2tox_ffi.so not found under apps/morsecq/android/app/src/main/jniLibs/<abi>/ " +
                    "— run tool/build_android_ffi.sh (ABIS=\"arm64-v8a x86_64\" for emulators) " +
                    "before building the Android app, or pass -PmorsecqAllowMissingFfi=true " +
                    "for a UI-only build with --dart-define=MORSECQ_FAKE_BACKEND=true."
            )
        } else if (packaging) {
            logger.warn("morsecq: no libtim2tox_ffi.so staged; building WITHOUT the Tox backend (morsecqAllowMissingFfi)")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
