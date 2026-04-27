import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/dashboard_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/toolkit_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/app_colors.dart';

class TabScaffold extends StatefulWidget {
  const TabScaffold({super.key});

  @override
  State<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<TabScaffold> {
  int _currentIndex = 0;

  static const _tabs = <_TabItem>[
    _TabItem(icon: CupertinoIcons.house_fill, label: 'Home'),
    _TabItem(icon: CupertinoIcons.chart_bar_fill, label: 'Insights'),
    _TabItem(icon: CupertinoIcons.square_grid_2x2_fill, label: 'Toolkit'),
    _TabItem(icon: CupertinoIcons.person_fill, label: 'Profile'),
  ];

  static const _screens = <Widget>[
    DashboardScreen(),
    InsightsScreen(),
    ToolkitScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int i) {
    if (i == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Screen content — all screens are kept alive; the active one fades in.
          for (int i = 0; i < _screens.length; i++)
            _AnimatedTabChild(
              isActive: i == _currentIndex,
              child: _screens[i],
            ),

          // Floating iOS 26 liquid-glass tab bar
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 14,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DecoratedBox(
                    // Outer drop shadows — float the bar above content
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(31),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 48,
                          offset: const Offset(0, 18),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 0.5,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(31),
                      child: BackdropFilter(
                        filter: ImageFilter.compose(
                          outer: ColorFilter.matrix(_saturationMatrix(1.6)),
                          inner: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                        ),
                        child: Container(
                          height: 62,
                          decoration: BoxDecoration(
                            // Gradient — slight cool tint top-right for that
                            // vitreous, lit-from-above look.
                            gradient: const LinearGradient(
                              begin: Alignment(0, -1),
                              end: Alignment(0.1, 1),
                              colors: [
                                Color(0xC7FFFFFF), // 0.78 white
                                Color(0xB8ECECF8), // 0.72 cool tint
                              ],
                            ),
                            borderRadius: BorderRadius.circular(31),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                              width: 0.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Top inset highlight — the "wet edge" of glass
                              Positioned(
                                top: 0,
                                left: 14,
                                right: 14,
                                child: Container(
                                  height: 1.5,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(alpha: 0.95),
                                        Colors.white.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                child: Row(
                                  children: List.generate(_tabs.length, (i) {
                                    final isSelected = i == _currentIndex;
                                    return Expanded(
                                      child: _GlassTabButton(
                                        icon: _tabs[i].icon,
                                        label: _tabs[i].label,
                                        isSelected: isSelected,
                                        onTap: () => _onTabTapped(i),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps every screen mounted (so scroll positions and state persist) while
/// cross-fading between the active and inactive ones.
class _AnimatedTabChild extends StatelessWidget {
  final bool isActive;
  final Widget child;

  const _AnimatedTabChild({
    required this.isActive,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isActive,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: TickerMode(
          enabled: isActive,
          child: child,
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

/// 4x5 color matrix for [ColorFilter.matrix] that boosts saturation by [s].
/// Rec.709 luma weights — same as CSS `saturate()`.
List<double> _saturationMatrix(double s) {
  const r = 0.2126;
  const g = 0.7152;
  const b = 0.0722;
  final iR = (1 - s) * r;
  final iG = (1 - s) * g;
  final iB = (1 - s) * b;
  return <double>[
    iR + s, iG,     iB,     0, 0,
    iR,     iG + s, iB,     0, 0,
    iR,     iG,     iB + s, 0, 0,
    0,      0,      0,      1, 0,
  ];
}

class _GlassTabButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlassTabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_GlassTabButton> createState() => _GlassTabButtonState();
}

class _GlassTabButtonState extends State<_GlassTabButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_bounce);
  }

  @override
  void didUpdateWidget(covariant _GlassTabButton old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    return Semantics(
      label: widget.label,
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: 50,
          decoration: BoxDecoration(
            // Active tab — inner glass pill that lifts off the bar
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment(0, -1),
                    end: Alignment(0.1, 1),
                    colors: [
                      Color(0xE6FFFFFF), // 0.90
                      Color(0xCCF5F5FF), // 0.80 cool tint
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(25),
            border: selected
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 0.5,
                  )
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: selected ? 1.0 : 0.42,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: selected
                        ? AppColors.accent
                        : const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? AppColors.accent
                        : const Color(0xFF000000),
                    letterSpacing: 0.1,
                    height: 1,
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
