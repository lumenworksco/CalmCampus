export const Colors = {
  // Apple-inspired palette
  primary: '#34C759',       // iOS green
  primaryDark: '#248A3D',
  primaryLight: '#D1F2D9',
  accent: '#007AFF',        // iOS blue
  accentLight: '#D6EAFF',

  background: '#F2F2F7',    // iOS system grouped bg
  surface: '#FFFFFF',
  surfaceSecondary: '#F9F9FB',

  text: '#1C1C1E',          // iOS primary label
  textSecondary: '#8E8E93',  // iOS secondary label
  textTertiary: '#AEAEB2',

  success: '#34C759',
  warning: '#FF9F0A',
  danger: '#FF3B30',
  purple: '#AF52DE',
  indigo: '#5856D6',
  teal: '#5AC8FA',

  dangerLight: '#FFE5E5',
  warningLight: '#FFF4E6',
  successLight: '#E8FAE8',
  purpleLight: '#F4E8FA',

  border: '#E5E5EA',        // iOS separator
  borderLight: '#F2F2F7',
  tabBar: '#FFFFFF',
  tabBarInactive: '#8E8E93',

  // Semantic
  cardShadow: 'rgba(0,0,0,0.04)',
};

export function getWellnessColor(score: number): string {
  if (score >= 75) return Colors.success;
  if (score >= 50) return Colors.warning;
  return Colors.danger;
}

export function getWellnessLabel(score: number): string {
  if (score >= 80) return "You're doing great!";
  if (score >= 65) return "Mostly good, stay mindful";
  if (score >= 50) return "We noticed some changes";
  if (score >= 35) return "Consider taking a break";
  return "Let's focus on your wellbeing";
}
