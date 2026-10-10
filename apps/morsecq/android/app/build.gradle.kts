import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing, first match wins:
//  1. env MORSECQ_ANDROID_KEYSTORE / _KEYSTORE_PASSWORD / _KEY_ALIAS /
//     _KEY_PASSWORD (CI, from repository secrets — passed verbatim, so a
//     password may contain any character);
//  2. android/key.properties (storeFile, storePassword, keyAlias, keyPassword;
//     gitignored), the usual Flutter setup for a local release build.
// Neither: release builds fail unless MORSECQ_ALLOW_DEBUG_SIGNING=1
// explicitly opts into a non-distributable debug-signed test artifact.
val morsecqSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
// Debug signing is useful for a deliberately non-distributable local/CI test
// build only. Release builds must opt in explicitly; otherwise a missing
// keystore must fail the release task instead of silently producing an APK that
// cannot be upgraded or uploaded to Play.
val morsecqAllowDebugSigning = System.getenv("MORSECQ_ALLOW_DEBUG_SIGNING") == "1"
val morsecqReleaseSigning: Map<String, String>? = run {
    val env = mapOf(
        "storeFile" to "MORSECQ_ANDROID_KEYSTORE",
        "storePassword" to "MORSECQ_ANDROID_KEYSTORE_PASSWORD",
        "keyAlias" to "MORSECQ_ANDROID_KEY_ALIAS",
        "keyPassword" to "MORSECQ_ANDROID_KEY_PASSWORD",
    ).mapValues { System.getenv(it.value).orEmpty() }
    if (env.values.all { it.isNotEmpty() }) return@run env
    if (env.values.any { it.isNotEmpty() }) {
        throw GradleException("All four MORSECQ_ANDROID signing environment values must be provided together")
    }
    val file = rootProject.file("key.properties").takeIf { it.isFile } ?: return@run null
    val props = Properties().apply { file.inputStream().use { load(it) } }
    morsecqSigningKeys.associateWith { props.getProperty(it).orEmpty() }
        .takeIf { keys -> keys.values.all { it.isNotEmpty() } }
        ?: throw GradleException("android/key.properties must set $morsecqSigningKeys")
}

android {
    namespace = "icu.agentx.morsecq"
    // SDK levels are pinned here rather than taken from the Flutter Gradle
    // plugin, so a Flutter upgrade cannot move them silently. Raise all three
    // together and update doc/release/APP_STORE.md; test/platform/
    // mobile_platform_config_test.dart pins the values. targetSdk 36 is what
    // Play requires for new apps and updates since 2026-08-31 (Flutter 3.41.9
    // defaults to the same three values).
    compileSdk = 36
    // Flutter's NDK (28.2 on 3.41.9) links plugin C/C++ 16 KB page-aligned by
    // default (MorseCQ ships no native library of its own). Never pin this
    // below r28.
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
        // minSdk 24: Flutter 3.41's floor. targetSdk 36: see compileSdk.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName


    }

    signingConfigs {
        morsecqReleaseSigning?.let { keys ->
            create("release") {
                storeFile = file(keys.getValue("storeFile"))
                storePassword = keys.getValue("storePassword")
                keyAlias = keys.getValue("keyAlias")
                keyPassword = keys.getValue("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                morsecqReleaseSigning != null -> signingConfigs.getByName("release")
                morsecqAllowDebugSigning -> signingConfigs.getByName("debug")
                else -> null
            }
        }
    }
}

// Check when a release task runs, not while Gradle configures all variants:
// ordinary debug builds must keep working without distribution credentials.
val verifyMorsecqReleaseSigning = tasks.register("verifyMorsecqReleaseSigning") {
    doLast {
        val taggedBuild = System.getenv("GITHUB_REF_TYPE") == "tag"
        if (morsecqReleaseSigning == null && (!morsecqAllowDebugSigning || taggedBuild)) {
            throw GradleException(
                "Android release signing is not configured. Provide MORSECQ_ANDROID_KEYSTORE, " +
                    "MORSECQ_ANDROID_KEYSTORE_PASSWORD, MORSECQ_ANDROID_KEY_ALIAS and " +
                    "MORSECQ_ANDROID_KEY_PASSWORD (or android/key.properties). " +
                    "For non-tag, non-distributable test artifacts only, set " +
                    "MORSECQ_ALLOW_DEBUG_SIGNING=1.",
            )
        }
        if (morsecqReleaseSigning == null) {
            logger.warn("MorseCQ release explicitly uses DEBUG signing: testing only, never upload to a store.")
        }
    }
}
tasks.configureEach {
    if (name == "preReleaseBuild" || name == "assembleRelease" ||
        name == "bundleRelease" || name == "packageRelease") {
        dependsOn(verifyMorsecqReleaseSigning)
    }
}

flutter {
    source = "../.."
}
