import '../models/inspection/inspection_result.dart';
import '../core/constants/app_constants.dart';

abstract class InspectionRepository {
  Future<InspectionResult> getLatestInspection(String trainId);
}

class MockInspectionRepository implements InspectionRepository {
  @override
  Future<InspectionResult> getLatestInspection(String trainId) async {
    return InspectionResult(
      id: 'INSP_2026_0089',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      trainId: trainId,
      imagePath: 'assets/images/train_bogie_inspection.png',
      detections: [
        DetectionBox(
          defectType: 'Bearing Housing Surface Pitting / Spalling',
          confidence: 0.92,
          x: 0.58,
          y: 0.42,
          width: 0.22,
          height: 0.28,
          componentId: AppConstants.compBearing06,
        ),
        DetectionBox(
          defectType: 'Wheel Tread Micro-Flange Wear',
          confidence: 0.74,
          x: 0.22,
          y: 0.45,
          width: 0.18,
          height: 0.24,
          componentId: AppConstants.compWheel03,
        ),
      ],
    );
  }
}
