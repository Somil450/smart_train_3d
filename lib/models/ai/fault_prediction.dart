/// Official 8 Fault Classes from AumAhuja/Predictive-Rolling-Stock-Failure-Detection dataset
enum FaultTypeEnum {
  NORMAL,
  WHEEL_FLAT,
  AXLE_MISALIGNMENT,
  BEARING_FAULT,
  BRAKE_ABNORMAL,
  SUSPENSION_FAULT,
  MOTOR_FAULT,
  BODY_DAMAGE,
  UNKNOWN,
}

/// Official Physical Fault Locations from AumAhuja/Predictive-Rolling-Stock-Failure-Detection dataset
enum FaultLocationEnum {
  NONE,
  MOTOR,
  FRONT_BOGIE,
  FRONT_BOGIE_AXLE_1,
  FRONT_BOGIE_AXLE_2,
  REAR_BOGIE,
  REAR_BOGIE_AXLE_1,
  REAR_BOGIE_AXLE_2,
  BODY,
  BRAKE,
}

class FaultProbability {
  final String faultType;
  final double confidence; // 0.0 to 1.0

  FaultProbability({
    required this.faultType,
    required this.confidence,
  });
}

class FaultPrediction {
  final DateTime timestamp;
  final String trainId;
  final List<FaultProbability> probabilities;
  final String primaryFault;
  final String localizedComponentId;
  final FaultTypeEnum faultTypeEnum;
  final FaultLocationEnum faultLocationEnum;

  FaultPrediction({
    required this.timestamp,
    required this.trainId,
    required this.probabilities,
    required this.primaryFault,
    required this.localizedComponentId,
    this.faultTypeEnum = FaultTypeEnum.BEARING_FAULT,
    this.faultLocationEnum = FaultLocationEnum.REAR_BOGIE_AXLE_2,
  });
}
