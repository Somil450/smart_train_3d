# Smart Rail AI 🚆

Smart Rail AI is an advanced, real-time IoT and Artificial Intelligence monitoring system for railway trains. This repository contains the complete stack, including ESP32-based hardware controllers for train operation, real-time vibration sensing, and a high-performance Flutter-based web dashboard.

---

## 🛠️ System Architecture

The project is split into three primary components:

### 1. Train ESP32 (Hardware/Train)
File: `train+mpu9250.c`
- Controls the train's dual motor drivers (L298N) via ESP-NOW wireless commands.
- Constantly reads dual **MPU9250** 9-axis IMU sensors via I2C at 20Hz.
- Calculates dynamic vibration deviations from 1g (gravity).
- Hosts a high-speed **WebSocket Server** on port 81 to stream live JSON vibration telemetry directly to the dashboard.

### 2. Remote Control ESP32 (Hardware/Controller)
File: `controller.c`
- Features 4 push buttons (Forward, Backward, Left, Right).
- Synchronizes Wi-Fi channels dynamically to establish a peer-to-peer **ESP-NOW** connection with the Train ESP32.
- Sends instant motor state commands to control the train remotely with zero latency.

### 3. Smart Rail AI Dashboard (Software/Flutter)
Directory: `lib/`
- A premium, responsive Flutter Web application.
- Connects to the hardware via a local Node.js proxy to bypass strict browser Private Network Access (PNA) security policies.
- Visualizes real-time telemetry, historical trend graphs, AI-predicted fault diagnostics, and train health metrics.

---

## 🚀 How to Run the Project

Follow these steps to launch the entire system end-to-end:

### Step 1: Hardware Setup
1. Open the Arduino IDE.
2. Ensure both ESP32 boards are powered on.
3. Upload `train+mpu9250.c` to the **Train ESP32**.
4. Upload `controller.c` to the **Remote Control ESP32**.
5. *Important*: Both files are configured to connect to your mobile hotspot (SSID: `Somil's A35`). This is required so both ESP32s operate on the exact same Wi-Fi channel for ESP-NOW to function.

### Step 2: Start the Node.js WebSocket Proxy
Modern web browsers (like Chrome) block local web apps from connecting directly to private IP addresses. We use a lightweight Node.js proxy to bridge this gap.

```bash
# Install dependencies (only needed the first time)
npm install

# Start the proxy server
node ws_proxy.js
```
*The proxy will connect to the Train ESP32 and expose the stream on `ws://localhost:8081`.*

### Step 3: Launch the Flutter Web Dashboard
Run the Flutter dashboard locally:

```bash
# Run flutter on Chrome with a specific port
flutter run -d chrome --web-port 8080
```
*Open `http://localhost:8080` in your browser. The dashboard will automatically connect to the proxy and stream data instantly.*

---

## 📂 Repository Structure

* `train+mpu9250.c` : Firmware for the primary train unit (Motors + Sensors + WebSocket Server).
* `controller.c` : Firmware for the wireless remote controller (Buttons + ESP-NOW Transmitter).
* `ws_proxy.js` : Node.js bridge to route WebSocket traffic between the ESP32 and the Web App.
* `lib/` : The complete Dart source code for the Flutter Web application.
* `package.json` : Node.js dependencies for the proxy.
* `pubspec.yaml` : Flutter project configuration and dependencies.

---

## 🔧 Troubleshooting

- **No Vibration Data / Proxy ETIMEDOUT**: The Train ESP32's IP address may have changed. Check the Arduino Serial Monitor for the Train ESP32 to get the new IP address, and update `ESP32_WS_URL` inside `ws_proxy.js`.
- **Motors Not Working**: Ensure the Controller ESP32 successfully connected to the Wi-Fi. Check its Serial Monitor for the `Channel Synced` message. If it fails to sync the channel, ESP-NOW commands will not reach the train.
