class FaultProbability {
  final String faultType;
  final double confidence; // 0.0 to 1.0

  FaultProbability({
    required this.faultType,
    required this.confidence,
  });
}

class FaultPrediction {
  final DateTime timestamp;
  final String trainId;
  final List<FaultProbability> probabilities;
  final String primaryFault;
  final String localizedComponentId;

  FaultPrediction({
    required this.timestamp,
    required this.trainId,
    required this.probabilities,
    required this.primaryFault,
    required this.localizedComponentId,
  });
}
