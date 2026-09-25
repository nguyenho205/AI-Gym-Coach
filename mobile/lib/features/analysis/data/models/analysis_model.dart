import 'analysis_result_model.dart';

/// Top-level analysis session entity matching backend schema.
class AnalysisModel {
  final int id;
  final int videoId;
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final DateTime createdAt;
  final AnalysisResultModel? result;

  const AnalysisModel({
    required this.id,
    required this.videoId,
    required this.status,
    required this.createdAt,
    this.result,
  });

  // Convenience getters for UI display
  int get score => result?.score ?? 0;
  int get repCount => result?.repCount ?? 0;
  String get exercise => result?.exercise ?? 'Exercise';

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    AnalysisResultModel? resultObj;
    if (json['result'] is Map<String, dynamic>) {
      resultObj = AnalysisResultModel.fromJson(json['result'] as Map<String, dynamic>);
    } else if (json['score'] != null) {
      resultObj = AnalysisResultModel.fromJson(json);
    }

    return AnalysisModel(
      id: json['analysis_id'] is int
          ? json['analysis_id'] as int
          : (json['id'] is int ? json['id'] as int : 0),
      videoId: json['video_id'] is int ? json['video_id'] as int : 0,
      status: (json['status'] ?? 'completed') as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      result: resultObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis_id': id,
      'video_id': videoId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'result': result?.toJson(),
    };
  }
}
