// =============================================================================
// SMART RAIL — Train ESP32  (Motor control + Dual MPU9250 + MQTT Vibration)
// =============================================================================
//
// HARDWARE
//   L298N  Motor 1: IN1=25, IN2=26
//   L298N  Motor 2: IN3=27, IN4=14
//   MPU9250 #1 (Motor 1): I2C addr 0x68  (AD0 → GND)
//   MPU9250 #2 (Motor 2): I2C addr 0x69  (AD0 → 3.3V)
//   I2C bus: SDA=21, SCL=22
//
// WIRELESS
//   ESP-NOW  → receives motor commands from controller ESP32
//   Wi-Fi STA → connects to AP for MQTT
//   MQTT     → publishes vibration JSON to broker.hivemq.com:1883
//
// MQTT TOPICS
//   rail/motor1/vibration
//   rail/motor2/vibration
//
// MQTT PAYLOAD (JSON, every VIBE_SAMPLE_INTERVAL ms while motor is active)
//   {"motor":1,"ax":0.012,"ay":-0.003,"az":0.981,"vibe":0.019,"alert":false}
//
// LIBRARY DEPENDENCIES (install via Arduino Library Manager)
//   - PubSubClient  by Nick O'Leary  (MQTT)
//
// CONFIGURATION — fill in before flashing
//   #define WIFI_SSID      "YOUR_SSID"
//   #define WIFI_PASSWORD  "YOUR_PASSWORD"
// =============================================================================

#include <WiFi.h>
#include <esp_now.h>
#include "esp_wifi.h"
#include <Wire.h>
#include <math.h>
#include <WebSocketsServer.h>   // Install: "arduinoWebSockets" by Markus Sattler

// =====================================
// USER CONFIGURATION
// =====================================

#define WIFI_SSID     "Somil's A35"       // <-- replace with your Wi-Fi SSID
#define WIFI_PASSWORD "somil@12"   // <-- replace with your Wi-Fi password

WebSocketsServer wsServer(81);  // WebSocket on port 81
float lastVib1 = 0.0;
float lastVib2 = 0.0;
float lastAx1=0, lastAy1=0, lastAz1=0;
float lastAx2=0, lastAy2=0, lastAz2=0;
unsigned long lastPublish = 0;

// =====================================
// L298N MOTOR PINS
// =====================================

#define IN1 25
#define IN2 26
#define IN3 27
#define IN4 14

// =====================================
// MPU9250 CONFIG
// =====================================
// Wire both sensors to the SAME I2C bus (SDA=21, SCL=22 on most ESP32 boards).
// Tie AD0 on sensor #1 to GND  -> address 0x68
// Tie AD0 on sensor #2 to 3.3V -> address 0x69

#define MPU1_ADDR 0x68   // sensor on Motor 1
#define MPU2_ADDR 0x69   // sensor on Motor 2

#define REG_PWR_MGMT_1   0x6B
#define REG_ACCEL_XOUT_H 0x3B
#define ACCEL_SENS       16384.0f   // LSB per g at default +/-2g range

// Vibration threshold in g — must match kVibrationThreshold in Flutter app
#define VIBRATION_THRESHOLD 0.914f

// How often to sample vibration (ms)
#define VIBE_SAMPLE_INTERVAL 100

unsigned long lastVibeCheck = 0;
unsigned long lastMqttReconnect = 0;

bool motor1Active = false;
bool motor2Active = false;

// (MQTT clients removed for direct HTTP mode)

// =====================================
// MOTOR 1
// =====================================

void motor1Stop() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  motor1Active = false;
}

void motor1Forward() {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  motor1Active = true;
}

void motor1Backward() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  motor1Active = true;
}

// =====================================
// MOTOR 2
// =====================================

void motor2Stop() {
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  motor2Active = false;
}

void motor2Forward() {
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
  motor2Active = true;
}

void motor2Backward() {
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
  motor2Active = true;
}

// =====================================
// STOP BOTH
// =====================================

void stopAllMotors() {
  motor1Stop();
  motor2Stop();
}

// =====================================
// MPU9250 HELPERS
// =====================================

void mpuWake(uint8_t addr) {
  Wire.beginTransmission(addr);
  Wire.write(REG_PWR_MGMT_1);
  Wire.write(0x00);
  Wire.endTransmission(true);
}

bool mpuReadAccelG(uint8_t addr, float &ax, float &ay, float &az) {
  Wire.beginTransmission(addr);
  Wire.write(REG_ACCEL_XOUT_H);
  if (Wire.endTransmission(false) != 0) {
    return false;
  }
  uint8_t received = Wire.requestFrom(addr, (uint8_t)6, (uint8_t)true);
  if (received != 6) {
    return false;
  }
  int16_t rawX = (Wire.read() << 8) | Wire.read();
  int16_t rawY = (Wire.read() << 8) | Wire.read();
  int16_t rawZ = (Wire.read() << 8) | Wire.read();
  ax = rawX / ACCEL_SENS;
  ay = rawY / ACCEL_SENS;
  az = rawZ / ACCEL_SENS;
  return true;
}

// Vibration = how far the acceleration magnitude deviates from 1g (gravity at rest)
float vibrationLevel(float ax, float ay, float az) {
  float magnitude = sqrtf(ax * ax + ay * ay + az * az);
  return fabsf(magnitude - 1.0f);
}

// =====================================
// WIFI HANDLER
// =====================================
void setupWiFi() {
  Serial.print("Connecting to Wi-Fi ");
  Serial.println(WIFI_SSID);
  
  // Clear previous saved Wi-Fi state just in case it's confused
  WiFi.disconnect(true);
  delay(100);

  // WIFI_STA only — NOT WIFI_AP_STA!
  // WIFI_AP_STA forces the single radio to switch channels between AP and hotspot,
  // which drops the WebSocket connection every ~2 seconds.
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  unsigned long startAttempt = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startAttempt < 20000) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("Wi-Fi connected. IP: ");
    Serial.println(WiFi.localIP());
    Serial.println(">>> ENTER THIS IP IN FLUTTER WEB APP <<<");
  } else {
    Serial.println("Wi-Fi connection failed or timeout. Continuing...");
  }
}

// =====================================
// WEBSOCKET SERVER
// =====================================

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  if (type == WStype_CONNECTED) {
    Serial.printf("[WS] Client #%u connected\n", num);
  } else if (type == WStype_DISCONNECTED) {
    Serial.printf("[WS] Client #%u disconnected\n", num);
  }
}

// Build and broadcast sensor JSON to all connected WS clients
void broadcastSensorData() {
  String json = "{";
  json += "\"m1_v\":" + String(lastVib1, 4) + ",";
  json += "\"m1_x\":" + String(lastAx1, 4) + ",";
  json += "\"m1_y\":" + String(lastAy1, 4) + ",";
  json += "\"m1_z\":" + String(lastAz1, 4) + ",";
  json += "\"m2_v\":" + String(lastVib2, 4) + ",";
  json += "\"m2_x\":" + String(lastAx2, 4) + ",";
  json += "\"m2_y\":" + String(lastAy2, 4) + ",";
  json += "\"m2_z\":" + String(lastAz2, 4);
  json += "}";
  wsServer.broadcastTXT(json);
}

// =====================================
// VIBRATION SAMPLE + PUBLISH
// =====================================

void checkAndPublishVibration(const char *label, int motorNum,
                              uint8_t addr, bool motorActive) {
  float ax, ay, az;
  if (!mpuReadAccelG(addr, ax, ay, az)) {
    Serial.print(label);
    Serial.println(": MPU9250 READ FAILED (check wiring/address)");
    return;
  }

  float vibe  = vibrationLevel(ax, ay, az);
  bool  alert = (vibe > VIBRATION_THRESHOLD);

  // Serial output (always)
  Serial.print(label);
  Serial.print(" | vibe: ");
  Serial.print(vibe, 4);
  Serial.print(" g");
  if (alert) {
    Serial.print("  <<< HIGH VIBRATION! (threshold ");
    Serial.print(VIBRATION_THRESHOLD, 3);
    Serial.print(" g)");
  }
  Serial.println();
}

// =====================================
// ESP-NOW RECEIVE
// =====================================

void receiveData(
  const esp_now_recv_info_t *info,
  const uint8_t *data,
  int len
) {
  if (len != 1) return;
  char command = data[0];

  Serial.print("RECEIVED: ");
  Serial.println(command);

  if      (command == 'A' || command == 'a') { motor2Stop();  motor1Forward();  Serial.println("MOTOR 1 FORWARD"); }
  else if (command == 'B' || command == 'b') { motor2Stop();  motor1Backward(); Serial.println("MOTOR 1 BACKWARD"); }
  else if (command == 'C' || command == 'c') { motor1Stop();  motor2Forward();  Serial.println("MOTOR 2 FORWARD"); }
  else if (command == 'D' || command == 'd') { motor1Stop();  motor2Backward(); Serial.println("MOTOR 2 BACKWARD"); }
  else if (command == 'S' || command == 's') { stopAllMotors(); Serial.println("STOP"); }
  else                                       { stopAllMotors(); Serial.println("UNKNOWN COMMAND"); }
}

// =====================================
// SETUP
// =====================================

void setup() {
  Serial.begin(115200);

  // Motor pins
  pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT);
  stopAllMotors();

  // I2C for the two MPU9250 sensors
  Wire.begin(21, 22);
  Wire.setClock(400000);
  mpuWake(MPU1_ADDR);
  mpuWake(MPU2_ADDR);

  // 4) Set up Wi-Fi and WebSocket Server
  setupWiFi();
  
  wsServer.begin();
  wsServer.onEvent(webSocketEvent);
  Serial.println("WebSocket server started on port 81");

  // ── ESP-NOW (after Wi-Fi, same radio, same channel) ─────────────────────
  if (esp_now_init() != ESP_OK) {
    Serial.println("ESP-NOW INIT FAILED!");
    while (true) delay(1000);
  }
  esp_now_register_recv_cb(receiveData);

  Serial.println();
  Serial.println("======================================");
  Serial.println("ESP32 MOTOR RECEIVER + VIBRATION WS");
  Serial.println("======================================");
  Serial.print("MAC: ");
  Serial.println(WiFi.macAddress());
  Serial.print("Vibration threshold: ");
  Serial.print(VIBRATION_THRESHOLD, 3);
  Serial.println(" g");
  Serial.println("WAITING FOR COMMANDS...");
}

// =====================================
// LOOP
// =====================================

unsigned long lastSensorRead = 0;

void loop() {
  // Process WebSocket events as fast as possible
  wsServer.loop();

  // Read Sensors every 50ms (20Hz) to prevent I2C bus lockup
  if (millis() - lastSensorRead >= 50) {
    lastSensorRead = millis();
    
    float ax1, ay1, az1;
    float ax2, ay2, az2;
    bool ok1 = mpuReadAccelG(MPU1_ADDR, ax1, ay1, az1);
    bool ok2 = mpuReadAccelG(MPU2_ADDR, ax2, ay2, az2);

    if (ok1) {
      lastAx1 = ax1; lastAy1 = ay1; lastAz1 = az1;
      lastVib1 = vibrationLevel(ax1, ay1, az1);
    }
    if (ok2) {
      lastAx2 = ax2; lastAy2 = ay2; lastAz2 = az2;
      lastVib2 = vibrationLevel(ax2, ay2, az2);
    }
  }

  // Broadcast to WebSockets every 500ms
  if (millis() - lastPublish >= 500) {
    lastPublish = millis();
    broadcastSensorData();
    
    Serial.print("Vib1="); Serial.print(lastVib1, 3);
    Serial.print(" | Vib2="); Serial.println(lastVib2, 3);
  }
}