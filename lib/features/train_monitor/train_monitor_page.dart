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

                    // 4 Dataset Sensor Category Cards (AumAhuja Dataset Channel Specification)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IMU 3D VIBRATION TENSOR
              Expanded(
                child: _buildTelemetryGroupCard(
                  context,
                  title: '1. IMU TENSOR (imu_x, imu_y, imu_z)',
                  icon: Icons.vibration,
                  iconColor: Colors.purple,
                  metrics: [
                    _Metric('IMU Vibration X (imu_x)', '${Formatters.formatDouble(snap?.imuX ?? 0)} g'),
                    _Metric('IMU Vibration Y (imu_y)', '${Formatters.formatDouble(snap?.imuY ?? 0)} g'),
                    _Metric('IMU Vibration Z (imu_z)', '${Formatters.formatDouble(snap?.imuZ ?? 0)} g'),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 2. DUAL DS18B20 THERMALS
              Expanded(
                child: _buildTelemetryGroupCard(
                  context,
                  title: '2. THERMAL (motor_temp, bearing_temp)',
                  icon: Icons.thermostat,
                  iconColor: Colors.orange.shade800,
                  metrics: [
                    _Metric('Motor Temp (DS18B20 #1)', '${Formatters.formatDouble(snap?.motorTemp ?? 0)} °C'),
                    _Metric('Bearing Temp (DS18B20 #2)', '${Formatters.formatDouble(snap?.bearingBogieTemp ?? 0)} °C'),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. INA219 ELECTRICAL & REED SPEED
              Expanded(
                child: _buildTelemetryGroupCard(
                  context,
                  title: '3. ELECTRICAL & SPEED (voltage, current, power, rpm)',
                  icon: Icons.electric_bolt,
                  iconColor: Colors.amber.shade900,
                  metrics: [
                    _Metric('Voltage (INA219)', '${Formatters.formatDouble(snap?.voltage ?? 0)} V'),
                    _Metric('Current (INA219)', '${Formatters.formatDouble(snap?.current ?? 0)} A'),
                    _Metric('Power (V × I)', '${Formatters.formatDouble((snap?.voltage ?? 0) * (snap?.current ?? 0))} W'),
                    _Metric('Speed (Reed Switch)', '${Formatters.formatDouble(snap?.rpm ?? 0)} RPM'),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 4. HX711 LOAD CELL
              Expanded(
                child: _buildTelemetryGroupCard(
                  context,
                  title: '4. LOAD DYNAMICS (load)',
                  icon: Icons.scale,
                  iconColor: Colors.indigo,
                  metrics: [
                    _Metric('Axle Load / Weight (load)', '${Formatters.formatDouble(snap?.loadWeight ?? 0)} kg'),
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
                title: 'IMU Z-AXIS VIBRATION TENSOR (imu_z)',
                unit: 'g',
                snapshots: sensorState.historyBuffer,
                valueExtractor: (s) => s.imuZ,
                lineColor: Colors.purple,
                selectedDurationMinutes: sensorState.chartDurationMinutes,
                onDurationChanged: (m) => sensorState.setChartDurationMinutes(m),
              ),
              TelemetryChart(
                title: 'DS18B20 #1 MOTOR TEMP (motor_temperature)',
                unit: '°C',
                snapshots: sensorState.historyBuffer,
                valueExtractor: (s) => s.motorTemp,
                lineColor: Colors.orange,
                selectedDurationMinutes: sensorState.chartDurationMinutes,
                onDurationChanged: (m) => sensorState.setChartDurationMinutes(m),
              ),
              TelemetryChart(
                title: 'DS18B20 #2 BEARING TEMP (bearing_temperature)',
                unit: '°C',
                snapshots: sensorState.historyBuffer,
                valueExtractor: (s) => s.bearingBogieTemp,
                lineColor: Colors.deepOrange,
                selectedDurationMinutes: sensorState.chartDurationMinutes,
                onDurationChanged: (m) => sensorState.setChartDurationMinutes(m),
              ),
              TelemetryChart(
                title: 'INA219 MOTOR CURRENT (current)',
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
