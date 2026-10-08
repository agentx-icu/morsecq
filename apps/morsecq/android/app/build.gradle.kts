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
// Neither: signed with the debug key — installable for testing, not for a
// store, and not upgradable to/from a properly signed build.
val morsecqSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
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
            signingConfig = signingConfigs.getByName(
                if (morsecqReleaseSigning != null) "release" else "debug",
            )
        }
    }
}

flutter {
    source = "../.."
}
