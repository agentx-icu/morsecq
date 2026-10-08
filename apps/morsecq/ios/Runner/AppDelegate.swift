import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.applicationRegistrar.messenger()
    registerBackgroundTaskChannel(messenger)
  }

  // MARK: - Background task bridge (lib/lifecycle/background_task_api.dart)
  //
  // iOS suspends the app a few seconds after it is backgrounded. Dart's
  // local persistence service holds a beginBackgroundTask assertion for its
  // background budget so the learning files and preferences finish.
  // Tokens are ours (not the raw UIBackgroundTaskIdentifier) so a late
  // "end" for a task that already expired is a harmless no-op.

  private var backgroundTasks: [Int: UIBackgroundTaskIdentifier] = [:]
  private var nextBackgroundTaskToken = 0

  private func registerBackgroundTaskChannel(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "icu.agentx.morsecq/background_task", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      switch call.method {
      case "begin":
        result(self.beginBackgroundTask())
      case "end":
        if let token = call.arguments as? Int {
          self.endBackgroundTask(token)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func beginBackgroundTask() -> Int? {
    nextBackgroundTaskToken += 1
    let token = nextBackgroundTaskToken
    let id = UIApplication.shared.beginBackgroundTask(withName: "MorseCQ flush") {
      [weak self] in
      // Out of time: end it ourselves or iOS terminates the app.
      self?.endBackgroundTask(token)
    }
    if id == .invalid { return nil }
    backgroundTasks[token] = id
    return token
  }

  private func endBackgroundTask(_ token: Int) {
    guard let id = backgroundTasks.removeValue(forKey: token) else { return }
    UIApplication.shared.endBackgroundTask(id)
  }
}
