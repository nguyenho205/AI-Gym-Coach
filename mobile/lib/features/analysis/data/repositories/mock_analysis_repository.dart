import '../../../video/data/models/video_model.dart';
import '../models/analysis_model.dart';
import '../models/analysis_result_model.dart';
import '../models/suggestion.dart';
import '../models/technique_error.dart';
import '../models/technique_metric.dart';
import 'analysis_repository.dart';

/// Development and UI testing mock repository.
///
/// NOTE: This repository returns synthetic test fixtures for UI verification ONLY.
/// It is NOT connected to a trained AI model, MediaPipe, or ST-GCN.
/// All output is explicitly tagged with `isDemoData = true`.
class MockAnalysisRepository implements AnalysisRepository {
  final List<AnalysisModel> _inMemoryHistory = [];
  final bool simulatedDelay;
  int _analysisIdCounter = 101;

  MockAnalysisRepository({this.simulatedDelay = true}) {
    _seedInitialHistory();
  }

  void _seedInitialHistory() {
    _inMemoryHistory.addAll([
      AnalysisModel(
        id: 100,
        videoId: 12,
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        result: const AnalysisResultModel(
          exercise: 'Squat',
          score: 88,
          repCount: 12,
          isDemoData: true,
          processingTime: 3.12,
          metrics: [
            TechniqueMetric(
              name: 'Depth & Hip Crease',
              value: '94% Parallel',
              status: MetricStatus.optimal,
              explanation: 'Thighs reached parallel to the floor on 11 of 12 reps.',
            ),
            TechniqueMetric(
              name: 'Knee Alignment',
              value: 'Mild Valgus',
              status: MetricStatus.warning,
              explanation: 'Slight inward collapse detected during the concentric drive.',
            ),
            TechniqueMetric(
              name: 'Back Angle',
              value: '42° Incline',
              status: MetricStatus.optimal,
              explanation: 'Torso remained rigid and neutral without excessive lumbar rounding.',
            ),
            TechniqueMetric(
              name: 'Movement Tempo',
              value: '2.1s / rep',
              status: MetricStatus.optimal,
              explanation: 'Controlled 2-second eccentric phase maintained throughout.',
            ),
          ],
          errors: [
            TechniqueError(
              title: 'Knee Valgus on Ascent',
              description: 'Knees tended to drift inwards when driving out of the bottom position.',
              severity: 'medium',
            ),
            TechniqueError(
              title: 'Minor Heel Lift',
              description: 'Weight shifted slightly toward toes on the final 2 repetitions.',
              severity: 'low',
            ),
          ],
          suggestions: [
            Suggestion(
              title: 'Drive Knees Outward',
              description: 'Actively push knees outward over pinky toes during ascent.',
              focusArea: 'Knee Stability',
            ),
            Suggestion(
              title: 'Tripod Foot Pressure',
              description: 'Distribute pressure evenly across heel, big toe base, and pinky toe base.',
              focusArea: 'Base of Support',
            ),
          ],
        ),
      ),
      AnalysisModel(
        id: 99,
        videoId: 11,
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
        result: const AnalysisResultModel(
          exercise: 'Push-up',
          score: 76,
          repCount: 15,
          isDemoData: true,
          processingTime: 2.85,
          metrics: [
            TechniqueMetric(
              name: 'Elbow Flare Angle',
              value: '68° Angle',
              status: MetricStatus.warning,
              explanation: 'Elbows flared beyond the recommended 45° angle on later reps.',
            ),
            TechniqueMetric(
              name: 'Plank Alignment',
              value: 'Stable Core',
              status: MetricStatus.optimal,
              explanation: 'Straight line maintained from head to heels.',
            ),
            TechniqueMetric(
              name: 'Chest Proximity',
              value: '82% Depth',
              status: MetricStatus.needsWork,
              explanation: 'Did not touch chest to hover position on last 4 reps.',
            ),
          ],
          errors: [
            TechniqueError(
              title: 'Excessive Elbow Flare',
              description: 'Elbows drifted wide, increasing strain on anterior shoulder capsule.',
              severity: 'medium',
            ),
          ],
          suggestions: [
            Suggestion(
              title: 'Arrowhead Arm Position',
              description: 'Keep elbows tucked at a 45-degree angle relative to torso.',
              focusArea: 'Shoulder Health',
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  Future<VideoModel> uploadVideo({
    required String filePath,
    required String exerciseType,
    void Function(double progress)? onProgress,
  }) async {
    // Simulate chunked upload progress
    if (simulatedDelay) {
      for (int i = 1; i <= 5; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        onProgress?.call(i / 5.0);
      }
    } else {
      onProgress?.call(1.0);
    }

    return VideoModel(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      path: filePath,
      fileName: filePath.split(RegExp(r'[\\/]')).last,
      fileSizeBytes: 15 * 1024 * 1024,
      durationSeconds: 24,
      exerciseType: exerciseType,
      selectedAt: DateTime.now(),
    );
  }

  @override
  Future<AnalysisModel> requestAnalysis({
    required int videoId,
    void Function(String stage, double progress)? onStageUpdate,
  }) async {
    final stages = [
      ('Uploading video to processing queue...', 0.2),
      ('Preparing biomechanical pipeline...', 0.4),
      ('Detecting 33 body keypoints...', 0.65),
      ('Evaluating movement kinematics...', 0.85),
      ('Synthesizing technique feedback...', 1.0),
    ];

    if (simulatedDelay) {
      for (final stage in stages) {
        await Future.delayed(const Duration(milliseconds: 400));
        onStageUpdate?.call(stage.$1, stage.$2);
      }
    } else {
      for (final stage in stages) {
        onStageUpdate?.call(stage.$1, stage.$2);
      }
    }

    final newId = ++_analysisIdCounter;
    final newAnalysis = AnalysisModel(
      id: newId,
      videoId: videoId,
      status: 'completed',
      createdAt: DateTime.now(),
      result: _generateSampleResult('Squat'),
    );

    _inMemoryHistory.insert(0, newAnalysis);
    return newAnalysis;
  }

  @override
  Future<AnalysisResultModel> getAnalysisResult(int analysisId) async {
    if (simulatedDelay) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    final match = _inMemoryHistory.where((a) => a.id == analysisId).firstOrNull;
    if (match != null && match.result != null) {
      return match.result!;
    }
    return _generateSampleResult('Squat');
  }

  @override
  Future<List<AnalysisModel>> getAnalysisHistory() async {
    if (simulatedDelay) {
      await Future.delayed(const Duration(milliseconds: 400));
    }
    return List.unmodifiable(_inMemoryHistory);
  }

  @override
  Future<void> deleteAnalysis(int analysisId) async {
    if (simulatedDelay) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    _inMemoryHistory.removeWhere((a) => a.id == analysisId);
  }

  AnalysisResultModel _generateSampleResult(String exercise) {
    return AnalysisResultModel(
      exercise: exercise,
      score: 85,
      repCount: 10,
      processingTime: 3.12,
      isDemoData: true,
      metrics: const [
        TechniqueMetric(
          name: 'Movement Range (ROM)',
          value: '92% Optimal',
          status: MetricStatus.optimal,
          explanation: 'Target joint angles achieved through eccentric descent.',
        ),
        TechniqueMetric(
          name: 'Joint Symmetry',
          value: 'Balanced',
          status: MetricStatus.optimal,
          explanation: 'Even bilateral loading across left and right sides.',
        ),
        TechniqueMetric(
          name: 'Core Stability',
          value: 'Mild Flexion',
          status: MetricStatus.warning,
          explanation: 'Minor spinal flexion observed under fatigue.',
        ),
        TechniqueMetric(
          name: 'Execution Tempo',
          value: '2.4s / rep',
          status: MetricStatus.optimal,
          explanation: 'Steady cadence without bouncing or abrupt rebounds.',
        ),
      ],
      errors: const [
        TechniqueError(
          title: 'Slight Anterior Tilt',
          description: 'Pelvis rotated slightly forward at the deepest point of movement.',
          severity: 'low',
        ),
      ],
      suggestions: const [
        Suggestion(
          title: 'Brace Core Before Descent',
          description: 'Inhale into your diaphragm and brace your abs like preparing for impact.',
          focusArea: 'Core Rigidity',
        ),
        Suggestion(
          title: 'Maintain Gaze Ahead',
          description: 'Avoid looking directly down; keep head in line with spine.',
          focusArea: 'Cervical Spine',
        ),
      ],
    );
  }
}
