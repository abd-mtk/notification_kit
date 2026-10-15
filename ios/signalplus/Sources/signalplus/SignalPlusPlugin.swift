import Flutter
import UIKit
import UserNotifications

public class SignalPlusPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "signalplus", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(SignalPlusPlugin(), channel: channel)
    guard let appDelegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate else { return }
    UNUserNotificationCenter.current().delegate = appDelegate
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "clearDelivered":
      UNUserNotificationCenter.current().removeAllDeliveredNotifications()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
