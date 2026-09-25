import '../../../../core/network/api_client.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  final ApiClient _apiClient;

  ExerciseRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<ExerciseModel>> getExercises() async {
    try {
      final response = await _apiClient.get('/exercises', requiresAuth: false);
      if (response is List) {
        return response
            .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return ExerciseModel.supportedExercises;
  }
}
