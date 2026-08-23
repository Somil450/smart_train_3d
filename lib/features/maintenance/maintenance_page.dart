import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/maintenance/maintenance_recommendation.dart';
import '../../state/maintenance_state_notifier.dart';
import '../../state/app_state_notifier.dart';
import '../../core/utils/formatters.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final maintState = context.watch<MaintenanceStateNotifier>();
    final appState = context.watch<AppStateNotifier>();
    final theme = Theme.of(context);

    final recommendations = maintState.recommendations;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PREDICTIVE MAINTENANCE & WORK ORDER WORKFLOW',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => maintState.loadRecommendations(appState.selectedTrainId),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Orders'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Maintenance Workflow Banner
          Card(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _WorkflowStep('1. DETECTED', true),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  _WorkflowStep('2. PENDING REVIEW', true),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  _WorkflowStep('3. ACKNOWLEDGED', true),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  _WorkflowStep('4. MAINTENANCE COMPLETED', true),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  _WorkflowStep('5. RESOLVED', true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Maintenance Recommendations List
          if (recommendations.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No active maintenance recommendations.')),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildPriorityBadge(item.priority),
                                const SizedBox(width: 8),
                                Text(
                                  item.componentName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Text('(ID: ${item.componentId})', style: theme.textTheme.bodySmall),
                              ],
                            ),
                            _buildStatusChip(item.status),
                          ],
                        ),
                        const Divider(height: 20),

                        // Reason & Recommended Action
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('DIAGNOSED FAULT & REASON',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(item.faultType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                                  const SizedBox(height: 4),
                                  Text(item.reason, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('RECOMMENDED ACTION',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(item.recommendedAction, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Timestamp & Operator Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Created: ${Formatters.formatDateTime(item.createdAt)}${item.updatedAt != null ? " | Updated: ${Formatters.formatDateTime(item.updatedAt!)}" : ""}',
                              style: theme.textTheme.bodySmall,
                            ),
                            Row(
                              children: [
                                if (item.status == MaintenanceStatus.pendingReview || item.status == MaintenanceStatus.detected)
                                  ElevatedButton.icon(
                                    onPressed: () => maintState.updateStatus(item.id, MaintenanceStatus.acknowledged),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Acknowledge'),
                                  ),
                                if (item.status == MaintenanceStatus.acknowledged)
                                  ElevatedButton.icon(
                                    onPressed: () => maintState.updateStatus(item.id, MaintenanceStatus.resolved),
                                    icon: const Icon(Icons.done_all, size: 16),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    label: const Text('Mark Resolved'),
                                  ),
                                if (item.status == MaintenanceStatus.resolved)
                                  OutlinedButton.icon(
                                    onPressed: () => maintState.updateStatus(item.id, MaintenanceStatus.pendingReview),
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Reopen Order'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(MaintenancePriority priority) {
    Color color;
    switch (priority) {
      case MaintenancePriority.low:
        color = Colors.blue;
        break;
      case MaintenancePriority.medium:
        color = Colors.amber.shade800;
        break;
      case MaintenancePriority.high:
        color = Colors.orange.shade900;
        break;
      case MaintenancePriority.critical:
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildStatusChip(MaintenanceStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case MaintenanceStatus.detected:
      case MaintenanceStatus.pendingReview:
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        break;
      case MaintenanceStatus.acknowledged:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
      case MaintenanceStatus.maintenanceCompleted:
      case MaintenanceStatus.resolved:
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final String title;
  final bool active;

  const _WorkflowStep(this.title, this.active);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: active ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
    );
  }
}
