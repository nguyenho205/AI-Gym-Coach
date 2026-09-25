import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../video/data/models/video_model.dart';
import '../models/analysis_model.dart';
import '../models/analysis_result_model.dart';
import 'analysis_repository.dart';

/// Production implementation of [AnalysisRepository].
/// Communicates with FastAPI backend, which orchestrates MediaPipe/ST-GCN AI inference.
class RemoteAnalysisRepository implements AnalysisRepository {
  final ApiClient _apiClient;

  RemoteAnalysisRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<VideoModel> uploadVideo({
    required String filePath,
    required String exerciseType,
    void Function(double progress)? onProgress,
  }) async {
    final response = await _apiClient.uploadMultipartVideo(
      endpoint: ApiEndpoints.videoUpload,
      filePath: filePath,
      exerciseType: exerciseType,
      onProgress: onProgress,
    );

    final map = response is Map<String, dynamic> ? response : <String, dynamic>{};
    return VideoModel.fromJson(map);
  }

  @override
  Future<AnalysisModel> requestAnalysis({
    required int videoId,
    void Function(String stage, double progress)? onStageUpdate,
  }) async {
    onStageUpdate?.call('Preparing analysis...', 0.25);
    final response = await _apiClient.post(
      ApiEndpoints.analysis,
      body: {'video_id': videoId},
    );

    onStageUpdate?.call('AI processing completed', 1.0);
    final map = response is Map<String, dynamic> ? response : <String, dynamic>{};
    return AnalysisModel.fromJson(map);
  }

  @override
  Future<AnalysisResultModel> getAnalysisResult(int analysisId) async {
    final response = await _apiClient.get(ApiEndpoints.analysisDetail(analysisId));
    final map = response is Map<String, dynamic> ? response : <String, dynamic>{};
    return AnalysisResultModel.fromJson(map, isDemo: false);
  }

  @override
  Future<List<AnalysisModel>> getAnalysisHistory() async {
    final response = await _apiClient.get(ApiEndpoints.history);
    List<dynamic> items = [];
    if (response is List) {
      items = response;
    } else if (response is Map<String, dynamic> && response['data'] is List) {
      items = response['data'] as List;
    }

    return items
        .map((item) => AnalysisModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteAnalysis(int analysisId) async {
    await _apiClient.delete(ApiEndpoints.historyItem(analysisId));
  }
}
