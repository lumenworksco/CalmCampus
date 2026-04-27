import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/dashboard_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/toolkit_screen.dart';
import 'tab_scaffold.dart';

/// Renders the four main screens in an [IndexedStack] driven by tab
/// selections coming from the native iOS [LiquidGlassTabController]. On any
/// non-iOS platform we fall back to the Flutter-rendered [TabScaffold].
///
/// The native side communicates over a [MethodChannel] named
/// `calmcampus/native_shell`:
///
/// * `setTab(int index)` — iOS → Flutter, the user tapped a tab
/// * `setOnboardingMode(bool)` — Flutter → iOS, hides/shows the tab bar
/// * `requestTab(int index)` — Flutter → iOS, programmatic tab change
///
/// State is preserved across tabs because every screen stays mounted in
/// the [IndexedStack].
class NativeTabHost extends StatefulWidget {
  const NativeTabHost({super.key});

  /// Channel used by both the host widget and any caller that needs to
  /// request a programmatic tab change or toggle onboarding mode.
  static const MethodChannel channel =
      MethodChannel('calmcampus/native_shell');

  /// Tells the native iOS shell to hide its tab bar (during onboarding).
  /// On non-iOS platforms this is a no-op.
  static Future<void> setOnboardingMode(bool isOnboarding) async {
    if (!_isIOS) return;
    try {
      await channel.invokeMethod('setOnboardingMode', isOnboarding);
    } catch (e) {
      debugPrint('setOnboardingMode failed: $e');
    }
  }

  /// Programmatically jump to another tab from inside Flutter (e.g. the
  /// "View resources" button on the crisis banner switches to Toolkit).
  static Future<void> requestTab(int index) async {
    if (!_isIOS) return;
    try {
      await channel.invokeMethod('requestTab', index);
    } catch (e) {
      debugPrint('requestTab failed: $e');
    }
  }

  static bool get _isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  State<NativeTabHost> createState() => _NativeTabHostState();
}

class _NativeTabHostState extends State<NativeTabHost> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    DashboardScreen(),
    InsightsScreen(),
    ToolkitScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    NativeTabHost.channel.setMethodCallHandler(_onChannelCall);
  }

  @override
  void dispose() {
    NativeTabHost.channel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<dynamic> _onChannelCall(MethodCall call) async {
    switch (call.method) {
      case 'setTab':
        final index = call.arguments as int?;
        if (index != null && index >= 0 && index < _screens.length) {
          setState(() => _currentIndex = index);
        }
        return null;
      default:
        throw MissingPluginException('Unknown method ${call.method}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Android / web continue to use the Flutter-drawn floating tab bar.
    if (!NativeTabHost._isIOS) {
      return const TabScaffold();
    }

    return IndexedStack(
      index: _currentIndex,
      children: _screens,
    );
  }
}
