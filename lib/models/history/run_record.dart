class RunRecord {
  final String runId;
  final String trainId;
  final DateTime timestamp;
  final int durationSeconds;
  final String condition;
  final String faultType;
  final String locationComponentId;
  final double confidence;
  final double healthScore;
  final String? experimentId;

  RunRecord({
    required this.runId,
    required this.trainId,
    required this.timestamp,
    required this.durationSeconds,
    required this.condition,
    required this.faultType,
    required this.locationComponentId,
    required this.confidence,
    required this.healthScore,
    this.experimentId,
  });
}
