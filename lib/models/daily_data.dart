class DailyData {
  final String date;
  final String dayLabel;
  final int dayOfWeek;
  final double sleepHours;
  final double screenTimeHours;
  final int activeMinutes;
  final int appSwitches;
  final int wellnessScore;
  final int? moodRating;
  final int? energyRating;
  final String? gratitudeEntry;
  final int? realSteps;

  const DailyData({
    required this.date,
    required this.dayLabel,
    required this.dayOfWeek,
    required this.sleepHours,
    required this.screenTimeHours,
    required this.activeMinutes,
    required this.appSwitches,
    required this.wellnessScore,
    this.moodRating,
    this.energyRating,
    this.gratitudeEntry,
    this.realSteps,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'dayLabel': dayLabel,
      'dayOfWeek': dayOfWeek,
      'sleepHours': sleepHours,
      'screenTimeHours': screenTimeHours,
      'activeMinutes': activeMinutes,
      'appSwitches': appSwitches,
      'wellnessScore': wellnessScore,
      'moodRating': moodRating,
      'energyRating': energyRating,
      'gratitudeEntry': gratitudeEntry,
      'realSteps': realSteps,
    };
  }

  factory DailyData.fromMap(Map<String, dynamic> map) {
    return DailyData(
      date: map['date'] as String,
      dayLabel: map['dayLabel'] as String,
      dayOfWeek: map['dayOfWeek'] as int,
      sleepHours: (map['sleepHours'] as num).toDouble(),
      screenTimeHours: (map['screenTimeHours'] as num).toDouble(),
      // Legacy data has typingSpeed but no activeMinutes — default to 30.
      activeMinutes: map['activeMinutes'] as int? ?? 30,
      appSwitches: map['appSwitches'] as int,
      wellnessScore: map['wellnessScore'] as int,
      moodRating: map['moodRating'] as int?,
      energyRating: map['energyRating'] as int?,
      gratitudeEntry: map['gratitudeEntry'] as String?,
      realSteps: map['realSteps'] as int?,
    );
  }

  DailyData copyWith({
    String? date,
    String? dayLabel,
    int? dayOfWeek,
    double? sleepHours,
    double? screenTimeHours,
    int? activeMinutes,
    int? appSwitches,
    int? wellnessScore,
    int? moodRating,
    int? energyRating,
    String? gratitudeEntry,
    int? realSteps,
  }) {
    return DailyData(
      date: date ?? this.date,
      dayLabel: dayLabel ?? this.dayLabel,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      sleepHours: sleepHours ?? this.sleepHours,
      screenTimeHours: screenTimeHours ?? this.screenTimeHours,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      appSwitches: appSwitches ?? this.appSwitches,
      wellnessScore: wellnessScore ?? this.wellnessScore,
      moodRating: moodRating ?? this.moodRating,
      energyRating: energyRating ?? this.energyRating,
      gratitudeEntry: gratitudeEntry ?? this.gratitudeEntry,
      realSteps: realSteps ?? this.realSteps,
    );
  }
}
