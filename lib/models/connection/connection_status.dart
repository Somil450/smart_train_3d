enum ConnectionStateEnum {
  connected,
  disconnected,
  connecting,
  error,
}

class SystemConnections {
  final ConnectionStateEnum sensor;
  final ConnectionStateEnum ai;
  final ConnectionStateEnum backend;
  final ConnectionStateEnum camera;
  final ConnectionStateEnum database;

  SystemConnections({
    this.sensor = ConnectionStateEnum.connected,
    this.ai = ConnectionStateEnum.connected,
    this.backend = ConnectionStateEnum.connected,
    this.camera = ConnectionStateEnum.connected,
    this.database = ConnectionStateEnum.connected,
  });

  SystemConnections copyWith({
    ConnectionStateEnum? sensor,
    ConnectionStateEnum? ai,
    ConnectionStateEnum? backend,
    ConnectionStateEnum? camera,
    ConnectionStateEnum? database,
  }) {
    return SystemConnections(
      sensor: sensor ?? this.sensor,
      ai: ai ?? this.ai,
      backend: backend ?? this.backend,
      camera: camera ?? this.camera,
      database: database ?? this.database,
    );
  }
}
