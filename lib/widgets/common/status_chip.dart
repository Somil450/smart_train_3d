import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/train/component.dart';
import '../../models/train/train.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusChip.fromComponentStatus(ComponentStatus status) {
    switch (status) {
      case ComponentStatus.normal:
        return const StatusChip(
          label: 'NORMAL',
          backgroundColor: Color(0xFFD1FAE5),
          textColor: AppColors.normal,
          icon: Icons.check_circle,
        );
      case ComponentStatus.warning:
        return const StatusChip(
          label: 'WARNING',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: AppColors.warning,
          icon: Icons.warning_amber,
        );
      case ComponentStatus.fault:
        return const StatusChip(
          label: 'FAULT',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: AppColors.fault,
          icon: Icons.error,
        );
      case ComponentStatus.noData:
        return const StatusChip(
          label: 'NO DATA',
          backgroundColor: Color(0xFFF3F4F6),
          textColor: AppColors.noData,
          icon: Icons.help_outline,
        );
    }
  }

  factory StatusChip.fromTrainStatus(TrainStatus status) {
    switch (status) {
      case TrainStatus.normal:
        return const StatusChip(
          label: 'HEALTHY',
          backgroundColor: Color(0xFFD1FAE5),
          textColor: AppColors.normal,
          icon: Icons.check_circle_outline,
        );
      case TrainStatus.warning:
        return const StatusChip(
          label: 'WARNING',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: AppColors.warning,
          icon: Icons.warning_amber,
        );
      case TrainStatus.critical:
        return const StatusChip(
          label: 'CRITICAL',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: AppColors.critical,
          icon: Icons.dangerous,
        );
      case TrainStatus.offline:
        return const StatusChip(
          label: 'OFFLINE',
          backgroundColor: Color(0xFFF3F4F6),
          textColor: AppColors.offline,
          icon: Icons.cloud_off,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
