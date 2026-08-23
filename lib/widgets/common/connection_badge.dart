import 'package:flutter/material.dart';
import '../../models/connection/connection_status.dart';
import '../../core/constants/app_colors.dart';

class ConnectionBadge extends StatelessWidget {
  final String label;
  final ConnectionStateEnum state;

  const ConnectionBadge({
    super.key,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String statusText;

    switch (state) {
      case ConnectionStateEnum.connected:
        dotColor = AppColors.connected;
        statusText = 'ON';
        break;
      case ConnectionStateEnum.connecting:
        dotColor = AppColors.connecting;
        statusText = 'CONNECTING';
        break;
      case ConnectionStateEnum.disconnected:
        dotColor = AppColors.disconnected;
        statusText = 'OFF';
        break;
      case ConnectionStateEnum.error:
        dotColor = AppColors.error;
        statusText = 'ERR';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              color: dotColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
