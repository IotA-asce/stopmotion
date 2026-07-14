import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let storageChannel = FlutterMethodChannel(
      name: "stop_motion/storage",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    storageChannel.setMethodCallHandler { call, result in
      guard call.method == "availableStorageBytes" else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        let values = try FileManager.default.attributesOfFileSystem(
          forPath: NSHomeDirectory()
        )
        result((values[.systemFreeSize] as? NSNumber)?.int64Value)
      } catch {
        result(nil)
      }
    }
  }
}
