class DetectionBox {
  final String defectType;
  final double confidence;
  final double x; // Normalized 0..1
  final double y; // Normalized 0..1
  final double width;
  final double height;
  final String componentId;

  DetectionBox({
    required this.defectType,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.componentId,
  });
}

class InspectionResult {
  final String id;
  final DateTime timestamp;
  final String trainId;
  final String imagePath;
  final List<DetectionBox> detections;

  InspectionResult({
    required this.id,
    required this.timestamp,
    required this.trainId,
    required this.imagePath,
    required this.detections,
  });
}
