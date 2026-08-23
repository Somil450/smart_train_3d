enum ExperimentStatus {
  idle,
  running,
  completed,
  cancelled,
}

class ComponentConfig {
  final bool bodyFault;
  final bool frontBogieFault;
  final bool rearBogieFault;
  final bool axleFault;
  final bool wheelFault;
  final bool bearingFault;
  final bool motorFault;
  final bool brakeFault;
  final bool suspensionFault;

  ComponentConfig({
    this.bodyFault = false,
    this.frontBogieFault = false,
    this.rearBogieFault = false,
    this.axleFault = false,
    this.wheelFault = false,
    this.bearingFault = false,
    this.motorFault = false,
    this.brakeFault = false,
    this.suspensionFault = false,
  });

  ComponentConfig copyWith({
    bool? bodyFault,
    bool? frontBogieFault,
    bool? rearBogieFault,
    bool? axleFault,
    bool? wheelFault,
    bool? bearingFault,
    bool? motorFault,
    bool? brakeFault,
    bool? suspensionFault,
  }) {
    return ComponentConfig(
      bodyFault: bodyFault ?? this.bodyFault,
      frontBogieFault: frontBogieFault ?? this.frontBogieFault,
      rearBogieFault: rearBogieFault ?? this.rearBogieFault,
      axleFault: axleFault ?? this.axleFault,
      wheelFault: wheelFault ?? this.wheelFault,
      bearingFault: bearingFault ?? this.bearingFault,
      motorFault: motorFault ?? this.motorFault,
      brakeFault: brakeFault ?? this.brakeFault,
      suspensionFault: suspensionFault ?? this.suspensionFault,
    );
  }
}

class ExperimentRecord {
  final String id;
  final String trainId;
  final DateTime startTime;
  final DateTime? endTime;
  final String expectedFault;
  final ComponentConfig configuration;
  final double loadKg;
  final double speedRpm;
  final ExperimentStatus status;
  final String? detectedFault;
  final double? confidence;
  final String notes;

  ExperimentRecord({
    required this.id,
    required this.trainId,
    required this.startTime,
    this.endTime,
    required this.expectedFault,
    required this.configuration,
    required this.loadKg,
    required this.speedRpm,
    required this.status,
    this.detectedFault,
    this.confidence,
    required this.notes,
  });

  bool get isMatch => expectedFault == (detectedFault ?? '');

  ExperimentRecord copyWith({
    String? id,
    String? trainId,
    DateTime? startTime,
    DateTime? endTime,
    String? expectedFault,
    ComponentConfig? configuration,
    double? loadKg,
    double? speedRpm,
    ExperimentStatus? status,
    String? detectedFault,
    double? confidence,
    String? notes,
  }) {
    return ExperimentRecord(
      id: id ?? this.id,
      trainId: trainId ?? this.trainId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      expectedFault: expectedFault ?? this.expectedFault,
      configuration: configuration ?? this.configuration,
      loadKg: loadKg ?? this.loadKg,
      speedRpm: speedRpm ?? this.speedRpm,
      status: status ?? this.status,
      detectedFault: detectedFault ?? this.detectedFault,
      confidence: confidence ?? this.confidence,
      notes: notes ?? this.notes,
    );
  }
}
