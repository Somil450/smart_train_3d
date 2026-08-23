import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartrail_ai/main.dart';
import 'package:smartrail_ai/repositories/train_repository.dart';
import 'package:smartrail_ai/repositories/sensor_repository.dart';
import 'package:smartrail_ai/repositories/ai_repository.dart';
import 'package:smartrail_ai/repositories/inspection_repository.dart';
import 'package:smartrail_ai/repositories/maintenance_repository.dart';
import 'package:smartrail_ai/repositories/experiment_repository.dart';
import 'package:smartrail_ai/repositories/history_repository.dart';
import 'package:smartrail_ai/services/simulation/simulation_engine.dart';
import 'package:smartrail_ai/state/app_state_notifier.dart';
import 'package:smartrail_ai/state/train_state_notifier.dart';
import 'package:smartrail_ai/state/sensor_state_notifier.dart';
import 'package:smartrail_ai/state/ai_state_notifier.dart';
import 'package:smartrail_ai/state/inspection_state_notifier.dart';
import 'package:smartrail_ai/state/maintenance_state_notifier.dart';
import 'package:smartrail_ai/state/experiment_state_notifier.dart';
import 'package:smartrail_ai/state/history_state_notifier.dart';

void main() {
  testWidgets('SmartRailApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final trainRepo = MockTrainRepository();
    final sensorRepo = MockSensorRepository();
    final aiRepo = MockAIRepository();
    final inspectionRepo = MockInspectionRepository();
    final maintenanceRepo = MockMaintenanceRepository();
    final experimentRepo = MockExperimentRepository();
    final historyRepo = MockHistoryRepository();
    final simEngine = SimulationEngine();
    addTearDown(simEngine.stop);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<TrainRepository>.value(value: trainRepo),
          Provider<SensorRepository>.value(value: sensorRepo),
          Provider<AIRepository>.value(value: aiRepo),
          Provider<InspectionRepository>.value(value: inspectionRepo),
          Provider<MaintenanceRepository>.value(value: maintenanceRepo),
          Provider<ExperimentRepository>.value(value: experimentRepo),
          Provider<HistoryRepository>.value(value: historyRepo),
          Provider<SimulationEngine>.value(value: simEngine),

          ChangeNotifierProvider(create: (_) => AppStateNotifier()),
          ChangeNotifierProvider(create: (_) => TrainStateNotifier(trainRepo)),
          ChangeNotifierProvider(create: (_) => SensorStateNotifier(sensorRepo)),
          ChangeNotifierProvider(create: (_) => AIStateNotifier(aiRepo)),
          ChangeNotifierProvider(create: (_) => InspectionStateNotifier(inspectionRepo)),
          ChangeNotifierProvider(create: (_) => MaintenanceStateNotifier(maintenanceRepo)),
          ChangeNotifierProvider(create: (_) => ExperimentStateNotifier(experimentRepo)),
          ChangeNotifierProvider(create: (_) => HistoryStateNotifier(historyRepo)),
        ],
        child: const SmartRailApp(),
      ),
    );

    await tester.pump();
    expect(find.textContaining('EXPRESS R-101'), findsAtLeast(1));

    simEngine.stop();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
