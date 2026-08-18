import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

import 'repositories/train_repository.dart';
import 'repositories/sensor_repository.dart';
import 'repositories/ai_repository.dart';
import 'repositories/inspection_repository.dart';
import 'repositories/maintenance_repository.dart';
import 'repositories/experiment_repository.dart';
import 'repositories/history_repository.dart';

import 'services/simulation/simulation_engine.dart';

import 'state/app_state_notifier.dart';
import 'state/train_state_notifier.dart';
import 'state/sensor_state_notifier.dart';
import 'state/ai_state_notifier.dart';
import 'state/inspection_state_notifier.dart';
import 'state/maintenance_state_notifier.dart';
import 'state/experiment_state_notifier.dart';
import 'state/history_state_notifier.dart';

import 'widgets/shell/app_shell.dart';

import 'features/dashboard/dashboard_page.dart';
import 'features/train_monitor/train_monitor_page.dart';
import 'features/fault_detection/fault_detection_page.dart';
import 'features/inspection/inspection_page.dart';
import 'features/analytics/analytics_page.dart';
import 'features/ai_insights/ai_insights_page.dart';
import 'features/maintenance/maintenance_page.dart';
import 'features/experiment_lab/experiment_lab_page.dart';
import 'features/history/history_page.dart';
import 'features/settings/settings_page.dart';
import 'features/vibration_monitor/vibration_monitor_page.dart';
import 'services/mqtt/mqtt_service.dart';
import 'state/mqtt_vibration_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate Repositories
  final trainRepository = MockTrainRepository();
  final sensorRepository = MockSensorRepository();
  final aiRepository = MockAIRepository();
  final inspectionRepository = MockInspectionRepository();
  final maintenanceRepository = MockMaintenanceRepository();
  final experimentRepository = MockExperimentRepository();
  final historyRepository = MockHistoryRepository();

  // MQTT vibration service
  final mqttService = MqttService();
  final mqttVibrationNotifier = MqttVibrationNotifier(mqttService);
  await mqttVibrationNotifier.init();

  // Instantiate Simulation Engine
  final simulationEngine = SimulationEngine();

  runApp(
    MultiProvider(
      providers: [
        Provider<TrainRepository>.value(value: trainRepository),
        Provider<SensorRepository>.value(value: sensorRepository),
        Provider<AIRepository>.value(value: aiRepository),
        Provider<InspectionRepository>.value(value: inspectionRepository),
        Provider<MaintenanceRepository>.value(value: maintenanceRepository),
        Provider<ExperimentRepository>.value(value: experimentRepository),
        Provider<HistoryRepository>.value(value: historyRepository),
        Provider<SimulationEngine>.value(value: simulationEngine),
        ChangeNotifierProvider.value(value: mqttVibrationNotifier),

        ChangeNotifierProvider(create: (_) => AppStateNotifier()),
        ChangeNotifierProvider(create: (_) => TrainStateNotifier(trainRepository)),
        ChangeNotifierProvider(create: (_) => SensorStateNotifier(sensorRepository)),
        ChangeNotifierProvider(create: (_) => AIStateNotifier(aiRepository)),
        ChangeNotifierProvider(create: (_) => InspectionStateNotifier(inspectionRepository)),
        ChangeNotifierProvider(create: (_) => MaintenanceStateNotifier(maintenanceRepository)),
        ChangeNotifierProvider(create: (_) => ExperimentStateNotifier(experimentRepository)),
        ChangeNotifierProvider(create: (_) => HistoryStateNotifier(historyRepository)),
      ],
      child: const SmartRailApp(),
    ),
  );
}

class SmartRailApp extends StatefulWidget {
  const SmartRailApp({super.key});

  @override
  State<SmartRailApp> createState() => _SmartRailAppState();
}

class _SmartRailAppState extends State<SmartRailApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApplicationState();
    });
  }

  void _initializeApplicationState() {
    final appState = context.read<AppStateNotifier>();
    final trainId = appState.selectedTrainId;

    context.read<TrainStateNotifier>().loadTrains(trainId);
    context.read<SensorStateNotifier>().initMockTelemetry(trainId);
    context.read<AIStateNotifier>().loadAIData(trainId);
    context.read<InspectionStateNotifier>().loadInspection(trainId);
    context.read<MaintenanceStateNotifier>().loadRecommendations(trainId);
    context.read<ExperimentStateNotifier>().loadExperiments(trainId);
    context.read<HistoryStateNotifier>().loadHistory(trainId);

    // Connect Simulation Stream to Sensor State Notifier
    final simEngine = context.read<SimulationEngine>();
    simEngine.start();
    simEngine.telemetryStream.listen((snapshot) {
      if (mounted) {
        context.read<SensorStateNotifier>().updateFromSnapshot(snapshot);
      }
    });
  }

  @override
  void dispose() {
    try {
      context.read<SimulationEngine>().stop();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const MainRouterShell(),
    );
  }
}

class MainRouterShell extends StatelessWidget {
  const MainRouterShell({super.key});

  @override
  Widget build(BuildContext context) {
    final route = context.watch<AppStateNotifier>().currentRoute;

    Widget pageBody;
    switch (route) {
      case AppRoute.dashboard:
        pageBody = const DashboardPage();
        break;
      case AppRoute.trainMonitor:
        pageBody = const TrainMonitorPage();
        break;
      case AppRoute.vibrationMonitor:
        pageBody = const VibrationMonitorPage();
        break;
      case AppRoute.faultDetection:
        pageBody = const FaultDetectionPage();
        break;
      case AppRoute.inspection:
        pageBody = const InspectionPage();
        break;
      case AppRoute.analytics:
        pageBody = const AnalyticsPage();
        break;
      case AppRoute.aiInsights:
        pageBody = const AIInsightsPage();
        break;
      case AppRoute.maintenance:
        pageBody = const MaintenancePage();
        break;
      case AppRoute.experimentLab:
        pageBody = const ExperimentLabPage();
        break;
      case AppRoute.history:
        pageBody = const HistoryPage();
        break;
      case AppRoute.settings:
        pageBody = const SettingsPage();
        break;
    }

    return AppShell(child: pageBody);
  }
}
