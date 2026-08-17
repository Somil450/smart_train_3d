import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/train/component.dart';
import '../../state/app_state_notifier.dart';
import '../../state/train_state_notifier.dart';
import '../../state/ai_state_notifier.dart';
import '../../state/sensor_state_notifier.dart';
import '../../state/maintenance_state_notifier.dart';
import '../../widgets/common/kpi_card.dart';
import '../../widgets/common/status_chip.dart';
import '../../widgets/digital_train/digital_train_view.dart';
import '../../widgets/digital_train/component_detail_panel.dart';
import '../../widgets/charts/telemetry_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateNotifier>();
    final trainState = context.watch<TrainStateNotifier>();
    final aiState = context.watch<AIStateNotifier>();
    final sensorState = context.watch<SensorStateNotifier>();
    final maintState = context.watch<MaintenanceStateNotifier>();

    final train = trainState.getTrain(appState.selectedTrainId);
    final selectedCompId = appState.selectedComponentId ?? AppConstants.compBearing06;
    final selectedComp = trainState.getComponent(appState.selectedTrainId, selectedCompId);

    // Build Component Status Map for Digital Train View
    final Map<String, ComponentStatus> statusMap = {};
    if (train != null) {
      void mapComponent(TrainComponent c) {
        statusMap[c.id] = c.status;
        for (final child in c.children) {
          mapComponent(child);
        }
      }

      for (final c in train.components) {
        mapComponent(c);
      }
    }

    final primaryFault = aiState.faultPrediction?.primaryFault ?? 'None';
    final aiConfidence = aiState.faultPrediction?.probabilities.isNotEmpty == true
        ? aiState.faultPrediction!.probabilities.first.confidence
        : 0.95;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1-4: Top 4 KPI Cards
          Row(
            children: [
              Expanded(
                child: KPICard(
                  title: '1. TRAIN HEALTH SCORE',
                  value: Formatters.formatPercentage((train?.healthScore ?? 100) / 100),
                  subtitle: 'Overall Rolling Stock Health',
                  icon: Icons.health_and_safety,
                  iconColor: (train?.healthScore ?? 100) < 70 ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KPICard(
                  title: '2. OPERATIONAL STATUS',
                  value: train?.status.name.toUpperCase() ?? 'UNKNOWN',
                  subtitle: 'Current Train Status',
                  icon: Icons.directions_railway,
                  iconColor: Colors.blue,
                  badge: train != null ? StatusChip.fromTrainStatus(train.status) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KPICard(
                  title: '3. ACTIVE FAULTS',
                  value: '${train?.activeFaults.length ?? 0}',
                  subtitle: train?.activeFaults.isNotEmpty == true ? train!.activeFaults.first : 'No active faults',
                  icon: Icons.error_outline,
                  iconColor: train?.activeFaults.isNotEmpty == true ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KPICard(
                  title: '4. AI DIAGNOSIS CONFIDENCE',
                  value: Formatters.formatPercentage(aiConfidence),
                  subtitle: 'Primary: $primaryFault',
                  icon: Icons.psychology,
                  iconColor: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 5 & 6: Digital Train Interactive View + Component Detail Panel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 5: Digital Train
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    DigitalTrainView(
                      selectedBogieId: appState.selectedBogieId,
                      onBogieSelected: (bogieId) => appState.selectBogie(bogieId),
                      selectedComponentId: selectedCompId,
                      onComponentSelected: (compId) => appState.selectComponent(compId),
                      componentStatuses: statusMap,
                      bogies: train?.bogies,
                    ),
                    const SizedBox(height: 16),
                    // Section 6: Active Diagnosis Box
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.saved_search, color: Colors.purple, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '6. PRIMARY ACTIVE DIAGNOSIS',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
                                  ),
                                  Text(
                                    primaryFault,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Localized Component ID: ${aiState.faultPrediction?.localizedComponentId ?? "N/A"}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => appState.setCurrentRoute(AppRoute.faultDetection),
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('View AI Pipeline'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Component Detail Panel
              Expanded(
                flex: 4,
                child: ComponentDetailPanel(
                  component: selectedComp,
                  degradation: aiState.degradation,
                  explanation: aiState.explanation,
                  maintenance: maintState.recommendations.isNotEmpty ? maintState.recommendations.first : null,
                  onNavigateToMaintenance: () => appState.setCurrentRoute(AppRoute.maintenance),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 7, 8, 9: Telemetry & Trend & Maintenance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 7 & 8: Sensor Status & Health Trend Chart
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 280,
                  child: TelemetryChart(
                    title: '8. TRAIN VIBRATION (IMU #2 Z-ACCEL) TELEMETRY TREND',
                    unit: 'g',
                    snapshots: sensorState.historyBuffer,
                    valueExtractor: (s) => s.imu2Z,
                    lineColor: Colors.purple,
                    selectedDurationMinutes: sensorState.chartDurationMinutes,
                    onDurationChanged: (mins) => sensorState.setChartDurationMinutes(mins),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Section 9: Maintenance Recommendations Summary
              Expanded(
                flex: 4,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '9. MAINTENANCE RECOMMENDATIONS',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () => appState.setCurrentRoute(AppRoute.maintenance),
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (maintState.recommendations.isEmpty)
                          const Text('No pending maintenance orders')
                        else
                          ...maintState.recommendations.take(2).map((m) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          m.componentName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      StatusChip(
                                        label: m.priority.name.toUpperCase(),
                                        backgroundColor: Colors.red.shade100,
                                        textColor: Colors.red.shade900,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(m.recommendedAction, style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
