import 'dart:math';
import 'dart:ui' show FontFeature;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sensor/motor_vibration.dart';
import '../../services/mqtt/mqtt_service.dart';
import '../../state/mqtt_vibration_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Vibration Monitor Page
// Real-time dual-motor vibration display over MQTT
// Threshold: 0.914 g  (matches ESP32 firmware #define VIBRATION_THRESHOLD)
// ─────────────────────────────────────────────────────────────────────────────

class VibrationMonitorPage extends StatelessWidget {
  const VibrationMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vib = context.watch<MqttVibrationNotifier>();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.sensors, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'REAL-TIME MOTOR VIBRATION MONITOR  (MQTT)',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _MqttStatusBadge(state: vib.connectionState),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Source: ESP32 WebSocket ws://10.89.142.193:81  •  '
            'Topics: Motor 1 & 2 Vibration  •  '
            'Threshold: ${kVibrationThreshold.toStringAsFixed(3)} g',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // ── Global alert banner ───────────────────────────────────────────
          if (vib.anyAlert)
            _AlertBanner(motor1Alert: vib.motor1Alert, motor2Alert: vib.motor2Alert),
          if (vib.anyAlert) const SizedBox(height: 12),

          // ── Motor cards ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _MotorCard(
                  motorNumber: 1,
                  latest: vib.motor1Latest,
                  color: const Color(0xFF7C4DFF), // purple
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MotorCard(
                  motorNumber: 2,
                  latest: vib.motor2Latest,
                  color: const Color(0xFF00BCD4), // teal
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Temperature Panel (Motor 2) ───────────────────────────────────
          _TemperaturePanel(
            temp: vib.motor2Temp,
            status: vib.motor2TempStatus,
            isDanger: vib.motor2TempDanger,
            isCritical: vib.motor2TempCritical,
          ),
          const SizedBox(height: 20),

          // ── Charts ────────────────────────────────────────────────────────
          Text(
            'VIBRATION TIME-SERIES',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const Divider(height: 12),
          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _VibrationChart(
                  title: 'Motor 1 Vibration',
                  history: vib.motor1History,
                  lineColor: const Color(0xFF7C4DFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VibrationChart(
                  title: 'Motor 2 Vibration',
                  history: vib.motor2History,
                  lineColor: const Color(0xFF00BCD4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Raw axes panel ─────────────────────────────────────────────────
          Text(
            'RAW ACCELEROMETER AXES  (g)',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const Divider(height: 12),
          Row(
            children: [
              Expanded(child: _AxesCard(motorNumber: 1, payload: vib.motor1Latest)),
              const SizedBox(width: 12),
              Expanded(child: _AxesCard(motorNumber: 2, payload: vib.motor2Latest)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MQTT status badge
// ─────────────────────────────────────────────────────────────────────────────
class _MqttStatusBadge extends StatelessWidget {
  final AppMqttConnectionState state;
  const _MqttStatusBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    Color dot;
    String label;
    switch (state) {
      case AppMqttConnectionState.connected:
        dot = Colors.green;
        label = 'MQTT LIVE';
        break;
      case AppMqttConnectionState.connecting:
        dot = Colors.orange;
        label = 'CONNECTING…';
        break;
      case AppMqttConnectionState.error:
        dot = Colors.red;
        label = 'MQTT ERROR';
        break;
      case AppMqttConnectionState.disconnected:
        dot = Colors.grey;
        label = 'DISCONNECTED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dot.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dot.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: dot,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alert banner
// ─────────────────────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  final bool motor1Alert;
  final bool motor2Alert;
  const _AlertBanner({required this.motor1Alert, required this.motor2Alert});

  @override
  Widget build(BuildContext context) {
    final affected = [
      if (motor1Alert) 'Motor 1',
      if (motor2Alert) 'Motor 2',
    ].join(' & ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠  HIGH VIBRATION DETECTED — $affected',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vibration magnitude exceeds ${kVibrationThreshold.toStringAsFixed(3)} g threshold. '
                  'Possible causes: bearing wear, wheel flat, track irregularity, '
                  'motor imbalance, or loose mounting. '
                  'Inspect immediately to prevent further damage.',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-motor status card
// ─────────────────────────────────────────────────────────────────────────────
class _MotorCard extends StatelessWidget {
  final int motorNumber;
  final MotorVibrationPayload? latest;
  final Color color;

  const _MotorCard({
    required this.motorNumber,
    required this.latest,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isAlert = latest?.alert ?? false;
    final vibe = latest?.vibe ?? 0.0;
    final cardColor = isAlert ? Colors.red.shade50 : Colors.white;
    final borderColor = isAlert ? Colors.red.shade400 : color.withOpacity(0.4);
    final valueColor = isAlert ? Colors.red : color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor, width: isAlert ? 2.0 : 1.0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isAlert ? Colors.red : color).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAlert ? Icons.warning_rounded : Icons.electric_bolt,
                color: isAlert ? Colors.red : color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'MOTOR  $motorNumber',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isAlert ? Colors.red : Colors.black87,
                ),
              ),
              const Spacer(),
              if (isAlert)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ALERT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    'NORMAL',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            latest == null ? '— g' : '${vibe.toStringAsFixed(4)} g',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vibration Level  •  threshold ${kVibrationThreshold.toStringAsFixed(3)} g',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: min(vibe / (kVibrationThreshold * 1.5), 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAlert ? Colors.red : color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 g', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              Text(
                '${(kVibrationThreshold * 1.5).toStringAsFixed(3)} g',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Real-time line chart with threshold reference line
// ─────────────────────────────────────────────────────────────────────────────
class _VibrationChart extends StatelessWidget {
  final String title;
  final List<MotorVibrationPayload> history;
  final Color lineColor;

  const _VibrationChart({
    required this.title,
    required this.history,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].vibe));
    }

    // Keep last 80 points for readability
    final displaySpots = spots.length > 80
        ? spots.sublist(spots.length - 80)
        : spots;

    // Renumber x to 0..n
    final renumbered = List.generate(
      displaySpots.length,
      (i) => FlSpot(i.toDouble(), displaySpots[i].y),
    );

    final maxY = max(
      kVibrationThreshold * 1.5,
      renumbered.isEmpty ? kVibrationThreshold * 1.5
          : renumbered.map((s) => s.y).reduce(max) * 1.2,
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(width: 16, height: 2,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(1),
                        )),
                    const SizedBox(width: 4),
                    const Text(
                      'threshold',
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: renumbered.isEmpty
                  ? Center(
                      child: Text(
                        'Waiting for data…',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maxY,
                        clipData: const FlClipData.all(),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: kVibrationThreshold / 2,
                          getDrawingHorizontalLine: (v) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(color: Colors.grey.shade300),
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 46,
                              interval: kVibrationThreshold / 2,
                              getTitlesWidget: (v, _) => Text(
                                v.toStringAsFixed(3),
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                          ),
                        ),
                        // Dashed threshold line
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: kVibrationThreshold,
                              color: Colors.red.withOpacity(0.8),
                              strokeWidth: 1.5,
                              dashArray: [6, 4],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topRight,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                labelResolver: (_) =>
                                    ' ${kVibrationThreshold.toStringAsFixed(3)} g',
                              ),
                            ),
                          ],
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: renumbered,
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: lineColor,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: lineColor.withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              'Live  •  last ${renumbered.length} samples  •  g = deviation from 1g gravity',
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Raw axes panel
// ─────────────────────────────────────────────────────────────────────────────
class _AxesCard extends StatelessWidget {
  final int motorNumber;
  final MotorVibrationPayload? payload;

  const _AxesCard({required this.motorNumber, required this.payload});

  @override
  Widget build(BuildContext context) {
    final p = payload;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motor $motorNumber — Raw Axes',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Divider(height: 14),
            _AxisRow(axis: 'X', value: p?.ax, color: Colors.red),
            const SizedBox(height: 6),
            _AxisRow(axis: 'Y', value: p?.ay, color: Colors.green),
            const SizedBox(height: 6),
            _AxisRow(axis: 'Z', value: p?.az, color: Colors.blue),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Vibration (|mag−1g|)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                Text(
                  p == null ? '—' : '${p.vibe.toStringAsFixed(5)} g',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AxisRow extends StatelessWidget {
  final String axis;
  final double? value;
  final Color color;

  const _AxisRow({required this.axis, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            axis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LinearProgressIndicator(
            value: value == null ? 0 : ((value! + 2) / 4).clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
            minHeight: 5,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(
            value == null ? '—' : '${value!.toStringAsFixed(5)} g',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Temperature Panel — Motor 2 Wheel Temperature Monitor
// ─────────────────────────────────────────────────────────────────────────────
class _TemperaturePanel extends StatelessWidget {
  final double temp;
  final String status;
  final bool isDanger;
  final bool isCritical;

  const _TemperaturePanel({
    required this.temp,
    required this.status,
    required this.isDanger,
    required this.isCritical,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isCritical
        ? const Color(0xFFD32F2F)   // deep red
        : isDanger
            ? const Color(0xFFF57C00) // deep orange
            : const Color(0xFF388E3C); // green

    final Color bgColor = isCritical
        ? const Color(0xFFD32F2F).withOpacity(0.10)
        : isDanger
            ? const Color(0xFFF57C00).withOpacity(0.10)
            : const Color(0xFF388E3C).withOpacity(0.08);

    final String statusLabel = isCritical
        ? '🚨 WHEEL FAILURE RISK — MOTOR 2 DISABLED'
        : isDanger
            ? '⚠️  DANGER ZONE — Temperature between 50°C – 80°C'
            : '✅ NORMAL — Temperature within safe range';

    // Progress bar: 0°C = 0%, 100°C = 100%
    final double progress = (temp.clamp(0.0, 100.0) / 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'WHEEL TEMPERATURE MONITOR  (Motor 2 — OUT 3 & 4)',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const Divider(height: 12),
        const SizedBox(height: 4),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: baseColor.withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon + temp value + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.thermostat, color: baseColor, size: 36),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temp == 0.0 ? '—°C' : '${temp.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: baseColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        'DS18B20 Sensor  •  Pin 32',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Temperature scale bar
              Stack(
                children: [
                  // Background bar with gradient zones
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF43A047), // green  0°C
                          Color(0xFFFFEE58), // yellow 50°C
                          Color(0xFFEF6C00), // orange 70°C
                          Color(0xFFD32F2F), // red   100°C
                        ],
                        stops: [0.0, 0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Needle indicator
                  Positioned(
                    left: (MediaQuery.of(context).size.width - 80) * progress,
                    top: -3,
                    child: Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.black54, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Scale labels
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0°C', style: TextStyle(fontSize: 10, color: Colors.green)),
                  Text('50°C', style: TextStyle(fontSize: 10, color: Colors.orange)),
                  Text('80°C', style: TextStyle(fontSize: 10, color: Colors.deepOrange)),
                  Text('100°C', style: TextStyle(fontSize: 10, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 12),

              // Status alert row
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                  ),
                ),
              ),

              // Wheel failure detail (only when critical)
              if (isCritical) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD32F2F)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'WHEEL FAILURE ALERT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD32F2F),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Temperature ≥ 80°C detected on Motor 2 (OUT 3 & 4).\n'
                        'Motor 2 has been AUTOMATICALLY DISABLED by the ESP32 safety system.\n'
                        'Motor 1 (OUT 1 & 2) continues to operate normally.\n'
                        'Motor 2 will resume when temperature drops below 80°C.',
                        style: TextStyle(fontSize: 11, color: Color(0xFFD32F2F), height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
