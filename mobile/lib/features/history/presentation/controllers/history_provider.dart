import 'package:flutter/material.dart';
import 'package:ai_coach_gym/core/errors/app_exception.dart';
import 'package:ai_coach_gym/features/analysis/data/models/analysis_model.dart';
import 'package:ai_coach_gym/features/analysis/data/repositories/analysis_repository.dart';

/// State controller for workout evaluation history.
class HistoryProvider extends ChangeNotifier {
  final AnalysisRepository _analysisRepository;

  List<AnalysisModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedFilter;

  HistoryProvider({required AnalysisRepository analysisRepository})
      : _analysisRepository = analysisRepository;

  List<AnalysisModel> get items {
    if (_selectedFilter == null || _selectedFilter!.isEmpty || _selectedFilter == 'All') {
      return _items;
    }
    return _items
        .where((item) =>
            (item.result?.exercise.toLowerCase() == _selectedFilter!.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedFilter => _selectedFilter;
  bool get isEmpty => _items.isEmpty && !_isLoading;

  void setFilter(String? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> fetchHistory({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _analysisRepository.getAnalysisHistory();
      _items = list;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Unable to load workout history.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteItem(int analysisId) async {
    try {
      await _analysisRepository.deleteAnalysis(analysisId);
      _items.removeWhere((item) => item.id == analysisId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
