import 'package:flutter/material.dart';
import '../models/maintenance/maintenance_recommendation.dart';
import '../repositories/maintenance_repository.dart';

class MaintenanceStateNotifier extends ChangeNotifier {
  final MaintenanceRepository _repository;

  List<MaintenanceRecommendation> _recommendations = [];
  bool _isLoading = false;

  MaintenanceStateNotifier(this._repository);

  List<MaintenanceRecommendation> get recommendations => List.unmodifiable(_recommendations);
  bool get isLoading => _isLoading;

  Future<void> loadRecommendations(String trainId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _recommendations = await _repository.getRecommendations(trainId);
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String recommendationId, MaintenanceStatus status) async {
    await _repository.updateStatus(recommendationId, status);
    final idx = _recommendations.indexWhere((r) => r.id == recommendationId);
    if (idx != -1) {
      _recommendations[idx] = _recommendations[idx].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
