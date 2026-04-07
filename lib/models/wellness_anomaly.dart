enum AnomalyType { warning, positive, info }

enum AnomalySeverity { low, medium, high }

class WellnessAnomaly {
  final String id;
  final AnomalyType type;
  final String title;
  final String message;
  final String metric;
  final AnomalySeverity severity;

  const WellnessAnomaly({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.metric,
    required this.severity,
  });
}
