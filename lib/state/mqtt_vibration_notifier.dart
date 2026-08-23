import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/sensor/motor_vibration.dart';
import '../services/mqtt/mqtt_service.dart'; // Keep for enum only

/// Connects to ESP32 over WebSocket (ws://[ip]:81)
/// The ESP32 pushes sensor JSON every 500ms.
/// Includes a 4-second watchdog — if no data arrives, auto-reconnects.
class MqttVibrationNotifier extends ChangeNotifier {
  static const String esp32Ip   = "127.0.0.1";  // Node.js proxy on localhost
  static const int    esp32Port = 8081;          // Proxy forwards to ESP32 at 10.89.142.193:81

  MotorVibrationPayload? _motor1Latest;
  MotorVibrationPayload? _motor2Latest;
  final List<MotorVibrationPayload> _motor1History = [];
  final List<MotorVibrationPayload> _motor2History = [];
  AppMqttConnectionState _connectionState = AppMqttConnectionState.disconnected;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _watchdog;      // fires if no data for 4s → force reconnect
  Timer? _retryTimer;    // delayed reconnect
  bool _disposed = false;

  MqttVibrationNotifier(MqttService ignored);

  AppMqttConnectionState get connectionState => _connectionState;
  MotorVibrationPayload? get motor1Latest => _motor1Latest;
  MotorVibrationPayload? get motor2Latest => _motor2Latest;
  List<MotorVibrationPayload> get motor1History => List.unmodifiable(_motor1History);
  List<MotorVibrationPayload> get motor2History => List.unmodifiable(_motor2History);
  bool get motor1Alert => _motor1Latest?.alert ?? false;
  bool get motor2Alert => _motor2Latest?.alert ?? false;
  bool get anyAlert    => motor1Alert || motor2Alert;

  Future<void> init() async {
    _setConnectionState(AppMqttConnectionState.connecting);
    _connect();
  }

  void _connect() {
    if (_disposed) return;

    // Clean up any old connection first
    _sub?.cancel();
    _sub = null;
    try { _channel?.sink.close(); } catch (_) {}
    _channel = null;

    try {
      debugPrint('[WS] Connecting to ws://$esp32Ip:$esp32Port ...');
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$esp32Ip:$esp32Port'),
      );

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          debugPrint('[WS] Error: $e');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('[WS] Connection closed — reconnecting');
          _scheduleReconnect();
        },
        cancelOnError: false,
      );

      // Start watchdog — if nothing received in 4s, reconnect
      _resetWatchdog();

    } catch (e) {
      debugPrint('[WS] Connect exception: $e');
      _scheduleReconnect();
    }
  }

  double _motor2Temp = 0.0;
  String _motor2TempStatus = 'NORMAL'; // NORMAL / DANGER / CRITICAL

  double get motor2Temp => _motor2Temp;
  String get motor2TempStatus => _motor2TempStatus;
  bool get motor2TempDanger   => _motor2Temp >= 50.0 && _motor2Temp < 80.0;
  bool get motor2TempCritical => _motor2Temp >= 80.0;

  void _onMessage(dynamic raw) {
    if (_disposed) return;
    _resetWatchdog(); // got data, reset the watchdog timer

    try {
      final String jsonString = raw.toString();
      final data = jsonDecode(jsonString);

      final double v1  = (data['m1_v'] as num?)?.toDouble() ?? 0.0;
      final double ax1 = (data['m1_x'] as num?)?.toDouble() ?? 0.0;
      final double ay1 = (data['m1_y'] as num?)?.toDouble() ?? 0.0;
      final double az1 = (data['m1_z'] as num?)?.toDouble() ?? 0.0;
      final double v2  = (data['m2_v'] as num?)?.toDouble() ?? 0.0;
      final double ax2 = (data['m2_x'] as num?)?.toDouble() ?? 0.0;
      final double ay2 = (data['m2_y'] as num?)?.toDouble() ?? 0.0;
      final double az2 = (data['m2_z'] as num?)?.toDouble() ?? 0.0;

      _motor2Temp       = (data['m2_t'] as num?)?.toDouble() ?? _motor2Temp;
      _motor2TempStatus = (data['m2_ts'] as String?) ?? _motor2TempStatus;

      final now = DateTime.now();
      final p1 = MotorVibrationPayload(motor: 1, ax: ax1, ay: ay1, az: az1, vibe: v1, alert: v1 > kVibrationThreshold, timestamp: now);
      final p2 = MotorVibrationPayload(motor: 2, ax: ax2, ay: ay2, az: az2, vibe: v2, alert: v2 > kVibrationThreshold, timestamp: now);

      _motor1Latest = p1;
      _motor1History.add(p1);
      if (_motor1History.length > 300) _motor1History.removeAt(0);

      _motor2Latest = p2;
      _motor2History.add(p2);
      if (_motor2History.length > 300) _motor2History.removeAt(0);

      _setConnectionState(AppMqttConnectionState.connected);
      notifyListeners();

    } catch (e, stack) {
      debugPrint('[WS] Parse error: $e\nStack: $stack\nraw=$raw');
    }
  }

  // Watchdog: if no message in 4 seconds, assume dead → reconnect
  void _resetWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 4), () {
      debugPrint('[WS] Watchdog fired — no data for 4s, reconnecting...');
      _setConnectionState(AppMqttConnectionState.error);
      _connect(); // reconnect immediately (no delay)
    });
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _watchdog?.cancel();
    _setConnectionState(AppMqttConnectionState.error);
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 2), _connect);
  }

  void _setConnectionState(AppMqttConnectionState s) {
    if (_connectionState != s) {
      _connectionState = s;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _watchdog?.cancel();
    _retryTimer?.cancel();
    _sub?.cancel();
    try { _channel?.sink.close(); } catch (_) {}
    super.dispose();
  }
}
