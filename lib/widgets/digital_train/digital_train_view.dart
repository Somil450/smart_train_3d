import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/train/component.dart';

class DigitalTrainView extends StatelessWidget {
  final String? selectedComponentId;
  final Function(String componentId) onComponentSelected;
  final Map<String, ComponentStatus> componentStatuses;
  final List<TrainComponent>? bogies;

  const DigitalTrainView({
    super.key,
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

    // Default bogie definitions if list not passed
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

    final double bogieSpacing = 160.0;
    final double startOffset = 70.0;
    final double canvasWidth = (activeBogies.length * bogieSpacing) + 120.0;

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
                      'DIGITAL TWIN MULTI-BOGIE SCHEMATIC',
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
                        '${activeBogies.length} BOGIES DETECTED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
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

          // Interactive Multi-Bogie Schematic Canvas Layout
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: canvasWidth < 820 ? 820 : canvasWidth,
              height: 230,
              child: Stack(
                children: [
                  // Train Main Body Shell across all bogies
                  Positioned(
                    left: 50,
                    top: 20,
                    width: canvasWidth - 100,
                    height: 85,
                    child: _buildInteractiveComponent(
                      context,
                      id: AppConstants.compBody,
                      label: 'TRAIN CAR BODY SHELL & INTEGRATED CHASSIS',
                      icon: Icons.directions_railway,
                      height: 85,
                    ),
                  ),

                  // Front Coupler
                  Positioned(
                    left: 5,
                    top: 45,
                    width: 40,
                    height: 40,
                    child: _buildInteractiveComponent(
                      context,
                      id: AppConstants.compCoupler,
                      label: 'COUPLER',
                      height: 40,
                    ),
                  ),

                  // Traction Motor 1
                  Positioned(
                    left: startOffset + (bogieSpacing * 0.5),
                    top: 110,
                    width: 80,
                    height: 40,
                    child: _buildInteractiveComponent(
                      context,
                      id: AppConstants.compMotor01,
                      label: 'MOTOR 1',
                      icon: Icons.electric_bolt,
                      height: 40,
                    ),
                  ),

                  // Traction Motor 2
                  if (activeBogies.length >= 3)
                    Positioned(
                      left: startOffset + (bogieSpacing * 2.5),
                      top: 110,
                      width: 80,
                      height: 40,
                      child: _buildInteractiveComponent(
                        context,
                        id: AppConstants.compMotor02,
                        label: 'MOTOR 2',
                        icon: Icons.electric_bolt,
                        height: 40,
                      ),
                    ),

                  // Dynamic Bogies Assembly Rendering (Bogie 1, 2, 3, ... N)
                  ...List.generate(activeBogies.length, (index) {
                    final bogie = activeBogies[index];
                    final leftPos = startOffset + (index * bogieSpacing);
                    final bogieNum = index + 1;
                    final axle1Num = (index * 2) + 1;
                    final axle2Num = (index * 2) + 2;

                    final axle1Id = 'AXLE_${axle1Num.toString().padLeft(2, '0')}';
                    final axle2Id = 'AXLE_${axle2Num.toString().padLeft(2, '0')}';
                    final wheel1Id = 'WHEEL_${axle1Num.toString().padLeft(2, '0')}';
                    final wheel2Id = 'WHEEL_${axle2Num.toString().padLeft(2, '0')}';
                    final bearing1Id = 'BEARING_${axle1Num.toString().padLeft(2, '0')}';
                    final bearing2Id = 'BEARING_${axle2Num.toString().padLeft(2, '0')}';

                    final isBogieSelected = selectedComponentId == bogie.id;
                    final bogieColor = _getStatusColor(bogie.id);

                    return Positioned(
                      left: leftPos,
                      top: 115,
                      width: 145,
                      height: 100,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isBogieSelected ? bogieColor.withOpacity(0.25) : theme.colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isBogieSelected ? Colors.blue.shade600 : bogieColor,
                            width: isBogieSelected ? 3 : 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => onComponentSelected(bogie.id),
                              child: Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'BOGIE $bogieNum',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: bogieColor,
                                      ),
                                    ),
                                    Icon(Icons.touch_app, size: 10, color: bogieColor),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWheelAxlePair(
                                  context,
                                  axleId: axle1Id,
                                  wheelId: wheel1Id,
                                  bearingId: bearing1Id,
                                  axleName: 'Axle $axle1Num',
                                ),
                                _buildWheelAxlePair(
                                  context,
                                  axleId: axle2Id,
                                  wheelId: wheel2Id,
                                  bearingId: bearing2Id,
                                  axleName: 'Axle $axle2Num',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
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

  Widget _buildInteractiveComponent(
    BuildContext context, {
    required String id,
    required String label,
    IconData? icon,
    double height = 50,
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
            width: isSelected ? 3 : 1.5,
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

  Widget _buildWheelAxlePair(
    BuildContext context, {
    required String axleId,
    required String wheelId,
    required String bearingId,
    required String axleName,
  }) {
    final isWheelSelected = selectedComponentId == wheelId;
    final isBearingSelected = selectedComponentId == bearingId;

    return Column(
      children: [
        // Wheel Component
        InkWell(
          onTap: () => onComponentSelected(wheelId),
          child: Container(
            width: 42,
            height: 22,
            decoration: BoxDecoration(
              color: _getStatusColor(wheelId).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isWheelSelected ? Colors.blue.shade600 : _getStatusColor(wheelId),
                width: isWheelSelected ? 2.5 : 1.5,
              ),
            ),
            child: const Center(
              child: Text('WHEEL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Bearing Component
        InkWell(
          onTap: () => onComponentSelected(bearingId),
          child: Container(
            width: 50,
            height: 26,
            decoration: BoxDecoration(
              color: _getStatusColor(bearingId).withOpacity(0.25),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: isBearingSelected ? Colors.blue.shade600 : _getStatusColor(bearingId),
                width: isBearingSelected ? 2.5 : 1.5,
              ),
            ),
            child: const Center(
              child: Text('BEARING', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}
