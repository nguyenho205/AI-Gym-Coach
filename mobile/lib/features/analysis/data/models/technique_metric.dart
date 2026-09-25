/// Evaluation status for an individual biomechanical technique metric.
enum MetricStatus {
  optimal,
  needsWork,
  warning;

  static MetricStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'optimal':
      case 'good':
      case 'passed':
        return MetricStatus.optimal;
      case 'warning':
      case 'moderate':
      case 'caution':
        return MetricStatus.warning;
      case 'needswork':
      case 'needs_work':
      case 'poor':
      case 'failed':
      default:
        return MetricStatus.needsWork;
    }
  }

  String get displayName {
    switch (this) {
      case MetricStatus.optimal:
        return 'Optimal';
      case MetricStatus.needsWork:
        return 'Needs Work';
      case MetricStatus.warning:
        return 'Caution';
    }
  }
}

/// Biomechanical technique metric (e.g., Depth, Knee Alignment, Back Angle, Tempo).
class TechniqueMetric {
  final String name;
  final String value;
  final MetricStatus status;
  final String explanation;

  const TechniqueMetric({
    required this.name,
    required this.value,
    required this.status,
    required this.explanation,
  });

  factory TechniqueMetric.fromJson(Map<String, dynamic> json) {
    return TechniqueMetric(
      name: (json['name'] ?? json['metric'] ?? '') as String,
      value: (json['value'] ?? '') as String,
      status: MetricStatus.fromString(json['status'] as String?),
      explanation: (json['explanation'] ?? json['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'status': status.name,
      'explanation': explanation,
    };
  }
}
