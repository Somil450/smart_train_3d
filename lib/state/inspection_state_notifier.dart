import 'package:flutter/material.dart';
import '../models/inspection/inspection_result.dart';
import '../repositories/inspection_repository.dart';

class InspectionStateNotifier extends ChangeNotifier {
  final InspectionRepository _inspectionRepository;

  InspectionResult? _inspectionResult;
  DetectionBox? _selectedDetection;
  bool _isLoading = false;

  InspectionStateNotifier(this._inspectionRepository);

  InspectionResult? get inspectionResult => _inspectionResult;
  DetectionBox? get selectedDetection => _selectedDetection;
  bool get isLoading => _isLoading;

  Future<void> loadInspection(String trainId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _inspectionResult = await _inspectionRepository.getLatestInspection(trainId);
      if (_inspectionResult != null && _inspectionResult!.detections.isNotEmpty) {
        _selectedDetection = _inspectionResult!.detections.first;
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDetection(DetectionBox detection) {
    _selectedDetection = detection;
    notifyListeners();
  }
}
