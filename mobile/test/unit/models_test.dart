import 'package:flutter_test/flutter_test.dart';
import 'package:ai_coach_gym/features/auth/data/models/auth_response_model.dart';
import 'package:ai_coach_gym/features/auth/data/models/user_model.dart';
import 'package:ai_coach_gym/features/exercise/data/models/exercise_model.dart';
import 'package:ai_coach_gym/features/video/data/models/video_model.dart';
import 'package:ai_coach_gym/features/analysis/data/models/analysis_result_model.dart';
import 'package:ai_coach_gym/features/history/data/models/history_item_model.dart';

void main() {
  group('UserModel Serialization', () {
    test('parses from standard backend json and serializes back', () {
      final json = {
        'id': 101,
        'full_name': 'Sarah Connor',
        'email': 'sarah@resistance.org',
        'avatar_url': 'https://example.com/avatar.jpg',
        'gender': 'Female',
        'height_cm': 172.0,
        'weight_kg': 63.5,
        'created_at': '2026-03-15T10:00:00.000Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 101);
      expect(user.fullName, 'Sarah Connor');
      expect(user.email, 'sarah@resistance.org');
      expect(user.gender, 'Female');
      expect(user.heightCm, 172.0);
      expect(user.weightKg, 63.5);

      final encoded = user.toJson();
      expect(encoded['id'], 101);
      expect(encoded['full_name'], 'Sarah Connor');
    });

    test('supports user_id alias and null fields gracefully', () {
      final json = {
        'user_id': 202,
        'name': 'Kyle Reese',
        'email': 'kyle@resistance.org',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 202);
      expect(user.fullName, 'Kyle Reese');
      expect(user.heightCm, isNull);
    });
  });

  group('AuthResponse Serialization', () {
    test('parses login response successfully', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'access_token': 'jwt.token.here',
        'token_type': 'Bearer',
      };

      final response = AuthResponse.fromJson(json);
      expect(response.success, isTrue);
      expect(response.accessToken, 'jwt.token.here');
      expect(response.tokenType, 'Bearer');
    });
  });

  group('ExerciseModel', () {
    test('contains supported exercises: Squat, Push-up, Bicep Curl', () {
      final exercises = ExerciseModel.supportedExercises;
      expect(exercises.length, 3);
      expect(exercises.map((e) => e.id), containsAll(['squat', 'push_up', 'bicep_curl']));
    });

    test('parses exercise from json', () {
      final json = {
        'id': 'squat',
        'name': 'Back Squat',
        'description': 'Lower body exercise',
        'technique_focus': 'Analyze depth and knees',
        'target_keypoints': ['Hips', 'Knees'],
      };

      final model = ExerciseModel.fromJson(json);
      expect(model.id, 'squat');
      expect(model.name, 'Back Squat');
      expect(model.targetKeypoints, contains('Knees'));
    });
  });

  group('VideoModel Validation', () {
    test('validates format constraints', () {
      expect(
        VideoModel.validateVideo(
          filePath: 'test.avi',
          fileSizeBytes: 1024,
          durationSeconds: 15,
        ),
        contains('Unsupported format'),
      );

      expect(
        VideoModel.validateVideo(
          filePath: 'test.mp4',
          fileSizeBytes: 1024,
          durationSeconds: 15,
        ),
        isNull,
      );
    });

    test('validates duration constraints (max 60 seconds)', () {
      expect(
        VideoModel.validateVideo(
          filePath: 'test.mp4',
          fileSizeBytes: 1024,
          durationSeconds: 75,
        ),
        contains('Maximum allowed duration is 60 seconds'),
      );
    });

    test('validates file size constraints (max 100 MB)', () {
      expect(
        VideoModel.validateVideo(
          filePath: 'test.mp4',
          fileSizeBytes: 150 * 1024 * 1024,
          durationSeconds: 30,
        ),
        contains('exceeds maximum allowed limit'),
      );
    });
  });

  group('AnalysisResultModel Parsing', () {
    test('parses complete AI result contract', () {
      final json = {
        'exercise': 'Squat',
        'score': 88,
        'rep_count': 12,
        'processing_time': 3.12,
        'errors': [
          'Knee Valgus',
          {'title': 'Insufficient Depth', 'description': 'Hip crease above knee'},
        ],
        'suggestions': [
          'Keep knees aligned with toes.',
          {'title': 'Deeper Descent', 'detail': 'Sink down lower.'},
        ],
      };

      final result = AnalysisResultModel.fromJson(json, isDemo: true);
      expect(result.exercise, 'Squat');
      expect(result.score, 88);
      expect(result.repCount, 12);
      expect(result.processingTime, 3.12);
      expect(result.isDemoData, isTrue);
      expect(result.errors.length, 2);
      expect(result.errors.first.title, 'Knee Valgus');
      expect(result.suggestions.length, 2);
      expect(result.suggestions.first.title, 'Keep knees aligned with toes.');
      expect(result.metrics.length, greaterThan(0));
    });
  });

  group('HistoryItemModel', () {
    test('parses history record', () {
      final json = {
        'analysis_id': 55,
        'exercise': 'Push-up',
        'score': 92,
        'rep_count': 20,
        'status': 'completed',
        'created_at': '2026-03-20T14:30:00.000Z',
      };

      final item = HistoryItemModel.fromJson(json);
      expect(item.analysisId, 55);
      expect(item.exercise, 'Push-up');
      expect(item.score, 92);
      expect(item.repCount, 20);
      expect(item.status, 'completed');
    });
  });
}
