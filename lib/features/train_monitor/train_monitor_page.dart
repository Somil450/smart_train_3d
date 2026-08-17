import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/sensor_state_notifier.dart';
import '../../widgets/charts/telemetry_chart.dart';
import '../../core/utils/formatters.dart';

class TrainMonitorPage extends StatefulWidget {
  const TrainMonitorPage({super.key});

  @override
  State<TrainMonitorPage> createState() => _TrainMonitorPageState();
}

class _TrainMonitorPageState extends State<TrainMonitorPage> {
  int _selectedBogieIndex = 2; // Default to Bogie 3 (Active Fault)

  final List<String> _bogieLabels = [
    'ALL BOGIES',
    'BOGIE 1 (LEAD)',
    'BOGIE 2 (CENTER 1)',
    'BOGIE 3 (CENTER 2)',
    'BOGIE 4 (TRAIL)',
  ];

  @override
  Widget build(BuildContext context) {
    final sensorState = context.watch<SensorStateNotifier>();
    final snap = sensorState.latestTelemetry;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REAL-TIME PHYSICAL SENSOR TELEMETRY MONITOR',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 10),
                  const SizedBox(width: 6),
                  Text(
                    'SAMPLING: 1000ms',
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Multi-Bogie Selection Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_bogieLabels.length, (idx) {
                final isSelected = _selectedBogieIndex == idx;
                final isFaultBogie = idx == 3;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isFaultBogie) ...[
                          const Icon(Icons.warning_amber, size: 14, color: Colors.red),
                          const SizedBox(width: 4),
                        ],
                        Text(_bogieLabels[idx]),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: isFaultBogie ? Colors.red.shade100 : Colors.blue.shade100,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (isFaultBogie ? Colors.red.shade900 : Colors.blue.shade900)
                          : theme.textTheme.bodyMedium?.color,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedBogieIndex = idx;
                        });
                      }
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // 6 Strict Sensor Category Cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. MOTOR GROUP
              Expanded(
                child: _buildTelemetryGroupCard(
                  context,
                  title: '1. MOTOR (IMU #1, DS18B20 #1, INA219, REED)',
                  icon: Icons.electric_bolt,
                  iconColor: Colors.amber.shade800,
                  metrics: [
                    _Metric('IMU #1 Accel X', '${Formatters.formatDouble(snap?.imu1X ?? 0)} g'),
                    _Metric('IMU #1 Accel Y', '${Formatters.formatDouble(snap?.imu1Y ?? 0)} g'),
                    _Metric('IMU #1 Accel Z', '${Formatters.formatDouble(snap?.imu1Z ?? 0)} g'),
                    _Metric('Motor Temp (DS18B20 #1)', '${Formatters.formatDouble(snap?.motorTemp ?? 0)} °C'),
                    _Metric('Voltage (INA219)', '${Formatters.formatDouble(snap?.voltage ?? 0)} V'),
                    _Metric('Current (INA219)', '${Formatters.formatDouble(snap?.current ?? 0)} A'),
                    _Metric('Power (V × I)', '${Formatters.formatDouble((snap?.voltage ?? 0) * (snap?.current ?? 0))} W'),
                    _Metric('RPM (Reed Switch)', '${Formatters.formatDouble(snap?.rpm ?? 0)} RPM'),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 2. BOGIE / RUNNING GEAR GROUP
              Expanded(
                child: _buildTelemetryGroupCard(
                  context,
                  title: '2. BOGIE (IMU #2, DS18B20 #2, REED)',
                  icon: Icons.subway,
                  iconColor: Colors.purple,
                  metrics: [
                    _Metric('IMU #2 Accel X', '${Formatters.formatDouble(snap?.imu2X ?? 0)} g'),
                    _Metric('IMU #2 Accel Y', '${Formatters.formatDouble(snap?.imu2Y ?? 0)} g'),
                    _Metric('IMU #2 Accel Z', '${Formatters.formatDouble(snap?.imu2Z ?? 0)} g'),
                    _Metric('Bearing/Bogie Temp (DS18B20 #2)', '${Formatters.formatDouble(snap?.bearingBogieTemp ?? 0)} °C'),
                    _Metric('RPM (Reed Switch)', '${Formatters.formatDouble(snap?.rpm ?? 0)} RPM'),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. LOAD, ENVIRONMENT, POSITION, INSPECTION
              Expanded(
                child: Column(
                  children: [
                    // 3. LOAD / OPERATING CONDITION
                    _buildTelemetryGroupCard(
                      context,
                      title: '3. LOAD (HX711 + LOAD CELL)',
                      icon: Icons.scale,
                      iconColor: Colors.indigo,
                      metrics: [
                        _Metric('Load / Weight', '${Formatters.formatDouble(snap?.loadWeight ?? 0)} kg'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 4. ENVIRONMENT
                    _buildTelemetryGroupCard(
                      context,
                      title: '4. ENVIRONMENT (DHT11)',
                      icon: Icons.thermostat,
                      iconColor: Colors.teal,
                      metrics: [
                        _Metric('Ambient Temp', '${Formatters.formatDouble(snap?.ambientTemp ?? 0)} °C'),
                        _Metric('Humidity', '${Formatters.formatDouble(snap?.humidity ?? 0)} %'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 5. POSITION & 6. INSPECTION
                    _buildTelemetryGroupCard(
                      context,
                      title: '5. GPS & 6. IR INSPECTION TRIGGER',
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      metrics: [
                        _Metric('GPS Status', snap?.gpsAvailable == true ? 'AVAILABLE' : 'UNAVAILABLE'),
                        _Metric('GPS Position', snap?.gpsPosition ?? 'N/A'),
                        _Metric('IR Sensor Trigger', snap?.irDetection == true ? 'DETECTED' : 'NOT DETECTED'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Real-time Telemetry Time-Series Charts Grid (Strict Hardware Sensor Signals)
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              TelemetryChart(
                title: 'IMU #2 BOGIE Z-ACCELERATION (g)',
                unit: 'g',
                snapshots: sensorState.historyBuffer,
                valueExtractor: (s) => s.imu2Z,
                lineColor: Colors.purple,
                selectedDurationMinutes: sensorState.chartDurationMinutes,
                onDurationChanged: (m) => sensorState.setChartDurationMinutes(m),
              ),
              TelemetryChart(
                title: 'DS18B20 #1 MOTOR TEMP (°C)',
                unit: '°C',
                snapshots: sensorState.historyBuffer,
                valueExtractor: (s) => s.motorTemp,
                lineColor: Colors.orange,
                selectedDurationMinutes: sensorState.chartDurationMinutes,
                onDurationChanged: (m) => sensorState.setChartDurationMinutes(m),
              ),
              TelemetryChart(
                title: 'DS18B20 #2 BEARING / BOGIE TEMP (°C)',
                unit: '°C',
                snapshots: sensorState.historyBuffer,
                valueExtractor: (s) => s.bearingBogieTemp,
                lineColor: Colors.deepOrange,
                selectedDurationMinutes: sensorState.chartDurationMinutes,
                onDurationChanged: (m) => sensorState.setChartDurationMinutes(m),
              ),
              TelemetryChart(
                title: 'INA219 MOTOR CURRENT (A)',
                unit: 'A',
                snapshots: sensorState.historyBuffer,
                valueExtractor: (s) => s.current,
                lineColor: Colors.blue,
                selectedDurationMinutes: sensorState.chartDurationMinutes,
                onDurationChanged: (m) => sensorState.setChartDurationMinutes(m),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGroupCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_Metric> metrics,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...metrics.map((m) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m.label, style: const TextStyle(fontSize: 11)),
                    Text(m.value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Metric {
  final String label;
  final String value;

  _Metric(this.label, this.value);
}
