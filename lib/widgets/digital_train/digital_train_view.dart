import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/train/component.dart';

class DigitalTrainView extends StatelessWidget {
  final String? selectedBogieId;
  final Function(String bogieId)? onBogieSelected;
  final String? selectedComponentId;
  final Function(String componentId) onComponentSelected;
  final Map<String, ComponentStatus> componentStatuses;
  final List<TrainComponent>? bogies;

  const DigitalTrainView({
    super.key,
    this.selectedBogieId,
    this.onBogieSelected,
    required this.selectedComponentId,
    required this.onComponentSelected,
    required this.componentStatuses,
    this.bogies,
  });

  Color _getStatusColor(String compId) {
    final status = componentStatuses[compId] ?? ComponentStatus.normal;
    switch (status) {
      case ComponentStatus.normal:
        return AppColors.normal;
      case ComponentStatus.warning:
        return AppColors.warning;
      case ComponentStatus.fault:
        return AppColors.fault;
      case ComponentStatus.noData:
        return AppColors.noData;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default bogies definition if list not provided
    final activeBogies = (bogies != null && bogies!.isNotEmpty)
        ? bogies!
        : [
            TrainComponent(
              id: AppConstants.compBogie01,
              name: 'Bogie 1',
              type: ComponentType.bogie,
              location: 'Lead',
              status: componentStatuses[AppConstants.compBogie01] ?? ComponentStatus.normal,
              healthScore: 96.0,
              sensorData: {},
              lastUpdated: DateTime.now(),
            ),
            TrainComponent(
              id: AppConstants.compBogie02,
              name: 'Bogie 2',
              type: ComponentType.bogie,
              location: 'Center 1',
              status: componentStatuses[AppConstants.compBogie02] ?? ComponentStatus.normal,
              healthScore: 92.5,
              sensorData: {},
              lastUpdated: DateTime.now(),
            ),
            TrainComponent(
              id: AppConstants.compBogie03,
              name: 'Bogie 3',
              type: ComponentType.bogie,
              location: 'Center 2',
              status: componentStatuses[AppConstants.compBogie03] ?? ComponentStatus.fault,
              healthScore: 38.5,
              sensorData: {},
              lastUpdated: DateTime.now(),
            ),
            TrainComponent(
              id: AppConstants.compBogie04,
              name: 'Bogie 4',
              type: ComponentType.bogie,
              location: 'Trail',
              status: componentStatuses[AppConstants.compBogie04] ?? ComponentStatus.normal,
              healthScore: 95.0,
              sensorData: {},
              lastUpdated: DateTime.now(),
            ),
          ];

    // Determine current selected bogie (default to Bogie 3 if fault, or first bogie)
    final activeBogieId = selectedBogieId ?? AppConstants.compBogie03;
    final selectedBogieIndex = activeBogies.indexWhere((b) => b.id == activeBogieId);
    final validIndex = selectedBogieIndex != -1 ? selectedBogieIndex : 0;
    final selectedBogie = activeBogies[validIndex];
    final bogieColor = _getStatusColor(selectedBogie.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.train, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'DIGITAL TWIN - BOGIE MONITOR',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'EXPRESS R-101 UNIT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    _buildLegendItem('Normal', AppColors.normal),
                    const SizedBox(width: 12),
                    _buildLegendItem('Warning', AppColors.warning),
                    const SizedBox(width: 12),
                    _buildLegendItem('Fault', AppColors.fault),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Layout: Bogie Selector (Left) + Single Selected Bogie Schematic (Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BOGIE SELECTOR PANEL (Left)
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BOGIE LIST',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${activeBogies.length} UNITS',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(activeBogies.length, (idx) {
                      final b = activeBogies[idx];
                      final isSelected = b.id == selectedBogie.id;
                      final statusColor = _getStatusColor(b.id);
                      final isFault = b.status == ComponentStatus.fault;

                      final axle1Num = (idx * 2) + 1;
                      final axle2Num = (idx * 2) + 2;
                      final motorName = idx < 2 ? 'Motor 1' : 'Motor 2';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (onBogieSelected != null) {
                                onBogieSelected!(b.id);
                              }
                              onComponentSelected(b.id);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isFault ? Colors.red.shade50 : Colors.blue.shade50)
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? (isFault ? Colors.red.shade600 : Colors.blue.shade600)
                                      : statusColor.withOpacity(0.4),
                                  width: isSelected ? 2.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'BOGIE ${idx + 1} (${b.location.toUpperCase()})',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? (isFault ? Colors.red.shade900 : Colors.blue.shade900)
                                                : theme.textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                      if (isFault)
                                        const Icon(Icons.warning, size: 12, color: Colors.red),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Sub-component Quick Breakdown Tags
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      _buildComponentTag(
                                        'Axle $axle1Num, $axle2Num',
                                        Colors.grey.shade700,
                                        Colors.grey.shade100,
                                      ),
                                      _buildComponentTag(
                                        '4 Wheels',
                                        Colors.blue.shade800,
                                        Colors.blue.shade50,
                                      ),
                                      _buildComponentTag(
                                        isFault ? 'Bearing 6 FAULT' : '4 Bearings',
                                        isFault ? Colors.red.shade800 : Colors.teal.shade800,
                                        isFault ? Colors.red.shade100 : Colors.teal.shade50,
                                      ),
                                      _buildComponentTag(
                                        motorName,
                                        Colors.amber.shade900,
                                        Colors.amber.shade50,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const VerticalDivider(width: 1),
              const SizedBox(width: 12),

              // 2. SINGLE SELECTED BOGIE SCHEMATIC (Right)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bogieColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: bogieColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected Bogie Header Status Banner
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${selectedBogie.name.toUpperCase()} SCHEMATIC',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '(${selectedBogie.location})',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: bogieColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: bogieColor),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selectedBogie.status == ComponentStatus.fault
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_outline,
                                  size: 14,
                                  color: bogieColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'STATUS: ${selectedBogie.status.name.toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: bogieColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Detailed Single Bogie Physical Schematic Layout
                      _buildSingleBogieSchematic(
                        context,
                        bogieIndex: validIndex,
                        bogie: selectedBogie,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleBogieSchematic(
    BuildContext context, {
    required int bogieIndex,
    required TrainComponent bogie,
  }) {
    final axle1Num = (bogieIndex * 2) + 1;
    final axle2Num = (bogieIndex * 2) + 2;

    final axle1Id = 'AXLE_${axle1Num.toString().padLeft(2, '0')}';
    final axle2Id = 'AXLE_${axle2Num.toString().padLeft(2, '0')}';
    final wheel1Id = 'WHEEL_${axle1Num.toString().padLeft(2, '0')}';
    final wheel2Id = 'WHEEL_${axle2Num.toString().padLeft(2, '0')}';
    final bearing1Id = 'BEARING_${axle1Num.toString().padLeft(2, '0')}';
    final bearing2Id = 'BEARING_${axle2Num.toString().padLeft(2, '0')}';

    final motorId = bogieIndex < 2 ? AppConstants.compMotor01 : AppConstants.compMotor02;
    final motorLabel = bogieIndex < 2 ? 'TRACTION MOTOR 1' : 'TRACTION MOTOR 2';

    return Column(
      children: [
        // Top Row: Axle Assemblies (Axle 1 & Axle 2 of this Bogie)
        Row(
          children: [
            Expanded(
              child: _buildAxleAssembly(
                context,
                axleId: axle1Id,
                wheelId: wheel1Id,
                bearingId: bearing1Id,
                axleTitle: 'AXLE $axle1Num (FRONT)',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAxleAssembly(
                context,
                axleId: axle2Id,
                wheelId: wheel2Id,
                bearingId: bearing2Id,
                axleTitle: 'AXLE $axle2Num (REAR)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bottom Row: Traction Motor, Suspension, Brake Units
        Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildInteractiveComponent(
                context,
                id: motorId,
                label: motorLabel,
                icon: Icons.electric_bolt,
                height: 48,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: _buildInteractiveComponent(
                context,
                id: AppConstants.compSuspension,
                label: 'PRIMARY SUSPENSION',
                icon: Icons.compress,
                height: 48,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: _buildInteractiveComponent(
                context,
                id: AppConstants.compBrake,
                label: 'BRAKE UNIT',
                icon: Icons.speed,
                height: 48,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAxleAssembly(
    BuildContext context, {
    required String axleId,
    required String wheelId,
    required String bearingId,
    required String axleTitle,
  }) {
    final theme = Theme.of(context);
    final axleColor = _getStatusColor(axleId);
    final wheelColor = _getStatusColor(wheelId);
    final bearingColor = _getStatusColor(bearingId);

    final isAxleSelected = selectedComponentId == axleId;
    final isWheelSelected = selectedComponentId == wheelId;
    final isBearingSelected = selectedComponentId == bearingId;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // Axle Header Clickable Bar
          InkWell(
            onTap: () => onComponentSelected(axleId),
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAxleSelected ? axleColor.withOpacity(0.25) : axleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isAxleSelected ? Colors.blue.shade600 : axleColor,
                  width: isAxleSelected ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      axleTitle,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: axleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.crop_16_9, size: 12, color: axleColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Wheel & Bearing Components
          Row(
            children: [
              // Wheel Component
              Expanded(
                child: InkWell(
                  onTap: () => onComponentSelected(wheelId),
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isWheelSelected ? wheelColor.withOpacity(0.3) : wheelColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isWheelSelected ? Colors.blue.shade600 : wheelColor,
                        width: isWheelSelected ? 2.5 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.tire_repair, size: 14, color: wheelColor),
                        const SizedBox(height: 2),
                        Text(
                          'WHEEL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isWheelSelected ? FontWeight.bold : FontWeight.w600,
                            color: wheelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Journal Bearing Component
              Expanded(
                child: InkWell(
                  onTap: () => onComponentSelected(bearingId),
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isBearingSelected ? bearingColor.withOpacity(0.35) : bearingColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isBearingSelected ? Colors.blue.shade600 : bearingColor,
                        width: isBearingSelected ? 2.5 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          bearingColor == AppColors.fault ? Icons.warning : Icons.adjust,
                          size: 14,
                          color: bearingColor,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'BEARING',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isBearingSelected ? FontWeight.bold : FontWeight.w600,
                            color: bearingColor,
                          ),
                        ),
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildComponentTag(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInteractiveComponent(
    BuildContext context, {
    required String id,
    required String label,
    IconData? icon,
    double height = 48,
  }) {
    final isSelected = selectedComponentId == id;
    final color = _getStatusColor(id);

    return InkWell(
      onTap: () => onComponentSelected(id),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.25) : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : color,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 14, color: color),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

