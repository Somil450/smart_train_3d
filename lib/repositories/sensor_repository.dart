import '../models/sensor/sensor_reading.dart';

abstract class SensorRepository {
  Future<List<SensorReading>> getRecentReadings(String trainId, SensorType sensorType, int durationMinutes);
  Future<TelemetrySnapshot> getLatestTelemetry(String trainId);
}

class MockSensorRepository implements SensorRepository {
  @override
  Future<List<SensorReading>> getRecentReadings(String trainId, SensorType sensorType, int durationMinutes) async {
    final now = DateTime.now();
    final List<SensorReading> results = [];
    final points = durationMinutes * 60;

    for (int i = points; i >= 0; i -= 5) {
      final time = now.subtract(Duration(seconds: i));
      double val = 0.0;

      switch (sensorType) {
        case SensorType.imu1X:
          val = 0.12 + ((i % 3) * 0.01);
          break;
        case SensorType.imu1Y:
          val = 0.08 + ((i % 2) * 0.01);
          break;
        case SensorType.imu1Z:
          val = 0.98 + ((i % 4) * 0.02);
          break;
        case SensorType.imu2X:
          val = 0.15 + ((i % 5) * 0.02);
          break;
        case SensorType.imu2Y:
          val = 0.10 + ((i % 3) * 0.01);
          break;
        case SensorType.imu2Z:
          val = 1.02 + (points - i) * 0.015 + ((i % 7) * 0.1);
          break;
        case SensorType.motorTemp:
          val = 42.0 + (points - i) * 0.05 + (i % 3);
          break;
        case SensorType.bearingBogieTemp:
          val = 38.0 + (points - i) * 0.04 + (i % 2);
          break;
        case SensorType.rpm:
          val = 1450.0 + ((i % 11) * 5.0);
          break;
        case SensorType.current:
          val = 12.5 + ((i % 5) * 0.4);
          break;
        case SensorType.voltage:
          val = 220.0 + ((i % 4) * 1.0);
          break;
        case SensorType.loadWeight:
          val = 450.0 + ((i % 13) * 2.0);
          break;
        case SensorType.ambientTemp:
          val = 26.0 + ((i % 2) * 0.2);
          break;
        case SensorType.humidity:
          val = 55.0 + (i % 3);
          break;
      }

      results.add(
        SensorReading(
          timestamp: time,
          trainId: trainId,
          componentId: _getComponentId(sensorType),
          sensorType: sensorType,
          value: val,
          unit: _getUnit(sensorType),
        ),
      );
    }
    return results;
  }

  String _getComponentId(SensorType type) {
    switch (type) {
      case SensorType.imu1X:
      case SensorType.imu1Y:
      case SensorType.imu1Z:
      case SensorType.motorTemp:
      case SensorType.voltage:
      case SensorType.current:
      case SensorType.rpm:
        return 'MOTOR_01';
      case SensorType.imu2X:
      case SensorType.imu2Y:
      case SensorType.imu2Z:
      case SensorType.bearingBogieTemp:
        return 'BEARING_06';
      case SensorType.loadWeight:
        return 'BODY_MAIN';
      case SensorType.ambientTemp:
      case SensorType.humidity:
        return 'BODY_MAIN';
    }
  }

  String _getUnit(SensorType type) {
    switch (type) {
      case SensorType.imu1X:
      case SensorType.imu1Y:
      case SensorType.imu1Z:
      case SensorType.imu2X:
      case SensorType.imu2Y:
      case SensorType.imu2Z:
        return 'g';
      case SensorType.motorTemp:
      case SensorType.bearingBogieTemp:
      case SensorType.ambientTemp:
        return '°C';
      case SensorType.voltage:
        return 'V';
      case SensorType.current:
        return 'A';
      case SensorType.rpm:
        return 'RPM';
      case SensorType.humidity:
        return '%';
      case SensorType.loadWeight:
        return 'kg';
    }
  }

  @override
  Future<TelemetrySnapshot> getLatestTelemetry(String trainId) async {
    return TelemetrySnapshot(
      timestamp: DateTime.now(),
      trainId: trainId,
      imu1X: 0.12,
      imu1Y: 0.08,
      imu1Z: 0.98,
      imu2X: 0.15,
      imu2Y: 0.10,
      imu2Z: 4.8,
      motorTemp: 44.2,
      bearingBogieTemp: 62.5,
      rpm: 1452.0,
      voltage: 221.5,
      current: 12.8,
      loadWeight: 452.0,
      ambientTemp: 26.5,
      humidity: 56.0,
      irDetection: true,
      gpsAvailable: true,
      gpsPosition: '12.9716° N, 77.5946° E',
    );
  }
}
