import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  double _currentPage = 0;

  static const _slides = [
    (
      '\u{1F9E0}',
      'Welcome to\nCalmCampus',
      'Your privacy-first companion for student wellbeing. '
          'Detect early signs of stress before burnout strikes.'
    ),
    (
      '\u{1F512}',
      'Your Data\nStays Yours',
      'All behavioral analysis happens on your device. '
          'Nothing is ever sent to a server. GDPR-compliant by design.'
    ),
    (
      '\u{1F33F}',
      'Gentle\nInterventions',
      'Evidence-based techniques \u2014 breathing exercises, mindfulness, '
          'and campus resources when you need them.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    final currentIndex = _currentPage.round();
    if (currentIndex == _slides.length - 1) {
      context.read<AppState>().setHasOnboarded(true);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentPage.round();
    final isLast = currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // -- Skip button --
            if (!isLast)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    onPressed: () =>
                        context.read<AppState>().setHasOnboarded(true),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 52),

            // -- Page content --
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];

                  // Subtle parallax effect
                  final distance = (_currentPage - index).abs();
                  final opacity = (1.0 - distance * 0.3).clamp(0.0, 1.0);

                  return AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Large emoji -- 64pt on plain background
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.background,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              slide.$1,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            slide.$2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                              height: 1.15,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            slide.$3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // -- Bottom controls --
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 56),
              child: Column(
                children: [
                  // Animated dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final distance = (_currentPage - i).abs();
                      final isActive = distance < 0.5;
                      final widthFactor = (1 - distance.clamp(0.0, 1.0));

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 8 + (16 * widthFactor),
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 36),

                  // Full-width button, 16px rounded corners
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: _next,
                      child: Text(
                        isLast ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
