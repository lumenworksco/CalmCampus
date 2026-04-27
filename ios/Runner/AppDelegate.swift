import Flutter
import UIKit

/// We build the view hierarchy programmatically in `SceneDelegate` and own
/// the `FlutterEngine` ourselves, so this class no longer needs to opt into
/// the implicit engine pattern.
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
