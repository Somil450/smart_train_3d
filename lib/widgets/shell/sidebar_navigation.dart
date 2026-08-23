import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class SidebarNavigation extends StatelessWidget {
  final AppRoute currentRoute;
  final Function(AppRoute route) onRouteSelected;

  const SidebarNavigation({
    super.key,
    required this.currentRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 240,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // App Title Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.train, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        AppConstants.appSubTitle,
                        style: theme.textTheme.labelSmall?.copyWith(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nav Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: [
                // Group 1
                _buildNavItem(context, AppRoute.dashboard, Icons.dashboard_outlined, Icons.dashboard),
                const SizedBox(height: 12),

                _buildGroupHeader(context, 'DEMO SHOWCASE'),
                _buildNavItem(context, AppRoute.fleetDemo, Icons.train_outlined, Icons.train),
                const SizedBox(height: 12),

                _buildGroupHeader(context, 'MONITORING & AI'),
                _buildNavItem(context, AppRoute.trainMonitor, Icons.monitor_heart_outlined, Icons.monitor_heart),
                _buildNavItem(context, AppRoute.vibrationMonitor, Icons.sensors_outlined, Icons.sensors),
                _buildNavItem(context, AppRoute.faultDetection, Icons.error_outline, Icons.error),
                const SizedBox(height: 12),

                _buildGroupHeader(context, 'DIAGNOSTICS'),
                _buildNavItem(context, AppRoute.analytics, Icons.analytics_outlined, Icons.analytics),
                _buildNavItem(context, AppRoute.aiInsights, Icons.psychology_outlined, Icons.psychology),
                const SizedBox(height: 12),

                _buildGroupHeader(context, 'OPERATIONS'),
                _buildNavItem(context, AppRoute.maintenance, Icons.build_outlined, Icons.build),
                _buildNavItem(context, AppRoute.serviceStations, Icons.map_outlined, Icons.map),
                _buildNavItem(context, AppRoute.experimentLab, Icons.science_outlined, Icons.science),
                _buildNavItem(context, AppRoute.history, Icons.history_outlined, Icons.history),
                const SizedBox(height: 12),

                _buildGroupHeader(context, 'SYSTEM'),
                _buildNavItem(context, AppRoute.settings, Icons.settings_outlined, Icons.settings),
              ],
            ),
          ),

          // Footer version info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.desktop_windows, size: 14, color: Colors.grey),
                SizedBox(width: 6),
                Flexible(child: Text('v1.0.0 (SIH Local)', style: TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Colors.grey,
            ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, AppRoute route, IconData icon, IconData activeIcon) {
    final isSelected = currentRoute == route;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primary.withOpacity(0.12),
          selectedColor: theme.colorScheme.primary,
          leading: Icon(isSelected ? activeIcon : icon, size: 20),
          title: Text(
            route.title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          onTap: () => onRouteSelected(route),
        ),
      ),
    );
  }
}
