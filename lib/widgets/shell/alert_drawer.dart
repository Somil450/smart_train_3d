import 'package:flutter/material.dart';
import '../../models/alert/alert_item.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/app_colors.dart';

class AlertDrawer extends StatelessWidget {
  final List<AlertItem> alerts;
  final Function(String id) onMarkAsRead;
  final VoidCallback onClearAll;
  final Function(String componentId)? onSelectComponent;

  const AlertDrawer({
    super.key,
    required this.alerts,
    required this.onMarkAsRead,
    required this.onClearAll,
    this.onSelectComponent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      width: 380,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'GLOBAL ALERTS (${alerts.length})',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: onClearAll,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: alerts.isEmpty
                ? const Center(child: Text('No active alerts'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      Color iconColor = AppColors.normal;
                      if (alert.severity == AlertSeverity.warning) iconColor = AppColors.warning;
                      if (alert.severity == AlertSeverity.critical) iconColor = AppColors.critical;

                      return Card(
                        color: alert.isRead ? theme.cardColor : theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: alert.isRead ? theme.dividerColor : iconColor, width: alert.isRead ? 1 : 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.warning, size: 16, color: iconColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        alert.severity.name.toUpperCase(),
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: iconColor),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    Formatters.formatTimeOnly(alert.timestamp),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                alert.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alert.description,
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Source: ${alert.source}',
                                    style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                                  ),
                                  Row(
                                    children: [
                                      if (onSelectComponent != null)
                                        TextButton(
                                          onPressed: () {
                                            onSelectComponent!(alert.componentId);
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                          child: const Text('View Component', style: TextStyle(fontSize: 11)),
                                        ),
                                      if (!alert.isRead)
                                        IconButton(
                                          icon: const Icon(Icons.check, size: 16),
                                          onPressed: () => onMarkAsRead(alert.id),
                                          tooltip: 'Mark as read',
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
          ),
        ],
      ),
    );
  }
}
