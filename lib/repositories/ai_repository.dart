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
      anomalyScore: 82.0,
    );
  }

  @override
  Future<FaultPrediction> getFaultPrediction(String trainId) async {
    return FaultPrediction(
      timestamp: DateTime.now(),
      trainId: trainId,
      primaryFault: 'BEARING_FAULT',
      localizedComponentId: AppConstants.compBearing06,
      faultTypeEnum: FaultTypeEnum.BEARING_FAULT,
      faultLocationEnum: FaultLocationEnum.REAR_BOGIE_AXLE_2,
      probabilities: [
        FaultProbability(faultType: 'BEARING_FAULT', confidence: 0.98),
        FaultProbability(faultType: 'WHEEL_FLAT', confidence: 0.01),
        FaultProbability(faultType: 'MOTOR_FAULT', confidence: 0.005),
        FaultProbability(faultType: 'AXLE_MISALIGNMENT', confidence: 0.003),
        FaultProbability(faultType: 'BRAKE_ABNORMAL', confidence: 0.001),
        FaultProbability(faultType: 'SUSPENSION_FAULT', confidence: 0.001),
      ],
    );
  }

  @override
  Future<AIExplanation> getAIExplanation(String trainId, String faultType) async {
    return AIExplanation(
      summary: 'XGBoost Multiclass isolated BEARING_FAULT on REAR_BOGIE_AXLE_2 (Bogie 3 Axle 6 Bearing).',
      confidence: 0.98,
      primarySignal: 'imu_z & bearing_temperature',
      evidence: [
        EvidenceItem(description: 'Isolation Forest Anomaly Score elevated (0.82)', changePercentage: '+0.82', significance: 'Critical Anomaly'),
        EvidenceItem(description: 'IMU Z-Axis Vibration RMS spike (2.15g)', changePercentage: '+320%', significance: 'High Impact'),
        EvidenceItem(description: 'Bearing temperature rising (+0.42°C/s)', changePercentage: '+14.2°C', significance: 'Thermal Spike'),
        EvidenceItem(description: 'Motor Current INA219 elevated (12.8A)', changePercentage: '+14%', significance: 'Electrical Drag'),
      ],
    );
  }

  @override
  Future<DegradationResult> getDegradation(String trainId, String componentId) async {
    final name = componentId == AppConstants.compBearing06
        ? 'REAR_BOGIE_AXLE_2 Journal Bearing'
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
      confidence: 0.98,
    );
  }
}
