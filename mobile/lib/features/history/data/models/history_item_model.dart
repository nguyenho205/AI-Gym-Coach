import 'package:ai_coach_gym/features/analysis/data/models/analysis_result_model.dart';

/// Historical workout analysis session item.
class HistoryItemModel {
  final int analysisId;
  final int? videoId;
  final String exercise;
  final int score;
  final int repCount;
  final String status;
  final DateTime createdAt;
  final AnalysisResultModel? detailedResult;

  const HistoryItemModel({
    required this.analysisId,
    this.videoId,
    required this.exercise,
    required this.score,
    required this.repCount,
    required this.status,
    required this.createdAt,
    this.detailedResult,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    AnalysisResultModel? result;
    if (json['result'] is Map<String, dynamic>) {
      result = AnalysisResultModel.fromJson(json['result'] as Map<String, dynamic>);
    } else if (json['score'] != null) {
      result = AnalysisResultModel.fromJson(json);
    }

    return HistoryItemModel(
      analysisId: json['analysis_id'] is int
          ? json['analysis_id'] as int
          : (json['id'] is int ? json['id'] as int : 0),
      videoId: json['video_id'] as int?,
      exercise: (json['exercise'] ?? json['exercise_type'] ?? 'Exercise') as String,
      score: (json['score'] as num?)?.toInt() ?? 0,
      repCount: (json['rep_count'] as num?)?.toInt() ?? (json['reps'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'completed') as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      detailedResult: result,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis_id': analysisId,
      'video_id': videoId,
      'exercise': exercise,
      'score': score,
      'rep_count': repCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'result': detailedResult?.toJson(),
    };
  }
}
