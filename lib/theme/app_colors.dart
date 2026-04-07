import 'dart:ui';

class AppColors {
  static const primary = Color(0xFF34C759);
  static const primaryDark = Color(0xFF248A3D);
  static const primaryLight = Color(0xFFD1F2D9);
  static const accent = Color(0xFF007AFF);
  static const accentLight = Color(0xFFD6EAFF);

  static const background = Color(0xFFF2F2F7);
  static const surface = Color(0xFFFFFFFF);

  static const text = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF8E8E93);
  static const textTertiary = Color(0xFFAEAEB2);

  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9F0A);
  static const danger = Color(0xFFFF3B30);
  static const purple = Color(0xFFAF52DE);
  static const indigo = Color(0xFF5856D6);
  static const teal = Color(0xFF5AC8FA);

  static const dangerLight = Color(0xFFFFE5E5);
  static const warningLight = Color(0xFFFFF4E6);
  static const successLight = Color(0xFFE8FAE8);
  static const purpleLight = Color(0xFFF4E8FA);

  static const border = Color(0xFFE5E5EA);
  static const borderLight = Color(0xFFF2F2F7);

  static Color getWellnessColor(int score) {
    if (score >= 75) return success;
    if (score >= 50) return warning;
    return danger;
  }

  static String getWellnessLabel(int score) {
    if (score >= 80) return "You're doing great!";
    if (score >= 65) return 'Mostly good, stay mindful';
    if (score >= 50) return 'We noticed some changes';
    if (score >= 35) return 'Consider taking a break';
    return "Let's focus on your wellbeing";
  }
}
