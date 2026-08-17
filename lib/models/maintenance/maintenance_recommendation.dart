enum MaintenancePriority {
  low,
  medium,
  high,
  critical,
}

enum MaintenanceStatus {
  detected,
  pendingReview,
  acknowledged,
  maintenanceCompleted,
  resolved,
}

class MaintenanceRecommendation {
  final String id;
  final String trainId;
  final String componentId;
  final String componentName;
  final String faultType;
  final MaintenancePriority priority;
  final String reason;
  final String recommendedAction;
  final DateTime createdAt;
  final MaintenanceStatus status;
  final DateTime? updatedAt;

  MaintenanceRecommendation({
    required this.id,
    required this.trainId,
    required this.componentId,
    required this.componentName,
    required this.faultType,
    required this.priority,
    required this.reason,
    required this.recommendedAction,
    required this.createdAt,
    required this.status,
    this.updatedAt,
  });

  MaintenanceRecommendation copyWith({
    String? id,
    String? trainId,
    String? componentId,
    String? componentName,
    String? faultType,
    MaintenancePriority? priority,
    String? reason,
    String? recommendedAction,
    DateTime? createdAt,
    MaintenanceStatus? status,
    DateTime? updatedAt,
  }) {
    return MaintenanceRecommendation(
      id: id ?? this.id,
      trainId: trainId ?? this.trainId,
      componentId: componentId ?? this.componentId,
      componentName: componentName ?? this.componentName,
      faultType: faultType ?? this.faultType,
      priority: priority ?? this.priority,
      reason: reason ?? this.reason,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
