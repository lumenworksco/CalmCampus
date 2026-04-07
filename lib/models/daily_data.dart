class DailyData {
  final String date;
  final String dayLabel;
  final int dayOfWeek;
  final double sleepHours;
  final double screenTimeHours;
  final int typingSpeed;
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
    required this.typingSpeed,
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
      'typingSpeed': typingSpeed,
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
      typingSpeed: map['typingSpeed'] as int,
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
    int? typingSpeed,
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
      typingSpeed: typingSpeed ?? this.typingSpeed,
      appSwitches: appSwitches ?? this.appSwitches,
      wellnessScore: wellnessScore ?? this.wellnessScore,
      moodRating: moodRating ?? this.moodRating,
      energyRating: energyRating ?? this.energyRating,
      gratitudeEntry: gratitudeEntry ?? this.gratitudeEntry,
      realSteps: realSteps ?? this.realSteps,
    );
  }
}
