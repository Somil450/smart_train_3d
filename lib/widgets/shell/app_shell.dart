import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state_notifier.dart';
import 'sidebar_navigation.dart';
import 'app_header.dart';
import 'alert_drawer.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateNotifier>();

    return Scaffold(
      endDrawer: AlertDrawer(
        alerts: appState.alerts,
        onMarkAsRead: appState.markAlertAsRead,
        onClearAll: appState.clearAllAlerts,
        onSelectComponent: (compId) => appState.selectComponent(compId),
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          SidebarNavigation(
            currentRoute: appState.currentRoute,
            onRouteSelected: (route) => appState.setCurrentRoute(route),
          ),
          const VerticalDivider(width: 1),

          // Main Header + Body Layout
          Expanded(
            child: Column(
              children: [
                Builder(
                  builder: (scaffoldContext) {
                    return AppHeader(
                      currentRoute: appState.currentRoute,
                      connections: appState.connections,
                      isMockMode: appState.isMockMode,
                      onToggleMockMode: (enabled) => appState.setMockMode(enabled),
                      unreadAlertCount: appState.unreadAlertCount,
                      onOpenAlerts: () {
                        Scaffold.of(scaffoldContext).openEndDrawer();
                      },
                    );
                  },
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
