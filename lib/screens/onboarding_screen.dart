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
      'Your privacy-first companion for student wellbeing. Detect early signs of stress before burnout strikes.'
    ),
    (
      '\u{1F512}',
      'Your Data\nStays Yours',
      'All behavioral analysis happens on your device. Nothing is ever sent to a server. GDPR-compliant by design.'
    ),
    (
      '\u{1F33F}',
      'Gentle\nInterventions',
      'Evidence-based techniques \u2014 breathing exercises, mindfulness, and campus resources when you need them.'
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                          ),
                          alignment: Alignment.center,
                          child: Text(slide.$1,
                              style: const TextStyle(fontSize: 40)),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                            height: 1.2,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.$3,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(44, 0, 44, 50),
              child: Column(
                children: [
                  // Animated dot indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      // Calculate how "active" this dot is based on the page position
                      final distance = (_currentPage - i).abs();
                      final isActive = distance < 0.5;
                      final widthFactor =
                          (1 - distance.clamp(0.0, 1.0));

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
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
                  const SizedBox(height: 28),
                  // Continue / Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _next,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(isLast ? 'Get Started' : 'Continue'),
                    ),
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          context.read<AppState>().setHasOnboarded(true),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
