import 'package:flutter/material.dart';
import '../models/history/run_record.dart';
import '../repositories/history_repository.dart';

class HistoryStateNotifier extends ChangeNotifier {
  final HistoryRepository _repository;

  List<RunRecord> _allRuns = [];
  String _searchQuery = '';
  String? _filterCondition;
  RunRecord? _selectedRun;
  bool _isLoading = false;

  HistoryStateNotifier(this._repository);

  List<RunRecord> get runs {
    return _allRuns.where((run) {
      final matchesSearch = _searchQuery.isEmpty ||
          run.runId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          run.faultType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          run.locationComponentId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCondition = _filterCondition == null || run.condition.toLowerCase() == _filterCondition!.toLowerCase();

      return matchesSearch && matchesCondition;
    }).toList();
  }

  RunRecord? get selectedRun => _selectedRun;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get filterCondition => _filterCondition;

  Future<void> loadHistory(String trainId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _allRuns = await _repository.getRunHistory(trainId);
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCondition(String? condition) {
    _filterCondition = condition;
    notifyListeners();
  }

  void selectRun(RunRecord? run) {
    _selectedRun = run;
    notifyListeners();
  }
}
