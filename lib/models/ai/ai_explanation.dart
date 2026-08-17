class EvidenceItem {
  final String description;
  final String changePercentage;
  final String significance;

  EvidenceItem({
    required this.description,
    required this.changePercentage,
    required this.significance,
  });
}

class AIExplanation {
  final String summary;
  final double confidence;
  final List<EvidenceItem> evidence;
  final String primarySignal;

  AIExplanation({
    required this.summary,
    required this.confidence,
    required this.evidence,
    required this.primarySignal,
  });
}
