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

          // Floating glass tab bar
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomPadding + 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_tabs.length, (i) {
                      final isSelected = i == _currentIndex;
                      return _GlassTabButton(
                        icon: _tabs[i].icon,
                        label: _tabs[i].label,
                        isSelected: isSelected,
                        onTap: () => _onTabTapped(i),
                      );
                    }),
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
    return Semantics(
      label: widget.label,
      button: true,
      selected: widget.isSelected,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.accent.withValues(alpha: 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ScaleTransition(
                  scale: _scale,
                  child: Icon(
                    widget.icon,
                    size: 22,
                    color: widget.isSelected
                        ? AppColors.accent
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isSelected
                      ? AppColors.accent
                      : AppColors.textTertiary,
                  letterSpacing: -0.1,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
