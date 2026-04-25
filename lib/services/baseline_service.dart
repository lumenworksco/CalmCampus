import '../data/data_engine.dart';
import 'wellness_repository.dart';

class BaselineMetrics {
  final double avgSleep;
  final double avgScreenTime;
  final double avgWellness;
  final double avgFocus;
  final double avgMood;
  final int dataPoints;

  const BaselineMetrics({
    required this.avgSleep,
    required this.avgScreenTime,
    required this.avgWellness,
    required this.avgFocus,
    required this.avgMood,
    required this.dataPoints,
  });
}

class BaselineService {
  final WellnessRepository _repo;

  BaselineService(this._repo);

  /// Compute baseline metrics from the last 7 days.
  BaselineMetrics get7DayBaseline() => _computeBaseline(7);

  /// Compute baseline metrics from the last 30 days.
  BaselineMetrics get30DayBaseline() => _computeBaseline(30);

  BaselineMetrics _computeBaseline(int days) {
    final data = _repo.getRange(days);
    if (data.isEmpty) {
      return const BaselineMetrics(
        avgSleep: 0,
        avgScreenTime: 0,
        avgWellness: 0,
        avgFocus: 0,
        avgMood: double.nan,
        dataPoints: 0,
      );
    }

    final avgSleep =
        data.map((d) => d.sleepHours).reduce((a, b) => a + b) / data.length;
    final avgScreenTime =
        data.map((d) => d.screenTimeHours).reduce((a, b) => a + b) / data.length;
    final avgWellness =
        data.map((d) => d.wellnessScore).reduce((a, b) => a + b) / data.length;
    final avgFocus =
        data.map((d) => computeFocusScore(d.appSwitches).toDouble()).reduce((a, b) => a + b) /
            data.length;

    // For mood, only average non-null values
    final moodValues =
        data.where((d) => d.moodRating != null).map((d) => d.moodRating!.toDouble()).toList();
    final avgMood = moodValues.isEmpty
        ? double.nan
        : moodValues.reduce((a, b) => a + b) / moodValues.length;

    return BaselineMetrics(
      avgSleep: avgSleep,
      avgScreenTime: avgScreenTime,
      avgWellness: avgWellness,
      avgFocus: avgFocus,
      avgMood: avgMood,
      dataPoints: data.length,
    );
  }
}
