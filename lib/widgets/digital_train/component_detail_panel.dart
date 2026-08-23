import 'package:flutter/material.dart';
import '../../models/train/component.dart';
import '../../models/ai/degradation_result.dart';
import '../../models/ai/ai_explanation.dart';
import '../../models/maintenance/maintenance_recommendation.dart';
import '../common/status_chip.dart';
import '../../core/utils/formatters.dart';

class ComponentDetailPanel extends StatelessWidget {
  final TrainComponent? component;
  final DegradationResult? degradation;
  final AIExplanation? explanation;
  final MaintenanceRecommendation? maintenance;
  final VoidCallback? onNavigateToMaintenance;

  const ComponentDetailPanel({
    super.key,
    required this.component,
    this.degradation,
    this.explanation,
    this.maintenance,
    this.onNavigateToMaintenance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (component == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Select a component on the digital train or tree to view real-time condition, telemetry and AI evidence.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final comp = component!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comp.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${comp.id} | Location: ${comp.location}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusChip.fromComponentStatus(comp.status),
              ],
            ),
            const Divider(height: 24),

            // Health Score Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HEALTH SCORE',
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  Formatters.formatPercentage(comp.healthScore / 100),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: comp.healthScore < 50 ? Colors.red : (comp.healthScore < 85 ? Colors.amber.shade800 : Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (comp.healthScore / 100).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: theme.dividerColor,
              color: comp.healthScore < 50 ? Colors.red : (comp.healthScore < 85 ? Colors.amber.shade800 : Colors.green),
            ),
            const SizedBox(height: 16),

            // Active Fault Box (if any)
            if (comp.activeFault != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACTIVE DIAGNOSED FAULT',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Text(
                            comp.activeFault!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Sensor Readings
            Text(
              'TELEMETRY READINGS',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: comp.sensorData.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text('${e.key}: ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      Text('${e.value}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Degradation Prediction (if available)
            if (degradation != null) ...[
              Text(
                'DEGRADATION & RUL FORECAST',
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Trend: ${degradation!.trend.name.toUpperCase()}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'RUL Conf: ${Formatters.formatPercentage(degradation!.confidence)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      degradation!.prediction,
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // AI Evidence (if available)
            if (explanation != null && explanation!.evidence.isNotEmpty) ...[
              Text(
                'AI EXPLANATION EVIDENCE',
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...explanation!.evidence.map((ev) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                        Expanded(
                          child: Text(
                            '${ev.description} (${ev.changePercentage})',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Maintenance Recommendation
            if (maintenance != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onNavigateToMaintenance,
                  icon: const Icon(Icons.build, size: 16),
                  label: Text('View Maintenance Order (${maintenance!.priority.name.toUpperCase()})'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
