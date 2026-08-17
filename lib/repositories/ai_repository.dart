import '../models/ai/anomaly_result.dart';
import '../models/ai/fault_prediction.dart';
import '../models/ai/ai_explanation.dart';
import '../models/ai/degradation_result.dart';
import '../core/constants/app_constants.dart';

abstract class AIRepository {
  Future<AnomalyResult> getAnomalyResult(String trainId);
  Future<FaultPrediction> getFaultPrediction(String trainId);
  Future<AIExplanation> getAIExplanation(String trainId, String faultType);
  Future<DegradationResult> getDegradation(String trainId, String componentId);
}

class MockAIRepository implements AIRepository {
  @override
  Future<AnomalyResult> getAnomalyResult(String trainId) async {
    return AnomalyResult(
      timestamp: DateTime.now(),
      trainId: trainId,
      status: AnomalyStatus.anomalous,
      anomalyScore: 78.4,
    );
  }

  @override
  Future<FaultPrediction> getFaultPrediction(String trainId) async {
    return FaultPrediction(
      timestamp: DateTime.now(),
      trainId: trainId,
      primaryFault: 'Bearing Outer Race Defect',
      localizedComponentId: AppConstants.compBearing06,
      probabilities: [
        FaultProbability(faultType: 'Bearing Fault', confidence: 0.87),
        FaultProbability(faultType: 'Wheel Fault', confidence: 0.06),
        FaultProbability(faultType: 'Motor Fault', confidence: 0.04),
        FaultProbability(faultType: 'Axle Misalignment', confidence: 0.03),
      ],
    );
  }

  @override
  Future<AIExplanation> getAIExplanation(String trainId, String faultType) async {
    return AIExplanation(
      summary: 'Automated signal analysis isolated high-frequency impact harmonics on Bogie 3 Axle 6.',
      confidence: 0.87,
      primarySignal: 'Bogie 3 Z-Axis Vibration & Journal Bearing Temp',
      evidence: [
        EvidenceItem(description: 'Vibration envelope increased by 320%', changePercentage: '+320%', significance: 'High Impact'),
        EvidenceItem(description: 'Bearing temperature increased by 18°C above baseline', changePercentage: '+47%', significance: 'Thermal Spike'),
        EvidenceItem(description: 'RPM micro-instability detected', changePercentage: '+3.4%', significance: 'Kinematic Irregularity'),
        EvidenceItem(description: 'Motor current draw increased by 14%', changePercentage: '+14%', significance: 'Drag Load'),
      ],
    );
  }

  @override
  Future<DegradationResult> getDegradation(String trainId, String componentId) async {
    final name = componentId == AppConstants.compBearing06
        ? 'Bogie 3 Axle 6 Journal Bearing'
        : 'Component $componentId';
    return DegradationResult(
      componentId: componentId,
      componentName: name,
      currentHealth: componentId == AppConstants.compBearing06 ? 38.5 : 94.0,
      previousHealth: 82.0,
      change: componentId == AppConstants.compBearing06 ? -43.5 : -1.2,
      trend: componentId == AppConstants.compBearing06 ? DegradationTrend.degrading : DegradationTrend.stable,
      prediction: componentId == AppConstants.compBearing06
          ? 'Estimated remaining useful life (RUL): 48 operating hours.'
          : 'Estimated remaining useful life (RUL): > 2500 operating hours.',
      confidence: 0.89,
    );
  }
}
