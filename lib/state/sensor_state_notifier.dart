import 'package:flutter/material.dart';
import '../models/sensor/sensor_reading.dart';
import '../repositories/sensor_repository.dart';

class SensorStateNotifier extends ChangeNotifier {
  final SensorRepository _sensorRepository;

  TelemetrySnapshot? _latestTelemetry;
  final List<TelemetrySnapshot> _historyBuffer = [];
  int _chartDurationMinutes = 15;
  bool _isLoading = false;

  SensorStateNotifier(this._sensorRepository);

  TelemetrySnapshot? get latestTelemetry => _latestTelemetry;
  List<TelemetrySnapshot> get historyBuffer => List.unmodifiable(_historyBuffer);
  int get chartDurationMinutes => _chartDurationMinutes;
  bool get isLoading => _isLoading;

  void setChartDurationMinutes(int durationMinutes) {
    _chartDurationMinutes = durationMinutes;
    notifyListeners();
  }

  Future<void> initMockTelemetry(String trainId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _latestTelemetry = await _sensorRepository.getLatestTelemetry(trainId);
      
      // Seed buffer with historical points
      _historyBuffer.clear();
      final now = DateTime.now();
      for (int i = 60; i >= 0; i--) {
        final time = now.subtract(Duration(seconds: i * 5));
        _historyBuffer.add(
          TelemetrySnapshot(
            timestamp: time,
            trainId: trainId,
            imu1X: 0.12 + (i % 2) * 0.01,
            imu1Y: 0.08 + (i % 3) * 0.01,
            imu1Z: 0.98 + (i % 4) * 0.02,
            imu2X: 0.15 + (i % 5) * 0.02,
            imu2Y: 0.10 + (i % 3) * 0.01,
            imu2Z: 0.6 + (60 - i) * 0.07,
            motorTemp: 42.0 + (60 - i) * 0.04,
            bearingBogieTemp: 38.0 + (60 - i) * 0.4,
            rpm: 1450.0 + (i % 7) * 4,
            voltage: 220.0 + (i % 3),
            current: 12.5 + (i % 2) * 0.3,
            loadWeight: 450.0 + (i % 4) * 2,
            ambientTemp: 26.0 + (i % 2) * 0.2,
            humidity: 55.0,
            irDetection: true,
            gpsAvailable: true,
            gpsPosition: '12.9716° N, 77.5946° E',
          ),
        );
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFromSnapshot(TelemetrySnapshot snapshot) {
    _latestTelemetry = snapshot;
    _historyBuffer.add(snapshot);

    // Keep max 300 points
    if (_historyBuffer.length > 300) {
      _historyBuffer.removeAt(0);
    }
    notifyListeners();
  }
}
