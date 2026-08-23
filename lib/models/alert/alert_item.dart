enum AlertSeverity {
  info,
  warning,
  critical,
}

class AlertItem {
  final String id;
  final DateTime timestamp;
  final String trainId;
  final String componentId;
  final AlertSeverity severity;
  final String title;
  final String description;
  final String source;
  final bool isRead;

  AlertItem({
    required this.id,
    required this.timestamp,
    required this.trainId,
    required this.componentId,
    required this.severity,
    required this.title,
    required this.description,
    required this.source,
    this.isRead = false,
  });

  AlertItem copyWith({
    String? id,
    DateTime? timestamp,
    String? trainId,
    String? componentId,
    AlertSeverity? severity,
    String? title,
    String? description,
    String? source,
    bool? isRead,
  }) {
    return AlertItem(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      trainId: trainId ?? this.trainId,
      componentId: componentId ?? this.componentId,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      source: source ?? this.source,
      isRead: isRead ?? this.isRead,
    );
  }
}
