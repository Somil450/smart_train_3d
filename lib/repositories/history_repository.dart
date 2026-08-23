import '../models/history/run_record.dart';
import '../core/constants/app_constants.dart';

abstract class HistoryRepository {
  Future<List<RunRecord>> getRunHistory(String trainId);
}

class MockHistoryRepository implements HistoryRepository {
  final List<RunRecord> _runs = [
    RunRecord(
      runId: 'RUN_20260817_01',
      trainId: AppConstants.activeTrainId,
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      durationSeconds: 1800,
      condition: 'Anomalous',
      faultType: 'Bearing Outer Race Defect',
      locationComponentId: AppConstants.compBearing06,
      confidence: 0.87,
      healthScore: 78.4,
      experimentId: 'EXP_2026_01',
    ),
    RunRecord(
      runId: 'RUN_20260816_04',
      trainId: AppConstants.activeTrainId,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      durationSeconds: 3600,
      condition: 'Normal',
      faultType: 'None',
      locationComponentId: AppConstants.compBody,
      confidence: 0.98,
      healthScore: 94.5,
    ),
    RunRecord(
      runId: 'RUN_20260815_02',
      trainId: AppConstants.activeTrainId,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      durationSeconds: 2400,
      condition: 'Anomalous',
      faultType: 'Wheel Flat Spot',
      locationComponentId: AppConstants.compWheel03,
      confidence: 0.82,
      healthScore: 81.0,
    ),
    RunRecord(
      runId: 'RUN_20260814_01',
      trainId: AppConstants.activeTrainId,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      durationSeconds: 4200,
      condition: 'Normal',
      faultType: 'None',
      locationComponentId: AppConstants.compBody,
      confidence: 0.96,
      healthScore: 95.0,
    ),
    RunRecord(
      runId: 'RUN_20260813_03',
      trainId: AppConstants.activeTrainId,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      durationSeconds: 3000,
      condition: 'Anomalous',
      faultType: 'Motor Insulation Degradation',
      locationComponentId: AppConstants.compMotor01,
      confidence: 0.91,
      healthScore: 72.5,
      experimentId: 'EXP_2026_02',
    ),
  ];

  @override
  Future<List<RunRecord>> getRunHistory(String trainId) async {
    return _runs;
  }
}
