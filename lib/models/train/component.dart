enum ComponentStatus {
  normal,
  warning,
  fault,
  noData,
}

enum ComponentType {
  body,
  bogie,
  axle,
  wheel,
  bearing,
  motor,
  brake,
  suspension,
  coupler,
}

class TrainComponent {
  final String id;
  final String name;
  final ComponentType type;
  final String location;
  final ComponentStatus status;
  final double healthScore; // 0.0 - 100.0
  final Map<String, dynamic> sensorData;
  final String? activeFault;
  final DateTime lastUpdated;
  final List<TrainComponent> children;

  TrainComponent({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.status,
    required this.healthScore,
    required this.sensorData,
    this.activeFault,
    required this.lastUpdated,
    this.children = const [],
  });

  TrainComponent copyWith({
    String? id,
    String? name,
    ComponentType? type,
    String? location,
    ComponentStatus? status,
    double? healthScore,
    Map<String, dynamic>? sensorData,
    String? activeFault,
    DateTime? lastUpdated,
    List<TrainComponent>? children,
  }) {
    return TrainComponent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      status: status ?? this.status,
      healthScore: healthScore ?? this.healthScore,
      sensorData: sensorData ?? this.sensorData,
      activeFault: activeFault ?? this.activeFault,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      children: children ?? this.children,
    );
  }
}
