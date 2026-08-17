enum DegradationTrend {
  improving,
  stable,
  degrading,
  unknown,
}

class DegradationResult {
  final String componentId;
  final String componentName;
  final double currentHealth;
  final double previousHealth;
  final double change;
  final DegradationTrend trend;
  final String prediction;
  final double confidence;

  DegradationResult({
    required this.componentId,
    required this.componentName,
    required this.currentHealth,
    required this.previousHealth,
    required this.change,
    required this.trend,
    required this.prediction,
    required this.confidence,
  });
}
