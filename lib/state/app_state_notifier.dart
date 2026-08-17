import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/connection/connection_status.dart';
import '../models/alert/alert_item.dart';

class AppStateNotifier extends ChangeNotifier {
  final String _selectedTrainId = AppConstants.activeTrainId;
  String _selectedBogieId = AppConstants.compBogie03;
  AppRoute _currentRoute = AppRoute.dashboard;
  bool _isMockMode = true;
  String? _selectedComponentId = AppConstants.compBearing06;

  SystemConnections _connections = SystemConnections(
    sensor: ConnectionStateEnum.connected,
    ai: ConnectionStateEnum.connected,
    backend: ConnectionStateEnum.connected,
    camera: ConnectionStateEnum.connected,
    database: ConnectionStateEnum.connected,
  );

  String _backendUrl = AppConstants.defaultBackendUrl;
  String _webSocketUrl = AppConstants.defaultWebSocketUrl;
  String _aiEndpoint = AppConstants.defaultAiEndpoint;
  String _cameraEndpoint = AppConstants.defaultCameraEndpoint;

  final List<AlertItem> _alerts = [
    AlertItem(
      id: 'ALT_001',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      trainId: AppConstants.activeTrainId,
      componentId: AppConstants.compBearing06,
      severity: AlertSeverity.critical,
      title: 'Bogie 3 Axle 6 Bearing Defect',
      description: 'Bogie 3 Axle 6 Journal Bearing vibration amplitude spikes detected (4.8g). AI Anomaly Confidence 78.4%.',
      source: 'AI Anomaly Engine',
    ),
    AlertItem(
      id: 'ALT_002',
      timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
      trainId: AppConstants.activeTrainId,
      componentId: AppConstants.compBearing06,
      severity: AlertSeverity.warning,
      title: 'Bogie 3 Bearing Thermal Rise',
      description: 'Bogie 3 journal bearing operating temp reached 62.5°C (+18°C above baseline).',
      source: 'Sensor Node ESP32',
    ),
    AlertItem(
      id: 'ALT_003',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      trainId: AppConstants.activeTrainId,
      componentId: AppConstants.compWheel03,
      severity: AlertSeverity.info,
      title: 'Computer Vision Wheel Defect Detected',
      description: 'Camera frame #89 detected micro-flange wear on Bogie 2 Axle 3 wheel.',
      source: 'Computer Vision CV-Node',
    ),
  ];

  // Getters
  String get selectedTrainId => _selectedTrainId;
  String get selectedBogieId => _selectedBogieId;
  AppRoute get currentRoute => _currentRoute;
  bool get isMockMode => _isMockMode;
  String? get selectedComponentId => _selectedComponentId;
  SystemConnections get connections => _connections;
  String get backendUrl => _backendUrl;
  String get webSocketUrl => _webSocketUrl;
  String get aiEndpoint => _aiEndpoint;
  String get cameraEndpoint => _cameraEndpoint;
  List<AlertItem> get alerts => List.unmodifiable(_alerts);

  int get unreadAlertCount => _alerts.where((a) => !a.isRead).length;

  void selectBogie(String bogieId) {
    if (_selectedBogieId != bogieId) {
      _selectedBogieId = bogieId;
      notifyListeners();
    }
  }

  void setCurrentRoute(AppRoute route) {
    if (_currentRoute != route) {
      _currentRoute = route;
      notifyListeners();
    }
  }

  void selectComponent(String componentId) {
    _selectedComponentId = componentId;
    notifyListeners();
  }

  void setMockMode(bool enabled) {
    _isMockMode = enabled;
    notifyListeners();
  }

  void updateEndpoints({
    String? backendUrl,
    String? webSocketUrl,
    String? aiEndpoint,
    String? cameraEndpoint,
  }) {
    if (backendUrl != null) _backendUrl = backendUrl;
    if (webSocketUrl != null) _webSocketUrl = webSocketUrl;
    if (aiEndpoint != null) _aiEndpoint = aiEndpoint;
    if (cameraEndpoint != null) _cameraEndpoint = cameraEndpoint;
    notifyListeners();
  }

  void updateConnectionState(SystemConnections connections) {
    _connections = connections;
    notifyListeners();
  }

  void markAlertAsRead(String alertId) {
    final idx = _alerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      _alerts[idx] = _alerts[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void clearAllAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  void addAlert(AlertItem alert) {
    _alerts.insert(0, alert);
    notifyListeners();
  }
}
