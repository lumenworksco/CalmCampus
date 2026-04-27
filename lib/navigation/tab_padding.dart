import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Bottom padding that screens should reserve so their last card sits
/// comfortably above the tab bar.
///
/// * **iOS:** the native `UITabBarController` reports its height through
///   `MediaQuery.padding.bottom`, so we just add a small breathing space.
/// * **Other platforms:** the Flutter-drawn floating tab bar in
///   [TabScaffold] is ~64pt tall + 8pt offset, so we add 80pt on top of
///   the system safe area.
double tabBarBottomPadding(BuildContext context) {
  final base = MediaQuery.of(context).padding.bottom;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    return base + 12;
  }
  return base + 80;
}
