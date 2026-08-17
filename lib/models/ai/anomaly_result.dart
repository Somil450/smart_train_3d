enum AnomalyStatus {
  normal,
  anomalous,
}

class AnomalyResult {
  final DateTime timestamp;
  final String trainId;
  final AnomalyStatus status;
  final double anomalyScore; // 0.0 to 100.0%

  AnomalyResult({
    required this.timestamp,
    required this.trainId,
    required this.status,
    required this.anomalyScore,
  });
}
