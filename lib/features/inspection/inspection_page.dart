import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../state/inspection_state_notifier.dart';
import '../../state/app_state_notifier.dart';
import '../../core/utils/formatters.dart';

class InspectionPage extends StatelessWidget {
  const InspectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inspState = context.watch<InspectionStateNotifier>();
    final appState = context.watch<AppStateNotifier>();
    final theme = Theme.of(context);

    final inspection = inspState.inspectionResult;
    final selectedDetection = inspState.selectedDetection;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COMPUTER VISION ROLLING STOCK INSPECTION',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.sensors, size: 14, color: Colors.purple),
                        SizedBox(width: 4),
                        Text('IR TRIGGER: DETECTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.videocam, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text('ESP32-CAM: ONLINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Inspection Bounding Box Image View
              Expanded(
                flex: 6,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'OPTICAL CAMERA FEED & DEFECT BOUNDING BOXES',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              'Frame Timestamp: ${inspection != null ? Formatters.formatTimeOnly(inspection.timestamp) : "N/A"}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Camera Feed Box with Overlay Bounding Boxes
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade700),
                            ),
                            child: Stack(
                              children: [
                                // Mock Train Bogie Background Graphic
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.subway, size: 90, color: Colors.grey.shade800),
                                      const SizedBox(height: 8),
                                      Text(
                                        '[ ROLLING STOCK BOGIE UNDER-CHASSIS CAMERA FEED ]',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),

                                // Bounding Boxes Overlay
                                if (inspection != null)
                                  ...inspection.detections.map((detection) {
                                    final isSelected = selectedDetection == detection;
                                    return Positioned(
                                      left: detection.x * 500, // scaled box positioning
                                      top: detection.y * 220,
                                      width: detection.width * 500,
                                      height: detection.height * 220,
                                      child: GestureDetector(
                                        onTap: () => inspState.selectDetection(detection),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.red.withOpacity(0.3) : Colors.amber.withOpacity(0.2),
                                            border: Border.all(
                                              color: isSelected ? Colors.red : Colors.amber,
                                              width: isSelected ? 3 : 2,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 2,
                                                left: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                  color: isSelected ? Colors.red : Colors.amber.shade900,
                                                  child: Text(
                                                    '${detection.defectType.split(' ').first} ${Formatters.formatPercentage(detection.confidence)}',
                                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Right: Defect Detections List & Digital Twin Component Link
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DETECTED DEFECT OBJECTS',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            if (inspection == null || inspection.detections.isEmpty)
                              const Text('No optical defects detected.')
                            else
                              ...inspection.detections.map((detection) {
                                final isSelected = selectedDetection == detection;
                                return Card(
                                  color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.4) : theme.cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: BorderSide(
                                      color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      detection.defectType,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    subtitle: Text('Component ID: ${detection.componentId}'),
                                    trailing: Text(
                                      Formatters.formatPercentage(detection.confidence),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                                    ),
                                    onTap: () => inspState.selectDetection(detection),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selected Defect Detail & Action Link
                    if (selectedDetection != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.link, color: Colors.blue, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'SHARED COMPONENT LINK',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Defect linked to component: ${selectedDetection.componentId}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Confidence: ${Formatters.formatPercentage(selectedDetection.confidence)}'),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    appState.selectComponent(selectedDetection.componentId);
                                    appState.setCurrentRoute(AppRoute.dashboard);
                                  },
                                  icon: const Icon(Icons.touch_app, size: 16),
                                  label: const Text('Highlight Component on Digital Twin'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
