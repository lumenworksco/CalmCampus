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
/// Architecture: a single `FlutterViewController` is mounted permanently
/// on this controller's own view, just below the tab bar. The four child
/// view controllers are empty placeholders — they exist solely so the tab
/// bar has four items to render. When the user taps a tab, we send the
/// new index to Flutter via a method channel; Flutter swaps which screen
/// sits at the top of an `IndexedStack`. Nothing in UIKit is reparented,
/// so there's no visual flicker and no re-attachment cost.
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

    // Mount the Flutter view permanently as a child of this controller,
    // sized to fill the whole view via autoresizing. iOS automatically
    // includes the tab bar's height in the bottom safe-area inset that
    // Flutter sees via MediaQuery.
    //
    // CRITICAL: insert *below* the tab bar so the tab bar renders on top,
    // and *above* whatever UITabBarController inserts for the selected
    // wrapper VC (which goes in at index 0 by default).
    addChild(flutterVC)
    flutterVC.view.frame = view.bounds
    flutterVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.insertSubview(flutterVC.view, belowSubview: tabBar)
    flutterVC.didMove(toParent: self)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Each tab change UIKit may re-insert the selected wrapper's view
    // somewhere that disrupts our z-order. Re-assert: Flutter view sits
    // just below the tab bar, above any wrapper views.
    if flutterVC.view.superview === view {
      view.insertSubview(flutterVC.view, belowSubview: tabBar)
    }
  }

  // MARK: - UITabBarControllerDelegate

  func tabBarController(
    _ tabBarController: UITabBarController,
    didSelect viewController: UIViewController
  ) {
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
        // selectedIndex assignment doesn't fire didSelect, so notify
        // Flutter explicitly.
        channel.invokeMethod(Self.setTabMethod, arguments: index)
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
    if visible { self.tabBar.isHidden = false }
    UIView.animate(withDuration: 0.22) {
      self.tabBar.alpha = visible ? 1 : 0
    } completion: { _ in
      self.tabBar.isHidden = !visible
    }
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
      // Transparent — Flutter view sits above and provides the actual
      // background colour.
      vc.view.backgroundColor = .clear
      vc.tabBarItem = UITabBarItem(
        title: item.title,
        image: UIImage(systemName: item.sf),
        selectedImage: UIImage(systemName: item.sfFilled))
      return vc
    }
  }
}
