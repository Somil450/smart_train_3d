# RAIL-P.R.O.M.I.S.

**Predictive Rolling Stock Operations & Maintenance Intelligence System**

> **Smart monitoring. Early fault detection. Reliable operations.**

---

## 🚆 Overview

**RAIL-P.R.O.M.I.S.** is an IoT and AI-assisted railway rolling-stock health monitoring and predictive maintenance system designed to detect abnormal conditions in train components before they develop into serious failures.

The system combines **real-time hardware sensing, vibration analysis, temperature monitoring, visual inspection, GPS-based service-station awareness, risk prediction, and a Flutter monitoring dashboard**.

Instead of simply displaying sensor values, RAIL-P.R.O.M.I.S. converts equipment-condition data into actionable information such as:

* What component may be abnormal?
* How severe is the condition?
* What is the current risk level?
* Where is the train?
* Which maintenance/service station is closest?
* Should the operator continue monitoring or initiate maintenance?
* How can unexpected failures and resulting train delays be minimized?

---

# 🎯 Problem

Railway rolling stock contains multiple critical components such as:

* Wheels
* Axles
* Bearings
* Motors
* Suspension systems
* Braking components

Component degradation can initially appear as relatively small changes in **vibration or temperature**. If these changes are not identified early, they can eventually lead to equipment failure, unscheduled maintenance and operational disruption.

Traditional inspection approaches can also be periodic rather than continuously condition-driven.

### Our objective

> **Detect abnormal equipment behaviour early, estimate the associated risk, and provide operators with information required for timely maintenance decisions.**

---

# 💡 Our Solution
<img width="1566" height="888" alt="WhatsApp Image 2026-08-23 at 11 05 24" src="https://github.com/user-attachments/assets/aa90117a-1b6a-44b7-83df-5e353ad0bb80" />

RAIL-P.R.O.M.I.S. follows the pipeline:

```text
Physical Component
       ↓
IoT Sensors
       ↓
Real-Time Data
       ↓
Signal Analysis
       ↓
Fault / Anomaly Detection
       ↓
Risk Prediction
       ↓
Train Health Assessment
       ↓
GPS + Nearest Service Station
       ↓
Operator Alert / Maintenance Decision
```

The system is demonstrated using a controlled physical prototype where normal and abnormal wheel conditions can be reproduced.

---

# 🔧 Hardware Prototype

Our prototype contains:

### ESP32

Acts as the primary microcontroller responsible for:

* Sensor acquisition
* Processing
* Motor control
* Communication with the dashboard

### MPU-9250 / MPU-6500

Used for:

* X/Y/Z acceleration
* Vibration measurement
* Motion analysis
* Abnormal vibration detection

The system compares vibration behaviour between a **normal wheel condition** and a **rough/damaged wheel condition**.

### DS18B20

Used for temperature monitoring of the simulated axle.

A controlled heating mechanism is used to reproduce an **axle overheating condition**.

### Motor + Motor Driver

The motor provides controlled wheel rotation so that different wheel conditions can be demonstrated while collecting sensor data.

### ESP32-CAM

Used for visual inspection and future computer-vision-based component inspection.

### GPS Module

Provides the train's location, which is used to determine the nearest railway maintenance/service station.

---

# 🧪 Fault Demonstrations

## 1. Wheel Vibration Fault

Two wheel conditions are demonstrated:

### Normal wheel

```text
Smooth rotation
↓
Lower vibration
↓
Normal baseline
```

### Rough/Damaged wheel

```text
Irregular rotation
↓
Higher vibration
↓
Anomaly detected
↓
Risk increases
↓
Dashboard alert
```

The system receives the **actual vibration data from the physical prototype** and displays it in the Flutter dashboard.

---

## 2. Axle Overheating

A physical axle-like metal component is heated to simulate an overheating condition.

The DS18B20 continuously monitors the temperature.

The demonstration uses configurable temperature ranges:

```text
Normal
   ↓
Warning
   ↓
Critical
   ↓
Failure simulation
```

When the temperature reaches the configured critical condition, the system demonstrates a protective response by stopping motor operation.

> **Note:** The temperature values used in the prototype are demonstration thresholds and should be calibrated against real railway component specifications before real-world deployment.

---

# 📊 Real-Time Dashboard

The Flutter dashboard receives sensor information and displays:

* Live vibration
* Temperature
* Motor status
* Wheel condition
* Fault status
* Risk level
* GPS location
* Nearest service station
* Alerts
* Maintenance information

The goal is to provide the operator with a **single operational view instead of isolated sensor readings**.

---

# 🤖 Risk Prediction

The current prototype contains a **risk-prediction simulation engine** for demonstrating the AI workflow.

It supports scenarios such as:

* Normal condition
* Bearing fault
* Wheel fault
* Motor fault

The simulation generates changing telemetry and corresponding:

* Anomaly score
* Fault probability
* AI explanation
* Degradation trend
* Remaining Useful Life (RUL) demonstration

### Example

```text
Normal Condition
       ↓
Low anomaly score
       ↓
Fault introduced
       ↓
Vibration increases
       ↓
Anomaly score increases
       ↓
Risk prediction increases
       ↓
Operator alert
```

### Future production architecture

The current simulation layer can be replaced by a real ML backend:

```text
ESP32
 ↓
MQTT / WebSocket
 ↓
Python Backend
 ↓
Feature Extraction
 ↓
Isolation Forest / XGBoost
 ↓
Risk Prediction
 ↓
Flutter Dashboard
```

This allows the prototype to evolve from a demonstration system into a deployable predictive-maintenance architecture.

---

# 📍 GPS & Service Station Intelligence

The system also provides location-aware maintenance support.

The hardware sends:

```text
GPS Latitude
GPS Longitude
```

The application maintains a database of railway:

* Workshops
* Depots
* Sheds
* Service stations

The system calculates the distance between the train's current location and available service stations.

### Example

```text
Train T001
      ↓
GPS Location
      ↓
Service Station Database
      ↓
Distance Calculation
      ↓
Nearest Station
      ↓
Operator Recommendation
```

If the risk becomes critical, the dashboard can highlight the nearest available maintenance location.

This converts:

> **"Something is wrong."**

into:

> **"Something is wrong, the risk is high, and this is the nearest maintenance location."**

---

# ⭐ Key Innovation / Novelty

The individual technologies used in the project—IoT sensors, vibration monitoring, temperature monitoring, computer vision, predictive maintenance and GPS—are not individually new.

### Our differentiation is their integration into an operational workflow.

RAIL-P.R.O.M.I.S. combines:

```text
Real Hardware Data
       +
Component Condition
       +
Fault Detection
       +
Risk Prediction
       +
Location Awareness
       +
Maintenance Support
```

The system therefore moves beyond simple:

> **Sensor → Alert**

towards:

> **Detect → Diagnose → Predict Risk → Locate → Support Maintenance Decision**

### Major novelty areas

**1. Multimodal condition monitoring**

Combines vibration, temperature and visual information rather than relying on one measurement.

**2. Risk-oriented monitoring**

The dashboard does not only show raw sensor values; it converts abnormal behaviour into a risk representation.

**3. Location-aware maintenance support**

A high-risk train can be associated with its nearest maintenance/service station.

**4. Fault-to-operation connection**

The purpose of detecting the fault is not simply to display an alarm but to help reduce the possibility of unexpected failures and operational delays.

**5. Low-cost scalable architecture**

The prototype uses affordable embedded hardware and a modular software architecture that can be expanded to multiple trains and multiple component types.

---

# 💰 Cost Advantage

The prototype is designed around low-cost commercially available embedded hardware.

Our current prototype architecture demonstrates that railway-condition monitoring concepts can be prototyped at a significantly lower hardware cost than conventional industrial monitoring systems.

### Prototype cost comparison

| System                                 | Approximate cost |
| -------------------------------------- | ---------------: |
| Conventional industrial-style solution |         ₹30,000+ |
| RAIL-P.R.O.M.I.S. prototype            |      **~₹2,011** |

> The above figures represent the prototype/BOM comparison used in our demonstration and are **not a claim about the cost of a certified railway deployment**.

---

# 📈 Scalability

The architecture is modular.

The current prototype:

```text
1 ESP32
+
Wheel monitoring
+
Axle temperature
```

can be expanded to:

```text
Multiple sensors
       ↓
Multiple components
       ↓
Multiple coaches
       ↓
Multiple trains
       ↓
Fleet-level monitoring
```

Additional sensor nodes can monitor:

* Bearings
* Axles
* Motors
* Braking systems
* Suspension
* Wheels

The same dashboard and backend architecture can then process data from multiple rolling-stock assets.

---

# 🔄 Current vs Future System

### Currently demonstrated

✅ Physical wheel vibration monitoring
✅ Normal vs rough/damaged wheel demonstration
✅ Live ESP32 sensor data
✅ MPU vibration measurements
✅ DS18B20 temperature monitoring
✅ Controlled axle overheating demonstration
✅ Automatic motor stop at critical temperature
✅ Flutter dashboard
✅ Risk prediction simulation
✅ GPS location
✅ Nearest service-station calculation
✅ Alerts and visualization

### Next development stage

🔲 Replace simulated AI predictions with trained ML models
🔲 Real vibration/RPM normalization
🔲 Current/voltage monitoring
🔲 Automated computer-vision wheel inspection
🔲 Component-level fault classification
🔲 Real-world railway sensor calibration
🔲 Fleet-level predictive maintenance
🔲 Maintenance-block optimization

---

# 🏗️ System Architecture

```text
                PHYSICAL TRAIN PROTOTYPE
                         │
          ┌──────────────┼──────────────┐
          ↓              ↓              ↓
       Vibration     Temperature      Camera
        MPU-9250       DS18B20       ESP32-CAM
          │              │              │
          └──────────────┼──────────────┘
                         ↓
                       ESP32
                         │
                         ↓
                 Real-Time Telemetry
                         │
                ┌────────┴────────┐
                ↓                 ↓
             Dashboard        AI/Risk Engine
                │                 │
                │                 ↓
                │            Risk Prediction
                │                 │
                └────────┬────────┘
                         ↓
                   Operator Alert
                         │
                         ↓
                  GPS Location
                         │
                         ↓
              Nearest Service Station
                         │
                         ↓
                Maintenance Support
```

---

# 🚀 Why RAIL-P.R.O.M.I.S.?

The system aims to change railway maintenance from:

> **Reactive → Preventive → Predictive**

Instead of waiting for a component to fail:

```text
Abnormal behaviour
       ↓
Early detection
       ↓
Risk estimation
       ↓
Maintenance awareness
       ↓
Reduced unexpected downtime
       ↓
Improved rolling-stock availability
```

---

# 🏆 Hackathon Demonstration

The complete demonstration can be performed in a few steps:

### Step 1 — Normal operation

Run the normal wheel.

Dashboard shows:

🟢 Normal vibration
🟢 Normal temperature
🟢 Low risk

### Step 2 — Introduce wheel fault

Run the rough/damaged wheel.

Dashboard shows:

🟠 Increased vibration
🟠 Anomaly detected
🔴 Increased risk

### Step 3 — Introduce axle overheating

Heat the simulated axle.

Temperature rises:

```text
Normal → Warning → Critical
```

### Step 4 — Critical condition

Once the configured critical threshold is exceeded:

> 🔴 **AXLE CRITICAL — MOTOR STOPPED**

### Step 5 — Location intelligence

Dashboard displays:

> 📍 Current train location
> 🛠️ Nearest service station
> 📏 Distance

### Step 6 — Risk prediction

The system demonstrates how increasing component degradation can translate into increasing failure risk and maintenance urgency.

---

# 🎯 Final Objective

> **RAIL-P.R.O.M.I.S. aims to provide an affordable, scalable and intelligent condition-monitoring framework that detects abnormal rolling-stock behaviour early, predicts risk, identifies maintenance requirements and provides location-aware operational support—ultimately helping reduce unexpected failures, downtime and railway service delays.**

---

# 🔌 RAIL-P.R.O.M.I.S. — Complete Wiring

## 1. ESP32 ↔ MPU-9250/6500

Use I²C.

| MPU-9250/6500 | ESP32            |
| ------------- | ---------------- |
| VCC           | **3.3V**         |
| GND           | **GND**          |
| SDA           | **GPIO21 / D21** |
| SCL           | **GPIO22 / D22** |

```text
MPU-9250          ESP32

VCC  ──────────── 3.3V
GND  ──────────── GND
SDA  ──────────── GPIO21
SCL  ──────────── GPIO22
```

The MPU should be **firmly attached to the motor/gearbox/axle structure** whose vibration you are measuring.

---

## 2. ESP32 ↔ DS18B20

| DS18B20   | ESP32            |
| --------- | ---------------- |
| 🔴 Red    | **3.3V**         |
| ⚫ Black   | **GND**          |
| 🟡 Yellow | **GPIO12 / D12** |

### 4.7 kΩ resistor

```text
             4.7kΩ
3.3V ───────/\/\/\─────┐
                       │
DS18B20 Yellow ────────┼──── GPIO12
                       │
```

So:

**Yellow → GPIO12 directly**

and

**3.3V → 4.7kΩ → DATA/GPIO12**

The resistor is **not in series** between the sensor and GPIO12.

---

## 3. ESP32 ↔ L298N ↔ ONE MOTOR

Since you're currently using **only one motor**, use one channel of the L298N.

### Motor

| L298N | Motor        |
| ----- | ------------ |
| OUT1  | Motor wire 1 |
| OUT2  | Motor wire 2 |

Leave:

```text
OUT3 → UNUSED
OUT4 → UNUSED
```

### Control pins

Use:

| L298N | ESP32  |
| ----- | ------ |
| IN1   | GPIO26 |
| IN2   | GPIO27 |
| ENA   | GPIO25 |

So:

```text
ESP32              L298N

GPIO26 ─────────── IN1
GPIO27 ─────────── IN2
GPIO25 ─────────── ENA

                 OUT1 ───── Motor wire 1
                 OUT2 ───── Motor wire 2
```

### Direction logic

```text
IN1 = HIGH
IN2 = LOW
       ↓
Motor Forward
```

```text
IN1 = LOW
IN2 = HIGH
       ↓
Motor Reverse
```

```text
IN1 = LOW
IN2 = LOW
       ↓
Motor Stop
```

---

## 4. L298N POWER

**Do not power the motor from the ESP32 3.3V pin.**

Use your separate motor battery/supply.

```text
Battery + ───────── L298N +12V/VMS
Battery - ───────── L298N GND
```

And critically:

```text
ESP32 GND ───────── L298N GND
```

You need a **common ground** between the ESP32 and motor driver.

### Important

Your motor battery voltage must be appropriate for your particular DC gear motor and L298N.

---

## 5. IR SENSOR → RPM

When you add the IR sensor, use it to count wheel revolutions.

Assuming your IR module has:

**VCC / GND / OUT**

connect:

| IR sensor | ESP32      |
| --------- | ---------- |
| VCC       | 3.3V       |
| GND       | GND        |
| OUT       | **GPIO13** |

```text
IR Sensor          ESP32

VCC ────────────── 3.3V
GND ────────────── GND
OUT ────────────── GPIO13
```

Put **one reflective/white mark** on the wheel.

---

## 6. GPS → ESP32

For your **NEO-6M GPS**, use UART.

A convenient connection is:

| NEO-6M | ESP32                              |
| ------ | ---------------------------------- |
| VCC    | Appropriate supply for your module |
| GND    | GND                                |
| TX     | **GPIO16 (RX)**                    |
| RX     | **GPIO17 (TX)**                    |

Remember:

```text
GPS TX → ESP32 RX
GPS RX → ESP32 TX
```

Not TX-to-TX.

```text
NEO-6M              ESP32

TX ──────────────── GPIO16
RX ──────────────── GPIO17
GND ─────────────── GND
VCC ─────────────── appropriate VCC
```

---

## 7. ESP32-CAM

Your ESP32-CAM should be treated as the **visual inspection unit**.

It doesn't need to be wired into the motor driver's outputs.

Its role is:

```text
ESP32-CAM
    ↓
Camera image
    ↓
Wheel/component inspection
    ↓
OpenCV / image-processing pipeline
    ↓
Visible damage detection
```

For the prototype, position the camera so that the wheel passes through a **fixed inspection zone**.

---

## 8. Your final ESP32 pin map

I'd use this:

| ESP32 GPIO | Function     |
| ---------- | ------------ |
| **GPIO12** | DS18B20 DATA |
| **GPIO13** | IR RPM       |
| **GPIO16** | GPS RX       |
| **GPIO17** | GPS TX       |
| **GPIO21** | MPU SDA      |
| **GPIO22** | MPU SCL      |
| **GPIO25** | L298N ENA    |
| **GPIO26** | L298N IN1    |
| **GPIO27** | L298N IN2    |
