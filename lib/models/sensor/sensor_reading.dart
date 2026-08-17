enum SensorType {
  imu1X,
  imu1Y,
  imu1Z,
  imu2X,
  imu2Y,
  imu2Z,
  motorTemp,
  bearingBogieTemp,
  rpm,
  voltage,
  current,
  loadWeight,
  ambientTemp,
  humidity,
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

  // IMU #1 (Motor / Gearbox)
  final double imu1X;
  final double imu1Y;
  final double imu1Z;

  // IMU #2 (Bogie / Wheel / Axle / Bearing / Suspension)
  final double imu2X;
  final double imu2Y;
  final double imu2Z;

  // DS18B20 #1 (Motor)
  final double motorTemp;

  // DS18B20 #2 (Bearing / Bogie)
  final double bearingBogieTemp;

  // Reed Switch
  final double rpm;

  // INA219
  final double voltage;
  final double current;

  // Calculated from voltage * current
  double get power => voltage * current;

  // HX711 + Load Cell
  final double loadWeight;

  // DHT11
  final double ambientTemp;
  final double humidity;

  // IR Sensor (Train / inspection-zone trigger)
  final bool irDetection;

  // GPS / GNSS
  final bool gpsAvailable;
  final String gpsPosition; // e.g. "12.9716° N, 77.5946° E" or "UNAVAILABLE"

  TelemetrySnapshot({
    required this.timestamp,
    required this.trainId,
    required this.imu1X,
    required this.imu1Y,
    required this.imu1Z,
    required this.imu2X,
    required this.imu2Y,
    required this.imu2Z,
    required this.motorTemp,
    required this.bearingBogieTemp,
    required this.rpm,
    required this.voltage,
    required this.current,
    required this.loadWeight,
    required this.ambientTemp,
    required this.humidity,
    required this.irDetection,
    required this.gpsAvailable,
    required this.gpsPosition,
  });
}
