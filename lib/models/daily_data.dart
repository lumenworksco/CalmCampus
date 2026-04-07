class DailyData {
  final String date;
  final String dayLabel;
  final int dayOfWeek;
  final double sleepHours;
  final double screenTimeHours;
  final int typingSpeed;
  final int appSwitches;
  final int wellnessScore;

  const DailyData({
    required this.date,
    required this.dayLabel,
    required this.dayOfWeek,
    required this.sleepHours,
    required this.screenTimeHours,
    required this.typingSpeed,
    required this.appSwitches,
    required this.wellnessScore,
  });
}
