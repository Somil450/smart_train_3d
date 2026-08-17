import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/sensor/sensor_reading.dart';
import '../../core/utils/formatters.dart';

class TelemetryChart extends StatelessWidget {
  final String title;
  final String unit;
  final List<TelemetrySnapshot> snapshots;
  final double Function(TelemetrySnapshot snapshot) valueExtractor;
  final Color lineColor;
  final int selectedDurationMinutes;
  final Function(int duration)? onDurationChanged;

  const TelemetryChart({
    super.key,
    required this.title,
    required this.unit,
    required this.snapshots,
    required this.valueExtractor,
    required this.lineColor,
    this.selectedDurationMinutes = 15,
    this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final spots = <FlSpot>[];
    for (int i = 0; i < snapshots.length; i++) {
      spots.add(FlSpot(i.toDouble(), valueExtractor(snapshots[i])));
    }

    final latestVal = snapshots.isNotEmpty ? valueExtractor(snapshots.last) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${Formatters.formatDouble(latestVal)} $unit',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: lineColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDurationChanged != null)
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 5, label: Text('5m')),
                      ButtonSegment(value: 15, label: Text('15m')),
                      ButtonSegment(value: 30, label: Text('30m')),
                      ButtonSegment(value: 60, label: Text('1h')),
                    ],
                    selected: {selectedDurationMinutes},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) onDurationChanged!(set.first);
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: spots.isEmpty
                  ? const Center(child: Text('No telemetry data'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (val) => FlLine(
                            color: theme.dividerColor.withOpacity(0.5),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: (spots.length / 5).clamp(1, 100).toDouble(),
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= 0 && idx < snapshots.length) {
                                  return Text(
                                    Formatters.formatTimeOnly(snapshots[idx].timestamp),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (val, meta) {
                                return Text(
                                  Formatters.formatDouble(val, decimals: 1),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: lineColor,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: lineColor.withOpacity(0.12),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
