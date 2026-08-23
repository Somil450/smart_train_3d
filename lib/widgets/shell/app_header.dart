import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/connection/connection_status.dart';
import '../common/connection_badge.dart';

class AppHeader extends StatelessWidget {
  final AppRoute currentRoute;
  final SystemConnections connections;
  final bool isMockMode;
  final Function(bool enabled) onToggleMockMode;
  final int unreadAlertCount;
  final VoidCallback onOpenAlerts;

  const AppHeader({
    super.key,
    required this.currentRoute,
    required this.connections,
    required this.isMockMode,
    required this.onToggleMockMode,
    required this.unreadAlertCount,
    required this.onOpenAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Current Page Title
            Text(
              currentRoute.title.toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 24),

            // Active Single Train Instance Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_railway, size: 18, color: Colors.blue.shade800),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.activeTrainName.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '4 BOGIES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // System Connection Badges
            Row(
              children: [
                ConnectionBadge(label: 'Sensor', state: connections.sensor),
                const SizedBox(width: 6),
                ConnectionBadge(label: 'AI', state: connections.ai),
                const SizedBox(width: 6),
                ConnectionBadge(label: 'Backend', state: connections.backend),
                const SizedBox(width: 6),
                ConnectionBadge(label: 'Camera', state: connections.camera),
              ],
            ),
            const SizedBox(width: 16),

            // Mock vs Live Mode Toggle
            Row(
              children: [
                Text(
                  isMockMode ? 'MOCK DATA' : 'LIVE DATA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isMockMode ? Colors.amber.shade800 : Colors.green,
                  ),
                ),
                Switch(
                  value: isMockMode,
                  onChanged: onToggleMockMode,
                  activeThumbColor: Colors.amber.shade800,
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Alert Notification Drawer Button
            IconButton(
              onPressed: onOpenAlerts,
              icon: Badge(
                label: Text('$unreadAlertCount'),
                isLabelVisible: unreadAlertCount > 0,
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
