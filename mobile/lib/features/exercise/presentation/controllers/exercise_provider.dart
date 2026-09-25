import 'package:flutter/widgets.dart';
import '../../data/models/exercise_model.dart';
import '../../data/repositories/exercise_repository.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository _repository;
  List<ExerciseModel> _exercises = ExerciseModel.supportedExercises;
  bool _isLoading = false;

  ExerciseProvider({required ExerciseRepository repository}) : _repository = repository {
    loadExercises();
  }

  List<ExerciseModel> get exercises => _exercises;
  bool get isLoading => _isLoading;

  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _repository.getExercises();
      if (list.isNotEmpty) {
        _exercises = list;
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}
