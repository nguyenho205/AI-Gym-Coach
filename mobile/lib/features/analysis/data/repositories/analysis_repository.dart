import '../models/analysis_model.dart';
import '../models/analysis_result_model.dart';
import '../../../video/data/models/video_model.dart';

/// Abstract contract for video upload and AI technique analysis.
/// Completely decouples the Flutter presentation layer from the AI inference engine.
abstract class AnalysisRepository {
  /// Uploads video file to backend and returns the uploaded [VideoModel] with `video_id`.
  Future<VideoModel> uploadVideo({
    required String filePath,
    required String exerciseType,
    void Function(double progress)? onProgress,
  });

  /// Requests AI technique evaluation for an uploaded video.
  Future<AnalysisModel> requestAnalysis({
    required int videoId,
    void Function(String stage, double progress)? onStageUpdate,
  });

  /// Fetches the detailed analysis evaluation for a given analysis ID.
  Future<AnalysisResultModel> getAnalysisResult(int analysisId);

  /// Fetches all analyses for the current user.
  Future<List<AnalysisModel>> getAnalysisHistory();

  /// Deletes a specific analysis record.
  Future<void> deleteAnalysis(int analysisId);
}
