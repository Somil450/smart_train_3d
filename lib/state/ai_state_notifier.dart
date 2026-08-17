import 'package:flutter/material.dart';
import '../models/ai/anomaly_result.dart';
import '../models/ai/fault_prediction.dart';
import '../models/ai/ai_explanation.dart';
import '../models/ai/degradation_result.dart';
import '../repositories/ai_repository.dart';

class AIStateNotifier extends ChangeNotifier {
  final AIRepository _aiRepository;

  AnomalyResult? _anomalyResult;
  FaultPrediction? _faultPrediction;
  AIExplanation? _explanation;
  DegradationResult? _degradation;
  bool _isLoading = false;

  AIStateNotifier(this._aiRepository);

  AnomalyResult? get anomalyResult => _anomalyResult;
  FaultPrediction? get faultPrediction => _faultPrediction;
  AIExplanation? get explanation => _explanation;
  DegradationResult? get degradation => _degradation;
  bool get isLoading => _isLoading;

  Future<void> loadAIData(String trainId, {String? componentId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _anomalyResult = await _aiRepository.getAnomalyResult(trainId);
      _faultPrediction = await _aiRepository.getFaultPrediction(trainId);
      _explanation = await _aiRepository.getAIExplanation(trainId, _faultPrediction?.primaryFault ?? '');
      _degradation = await _aiRepository.getDegradation(trainId, componentId ?? 'BEARING_REAR_02');
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setAnomalyResult(AnomalyResult result) {
    _anomalyResult = result;
    notifyListeners();
  }

  void setFaultPrediction(FaultPrediction prediction) {
    _faultPrediction = prediction;
    notifyListeners();
  }

  void setExplanation(AIExplanation exp) {
    _explanation = exp;
    notifyListeners();
  }

  void setDegradation(DegradationResult deg) {
    _degradation = deg;
    notifyListeners();
  }
}
