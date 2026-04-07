enum SignalTrend { up, down, stable }

class BehavioralSignal {
  final String id;
  final String label;
  final String value;
  final String unit;
  final SignalTrend trend;
  final bool trendIsGood;
  final String icon;
  final bool isLive;

  const BehavioralSignal({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    required this.trend,
    required this.trendIsGood,
    required this.icon,
    this.isLive = false,
  });
}
