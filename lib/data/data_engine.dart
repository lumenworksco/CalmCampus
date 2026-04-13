import '../models/daily_data.dart';
import '../models/behavioral_signal.dart';
import '../models/wellness_anomaly.dart';

const _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

// Mulberry32 seeded PRNG
typedef _Rng = double Function();

_Rng _seededRandom(int seed) {
  int s = seed;
  return () {
    s |= 0;
    s = (s + 0x6D2B79F5) | 0;
    int t = (s ^ (s >> 15)) * (1 | s);
    t = (t + (t ^ (t >> 7)) * (61 | t)) ^ t;
    return ((t ^ (t >> 14)) & 0x7FFFFFFF) / 0x7FFFFFFF;
  };
}

int _dateSeed(String dateStr) {
  int hash = 0;
  for (int i = 0; i < dateStr.length; i++) {
    hash = ((hash << 5) - hash) + dateStr.codeUnitAt(i);
    hash &= 0x7FFFFFFF;
  }
  return hash.abs();
}

double _clamp(double val, double lo, double hi) => val.clamp(lo, hi);
double _round1(double val) => (val * 10).round() / 10;

DailyData _generateDay(DateTime date) {
  final dateStr =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final rand = _seededRandom(_dateSeed(dateStr));
  final dow = date.weekday % 7; // 0=Sun in JS, Dart weekday 7=Sun

  const stressByDay = <int, double>{
    0: 0.1, // Sun
    1: 0.3, // Mon
    2: 0.5, // Tue
    3: 0.7, // Wed
    4: 0.8, // Thu
    5: 0.5, // Fri
    6: 0.15, // Sat
  };
  final stress = stressByDay[dow] ?? 0.5;
  final noise = (rand() - 0.5) * 0.3;
  final effectiveStress = _clamp(stress + noise, 0, 1);
  final isBadDay = rand() < 0.10;
  final totalStress = _clamp(effectiveStress + (isBadDay ? 0.3 : 0), 0, 1);

  final sleepBase = 8.5 - totalStress * 4.0;
  final sleepHours = _round1(_clamp(sleepBase + (rand() - 0.5) * 0.8, 4.0, 9.5));

  final screenBase = 2.5 + totalStress * 5.5;
  final screenTimeHours = _round1(_clamp(screenBase + (rand() - 0.5) * 1.0, 1.5, 9.0));

  // Active minutes: higher stress → less activity
  final activityBase = 50 - totalStress * 40;
  final activeMinutes = _clamp(activityBase + (rand() - 0.5) * 20, 5, 90).round();

  final switchBase = 8 + totalStress * 27;
  final appSwitches = _clamp(switchBase + (rand() - 0.5) * 6, 5, 40).round();

  final sleepScore = _clamp((sleepHours - 4) / 5, 0, 1);
  final screenScore = _clamp(1 - (screenTimeHours - 1.5) / 7, 0, 1);
  final activityScore = _clamp((activeMinutes - 5) / 85, 0, 1);
  final focusScore = _clamp(1 - (appSwitches - 5) / 30, 0, 1);

  final rawWellness =
      (sleepScore * 0.30 + screenScore * 0.25 + activityScore * 0.20 + focusScore * 0.25) * 100;
  final wellnessScore = _clamp(rawWellness + (rand() - 0.5) * 6, 10, 98).round();

  return DailyData(
    date: dateStr,
    dayLabel: _dayNames[dow],
    dayOfWeek: dow,
    sleepHours: sleepHours,
    screenTimeHours: screenTimeHours,
    activeMinutes: activeMinutes,
    appSwitches: appSwitches,
    wellnessScore: wellnessScore,
  );
}

/// Public wrapper to generate synthetic data for an arbitrary date.
DailyData generateForDate(DateTime date) => _generateDay(date);

/// Compute focus score (0-100) from app switch count.
/// Higher switches = lower focus. Capped at 40 switches = 0%.
int computeFocusScore(int appSwitches) =>
    (100 - (appSwitches / 40 * 100)).round().clamp(0, 100);

List<DailyData> getWeeklyData({int days = 7}) {
  final now = DateTime.now();
  return List.generate(days, (i) {
    return _generateDay(now.subtract(Duration(days: days - 1 - i)));
  });
}

DailyData getTodayData() => _generateDay(DateTime.now());

List<BehavioralSignal> getTodaySignals({DailyData? todayOverride}) {
  final today = todayOverride ?? getTodayData();
  final yesterday = _generateDay(DateTime.now().subtract(const Duration(days: 1)));

  SignalTrend trend(double a, double b) {
    if (a > b) return SignalTrend.up;
    if (a < b) return SignalTrend.down;
    return SignalTrend.stable;
  }

  return [
    BehavioralSignal(
      id: 'sleep',
      label: 'Sleep',
      value: today.sleepHours.toStringAsFixed(1),
      unit: 'hours',
      trend: trend(today.sleepHours, yesterday.sleepHours),
      trendIsGood: today.sleepHours >= 7,
      icon: 'moon',
    ),
    BehavioralSignal(
      id: 'screen',
      label: 'Screen Time',
      value: today.screenTimeHours.toStringAsFixed(1),
      unit: 'hours',
      trend: trend(today.screenTimeHours, yesterday.screenTimeHours),
      trendIsGood: today.screenTimeHours <= 5,
      icon: 'phone',
    ),
    BehavioralSignal(
      id: 'movement',
      label: 'Active Minutes',
      value: today.activeMinutes.toString(),
      unit: 'min',
      trend: trend(today.activeMinutes.toDouble(), yesterday.activeMinutes.toDouble()),
      trendIsGood: today.activeMinutes >= 30,
      icon: 'walk',
    ),
    BehavioralSignal(
      id: 'focus',
      label: 'Focus Score',
      value: computeFocusScore(today.appSwitches).toString(),
      unit: '%',
      trend: trend(yesterday.appSwitches.toDouble(), today.appSwitches.toDouble()),
      trendIsGood: today.appSwitches <= 15,
      icon: 'target',
    ),
  ];
}


/// Enhanced today data that overlays real sensor data on the synthetic baseline.
///
/// Real values replace their synthetic counterparts, then the wellness score is
/// recalculated from the (possibly real) inputs.
DailyData getEnhancedTodayData({
  int? realSteps,
  int? moodRating,
  double? realSleepHours,
  double? realScreenTimeHours,
  int? realActiveMinutes,
  int? realAppCount,
}) {
  var base = getTodayData();

  // Overlay real sensor data onto synthetic baseline.
  base = base.copyWith(
    sleepHours: realSleepHours ?? base.sleepHours,
    screenTimeHours: realScreenTimeHours ?? base.screenTimeHours,
    activeMinutes: realActiveMinutes ?? base.activeMinutes,
    appSwitches: realAppCount ?? base.appSwitches,
    moodRating: moodRating,
    realSteps: realSteps,
  );

  final score = calculateWellnessScore(base, realSteps: realSteps);
  return base.copyWith(wellnessScore: score);
}

/// Calculate wellness score from the four behavioral signals.
///
/// Weights: sleep 0.30, screen time 0.25, activity 0.20, focus 0.25.
/// Optional [realSteps] and [DailyData.moodRating] add bonuses / penalties.
int calculateWellnessScore(DailyData data, {int? realSteps}) {
  final sleepScore = _clamp((data.sleepHours - 4) / 5, 0, 1);
  final screenScore = _clamp(1 - (data.screenTimeHours - 1.5) / 7, 0, 1);
  final activityScore = _clamp((data.activeMinutes - 5) / 85, 0, 1);
  final focusScore = _clamp(1 - (data.appSwitches - 5) / 30, 0, 1);

  double raw =
      (sleepScore * 0.30 + screenScore * 0.25 + activityScore * 0.20 + focusScore * 0.25) * 100;

  // Step bonus
  final steps = realSteps ?? data.realSteps;
  if (steps != null) {
    if (steps >= 8000) {
      raw += 5;
    } else if (steps >= 5000) {
      raw += 3;
    } else if (steps >= 2000) {
      raw += 1;
    } else {
      raw -= 3;
    }
  }

  // Mood adjustment
  if (data.moodRating != null) {
    raw += _moodAdjustment(data.moodRating!);
  }

  return raw.round().clamp(10, 98);
}

/// Returns a wellness score adjustment based on mood rating (1-5).
/// Mood 1 = -8, Mood 2 = -5, Mood 3 = 0, Mood 4 = +3, Mood 5 = +5
int _moodAdjustment(int moodRating) {
  switch (moodRating) {
    case 1:
      return -8;
    case 2:
      return -5;
    case 3:
      return 0;
    case 4:
      return 3;
    case 5:
      return 5;
    default:
      return 0;
  }
}

/// Detect anomalies by comparing today's data against the 7-day rolling average.
/// Returns a list of anomaly/warning objects for display in the UI.
///
/// If [history] is provided, it will be used for computing averages instead of
/// regenerating synthetic data. The last entry in [history] is treated as today.
/// If [history] is null, falls back to existing behavior using [getWeeklyData].
List<WellnessAnomaly> detectAnomalies({List<DailyData>? history}) {
  final week = history ?? getWeeklyData();
  if (week.isEmpty) return [];
  final today = week.last;
  final anomalies = <WellnessAnomaly>[];

  // Compute 7-day averages
  final avgSleep = week.map((d) => d.sleepHours).reduce((a, b) => a + b) / week.length;
  final avgScreen = week.map((d) => d.screenTimeHours).reduce((a, b) => a + b) / week.length;
  final avgWellness = week.map((d) => d.wellnessScore).reduce((a, b) => a + b) / week.length;
  final avgFocus =
      week.map((d) => computeFocusScore(d.appSwitches).toDouble()).reduce((a, b) => a + b) / week.length;

  // Sleep < 6h absolute warning
  if (today.sleepHours < 6) {
    anomalies.add(WellnessAnomaly(
      id: 'sleep-low',
      type: AnomalyType.warning,
      title: 'Low sleep detected',
      message:
          'You logged ${today.sleepHours}h of sleep. Aim for at least 7 hours to support recovery.',
      metric: 'sleep',
      severity: today.sleepHours < 5 ? AnomalySeverity.high : AnomalySeverity.medium,
    ));
  }

  // Sleep dropped > 1.5h from average
  if (avgSleep - today.sleepHours > 1.5) {
    anomalies.add(WellnessAnomaly(
      id: 'sleep-drop',
      type: AnomalyType.warning,
      title: 'Sleep dropped significantly',
      message:
          'Your sleep is ${_round1(avgSleep - today.sleepHours)}h below your weekly average of ${_round1(avgSleep)}h.',
      metric: 'sleep',
      severity: AnomalySeverity.medium,
    ));
  }

  // Screen time > 6h absolute warning
  if (today.screenTimeHours > 6) {
    anomalies.add(WellnessAnomaly(
      id: 'screen-high',
      type: AnomalyType.warning,
      title: 'High screen time',
      message:
          'Screen time is at ${today.screenTimeHours}h today. Consider taking a break from devices.',
      metric: 'screenTime',
      severity: today.screenTimeHours > 7.5 ? AnomalySeverity.high : AnomalySeverity.medium,
    ));
  }

  // Screen time jumped > 2h above average
  if (today.screenTimeHours - avgScreen > 2) {
    anomalies.add(WellnessAnomaly(
      id: 'screen-spike',
      type: AnomalyType.warning,
      title: 'Screen time spike',
      message:
          'Screen time is ${_round1(today.screenTimeHours - avgScreen)}h above your weekly average of ${_round1(avgScreen)}h.',
      metric: 'screenTime',
      severity: AnomalySeverity.medium,
    ));
  }

  // Wellness score < 50 (high warning)
  if (today.wellnessScore < 50) {
    anomalies.add(WellnessAnomaly(
      id: 'wellness-low',
      type: AnomalyType.warning,
      title: 'Wellness score is low',
      message:
          'Your score of ${today.wellnessScore} is below the healthy range. Focus on sleep and reducing screen time.',
      metric: 'wellness',
      severity: AnomalySeverity.high,
    ));
  }

  // Wellness improving trend (last 3 days rising)
  if (week.length >= 3) {
    final last3 = week.sublist(week.length - 3);
    final isImproving = last3[2].wellnessScore > last3[1].wellnessScore &&
        last3[1].wellnessScore > last3[0].wellnessScore;
    if (isImproving && today.wellnessScore > avgWellness) {
      anomalies.add(const WellnessAnomaly(
        id: 'wellness-improving',
        type: AnomalyType.positive,
        title: 'Wellness is trending up',
        message: 'Your score has been rising over the past 3 days. Keep up the good habits.',
        metric: 'wellness',
        severity: AnomalySeverity.low,
      ));
    }
  }

  // Low mood warning
  if (today.moodRating != null && today.moodRating! <= 2) {
    anomalies.add(WellnessAnomaly(
      id: 'mood-low',
      type: AnomalyType.warning,
      title: 'Low mood reported',
      message:
          'You rated your mood ${today.moodRating}/5. Consider a breathing exercise or reaching out to someone.',
      metric: 'mood',
      severity: today.moodRating == 1 ? AnomalySeverity.high : AnomalySeverity.medium,
    ));
  }

  // Focus score dropping (today vs average)
  final todayFocus = computeFocusScore(today.appSwitches).toDouble();
  if (avgFocus - todayFocus > 15) {
    anomalies.add(WellnessAnomaly(
      id: 'focus-drop',
      type: AnomalyType.info,
      title: 'Focus score is lower than usual',
      message:
          'Your focus is ${(avgFocus - todayFocus).round()} points below your weekly average. Try minimizing app switching.',
      metric: 'focus',
      severity: AnomalySeverity.low,
    ));
  }

  return anomalies;
}

/// Generate a smart insight that references step data, anomalies, and weekly trends.
/// Replaces [getWeeklyInsight] with richer, more contextual output.
///
/// If [history] is provided, it will be used instead of regenerating synthetic data.
/// The last entry in [history] is treated as today.
String getSmartInsight({int? realSteps, List<DailyData>? history}) {
  final week = history ?? getWeeklyData();
  if (week.isEmpty) return 'No data available yet.';
  final today = week.last;
  final avgSleep = week.map((d) => d.sleepHours).reduce((a, b) => a + b) / week.length;
  final avgScreen = week.map((d) => d.screenTimeHours).reduce((a, b) => a + b) / week.length;
  final worstDay = week.reduce((a, b) => a.wellnessScore < b.wellnessScore ? a : b);
  final bestDay = week.reduce((a, b) => a.wellnessScore > b.wellnessScore ? a : b);
  final scoreTrend = today.wellnessScore - week.first.wellnessScore;
  final anomalies = detectAnomalies(history: history);
  final warningCount = anomalies.where((a) => a.type == AnomalyType.warning).length;

  // Step-based context
  final steps = realSteps ?? today.realSteps;
  var stepContext = '';
  if (steps != null) {
    final formatted = _formatNumber(steps);
    if (steps >= 8000) {
      stepContext = " You've walked $formatted steps today — excellent activity level.";
    } else if (steps >= 5000) {
      stepContext = " With $formatted steps so far, you're moderately active. Try to reach 8,000.";
    } else if (steps >= 2000) {
      stepContext =
          " You're at $formatted steps — a short walk could boost your mood and focus.";
    } else {
      stepContext =
          ' Only $formatted steps recorded. Physical activity strongly correlates with better sleep and focus.';
    }
  }

  // Mood-based context
  var moodContext = '';
  if (today.moodRating != null) {
    if (today.moodRating! <= 2) {
      moodContext = ' Your self-reported mood is low — be gentle with yourself today.';
    } else if (today.moodRating! >= 4) {
      moodContext = ' Great to see your mood is positive today.';
    }
  }

  // Priority-ordered insight selection
  if (warningCount >= 2) {
    final metrics =
        anomalies.where((a) => a.type == AnomalyType.warning).map((a) => a.metric).join(', ');
    return 'Multiple areas need attention today: $metrics. Small improvements in any one area can lift your overall wellbeing.$moodContext$stepContext';
  }
  if (today.sleepHours < 6) {
    return 'You slept only ${today.sleepHours}h last night. Sleep deprivation compounds — even one recovery night helps. Consider winding down earlier tonight.$moodContext$stepContext';
  }
  if (today.screenTimeHours > 6) {
    return 'Screen time is elevated at ${today.screenTimeHours}h today. Try the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds.$moodContext$stepContext';
  }
  if (today.wellnessScore < 50) {
    return 'Your wellness score is ${today.wellnessScore} today. ${worstDay.dayLabel} was your toughest day this week at ${worstDay.wellnessScore}. Focus on one improvement — sleep or screen time — to recover.$moodContext$stepContext';
  }
  if (avgSleep < 6.5) {
    return 'Your average sleep this week is ${_round1(avgSleep)}h — below the recommended 7-9h. Sleep is the strongest predictor of next-day wellbeing in students.$moodContext$stepContext';
  }
  if (scoreTrend > 10) {
    return 'Your wellness trend is improving (+$scoreTrend points since ${week.first.dayLabel}). Keep maintaining your current routine — consistency is key.$moodContext$stepContext';
  }
  if (avgScreen > 5.5) {
    return 'Average screen time is ${_round1(avgScreen)}h this week. Consider setting app timers for your most-used apps to stay mindful of usage.$moodContext$stepContext';
  }
  if (anomalies.any((a) => a.type == AnomalyType.positive)) {
    return 'Great progress — your wellness has been improving steadily. ${bestDay.dayLabel} was your best day at ${bestDay.wellnessScore}. Keep up the momentum.$moodContext$stepContext';
  }
  return 'Your wellness has been ${today.wellnessScore >= 70 ? 'steady' : 'variable'} this week. ${bestDay.dayLabel} was your strongest day at ${bestDay.wellnessScore}. Keep prioritizing sleep and breaks.$moodContext$stepContext';
}

String _formatNumber(int n) {
  if (n < 1000) return n.toString();
  final thousands = n ~/ 1000;
  final remainder = n % 1000;
  if (remainder == 0) return '$thousands,000';
  return '$thousands,${remainder.toString().padLeft(3, '0')}';
}
