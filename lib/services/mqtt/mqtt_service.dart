import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

import '../../../models/sensor/motor_vibration.dart';

// ---------------------------------------------------------------------------
// MQTT service — connects to HiveMQ public broker over WebSocket (port 8000).
// Browsers cannot use raw TCP MQTT, so we use the WS endpoint.
//
// Topics subscribed:
//   rail/motor1/vibration
//   rail/motor2/vibration
//
// Payload (JSON published by ESP32 every 100ms):
//   {"motor":1,"ax":0.012,"ay":-0.003,"az":0.981,"vibe":0.019,"alert":false}
// ---------------------------------------------------------------------------

/// Vibration threshold — must match #define VIBRATION_THRESHOLD in ESP32 .c file.
const double kVibrationThreshold = 0.914;

enum MqttConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class MqttService {
  // Local Node.js Aedes broker — plain WebSocket on port 9001
  // Chrome allows plain WS (non-TLS) for localhost connections.
  static const String _wsUrl  = 'ws://127.0.0.1';
  static const int    _wsPort = 9001;

  static const String _topic1 = 'rail/motor1/vibration';
  static const String _topic2 = 'rail/motor2/vibration';

  final _controller = StreamController<MotorVibrationPayload>.broadcast();

  MqttBrowserClient? _client;
  Timer? _simulationTimer;
  Timer? _reconnectTimer;

  MqttConnectionState _state = MqttConnectionState.disconnected;
  MqttConnectionState get connectionState => _state;

  Stream<MotorVibrationPayload> get vibrationStream => _controller.stream;

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> connect() async {
    _setState(MqttConnectionState.connecting);
    await _connectReal();
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _simulationTimer?.cancel();
    _client?.disconnect();
    if (!_controller.isClosed) await _controller.close();
    _setState(MqttConnectionState.disconnected);
  }

  // ── Real MQTT over WebSocket ───────────────────────────────────────────────

  Future<void> _connectReal() async {
    final clientId =
        'smartrail_${DateTime.now().millisecondsSinceEpoch % 100000}';

    _client = MqttBrowserClient(_wsUrl, clientId)
      ..port = _wsPort
      ..keepAlivePeriod = 20
      ..connectTimeoutPeriod = 15000
      ..autoReconnect = false
      ..websocketProtocols = MqttClientConstants.protocolsSingleDefault
      ..logging(on: false)
      ..onConnected    = _onConnected
      ..onDisconnected = _onDisconnected;

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMsg;

    try {
      await _client!.connect();
    } catch (e) {
      // ignore: avoid_print
      print('[MQTT] Connect error: $e — falling back to simulation');
      _startSimulation();
      return;
    }

    if (_client!.connectionStatus?.state != MqttConnectionState.connected) {
      // ignore: avoid_print
      print('[MQTT] Unexpected state — falling back to simulation');
      _startSimulation();
      return;
    }

    // Subscribe
    _client!.subscribe(_topic1, MqttQos.atLeastOnce);
    _client!.subscribe(_topic2, MqttQos.atLeastOnce);

    // Listen for incoming messages
    _client!.updates?.listen(_onMessage);
  }

  void _onConnected() {
    // ignore: avoid_print
    print('[MQTT] Connected to broker');
    _simulationTimer?.cancel(); // stop simulation if it was running
    _setState(MqttConnectionState.connected);
  }

  void _onDisconnected() {
    // ignore: avoid_print
    print('[MQTT] Disconnected');
    _setState(MqttConnectionState.disconnected);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage?>> events) {
    for (final event in events) {
      final recMsg = event.payload as MqttPublishMessage;
      final raw = MqttPublishPayload.bytesToStringAsString(
          recMsg.payload.message);
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        if (!_controller.isClosed) {
          _controller.add(MotorVibrationPayload.fromJson(json));
        }
      } catch (e) {
        // ignore: avoid_print
        print('[MQTT] Bad payload: $raw  err=$e');
      }
    }
  }

  // ── Simulation fallback ────────────────────────────────────────────────────
  // Provides realistic synthetic data while hardware is offline.

  void _startSimulation() {
    _setState(MqttConnectionState.connected); // green badge = "sim connected"
    final rng = Random();
    int tick = 0;

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      tick++;
      final t = tick * 0.12;

      // Motor 1
      final ax1 = 0.01 * sin(t * 3.1) + rng.nextDouble() * 0.008;
      final ay1 = 0.01 * cos(t * 2.3) + rng.nextDouble() * 0.006;
      final az1 = 0.98 + 0.005 * sin(t * 5.7) + rng.nextDouble() * 0.004;
      final mag1 = sqrt(ax1 * ax1 + ay1 * ay1 + az1 * az1);
      final vibe1 = (mag1 - 1.0).abs();
      if (!_controller.isClosed) {
        _controller.add(MotorVibrationPayload(
          motor: 1,
          ax: ax1, ay: ay1, az: az1,
          vibe: vibe1,
          alert: vibe1 > kVibrationThreshold,
          timestamp: DateTime.now(),
        ));
      }

      // Motor 2
      final ax2 = 0.015 * sin(t * 4.2) + rng.nextDouble() * 0.012;
      final ay2 = 0.012 * cos(t * 3.8) + rng.nextDouble() * 0.009;
      final az2 = 0.97 + 0.008 * sin(t * 6.1) + rng.nextDouble() * 0.006;
      final mag2 = sqrt(ax2 * ax2 + ay2 * ay2 + az2 * az2);
      final vibe2 = (mag2 - 1.0).abs();
      if (!_controller.isClosed) {
        _controller.add(MotorVibrationPayload(
          motor: 2,
          ax: ax2, ay: ay2, az: az2,
          vibe: vibe2,
          alert: vibe2 > kVibrationThreshold,
          timestamp: DateTime.now(),
        ));
      }
    });
  }

  void _setState(MqttConnectionState s) {
    _state = s;
  }
}
