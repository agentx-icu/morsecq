package icu.agentx.morsecq

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "morsecq/privacy_consent")
            .setMethodCallHandler { call, result ->
                if (call.method == "getNoBackupDirectory") {
                    val directory = noBackupFilesDir
                    if (directory?.isDirectory == true) {
                        result.success(directory.path)
                    } else {
                        result.error("storage_unavailable", null, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
