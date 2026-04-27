import Flutter
import UIKit

/// Native iOS 26 Liquid Glass tab bar hosting a single shared FlutterViewController.
///
/// # Architecture
/// UITabBarController gives us the Liquid Glass appearance automatically.
/// A single FlutterViewController is pinned at z-index 0 (beneath all
/// UITabBarController-managed views). Four transparent placeholder VCs exist
/// solely to populate the tab bar items.
///
/// # z-order (iOS 26)
/// In iOS 26 `tabBar` is no longer a direct subview of `self.view`; it lives
/// inside a glass container. `insertSubview(_:belowSubview:tabBar)` falls back
/// to appending on top. We use `insertSubview(at:0)` instead.
///
/// # Touch pass-through
/// UITabBarController's UITransitionView (the placeholder VC container) sits
/// above Flutter. We neutralise it every layout pass:
///   • backgroundColor / layer.backgroundColor = .clear — no opaque flash
///   • isOpaque = false                                  — correct compositor hint
///   • isUserInteractionEnabled = false                  — touches reach Flutter
///
/// # Tab-switch flash elimination
/// Returning `true` from `shouldSelect` lets UITabBarController run its own
/// cross-fade animation, which can briefly show an opaque compositing layer
/// ("black flash") regardless of how transparent the placeholder VCs are.
/// Solution: return `false` from `shouldSelect` and drive the selection
/// ourselves.  Setting `selectedIndex` programmatically:
///   a) Still animates the Liquid Glass selection pill in the tab bar ✓
///   b) Does NOT trigger UITabBarController's content-area cross-fade ✓
/// We guard against the resulting `didSelect` double-notification with a flag.
///
/// # Safe-area propagation
/// UITabBarController only forwards safe-area insets to VCs in `viewControllers`.
/// FlutterVC is added via `addChild` but is NOT in that array, so we patch
/// both top (Dynamic Island) and bottom (tab-bar height) manually.
final class LiquidGlassTabController: UITabBarController, UITabBarControllerDelegate {

  // MARK: - Channel contract
  static  let channelName        = "calmcampus/native_shell"
  private static let setTabMethod        = "setTab"
  private static let setOnboardingMethod = "setOnboardingMode"
  private static let requestTabMethod    = "requestTab"

  // MARK: - State
  let flutterEngine: FlutterEngine
  private let flutterVC: FlutterViewController
  private let channel:   FlutterMethodChannel

  /// Prevents `didSelect` from sending a duplicate channel call when we set
  /// `selectedIndex` programmatically inside `shouldSelect`.
  private var suppressDidSelect = false

  /// Guards `viewSafeAreaInsetsDidChange` against oscillation.
  private var lastAppliedTopInset: CGFloat = -1

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

  required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // App background colour — avoids any compositing gap appearing black.
    view.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1)

    // Flutter view at the very bottom of the z-stack.
    addChild(flutterVC)
    flutterVC.view.frame            = view.bounds
    flutterVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.insertSubview(flutterVC.view, at: 0)
    flutterVC.didMove(toParent: self)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    neutralisePlaceholderViews()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // Re-assert Flutter at index 0 after each UIKit layout pass.
    if flutterVC.view.superview === view {
      view.insertSubview(flutterVC.view, at: 0)
    }

    neutralisePlaceholderViews()

    // Bottom safe-area: UITabBarController doesn't set this for non-viewControllers
    // children. Tell Flutter the tab bar occupies the bottom so scroll content
    // lands above the Liquid Glass pill.
    let tabH = tabBar.frame.height
    if flutterVC.additionalSafeAreaInsets.bottom != tabH {
      flutterVC.additionalSafeAreaInsets.bottom = tabH
    }
  }

  // Top safe-area: patch Dynamic Island / notch for FlutterVC which is not
  // in `viewControllers` and therefore skipped by UITabBarController's
  // normal inset propagation.
  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    guard let window = view.window else { return }

    let windowTop  = window.safeAreaInsets.top
    guard windowTop > 0 else { return }

    // Strip out what we previously added to isolate UIKit's own contribution.
    let inherited  = flutterVC.view.safeAreaInsets.top
                   - flutterVC.additionalSafeAreaInsets.top
    let extra      = max(0, windowTop - inherited)

    guard extra != lastAppliedTopInset else { return }
    lastAppliedTopInset = extra
    flutterVC.additionalSafeAreaInsets.top = extra
  }

  // MARK: - Placeholder neutralisation

  private func neutralisePlaceholderViews() {
    for sub in view.subviews {
      guard sub !== flutterVC.view            else { continue }
      guard !subtreeContains(sub, target: tabBar) else { continue }
      // Visual transparency
      sub.backgroundColor          = .clear
      sub.isOpaque                 = false
      sub.layer.backgroundColor    = UIColor.clear.cgColor
      sub.layer.isOpaque           = false
      // Touch pass-through
      sub.isUserInteractionEnabled = false
      for child in sub.subviews {
        child.backgroundColor       = .clear
        child.isOpaque              = false
        child.layer.backgroundColor = UIColor.clear.cgColor
        child.layer.isOpaque        = false
      }
    }
  }

  private func subtreeContains(_ root: UIView, target: UIView) -> Bool {
    root === target || root.subviews.contains { subtreeContains($0, target: target) }
  }

  // MARK: - UITabBarControllerDelegate

  func tabBarController(
    _ tabBarController: UITabBarController,
    shouldSelect viewController: UIViewController
  ) -> Bool {
    guard let index = viewControllers?.firstIndex(of: viewController),
          index != selectedIndex
    else { return false }

    // Drive the switch ourselves:
    //   • Returning false cancels UITabBarController's content-area cross-fade
    //     (the source of the "black flash") while the tab bar pill still
    //     animates smoothly because we update selectedIndex programmatically.
    //   • suppressDidSelect prevents didSelect from sending a duplicate
    //     channel notification (didSelect is called synchronously during the
    //     selectedIndex assignment below).
    suppressDidSelect = true
    selectedIndex = index          // tab bar pill animates; no view cross-fade
    suppressDidSelect = false

    channel.invokeMethod(Self.setTabMethod, arguments: index)
    return false
  }

  func tabBarController(
    _ tabBarController: UITabBarController,
    didSelect viewController: UIViewController
  ) {
    // Only fires for programmatic selectedIndex changes not originating from
    // shouldSelect (e.g., requestTab channel calls).  The suppressDidSelect
    // flag blocks the duplicate from our own shouldSelect logic above.
    guard !suppressDidSelect else { return }
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
    if visible { tabBar.isHidden = false }
    UIView.animate(withDuration: 0.22) {
      self.tabBar.alpha = visible ? 1 : 0
    } completion: { _ in
      self.tabBar.isHidden = !visible
    }
  }

  // MARK: - Tab item factory

  private func makePlaceholderTabs() -> [UIViewController] {
    let items: [(title: String, sf: String, sfFilled: String)] = [
      ("Home",     "house",           "house.fill"),
      ("Insights", "chart.bar",       "chart.bar.fill"),
      ("Toolkit",  "square.grid.2x2", "square.grid.2x2.fill"),
      ("Profile",  "person",          "person.fill"),
    ]
    return items.map { item in
      let vc = UIViewController()
      vc.view.backgroundColor          = .clear
      vc.view.isUserInteractionEnabled = false
      vc.tabBarItem = UITabBarItem(
        title: item.title,
        image: UIImage(systemName: item.sf),
        selectedImage: UIImage(systemName: item.sfFilled))
      return vc
    }
  }
}
