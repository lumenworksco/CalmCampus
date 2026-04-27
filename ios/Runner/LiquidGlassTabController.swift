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
///   • backgroundColor = .clear  — prevents opaque flash during tab animation
///   • isOpaque = false           — correct compositor hint
///   • isUserInteractionEnabled = false — touches fall through to Flutter
/// We also call this in `shouldSelect` so the neutralisation happens BEFORE
/// UIKit snapshots the view for its cross-fade animation.
///
/// # Safe-area / Dynamic Island
/// UITabBarController propagates safe-area insets only to the VCs inside its
/// `viewControllers` array. Our FlutterVC is added via `addChild` but is NOT
/// in that array, so UIKit never delivers:
///   • top inset  — Dynamic Island / notch
///   • bottom inset — tab bar height
/// We patch both explicitly via `additionalSafeAreaInsets`.
final class LiquidGlassTabController: UITabBarController, UITabBarControllerDelegate {

  // MARK: - Channel contract
  static  let channelName        = "calmcampus/native_shell"
  private static let setTabMethod        = "setTab"
  private static let setOnboardingMethod = "setOnboardingMode"
  private static let requestTabMethod    = "requestTab"

  // MARK: - Stored state
  let flutterEngine: FlutterEngine
  private let flutterVC: FlutterViewController
  private let channel:   FlutterMethodChannel

  /// Guard that prevents an `additionalSafeAreaInsets.top` set from looping back
  /// through `viewSafeAreaInsetsDidChange` and oscillating.
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

    // Give the tab-controller view the app's background colour so that any
    // compositing gap (during UITabBarController animations) shows cream/gray
    // instead of black.
    view.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1)

    // Pin Flutter at the very bottom (index 0) of the subview stack.
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

    // Re-assert Flutter at index 0.
    if flutterVC.view.superview === view {
      view.insertSubview(flutterVC.view, at: 0)
    }

    neutralisePlaceholderViews()

    // ── Bottom safe-area correction ──────────────────────────────────────────
    // UITabBarController adds tab-bar height to additionalSafeAreaInsets.bottom
    // only for VCs in its `viewControllers` array. FlutterVC is not in that
    // array, so we set it manually here. This lets Flutter's
    // MediaQuery.viewPadding.bottom reflect (homeIndicator + tabBarHeight).
    let tabH = tabBar.frame.height
    if flutterVC.additionalSafeAreaInsets.bottom != tabH {
      flutterVC.additionalSafeAreaInsets.bottom = tabH
    }
  }

  // ── Top safe-area correction (Dynamic Island / notch) ────────────────────
  // UITabBarController does NOT propagate the window's top inset to FlutterVC
  // because FlutterVC is not in `viewControllers`. We bridge the gap here.
  //
  // The loop-guard (lastAppliedTopInset) prevents the common oscillation:
  //   set additionalSafeAreaInsets.top
  //   → UIKit calls viewSafeAreaInsetsDidChange again
  //   → we recalculate and set again → infinite loop
  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    guard let window = view.window else { return }

    let windowTop = window.safeAreaInsets.top
    guard windowTop > 0 else { return }

    // Isolate the "naturally inherited" top (strip out what we already added).
    let inherited = flutterVC.view.safeAreaInsets.top
                    - flutterVC.additionalSafeAreaInsets.top
    let extra = max(0, windowTop - inherited)

    guard extra != lastAppliedTopInset else { return }   // no-op if unchanged
    lastAppliedTopInset = extra
    flutterVC.additionalSafeAreaInsets.top = extra
  }

  // MARK: - Placeholder view neutralisation

  /// Clears visual and touch properties of every UITabBarController-internal
  /// view that sits above Flutter (the UITransitionView and its children).
  /// Skips the tab bar and its glass container so tab interaction still works.
  private func neutralisePlaceholderViews() {
    for sub in view.subviews {
      guard sub !== flutterVC.view else { continue }
      guard !subtreeContains(sub, target: tabBar) else { continue }
      sub.backgroundColor          = .clear
      sub.isOpaque                 = false
      sub.isUserInteractionEnabled = false
      for child in sub.subviews {
        child.backgroundColor = .clear
        child.isOpaque        = false
      }
    }
  }

  private func subtreeContains(_ root: UIView, target: UIView) -> Bool {
    if root === target { return true }
    return root.subviews.contains { subtreeContains($0, target: target) }
  }

  // MARK: - UITabBarControllerDelegate

  func tabBarController(
    _ tabBarController: UITabBarController,
    shouldSelect viewController: UIViewController
  ) -> Bool {
    // Neutralise placeholder views RIGHT NOW — before UIKit snapshots them for
    // the cross-fade animation. This ensures the animation is between two
    // fully-transparent layers so the Flutter content beneath is always visible
    // (no black flash during tab transitions).
    neutralisePlaceholderViews()
    return true
  }

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
      vc.view.isUserInteractionEnabled = false   // touches fall through to Flutter
      vc.tabBarItem = UITabBarItem(
        title: item.title,
        image: UIImage(systemName: item.sf),
        selectedImage: UIImage(systemName: item.sfFilled))
      return vc
    }
  }
}
