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
  int _step = 0;

  static const _slides = [
    ('🧠', 'Welcome to\nCalmCampus', 'Your privacy-first companion for student wellbeing. Detect early signs of stress before burnout strikes.'),
    ('🔒', 'Your Data\nStays Yours', 'All behavioral analysis happens on your device. Nothing is ever sent to a server. GDPR-compliant by design.'),
    ('🌿', 'Gentle\nInterventions', 'Evidence-based techniques — breathing exercises, mindfulness, and campus resources when you need them.'),
  ];

  void _next() {
    if (_step == _slides.length - 1) {
      context.read<AppState>().setHasOnboarded(true);
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_step];
    final isLast = _step == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
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
                      child: Text(slide.$1, style: const TextStyle(fontSize: 40)),
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
              ),
            ),
            // Bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(44, 0, 44, 50),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = i == _step;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: active ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: active ? AppColors.accent : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _next,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                      onPressed: () => context.read<AppState>().setHasOnboarded(true),
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
