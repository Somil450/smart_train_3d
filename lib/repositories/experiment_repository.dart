import '../models/experiment/experiment.dart';
import '../core/constants/app_constants.dart';

abstract class ExperimentRepository {
  Future<List<ExperimentRecord>> getExperiments(String trainId);
  Future<void> saveExperiment(ExperimentRecord experiment);
}

class MockExperimentRepository implements ExperimentRepository {
  final List<ExperimentRecord> _experiments = [
    ExperimentRecord(
      id: 'EXP_2026_01',
      trainId: AppConstants.activeTrainId,
      startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      expectedFault: 'Bearing Fault',
      configuration: ComponentConfig(bearingFault: true, rearBogieFault: true),
      loadKg: 450.0,
      speedRpm: 1450.0,
      status: ExperimentStatus.completed,
      detectedFault: 'Bearing Fault',
      confidence: 0.87,
      notes: 'Controlled outer race spalling defect test on Bogie 3 Axle 6.',
    ),
    ExperimentRecord(
      id: 'EXP_2026_02',
      trainId: AppConstants.activeTrainId,
      startTime: DateTime.now().subtract(const Duration(days: 3)),
      endTime: DateTime.now().subtract(const Duration(days: 3, hours: -1)),
      expectedFault: 'Motor Fault',
      configuration: ComponentConfig(motorFault: true),
      loadKg: 500.0,
      speedRpm: 1600.0,
      status: ExperimentStatus.completed,
      detectedFault: 'Motor Fault',
      confidence: 0.91,
      notes: 'High current thermal overload test on traction motor stator.',
    ),
  ];

  @override
  Future<List<ExperimentRecord>> getExperiments(String trainId) async {
    return _experiments;
  }

  @override
  Future<void> saveExperiment(ExperimentRecord experiment) async {
    _experiments.insert(0, experiment);
  }
}
