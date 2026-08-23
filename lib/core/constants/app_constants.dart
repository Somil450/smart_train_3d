class AppConstants {
  static const String appName = 'SmartRail AI';
  static const String appSubTitle = 'Condition Monitoring & Predictive Maintenance';

  // Default Endpoints — Node.js proxy at localhost bridges to ESP32 at 10.89.142.193
  static const String defaultBackendUrl = 'http://localhost:8000';
  static const String defaultWebSocketUrl = 'ws://127.0.0.1:8081'; // Node proxy → ESP32:81
  static const String defaultAiEndpoint = 'http://localhost:8000/ai';

  // Active Train Definition
  static const String activeTrainId = 'TRAIN_EXPRESS_R101';
  static const String activeTrainName = 'Express R-101 (Rolling Stock Unit)';

  // Shared Unique Component Identifiers
  static const String compBody = 'BODY_MAIN';
  
  // Bogie Identifiers (Multi-Bogie Train System)
  static const String compBogie01 = 'BOGIE_01';
  static const String compBogie02 = 'BOGIE_02';
  static const String compBogie03 = 'BOGIE_03';
  static const String compBogie04 = 'BOGIE_04';

  // Axle Identifiers across Bogies
  static const String compAxle01 = 'AXLE_01';
  static const String compAxle02 = 'AXLE_02';
  static const String compAxle03 = 'AXLE_03';
  static const String compAxle04 = 'AXLE_04';
  static const String compAxle05 = 'AXLE_05';
  static const String compAxle06 = 'AXLE_06';
  static const String compAxle07 = 'AXLE_07';
  static const String compAxle08 = 'AXLE_08';

  // Wheel Identifiers across Bogies
  static const String compWheel01 = 'WHEEL_01';
  static const String compWheel02 = 'WHEEL_02';
  static const String compWheel03 = 'WHEEL_03';
  static const String compWheel04 = 'WHEEL_04';
  static const String compWheel05 = 'WHEEL_05';
  static const String compWheel06 = 'WHEEL_06';
  static const String compWheel07 = 'WHEEL_07';
  static const String compWheel08 = 'WHEEL_08';

  // Bearing Identifiers across Bogies
  static const String compBearing01 = 'BEARING_01';
  static const String compBearing02 = 'BEARING_02';
  static const String compBearing03 = 'BEARING_03';
  static const String compBearing04 = 'BEARING_04';
  static const String compBearing05 = 'BEARING_05';
  static const String compBearing06 = 'BEARING_06';
  static const String compBearing07 = 'BEARING_07';
  static const String compBearing08 = 'BEARING_08';

  static const String compMotor01 = 'MOTOR_01';
  static const String compMotor02 = 'MOTOR_02';
  static const String compMotor = compMotor01;
  static const String compBrake = 'BRAKE_PRIMARY';
  static const String compSuspension = 'SUSPENSION_MAIN';
  static const String compCoupler = 'COUPLER_FRONT';
}

enum AppRoute {
  dashboard,
  trainMonitor,
  vibrationMonitor,   // NEW – real MQTT vibration feed
  faultDetection,
  analytics,
  aiInsights,
  maintenance,
  experimentLab,
  history,
  settings,
}

extension AppRouteExtension on AppRoute {
  String get title {
    switch (this) {
      case AppRoute.dashboard:
        return 'Dashboard';
      case AppRoute.trainMonitor:
        return 'Train Monitor';
      case AppRoute.vibrationMonitor:
        return 'Vibration Monitor';
      case AppRoute.faultDetection:
        return 'Fault Detection';
      case AppRoute.analytics:
        return 'Analytics';
      case AppRoute.aiInsights:
        return 'AI Insights';
      case AppRoute.maintenance:
        return 'Maintenance';
      case AppRoute.experimentLab:
        return 'Experiment Lab';
      case AppRoute.history:
        return 'History';
      case AppRoute.settings:
        return 'Settings';
    }
  }
}
