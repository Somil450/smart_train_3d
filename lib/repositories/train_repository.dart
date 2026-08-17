import '../models/train/train.dart';
import '../models/train/component.dart';
import '../core/constants/app_constants.dart';

abstract class TrainRepository {
  Future<List<Train>> getTrains();
  Future<Train> getTrainById(String trainId);
  Future<TrainComponent?> getComponent(String trainId, String componentId);
  Future<void> updateComponentStatus(String trainId, String componentId, ComponentStatus status, double healthScore, String? activeFault);
}

class MockTrainRepository implements TrainRepository {
  late List<Train> _trains;

  MockTrainRepository() {
    _initMockData();
  }

  void _initMockData() {
    final now = DateTime.now();

    // Helper to build a standard bogie with 2 axles, 2 wheels, and 2 bearings
    TrainComponent buildBogie({
      required String bogieId,
      required String bogieName,
      required String location,
      required ComponentStatus bogieStatus,
      required double bogieHealth,
      String? activeFault,
      required String axle1Id,
      required String axle1Name,
      required String wheel1Id,
      required String bearing1Id,
      required String bearing1Name,
      required ComponentStatus bearing1Status,
      required double bearing1Health,
      String? bearing1Fault,
      required String axle2Id,
      required String axle2Name,
      required String wheel2Id,
      required String bearing2Id,
      required String bearing2Name,
      required ComponentStatus bearing2Status,
      required double bearing2Health,
      String? bearing2Fault,
    }) {
      return TrainComponent(
        id: bogieId,
        name: bogieName,
        type: ComponentType.bogie,
        location: location,
        status: bogieStatus,
        healthScore: bogieHealth,
        activeFault: activeFault,
        sensorData: {'bogieVibX': 0.35, 'bogieVibY': 0.28},
        lastUpdated: now,
        children: [
          TrainComponent(
            id: axle1Id,
            name: axle1Name,
            type: ComponentType.axle,
            location: '$location - Front Axle',
            status: ComponentStatus.normal,
            healthScore: 94.0,
            sensorData: {'axialLoad': 120.0},
            lastUpdated: now,
            children: [
              TrainComponent(
                id: wheel1Id,
                name: '$axle1Name Wheel',
                type: ComponentType.wheel,
                location: '$location - Wheel Rim',
                status: ComponentStatus.normal,
                healthScore: 93.0,
                sensorData: {'diameterMm': 840.0, 'flangeWear': 1.2},
                lastUpdated: now,
              ),
              TrainComponent(
                id: bearing1Id,
                name: bearing1Name,
                type: ComponentType.bearing,
                location: '$location - Axle Housing 1',
                status: bearing1Status,
                healthScore: bearing1Health,
                activeFault: bearing1Fault,
                sensorData: {'temperature': bearing1Status == ComponentStatus.fault ? 62.5 : 37.5, 'vibEnvelope': bearing1Status == ComponentStatus.fault ? 4.8 : 0.3},
                lastUpdated: now,
              ),
            ],
          ),
          TrainComponent(
            id: axle2Id,
            name: axle2Name,
            type: ComponentType.axle,
            location: '$location - Rear Axle',
            status: bearing2Status,
            healthScore: bearing2Health,
            activeFault: bearing2Fault,
            sensorData: {'axialLoad': 118.0},
            lastUpdated: now,
            children: [
              TrainComponent(
                id: wheel2Id,
                name: '$axle2Name Wheel',
                type: ComponentType.wheel,
                location: '$location - Wheel Rim',
                status: ComponentStatus.normal,
                healthScore: 91.0,
                sensorData: {'diameterMm': 839.5, 'flatSpotMm': 0.0},
                lastUpdated: now,
              ),
              TrainComponent(
                id: bearing2Id,
                name: bearing2Name,
                type: ComponentType.bearing,
                location: '$location - Axle Housing 2',
                status: bearing2Status,
                healthScore: bearing2Health,
                activeFault: bearing2Fault,
                sensorData: {'temperature': bearing2Status == ComponentStatus.fault ? 62.5 : 38.0, 'vibEnvelope': bearing2Status == ComponentStatus.fault ? 4.8 : 0.4},
                lastUpdated: now,
              ),
            ],
          ),
        ],
      );
    }

    final bogie1 = buildBogie(
      bogieId: AppConstants.compBogie01,
      bogieName: 'Bogie 1 Assembly (Lead Car)',
      location: 'Lead Car Carriage',
      bogieStatus: ComponentStatus.normal,
      bogieHealth: 96.0,
      axle1Id: AppConstants.compAxle01,
      axle1Name: 'Axle 1',
      wheel1Id: AppConstants.compWheel01,
      bearing1Id: AppConstants.compBearing01,
      bearing1Name: 'Bogie 1 Axle 1 Bearing',
      bearing1Status: ComponentStatus.normal,
      bearing1Health: 96.0,
      axle2Id: AppConstants.compAxle02,
      axle2Name: 'Axle 2',
      wheel2Id: AppConstants.compWheel02,
      bearing2Id: AppConstants.compBearing02,
      bearing2Name: 'Bogie 1 Axle 2 Bearing',
      bearing2Status: ComponentStatus.normal,
      bearing2Health: 94.0,
    );

    final bogie2 = buildBogie(
      bogieId: AppConstants.compBogie02,
      bogieName: 'Bogie 2 Assembly (Center Car 1)',
      location: 'Center Car 1 Carriage',
      bogieStatus: ComponentStatus.normal,
      bogieHealth: 92.5,
      axle1Id: AppConstants.compAxle03,
      axle1Name: 'Axle 3',
      wheel1Id: AppConstants.compWheel03,
      bearing1Id: AppConstants.compBearing03,
      bearing1Name: 'Bogie 2 Axle 3 Bearing',
      bearing1Status: ComponentStatus.normal,
      bearing1Health: 93.0,
      axle2Id: AppConstants.compAxle04,
      axle2Name: 'Axle 4',
      wheel2Id: AppConstants.compWheel04,
      bearing2Id: AppConstants.compBearing04,
      bearing2Name: 'Bogie 2 Axle 4 Bearing',
      bearing2Status: ComponentStatus.normal,
      bearing2Health: 92.0,
    );

    final bogie3 = buildBogie(
      bogieId: AppConstants.compBogie03,
      bogieName: 'Bogie 3 Assembly (Center Car 2)',
      location: 'Center Car 2 Carriage',
      bogieStatus: ComponentStatus.fault,
      bogieHealth: 38.5,
      activeFault: 'Bearing Outer Race Defect',
      axle1Id: AppConstants.compAxle05,
      axle1Name: 'Axle 5',
      wheel1Id: AppConstants.compWheel05,
      bearing1Id: AppConstants.compBearing05,
      bearing1Name: 'Bogie 3 Axle 5 Bearing',
      bearing1Status: ComponentStatus.normal,
      bearing1Health: 88.0,
      axle2Id: AppConstants.compAxle06,
      axle2Name: 'Axle 6',
      wheel2Id: AppConstants.compWheel06,
      bearing2Id: AppConstants.compBearing06,
      bearing2Name: 'Bogie 3 Axle 6 Journal Bearing',
      bearing2Status: ComponentStatus.fault,
      bearing2Health: 38.5,
      bearing2Fault: 'Bearing Outer Race Defect',
    );

    final bogie4 = buildBogie(
      bogieId: AppConstants.compBogie04,
      bogieName: 'Bogie 4 Assembly (Trail Car)',
      location: 'Trail Car Carriage',
      bogieStatus: ComponentStatus.normal,
      bogieHealth: 95.0,
      axle1Id: AppConstants.compAxle07,
      axle1Name: 'Axle 7',
      wheel1Id: AppConstants.compWheel07,
      bearing1Id: AppConstants.compBearing07,
      bearing1Name: 'Bogie 4 Axle 7 Bearing',
      bearing1Status: ComponentStatus.normal,
      bearing1Health: 95.0,
      axle2Id: AppConstants.compAxle08,
      axle2Name: 'Axle 8',
      wheel2Id: AppConstants.compWheel08,
      bearing2Id: AppConstants.compBearing08,
      bearing2Name: 'Bogie 4 Axle 8 Bearing',
      bearing2Status: ComponentStatus.normal,
      bearing2Health: 95.0,
    );

    final trainComponents = [
      TrainComponent(
        id: AppConstants.compBody,
        name: 'Main Body Shell & Structural Chassis',
        type: ComponentType.body,
        location: 'Full Car Structure',
        status: ComponentStatus.normal,
        healthScore: 98.0,
        sensorData: {'structureVibration': 0.12, 'strainGauge': 42.0},
        lastUpdated: now,
      ),
      bogie1,
      bogie2,
      bogie3,
      bogie4,
      TrainComponent(
        id: AppConstants.compMotor01,
        name: 'Lead Traction Motor 1',
        type: ComponentType.motor,
        location: 'Bogie 1 Motor Housing',
        status: ComponentStatus.normal,
        healthScore: 94.0,
        sensorData: {'temp': 42.0, 'current': 12.5, 'rpm': 1450},
        lastUpdated: now,
      ),
      TrainComponent(
        id: AppConstants.compMotor02,
        name: 'Center Traction Motor 2',
        type: ComponentType.motor,
        location: 'Bogie 3 Motor Housing',
        status: ComponentStatus.normal,
        healthScore: 91.0,
        sensorData: {'temp': 46.0, 'current': 13.1, 'rpm': 1448},
        lastUpdated: now,
      ),
      TrainComponent(
        id: AppConstants.compBrake,
        name: 'Primary Electro-Pneumatic Brake Disc System',
        type: ComponentType.brake,
        location: 'Bogie Wheel Caliper Units',
        status: ComponentStatus.normal,
        healthScore: 96.0,
        sensorData: {'padThicknessMm': 18.5, 'pressureBar': 5.2},
        lastUpdated: now,
      ),
      TrainComponent(
        id: AppConstants.compSuspension,
        name: 'Primary Coil & Secondary Air Damper Suspension',
        type: ComponentType.suspension,
        location: 'Bogie Bolster Mounts',
        status: ComponentStatus.normal,
        healthScore: 95.0,
        sensorData: {'deflectionMm': 12.0},
        lastUpdated: now,
      ),
      TrainComponent(
        id: AppConstants.compCoupler,
        name: 'Automatic Front Inter-Car Coupler',
        type: ComponentType.coupler,
        location: 'Lead Nose Assembly',
        status: ComponentStatus.normal,
        healthScore: 99.0,
        sensorData: {'draftGearForceKn': 0.0},
        lastUpdated: now,
      ),
    ];

    _trains = [
      Train(
        id: AppConstants.activeTrainId,
        name: AppConstants.activeTrainName,
        status: TrainStatus.warning,
        healthScore: 78.4,
        location: 'Track Section A-12',
        lastUpdated: now,
        components: trainComponents,
        activeFaults: ['Bogie 3 Axle 6 Bearing Outer Race Defect'],
      ),
    ];
  }

  @override
  Future<List<Train>> getTrains() async {
    return _trains;
  }

  @override
  Future<Train> getTrainById(String trainId) async {
    return _trains.firstWhere((t) => t.id == trainId, orElse: () => _trains.first);
  }

  @override
  Future<TrainComponent?> getComponent(String trainId, String componentId) async {
    final train = await getTrainById(trainId);
    return train.findComponent(componentId);
  }

  @override
  Future<void> updateComponentStatus(String trainId, String componentId, ComponentStatus status, double healthScore, String? activeFault) async {
    final trainIndex = _trains.indexWhere((t) => t.id == trainId);
    if (trainIndex == -1) return;

    // Helper recursive update
    List<TrainComponent> updateInList(List<TrainComponent> list) {
      return list.map((comp) {
        if (comp.id == componentId) {
          return comp.copyWith(
            status: status,
            healthScore: healthScore,
            activeFault: activeFault,
            lastUpdated: DateTime.now(),
          );
        }
        return comp.copyWith(children: updateInList(comp.children));
      }).toList();
    }

    final updatedComponents = updateInList(_trains[trainIndex].components);
    _trains[trainIndex] = _trains[trainIndex].copyWith(
      components: updatedComponents,
      lastUpdated: DateTime.now(),
    );
  }
}
