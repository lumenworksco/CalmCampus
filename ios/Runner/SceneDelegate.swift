import Flutter
import UIKit

/// Builds the iOS view hierarchy programmatically: a single `FlutterEngine`
/// hosted inside a `LiquidGlassTabController`. iOS 26 takes care of giving
/// us the real Liquid Glass tab bar appearance.
class SceneDelegate: FlutterSceneDelegate {

  private var sharedEngine: FlutterEngine?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    // 1. Spin up one shared Flutter engine and register all plugins.
    let engine = FlutterEngine(name: "calmcampus.main")
    engine.run()
    GeneratedPluginRegistrant.register(with: engine)
    self.sharedEngine = engine

    // 2. Wrap it in the native tab controller.
    let tabController = LiquidGlassTabController(flutterEngine: engine)

    // 3. Mount it on the scene's window.
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = tabController
    self.window = window
    window.makeKeyAndVisible()
  }
}
