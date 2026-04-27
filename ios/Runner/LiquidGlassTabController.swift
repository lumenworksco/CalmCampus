import Flutter
import UIKit

/// Native iOS 26 Liquid Glass tab bar that hosts a single shared
/// `FlutterViewController`.
///
/// The tab bar belongs to UIKit so iOS 26 automatically gives us the real
/// Liquid Glass appearance — translucency that samples the underlying
/// content, the morphing selection pill, native haptics, and proper
/// VoiceOver / Dynamic Type support.
///
/// All four tab items map to the same `FlutterViewController`. We move the
/// Flutter view between four placeholder child view controllers as the user
/// switches tabs, and tell Flutter which screen to render via a method
/// channel. One Dart isolate, one Provider tree, one Flutter view — just
/// reparented as the user navigates.
final class LiquidGlassTabController: UITabBarController, UITabBarControllerDelegate {

  // MARK: - Channel contract
  static let channelName = "calmcampus/native_shell"
  /// Sent iOS → Flutter whenever the user changes tabs.
  private static let setTabMethod = "setTab"
  /// Received Flutter → iOS — Flutter tells us whether to show or hide
  /// the tab bar (e.g. during onboarding).
  private static let setOnboardingMethod = "setOnboardingMode"
  /// Received Flutter → iOS — programmatic tab change request.
  private static let requestTabMethod = "requestTab"

  // MARK: - Stored state
  let flutterEngine: FlutterEngine
  private let flutterVC: FlutterViewController
  private let channel: FlutterMethodChannel

  // MARK: - Init

  init(flutterEngine: FlutterEngine) {
    self.flutterEngine = flutterEngine
    self.flutterVC = FlutterViewController(
      engine: flutterEngine, nibName: nil, bundle: nil)
    self.channel = FlutterMethodChannel(
      name: LiquidGlassTabController.channelName,
      binaryMessenger: flutterEngine.binaryMessenger)

    super.init(nibName: nil, bundle: nil)

    self.delegate = self
    self.viewControllers = makePlaceholderTabs()
    self.flutterVC.view.backgroundColor = .clear

    self.channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call: call, result: result)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not used")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Embed the Flutter view in whichever tab is selected at launch.
    if let first = viewControllers?.first {
      embedFlutter(in: first)
    }
  }

  // MARK: - UITabBarControllerDelegate

  func tabBarController(
    _ tabBarController: UITabBarController,
    didSelect viewController: UIViewController
  ) {
    embedFlutter(in: viewController)
    if let index = viewControllers?.firstIndex(of: viewController) {
      channel.invokeMethod(Self.setTabMethod, arguments: index)
    }
  }

  // MARK: - Channel handler

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case Self.setOnboardingMethod:
      if let isOnboarding = call.arguments as? Bool {
        setTabBarVisible(!isOnboarding)
        result(nil)
      } else {
        result(FlutterError(
          code: "bad_args",
          message: "setOnboardingMode expects Bool",
          details: nil))
      }

    case Self.requestTabMethod:
      if let index = call.arguments as? Int,
         let tabs = viewControllers,
         (0..<tabs.count).contains(index)
      {
        selectedIndex = index
        embedFlutter(in: tabs[index])
        result(nil)
      } else {
        result(FlutterError(
          code: "bad_args",
          message: "requestTab expects valid Int index",
          details: nil))
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Tab bar visibility

  private func setTabBarVisible(_ visible: Bool) {
    // Animate the tab bar out of the way during onboarding so the Flutter
    // splash/onboarding fills the full screen.
    UIView.animate(withDuration: 0.22) {
      self.tabBar.alpha = visible ? 1 : 0
    } completion: { _ in
      self.tabBar.isHidden = !visible
    }
    if visible { self.tabBar.isHidden = false }
  }

  // MARK: - Flutter view reparenting

  /// Move the shared Flutter view controller to be a child of `parent` and
  /// fill its bounds. Called every time the user switches tabs. UIKit's
  /// addChild/removeFromParent contract is followed so view-appearance
  /// callbacks fire on the Flutter side as expected.
  private func embedFlutter(in parent: UIViewController) {
    if flutterVC.parent === parent { return }

    if flutterVC.parent != nil {
      flutterVC.willMove(toParent: nil)
      flutterVC.view.removeFromSuperview()
      flutterVC.removeFromParent()
    }

    parent.addChild(flutterVC)
    parent.view.addSubview(flutterVC.view)
    flutterVC.view.frame = parent.view.bounds
    flutterVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    flutterVC.didMove(toParent: parent)
  }

  // MARK: - Tab item factory

  private func makePlaceholderTabs() -> [UIViewController] {
    let items: [(title: String, sf: String, sfFilled: String)] = [
      ("Home",     "house",                   "house.fill"),
      ("Insights", "chart.bar",               "chart.bar.fill"),
      ("Toolkit",  "square.grid.2x2",         "square.grid.2x2.fill"),
      ("Profile",  "person",                  "person.fill"),
    ]

    return items.map { item in
      let vc = UIViewController()
      vc.view.backgroundColor = UIColor(named: "BackgroundColor")
        ?? UIColor.systemGray6
      vc.tabBarItem = UITabBarItem(
        title: item.title,
        image: UIImage(systemName: item.sf),
        selectedImage: UIImage(systemName: item.sfFilled))
      return vc
    }
  }
}
