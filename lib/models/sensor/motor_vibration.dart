// Motor vibration payload — matches JSON published by ESP32 over MQTT.
// Topic: rail/motor1/vibration  and  rail/motor2/vibration
// Payload: { "motor":1, "ax":0.012, "ay":-0.003, "az":0.981, "vibe":0.019, "alert":false }

class MotorVibrationPayload {
  final int motor;           // 1 or 2
  final double ax;           // raw X accelerometer (g)
  final double ay;           // raw Y accelerometer (g)
  final double az;           // raw Z accelerometer (g)
  final double vibe;         // |magnitude - 1g|  (vibration level in g)
  final bool alert;          // true when vibe > VIBRATION_THRESHOLD
  final DateTime timestamp;

  const MotorVibrationPayload({
    required this.motor,
    required this.ax,
    required this.ay,
    required this.az,
    required this.vibe,
    required this.alert,
    required this.timestamp,
  });

  factory MotorVibrationPayload.fromJson(Map<String, dynamic> json) {
    return MotorVibrationPayload(
      motor: (json['motor'] as num).toInt(),
      ax:    (json['ax']    as num).toDouble(),
      ay:    (json['ay']    as num).toDouble(),
      az:    (json['az']    as num).toDouble(),
      vibe:  (json['vibe']  as num).toDouble(),
      alert: json['alert']  as bool,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'Motor$motor  vibe=${vibe.toStringAsFixed(4)}g  alert=$alert';
}
