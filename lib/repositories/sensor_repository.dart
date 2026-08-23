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
        case SensorType.imuX:
          val = 0.12 + ((i % 3) * 0.01);
          break;
        case SensorType.imuY:
          val = 0.08 + ((i % 2) * 0.01);
          break;
        case SensorType.imuZ:
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
      case SensorType.imuX:
      case SensorType.imuY:
      case SensorType.motorTemp:
      case SensorType.voltage:
      case SensorType.current:
      case SensorType.rpm:
        return 'MOTOR_01';
      case SensorType.imuZ:
      case SensorType.bearingBogieTemp:
        return 'BEARING_06';
      case SensorType.loadWeight:
        return 'BODY_MAIN';
    }
  }

  String _getUnit(SensorType type) {
    switch (type) {
      case SensorType.imuX:
      case SensorType.imuY:
      case SensorType.imuZ:
        return 'g';
      case SensorType.motorTemp:
      case SensorType.bearingBogieTemp:
        return '°C';
      case SensorType.voltage:
        return 'V';
      case SensorType.current:
        return 'A';
      case SensorType.rpm:
        return 'RPM';
      case SensorType.loadWeight:
        return 'kg';
    }
  }

  @override
  Future<TelemetrySnapshot> getLatestTelemetry(String trainId) async {
    return TelemetrySnapshot(
      timestamp: DateTime.now(),
      trainId: trainId,
      imuX: 0.15,
      imuY: 0.10,
      imuZ: 4.8,
      motorTemp: 44.2,
      bearingBogieTemp: 62.5,
      rpm: 1452.0,
      voltage: 221.5,
      current: 12.8,
      loadWeight: 452.0,
    );
  }
}
