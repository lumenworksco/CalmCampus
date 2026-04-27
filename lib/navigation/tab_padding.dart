import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Bottom padding that screens should reserve so their last card sits
/// comfortably above the tab bar.
///
/// * **iOS (native tab bar):** `LiquidGlassTabController` explicitly sets
///   `flutterVC.additionalSafeAreaInsets.bottom = tabBar.frame.height`, so
///   `viewPadding.bottom` already contains (home-indicator + tab-bar height).
///   We add 16 pt of breathing room above the tab bar pill.
/// * **Other platforms:** the Flutter-drawn floating tab bar in [TabScaffold]
///   is ~64 pt tall + 8 pt offset, so we add 80 pt on top of the system inset.
double tabBarBottomPadding(BuildContext context) {
  // Use viewPadding (never consumed by parent widgets) for reliability.
  final base = MediaQuery.of(context).viewPadding.bottom;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    return base + 16;   // base already includes tab bar height via Swift patch
  }
  return base + 80;
}
