import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../state/mqtt_vibration_notifier.dart';
import '../../services/mqtt/mqtt_service.dart';
import '../service_stations/service_stations_page.dart'; // To reuse realStations

class FleetDemoPage extends StatefulWidget {
  const FleetDemoPage({super.key});

  @override
  State<FleetDemoPage> createState() => _FleetDemoPageState();
}

class _FleetDemoPageState extends State<FleetDemoPage> {
  final MapController _mapController = MapController();

  // Artificial offset so Train 2 doesn't exactly overlap Train 1 on the map
  static const double _latOffset = 0.005; // roughly 500 meters
  static const double _lngOffset = -0.003; 

  @override
  Widget build(BuildContext context) {
    final mqttNotifier = context.watch<MqttVibrationNotifier>();
    final theme = Theme.of(context);

    // Retrieve live vibrations (fallback to 0 if null)
    final double v1 = mqttNotifier.motor1Latest?.vibe ?? 0.0;
    final double v2 = mqttNotifier.motor2Latest?.vibe ?? 0.0;
    final double t2 = mqttNotifier.motor2Temp;

    // Calculate Risk % with a noise deadband (e.g. < 0.1g is normal noise -> 0% risk)
    double risk1 = v1 < 0.1 ? 0.0 : (v1 / kVibrationThreshold) * 100.0;
    // Motor 1 is the "Ideal Wheel" for the demo, so cap its risk at 49.9% 
    // to ensure it never shows critical faults even if the whole rig shakes.
    if (risk1 > 49.9) risk1 = 49.9;
    
    double vRisk2 = v2 < 0.1 ? 0.0 : (v2 / kVibrationThreshold) * 100.0;
    // Temperature risk: 40C = 0%, 90C = 100%
    double tRisk2 = t2 < 40.0 ? 0.0 : ((t2 - 40.0) / (90.0 - 40.0)) * 100.0;
    
    double risk2 = math.max(vRisk2, tRisk2);
    if (risk2 > 100.0) risk2 = 100.0;

    // Determine Status and Remaining Time
    final train1Status = _getTrainStatus(risk1);
    final train2Status = _getTrainStatus(risk2);

    // Get Base Location (Train 1)
    final bool hasGpsFix = mqttNotifier.gpsLat != 0.0 && mqttNotifier.gpsLng != 0.0;
    final LatLng train1Loc = hasGpsFix 
        ? LatLng(mqttNotifier.gpsLat, mqttNotifier.gpsLng)
        : const LatLng(20.5937, 78.9629); // Center of India
        
    // Apply offset for Train 2
    final LatLng train2Loc = hasGpsFix
        ? LatLng(mqttNotifier.gpsLat + _latOffset, mqttNotifier.gpsLng + _lngOffset)
        : const LatLng(20.6937, 78.8629);

    // Calculate nearest service stations
    const distanceCalc = Distance();
    ServiceStation? nearest1;
    ServiceStation? nearest2;
    double dist1 = double.infinity;
    double dist2 = double.infinity;

    if (hasGpsFix) {
      for (final s in realStations) {
        final d1 = distanceCalc.as(LengthUnit.Kilometer, train1Loc, s.location).toDouble();
        if (d1 < dist1) {
          dist1 = d1;
          nearest1 = s;
        }
        final d2 = distanceCalc.as(LengthUnit.Kilometer, train2Loc, s.location).toDouble();
        if (d2 < dist2) {
          dist2 = d2;
          nearest2 = s;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.train, size: 28),
              const SizedBox(width: 8),
              Text(
                'MULTI-TRAIN FLEET RISK TRACKING',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (!hasGpsFix)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text('GPS: NO FIX (Waiting for ESP32)', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Train Panels
          Row(
            children: [
              Expanded(child: _buildTrainPanel(theme, 1, 'Express R-101 (Northbound)', risk1, train1Status, nearest1, dist1, hasGpsFix)),
              const SizedBox(width: 16),
              Expanded(child: _buildTrainPanel(theme, 2, 'Express R-102 (Southbound)', risk2, train2Status, nearest2, dist2, hasGpsFix)),
            ],
          ),
          const SizedBox(height: 16),
          // Shared Map
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: theme.dividerColor)),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: train1Loc,
                    initialZoom: hasGpsFix ? 12.0 : 4.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.smartrail.ai',
                    ),
                    MarkerLayer(
                      markers: [
                        if (hasGpsFix) ...[
                          // Service Stations
                          if (nearest1 != null) Marker(point: nearest1.location, child: const Icon(Icons.build_circle, color: Colors.blueAccent, size: 30)),
                          if (nearest2 != null && nearest2 != nearest1) Marker(point: nearest2.location, child: const Icon(Icons.build_circle, color: Colors.blueAccent, size: 30)),
                          // Train 1
                          Marker(
                            point: train1Loc,
                            width: 80,
                            height: 40,
                            child: _buildMapLabel('T1', risk1 > 90 ? Colors.red : risk1 > 40 ? Colors.orange : Colors.green),
                          ),
                          // Train 2
                          Marker(
                            point: train2Loc,
                            width: 80,
                            height: 40,
                            child: _buildMapLabel('T2', risk2 > 90 ? Colors.red : risk2 > 40 ? Colors.orange : Colors.green),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMapLabel(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTrainPanel(
    ThemeData theme,
    int trainId,
    String name,
    double risk,
    _TrainStatus status,
    ServiceStation? nearestStation,
    double dist,
    bool hasGpsFix,
  ) {
    Color riskColor;
    if (risk < 15) riskColor = Colors.green;
    else if (risk < 50) riskColor = Colors.orange;
    else if (risk < 100) riskColor = Colors.deepOrange;
    else riskColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: risk >= 100 ? Colors.red.withOpacity(0.5) : theme.dividerColor, width: risk >= 100 ? 2 : 1),
        boxShadow: risk >= 100 ? [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: riskColor.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.train, color: riskColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TRAIN $trainId', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                    Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Risk Dial
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: risk / 100.0,
                      strokeWidth: 10,
                      backgroundColor: theme.dividerColor,
                      color: riskColor,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${risk.toStringAsFixed(1)}%', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: riskColor)),
                          const Text('RISK', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Status Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.label,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: riskColor),
                    ),
                    const SizedBox(height: 8),
                    if (risk > 50) ...[
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(child: Text(status.timeLeft, style: const TextStyle(fontWeight: FontWeight.w500))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(child: Text(status.failureIssue, style: const TextStyle(fontWeight: FontWeight.w500))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (hasGpsFix && nearestStation != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.build_circle, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Nearest: ${nearestStation.city} (${dist.toStringAsFixed(1)} km)',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                         const Text('Nearest Station: Awaiting GPS...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ]
                    ] else ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Expanded(child: Text('Safe to run indefinitely', style: TextStyle(fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _TrainStatus _getTrainStatus(double risk) {
    if (risk < 15) {
      return _TrainStatus('No Fault Detected', 'Safe to run indefinitely', 'None');
    } else if (risk < 50) {
      return _TrainStatus('Minor Degradation', 'Est. > 24 Hours remaining', 'Wear & Tear');
    } else if (risk < 80) {
      return _TrainStatus('Moderate Risk', 'Est. 4 - 8 Hours remaining', 'Bearing Misalignment');
    } else if (risk < 100) {
      return _TrainStatus('High Risk', 'Est. 15 - 45 Mins remaining', 'Severe Vibration/Overheating');
    } else {
      return _TrainStatus('CRITICAL FAULT', 'STOP IMMEDIATELY', 'Impending Structural Failure');
    }
  }
}

class _TrainStatus {
  final String label;
  final String timeLeft;
  final String failureIssue;
  _TrainStatus(this.label, this.timeLeft, this.failureIssue);
}
