import com.android.apksig.ApkVerifier
import com.android.build.api.artifact.SingleArtifact
import com.android.build.api.variant.BuiltArtifactsLoader
import org.gradle.process.ExecOperations
import java.util.Properties
import javax.inject.Inject
import javax.naming.ldap.LdapName

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

// Opt in with `-PstoreRelease` on Flutter APK and App Bundle builds.
val storeRelease = project.hasProperty("storeRelease")

android {
    namespace = "icu.agentx.morsecq"
    // SDK levels are pinned here rather than taken from the Flutter Gradle
    // plugin, so a Flutter upgrade cannot move them silently. Review target/compile against submission rules; keep the supported
    // minimum independent and update doc/release/APP_STORE.md; test/platform/
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
                storeRelease -> throw GradleException(
                    "Store release requires the MORSECQ_ANDROID signing keys " +
                        "(env or android/key.properties); refusing to sign with the debug key"
                )
                else -> signingConfigs.getByName("debug")
            }
        }
    }
}

abstract class VerifyStoreApkSigning : DefaultTask() {
    @get:InputDirectory
    abstract val apkDirectory: DirectoryProperty

    @get:Internal
    abstract val artifactLoader: Property<BuiltArtifactsLoader>

    @TaskAction
    fun verify() {
        val artifacts = artifactLoader.get().load(apkDirectory.get())
            ?: throw GradleException("Missing store APK output metadata")
        if (artifacts.elements.isEmpty()) throw GradleException("No store APKs were built")

        for (artifact in artifacts.elements) {
            val apk = File(artifact.outputFile)
            val result = ApkVerifier.Builder(apk).build().verify()
            if (!result.isVerified || result.signerCertificates.isEmpty()) {
                throw GradleException("Could not verify store APK signature for ${apk.name}")
            }
            val certificates = result.signerCertificates +
                result.signingCertificateLineage?.certificatesInLineage.orEmpty()
            val hasDebugSigner = certificates.any { certificate ->
                LdapName(certificate.subjectX500Principal.name).rdns.any { rdn ->
                    rdn.toAttributes().get("CN")?.get()?.toString()
                        .equals("Android Debug", ignoreCase = true)
                }
            }
            if (hasDebugSigner) {
                throw GradleException("Android Debug certificate cannot sign a store APK (${apk.name})")
            }
        }
    }
}

abstract class VerifyStoreBundleSigning @Inject constructor(
    private val execOperations: ExecOperations,
) : DefaultTask() {
    @get:InputFile
    abstract val bundle: RegularFileProperty

    @get:InputFile
    abstract val verifier: RegularFileProperty

    @get:OutputFile
    abstract val verifiedBundle: RegularFileProperty

    @TaskAction
    fun verify() {
        val source = bundle.get().asFile
        val output = verifiedBundle.get().asFile
        val javaBin = File(System.getProperty("java.home"), "bin")
        val java = javaBin.resolve("java").takeIf { it.isFile } ?: javaBin.resolve("java.exe")
        if (output.exists() && !output.delete()) {
            throw GradleException("Could not remove the previous verified store AAB")
        }
        execOperations.exec {
            commandLine(java, verifier.get().asFile, source, "-", "store")
        }
        source.copyTo(output)
    }
}

if (storeRelease) {
    androidComponents.onVariants(androidComponents.selector().withBuildType("release")) { variant ->
        val verification = tasks.register<VerifyStoreApkSigning>(
            variant.computeTaskName("verify", "StoreApkSigning"),
        ) {
            apkDirectory.set(variant.artifacts.get(SingleArtifact.APK))
            artifactLoader.set(variant.artifacts.getBuiltArtifactsLoader())
        }
        // Run after AGP packages every APK and before Flutter copies the outputs.
        val assembleTask = "assemble${variant.name.replaceFirstChar { it.uppercaseChar() }}"
        tasks.matching { it.name == assembleTask }.configureEach {
            dependsOn(verification)
        }

        val bundleVerification = tasks.register<VerifyStoreBundleSigning>(
            variant.computeTaskName("verify", "StoreBundleSigning"),
        ) {
            verifier.set(rootProject.file("../../../tool/ci/VerifyAndroidBundle.java"))
        }
        variant.artifacts.use(bundleVerification)
            .wiredWithFiles(VerifyStoreBundleSigning::bundle, VerifyStoreBundleSigning::verifiedBundle)
            .toTransform(SingleArtifact.BUNDLE)
    }
}

flutter {
    source = "../.."
}
