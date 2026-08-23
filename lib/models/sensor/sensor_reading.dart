enum SensorType {
  imuX,
  imuY,
  imuZ,
  motorTemp,
  bearingBogieTemp,
  rpm,
  voltage,
  current,
  loadWeight,
}

class SensorReading {
  final DateTime timestamp;
  final String trainId;
  final String componentId;
  final SensorType sensorType;
  final double value;
  final String unit;

  SensorReading({
    required this.timestamp,
    required this.trainId,
    required this.componentId,
    required this.sensorType,
    required this.value,
    required this.unit,
  });
}

class TelemetrySnapshot {
  final DateTime timestamp;
  final String trainId;

  // IMU 3D Vibration Tensor (MPU6050 / ADXL345)
  final double imuX;
  final double imuY;
  final double imuZ;

  // Dual DS18B20 Thermals
  final double motorTemp;
  final double bearingBogieTemp;

  // Speed (Reed Switch)
  final double rpm;

  // INA219 Electrical Monitoring
  final double voltage;
  final double current;

  // Derived Electrical Power (V * I)
  double get power => voltage * current;

  // HX711 Load Cell Weight Dynamics
  final double loadWeight;

  // Legacy/Alias getters for smooth UI integration
  double get imu1X => imuX;
  double get imu1Y => imuY;
  double get imu1Z => imuZ;
  double get imu2X => imuX;
  double get imu2Y => imuY;
  double get imu2Z => imuZ;

  TelemetrySnapshot({
    required this.timestamp,
    required this.trainId,
    required this.imuX,
    required this.imuY,
    required this.imuZ,
    required this.motorTemp,
    required this.bearingBogieTemp,
    required this.rpm,
    required this.voltage,
    required this.current,
    required this.loadWeight,
  });
}
