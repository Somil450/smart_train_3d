import '../models/maintenance/maintenance_recommendation.dart';
import '../core/constants/app_constants.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceRecommendation>> getRecommendations(String trainId);
  Future<void> updateStatus(String recommendationId, MaintenanceStatus newStatus);
}

class MockMaintenanceRepository implements MaintenanceRepository {
  final List<MaintenanceRecommendation> _items = [
    MaintenanceRecommendation(
      id: 'MAINT_001',
      trainId: AppConstants.activeTrainId,
      componentId: AppConstants.compBearing06,
      componentName: 'Bogie 3 Axle 6 Journal Bearing',
      faultType: 'Bearing Outer Race Defect',
      priority: MaintenancePriority.critical,
      reason: 'AI Anomaly Score 78.4% & Vibration Z amplitude +320%',
      recommendedAction: 'Schedule immediate depot replacement of Bogie 3 Axle 6 journal bearing assembly.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: MaintenanceStatus.pendingReview,
    ),
    MaintenanceRecommendation(
      id: 'MAINT_002',
      trainId: AppConstants.activeTrainId,
      componentId: AppConstants.compWheel03,
      componentName: 'Bogie 2 Axle 3 Wheel',
      faultType: 'Wheel Tread Flat Spot',
      priority: MaintenancePriority.medium,
      reason: 'Periodic impact harmonics detected during acceleration phase',
      recommendedAction: 'Inspect wheel tread on lathe during routine 500km servicing.',
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      status: MaintenanceStatus.acknowledged,
    ),
    MaintenanceRecommendation(
      id: 'MAINT_003',
      trainId: AppConstants.activeTrainId,
      componentId: AppConstants.compMotor01,
      componentName: 'Lead Traction Motor 1',
      faultType: 'Thermal Dissipation Degradation',
      priority: MaintenancePriority.low,
      reason: 'Cooling duct air flow 8% lower than nominal baseline',
      recommendedAction: 'Clean intake air filter and inspect cooling fan blades.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: MaintenanceStatus.resolved,
      updatedAt: DateTime.now().subtract(const Duration(hours: 20)),
    ),
  ];

  @override
  Future<List<MaintenanceRecommendation>> getRecommendations(String trainId) async {
    return _items;
  }

  @override
  Future<void> updateStatus(String recommendationId, MaintenanceStatus newStatus) async {
    final idx = _items.indexWhere((item) => item.id == recommendationId);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    }
  }
}
