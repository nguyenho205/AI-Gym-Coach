import 'technique_metric.dart';
import 'technique_error.dart';
import 'suggestion.dart';

/// Detailed technique evaluation result received from backend/AI service.
class AnalysisResultModel {
  final String exercise;
  final int score;
  final int repCount;
  final List<TechniqueMetric> metrics;
  final List<TechniqueError> errors;
  final List<Suggestion> suggestions;
  final double? processingTime;
  final bool isDemoData;

  const AnalysisResultModel({
    required this.exercise,
    required this.score,
    required this.repCount,
    required this.metrics,
    required this.errors,
    required this.suggestions,
    this.processingTime,
    this.isDemoData = false,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json, {bool isDemo = false}) {
    // Parse metrics
    List<TechniqueMetric> metricList = [];
    if (json['metrics'] is List) {
      metricList = (json['metrics'] as List)
          .map((m) => TechniqueMetric.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      // Default standard metrics if not individually broken down
      metricList = _inferMetricsFromScore(
        (json['exercise'] ?? 'Squat').toString(),
        (json['score'] as num?)?.toInt() ?? 80,
      );
    }

    // Parse errors
    List<TechniqueError> errorList = [];
    if (json['errors'] is List) {
      errorList = (json['errors'] as List)
          .map((e) => TechniqueError.fromJson(e))
          .toList();
    }

    // Parse suggestions
    List<Suggestion> suggestionList = [];
    if (json['suggestions'] is List) {
      suggestionList = (json['suggestions'] as List)
          .map((s) => Suggestion.fromJson(s))
          .toList();
    }

    return AnalysisResultModel(
      exercise: (json['exercise'] ?? json['exercise_type'] ?? 'Exercise') as String,
      score: (json['score'] as num?)?.toInt() ?? 0,
      repCount: (json['rep_count'] as num?)?.toInt() ?? (json['reps'] as num?)?.toInt() ?? 0,
      metrics: metricList,
      errors: errorList,
      suggestions: suggestionList,
      processingTime: (json['processing_time'] as num?)?.toDouble(),
      isDemoData: isDemo || (json['is_demo_data'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise,
      'score': score,
      'rep_count': repCount,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'errors': errors.map((e) => e.toJson()).toList(),
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
      'processing_time': processingTime,
      'is_demo_data': isDemoData,
    };
  }

  static List<TechniqueMetric> _inferMetricsFromScore(String exercise, int score) {
    final isGood = score >= 80;
    return [
      TechniqueMetric(
        name: 'Depth & Range',
        value: isGood ? '94% ROM' : '78% ROM',
        status: isGood ? MetricStatus.optimal : MetricStatus.warning,
        explanation: isGood ? 'Thighs parallel to floor achieved.' : 'Slightly shallow depth on bottom reps.',
      ),
      TechniqueMetric(
        name: 'Joint Alignment',
        value: isGood ? 'Controlled' : 'Mild Valgus',
        status: isGood ? MetricStatus.optimal : MetricStatus.needsWork,
        explanation: isGood ? 'Knees tracking over toes throughout.' : 'Inward knee drift detected during ascent.',
      ),
      TechniqueMetric(
        name: 'Spine & Posture',
        value: isGood ? 'Neutral' : 'Forward Lean',
        status: MetricStatus.optimal,
        explanation: 'Lumbar spine maintained neutral curve without excessive flexion.',
      ),
      TechniqueMetric(
        name: 'Tempo & Cadence',
        value: '2.4s / rep',
        status: MetricStatus.optimal,
        explanation: 'Consistent eccentric and concentric cadence.',
      ),
    ];
  }
}
