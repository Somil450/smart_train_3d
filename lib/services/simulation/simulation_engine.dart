import 'dart:async';
import 'dart:math';

import '../../models/sensor/sensor_reading.dart';
import '../../models/ai/anomaly_result.dart';
import '../../models/ai/fault_prediction.dart';
import '../../models/ai/ai_explanation.dart';
import '../../models/ai/degradation_result.dart';
import '../../core/constants/app_constants.dart';

enum SimulationPreset {
  normal,
  bearingFault,
  wheelFault,
  motorFault,
}

class SimulationEngine {
  final _telemetryController = StreamController<TelemetrySnapshot>.broadcast();
  Timer? _timer;
  final Random _random = Random();

  SimulationPreset _currentPreset = SimulationPreset.bearingFault;
  double _timeCounter = 0;

  Stream<TelemetrySnapshot> get telemetryStream => _telemetryController.stream;
  SimulationPreset get currentPreset => _currentPreset;

  void setPreset(SimulationPreset preset) {
    _currentPreset = preset;
    _timeCounter = 0;
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _timeCounter += 1.0;
      final snapshot = _generateSnapshot();
      _telemetryController.add(snapshot);
    });
  }

  void stop() {
    _timer?.cancel();
  }

  TelemetrySnapshot _generateSnapshot() {
    // Default nominal raw values
    double imu1X = 0.12 + (_random.nextDouble() - 0.5) * 0.05;
    double imu1Y = 0.08 + (_random.nextDouble() - 0.5) * 0.04;
    double imu1Z = 0.98 + (_random.nextDouble() - 0.5) * 0.05;

    double imu2X = 0.15 + (_random.nextDouble() - 0.5) * 0.06;
    double imu2Y = 0.10 + (_random.nextDouble() - 0.5) * 0.04;
    double imu2Z = 1.02 + (_random.nextDouble() - 0.5) * 0.08;

    double motorTemp = 42.0 + _random.nextDouble() * 2.0;
    double bearingBogieTemp = 38.0 + _random.nextDouble() * 1.5;

    double rpm = 1450.0 + (_random.nextDouble() - 0.5) * 20.0;
    double voltage = 220.0 + (_random.nextDouble() - 0.5) * 3.0;
    double current = 12.5 + (_random.nextDouble() - 0.5) * 1.0;

    double loadWeight = 450.0 + (_random.nextDouble() - 0.5) * 10.0;

    double ambientTemp = 26.0 + (_random.nextDouble() - 0.5) * 0.5;
    double humidity = 55.0 + (_random.nextDouble() - 0.5) * 1.0;

    bool irDetection = true;
    bool gpsAvailable = true;
    String gpsPos = '12.9716° N, 77.5946° E';

    switch (_currentPreset) {
      case SimulationPreset.normal:
        break;

      case SimulationPreset.bearingFault:
        final scale = min(1.0, _timeCounter / 60.0);
        imu2Z += 3.8 * scale + _random.nextDouble() * 0.8;
        bearingBogieTemp += 24.5 * scale + _random.nextDouble() * 2.0;
        current += 3.2 * scale;
        break;

      case SimulationPreset.wheelFault:
        final periodicSpike = (sin(_timeCounter * 0.5) * 2.5).abs();
        imu2X += periodicSpike;
        imu2Y += periodicSpike * 0.7;
        rpm += sin(_timeCounter * 0.8) * 85.0;
        break;

      case SimulationPreset.motorFault:
        final scale = min(1.0, _timeCounter / 40.0);
        motorTemp += 32.0 * scale + _random.nextDouble() * 3.0;
        current += 8.5 * scale;
        imu1Z += 3.5 * scale;
        rpm += sin(_timeCounter) * 120.0;
        break;
    }

    return TelemetrySnapshot(
      timestamp: DateTime.now(),
      trainId: AppConstants.activeTrainId,
      imu1X: imu1X,
      imu1Y: imu1Y,
      imu1Z: imu1Z,
      imu2X: imu2X,
      imu2Y: imu2Y,
      imu2Z: imu2Z,
      motorTemp: motorTemp,
      bearingBogieTemp: bearingBogieTemp,
      rpm: rpm,
      voltage: voltage,
      current: current,
      loadWeight: loadWeight,
      ambientTemp: ambientTemp,
      humidity: humidity,
      irDetection: irDetection,
      gpsAvailable: gpsAvailable,
      gpsPosition: gpsPos,
    );
  }

  AnomalyResult generateAnomalyResult(String trainId) {
    switch (_currentPreset) {
      case SimulationPreset.normal:
        return AnomalyResult(
          timestamp: DateTime.now(),
          trainId: trainId,
          status: AnomalyStatus.normal,
          anomalyScore: 4.2 + _random.nextDouble() * 2.0,
        );
      case SimulationPreset.bearingFault:
        return AnomalyResult(
          timestamp: DateTime.now(),
          trainId: trainId,
          status: AnomalyStatus.anomalous,
          anomalyScore: 84.6 + _random.nextDouble() * 3.0,
        );
      case SimulationPreset.wheelFault:
        return AnomalyResult(
          timestamp: DateTime.now(),
          trainId: trainId,
          status: AnomalyStatus.anomalous,
          anomalyScore: 71.4 + _random.nextDouble() * 4.0,
        );
      case SimulationPreset.motorFault:
        return AnomalyResult(
          timestamp: DateTime.now(),
          trainId: trainId,
          status: AnomalyStatus.anomalous,
          anomalyScore: 92.1 + _random.nextDouble() * 2.0,
        );
    }
  }

  FaultPrediction generateFaultPrediction(String trainId) {
    switch (_currentPreset) {
      case SimulationPreset.normal:
        return FaultPrediction(
          timestamp: DateTime.now(),
          trainId: trainId,
          primaryFault: 'Normal Operation',
          localizedComponentId: AppConstants.compBody,
          probabilities: [
            FaultProbability(faultType: 'Normal Operation', confidence: 0.96),
            FaultProbability(faultType: 'Bearing Fault', confidence: 0.02),
            FaultProbability(faultType: 'Wheel Fault', confidence: 0.01),
            FaultProbability(faultType: 'Motor Fault', confidence: 0.01),
          ],
        );

      case SimulationPreset.bearingFault:
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

      case SimulationPreset.wheelFault:
        return FaultPrediction(
          timestamp: DateTime.now(),
          trainId: trainId,
          primaryFault: 'Wheel Tread Flat / Polygonization',
          localizedComponentId: AppConstants.compWheel03,
          probabilities: [
            FaultProbability(faultType: 'Wheel Fault', confidence: 0.82),
            FaultProbability(faultType: 'Bearing Fault', confidence: 0.11),
            FaultProbability(faultType: 'Suspension Fault', confidence: 0.05),
            FaultProbability(faultType: 'Motor Fault', confidence: 0.02),
          ],
        );

      case SimulationPreset.motorFault:
        return FaultPrediction(
          timestamp: DateTime.now(),
          trainId: trainId,
          primaryFault: 'Motor Stator Overheating & Current Spike',
          localizedComponentId: AppConstants.compMotor01,
          probabilities: [
            FaultProbability(faultType: 'Motor Fault', confidence: 0.91),
            FaultProbability(faultType: 'Bearing Fault', confidence: 0.05),
            FaultProbability(faultType: 'Axle Misalignment', confidence: 0.03),
            FaultProbability(faultType: 'Wheel Fault', confidence: 0.01),
          ],
        );
    }
  }

  AIExplanation generateAIExplanation() {
    switch (_currentPreset) {
      case SimulationPreset.normal:
        return AIExplanation(
          summary: 'All telemetry metrics remain within nominal baseline limits.',
          confidence: 0.96,
          primarySignal: 'IMU #2 Z-Acceleration & DS18B20 #2 Temp',
          evidence: [
            EvidenceItem(description: 'IMU #2 Z-acceleration within 1.0g nominal band', changePercentage: '-1.2%', significance: 'Normal'),
            EvidenceItem(description: 'DS18B20 #2 Bearing Temp nominal at 38°C', changePercentage: '0.0%', significance: 'Normal'),
            EvidenceItem(description: 'INA219 Motor Current steady at 12.5A', changePercentage: '+0.5%', significance: 'Normal'),
          ],
        );

      case SimulationPreset.bearingFault:
        return AIExplanation(
          summary: 'High frequency impact acceleration spikes detected on IMU #2 (Bogie 3).',
          confidence: 0.87,
          primarySignal: 'IMU #2 Z-Axis & DS18B20 #2 Bearing Temp',
          evidence: [
            EvidenceItem(description: 'IMU #2 Z-axis acceleration amplitude increased', changePercentage: '+380%', significance: 'High Impact'),
            EvidenceItem(description: 'DS18B20 #2 Bearing temp increased by 18°C above baseline', changePercentage: '+47%', significance: 'Thermal Rise'),
            EvidenceItem(description: 'INA219 Motor current draw increased by 14%', changePercentage: '+14%', significance: 'Secondary Indicator'),
          ],
        );

      case SimulationPreset.wheelFault:
        return AIExplanation(
          summary: 'Periodic X-axis acceleration pulse once per revolution on IMU #2.',
          confidence: 0.82,
          primarySignal: 'IMU #2 X-Axis & Reed Switch RPM',
          evidence: [
            EvidenceItem(description: 'IMU #2 X-axis acceleration peak harmonic detected', changePercentage: '+240%', significance: 'High Impact'),
            EvidenceItem(description: 'Reed switch RPM micro-fluctuations', changePercentage: '+5.8%', significance: 'Irregular Speed'),
          ],
        );

      case SimulationPreset.motorFault:
        return AIExplanation(
          summary: 'Severe current draw and DS18B20 #1 thermal anomaly detected in Traction Motor.',
          confidence: 0.91,
          primarySignal: 'INA219 Current & DS18B20 #1 Motor Temp',
          evidence: [
            EvidenceItem(description: 'DS18B20 #1 Motor temp exceeded 74°C limit', changePercentage: '+76%', significance: 'Critical Overheat'),
            EvidenceItem(description: 'INA219 Motor current draw increased by 68%', changePercentage: '+68%', significance: 'Electrical Overload'),
            EvidenceItem(description: 'IMU #1 Z-axis motor housing vibration spike', changePercentage: '+310%', significance: 'Mechanical Stress'),
          ],
        );
    }
  }

  DegradationResult generateDegradationResult(String componentId) {
    if (_currentPreset == SimulationPreset.bearingFault && (componentId == AppConstants.compBearing06 || componentId == AppConstants.compBearing04)) {
      return DegradationResult(
        componentId: componentId,
        componentName: 'Bogie 3 Axle 6 Bearing',
        currentHealth: 38.5,
        previousHealth: 82.0,
        change: -43.5,
        trend: DegradationTrend.degrading,
        prediction: 'Estimated remaining useful life (RUL): 48 operating hours.',
        confidence: 0.89,
      );
    } else if (_currentPreset == SimulationPreset.motorFault && (componentId == AppConstants.compMotor01 || componentId == AppConstants.compMotor)) {
      return DegradationResult(
        componentId: componentId,
        componentName: 'Main Traction Motor',
        currentHealth: 25.0,
        previousHealth: 78.0,
        change: -53.0,
        trend: DegradationTrend.degrading,
        prediction: 'Estimated remaining useful life (RUL): 18 operating hours.',
        confidence: 0.94,
      );
    } else {
      return DegradationResult(
        componentId: componentId,
        componentName: 'Monitored Component',
        currentHealth: 94.0,
        previousHealth: 95.5,
        change: -1.5,
        trend: DegradationTrend.stable,
        prediction: 'Component operating normally within standard wear curve.',
        confidence: 0.95,
      );
    }
  }

  void dispose() {
    _timer?.cancel();
    _telemetryController.close();
  }
}
