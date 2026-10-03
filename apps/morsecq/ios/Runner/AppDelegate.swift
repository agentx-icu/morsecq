import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications: taps and foreground presentation on iOS
    // are delivered through the app delegate (FlutterAppDelegate already
    // conforms to UNUserNotificationCenterDelegate). See
    // lib/notifications/README.md.
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MorsecqBackupExclusion") {
      BackupExclusion.register(messenger: registrar.messenger())
    }
  }
}

/// lib/di/backup_exclusion.dart: keeps the identity data out of iCloud /
/// iTunes device backups (it holds the Tox identity; the user moves it with
/// the in-app backup file instead).
enum BackupExclusion {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "icu.agentx.morsecq/backup_exclusion", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "exclude",
        let path = (call.arguments as? [String: Any])?["path"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      var url = URL(fileURLWithPath: path, isDirectory: true)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      do {
        try url.setResourceValues(values)
        result(true)
      } catch {
        result(FlutterError(
          code: "exclude_failed", message: error.localizedDescription, details: nil))
      }
    }
  }
}
