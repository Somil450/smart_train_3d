import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ai/degradation_result.dart';
import '../../models/sensor/sensor_reading.dart';
import '../../state/ai_state_notifier.dart';
import '../../state/sensor_state_notifier.dart';
import '../../state/train_state_notifier.dart';
import '../../state/app_state_notifier.dart';
import '../../widgets/charts/telemetry_chart.dart';
import '../../core/utils/formatters.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  SensorType _selectedSensor = SensorType.imuZ;

  @override
  Widget build(BuildContext context) {
    final aiState = context.watch<AIStateNotifier>();
    final sensorState = context.watch<SensorStateNotifier>();
    final trainState = context.watch<TrainStateNotifier>();
    final appState = context.watch<AppStateNotifier>();
    final theme = Theme.of(context);

    final train = trainState.getTrain(appState.selectedTrainId);
    final degradation = aiState.degradation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANALYTICS & DEGRADATION ANALYSIS',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Top Degradation Tracking Panel
          if (degradation != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: degradation.trend == DegradationTrend.degrading ? Colors.red.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        degradation.trend == DegradationTrend.degrading ? Icons.trending_down : Icons.trending_up,
                        color: degradation.trend == DegradationTrend.degrading ? Colors.red : Colors.green,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DEGRADATION TRACKING: ${degradation.componentName}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: degradation.trend == DegradationTrend.degrading ? Colors.red.shade100 : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'TREND: ${degradation.trend.name.toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: degradation.trend == DegradationTrend.degrading ? Colors.red.shade900 : Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('Current Health: ${Formatters.formatPercentage(degradation.currentHealth / 100)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 16),
                              Text('Previous Health: ${Formatters.formatPercentage(degradation.previousHealth / 100)}'),
                              const SizedBox(width: 16),
                              Text('Health Change: ${Formatters.formatDouble(degradation.change)}%',
                                  style: TextStyle(color: degradation.change < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Prediction RUL: ${degradation.prediction}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Component Health Breakdown Table & Signal Selection
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Component Health List
              Expanded(
                flex: 5,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COMPONENT HEALTH SCORE BREAKDOWN',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        if (train != null)
                          ...train.components.map((comp) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(comp.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      Text(Formatters.formatPercentage(comp.healthScore / 100),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: comp.healthScore < 50 ? Colors.red : (comp.healthScore < 85 ? Colors.amber.shade800 : Colors.green),
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: (comp.healthScore / 100).clamp(0.0, 1.0),
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                    color: comp.healthScore < 50 ? Colors.red : (comp.healthScore < 85 ? Colors.amber.shade800 : Colors.green),
                                    backgroundColor: theme.dividerColor,
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Individual Signal Selection Chart
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Text('Physical Sensor Signal: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<SensorType>(
                                  value: _selectedSensor,
                                  isExpanded: true,
                                  items: SensorType.values.map((st) {
                                    return DropdownMenuItem(
                                      value: st,
                                      child: Text(_getSensorLabel(st), style: const TextStyle(fontSize: 11)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedSensor = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 300,
                      child: TelemetryChart(
                        title: '${_getSensorLabel(_selectedSensor).toUpperCase()} TIME-SERIES',
                        unit: _getSensorUnit(_selectedSensor),
                        snapshots: sensorState.historyBuffer,
                        valueExtractor: (s) => _extractVal(s, _selectedSensor),
                        lineColor: Colors.blue,
                        selectedDurationMinutes: sensorState.chartDurationMinutes,
                        onDurationChanged: (m) => sensorState.setChartDurationMinutes(m),
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

  String _getSensorLabel(SensorType st) {
    switch (st) {
      case SensorType.imuX:
        return 'IMU Vibration X Tensor (imu_x)';
      case SensorType.imuY:
        return 'IMU Vibration Y Tensor (imu_y)';
      case SensorType.imuZ:
        return 'IMU Vibration Z Tensor (imu_z)';
      case SensorType.motorTemp:
        return 'DS18B20 #1 Motor Temp (motor_temperature)';
      case SensorType.bearingBogieTemp:
        return 'DS18B20 #2 Bearing Temp (bearing_temperature)';
      case SensorType.rpm:
        return 'Reed Switch Speed (rpm)';
      case SensorType.voltage:
        return 'INA219 Motor Voltage (voltage)';
      case SensorType.current:
        return 'INA219 Motor Current (current)';
      case SensorType.loadWeight:
        return 'HX711 Load Dynamics (load)';
    }
  }

  String _getSensorUnit(SensorType st) {
    switch (st) {
      case SensorType.imuX:
      case SensorType.imuY:
      case SensorType.imuZ:
        return 'g';
      case SensorType.motorTemp:
      case SensorType.bearingBogieTemp:
        return '°C';
      case SensorType.voltage:
        return 'V';
      case SensorType.current:
        return 'A';
      case SensorType.rpm:
        return 'RPM';
      case SensorType.loadWeight:
        return 'kg';
    }
  }

  double _extractVal(TelemetrySnapshot s, SensorType st) {
    switch (st) {
      case SensorType.imuX:
        return s.imuX;
      case SensorType.imuY:
        return s.imuY;
      case SensorType.imuZ:
        return s.imuZ;
      case SensorType.motorTemp:
        return s.motorTemp;
      case SensorType.bearingBogieTemp:
        return s.bearingBogieTemp;
      case SensorType.rpm:
        return s.rpm;
      case SensorType.voltage:
        return s.voltage;
      case SensorType.current:
        return s.current;
      case SensorType.loadWeight:
        return s.loadWeight;
    }
  }
}
