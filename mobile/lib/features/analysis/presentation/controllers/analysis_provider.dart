import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../exercise/data/models/exercise_model.dart';
import '../../../video/data/models/video_model.dart';
import '../../data/models/analysis_model.dart';
import '../../data/models/analysis_result_model.dart';
import '../../data/repositories/analysis_repository.dart';

enum AnalysisStepStatus {
  idle,
  uploading,
  processing,
  completed,
  error,
}

/// State controller for the end-to-end video analysis pipeline.
class AnalysisProvider extends ChangeNotifier {
  final AnalysisRepository _analysisRepository;

  ExerciseModel? _selectedExercise;
  VideoModel? _selectedVideo;
  AnalysisStepStatus _status = AnalysisStepStatus.idle;
  String _currentStage = 'Ready to analyze';
  double _progress = 0.0;
  AnalysisModel? _completedAnalysis;
  AnalysisResultModel? _result;
  String? _errorMessage;

  AnalysisProvider({required AnalysisRepository analysisRepository})
      : _analysisRepository = analysisRepository;

  ExerciseModel? get selectedExercise => _selectedExercise;
  VideoModel? get selectedVideo => _selectedVideo;
  AnalysisStepStatus get status => _status;
  String get currentStage => _currentStage;
  double get progress => _progress;
  AnalysisModel? get completedAnalysis => _completedAnalysis;
  AnalysisResultModel? get result => _result;
  String? get errorMessage => _errorMessage;

  bool get isProcessing =>
      _status == AnalysisStepStatus.uploading || _status == AnalysisStepStatus.processing;

  void selectExercise(ExerciseModel exercise) {
    _selectedExercise = exercise;
    notifyListeners();
  }

  void setVideo(VideoModel video) {
    _selectedVideo = video;
    notifyListeners();
  }

  void clearVideo() {
    _selectedVideo = null;
    notifyListeners();
  }

  void reset() {
    _status = AnalysisStepStatus.idle;
    _currentStage = 'Ready to analyze';
    _progress = 0.0;
    _completedAnalysis = null;
    _result = null;
    _errorMessage = null;
    _selectedVideo = null;
    notifyListeners();
  }

  /// Starts the upload and AI processing stages.
  Future<bool> startAnalysis() async {
    if (_selectedVideo == null || _selectedExercise == null) {
      _errorMessage = 'Please choose an exercise and select a valid video first.';
      _status = AnalysisStepStatus.error;
      notifyListeners();
      return false;
    }

    _status = AnalysisStepStatus.uploading;
    _currentStage = 'Uploading video...';
    _progress = 0.1;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload video
      final uploadedVideo = await _analysisRepository.uploadVideo(
        filePath: _selectedVideo!.path,
        exerciseType: _selectedExercise!.id,
        onProgress: (p) {
          _progress = 0.1 + (p * 0.3); // Upload accounts for 10% - 40%
          notifyListeners();
        },
      );
      _selectedVideo = uploadedVideo;

      // 2. Request AI Analysis
      _status = AnalysisStepStatus.processing;
      _currentStage = 'Preparing biomechanical pipeline...';
      _progress = 0.45;
      notifyListeners();

      final analysis = await _analysisRepository.requestAnalysis(
        videoId: uploadedVideo.id ?? 1,
        onStageUpdate: (stage, stageProgress) {
          _currentStage = stage;
          _progress = 0.4 + (stageProgress * 0.55);
          notifyListeners();
        },
      );

      _completedAnalysis = analysis;

      // 3. Fetch detailed result
      _currentStage = 'Synthesizing feedback...';
      _progress = 0.95;
      notifyListeners();

      final detailedResult = await _analysisRepository.getAnalysisResult(analysis.id);
      _result = detailedResult;

      _progress = 1.0;
      _currentStage = 'Analysis complete!';
      _status = AnalysisStepStatus.completed;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _status = AnalysisStepStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Analysis failed to complete. Please try again.';
      _status = AnalysisStepStatus.error;
      notifyListeners();
      return false;
    }
  }
}
