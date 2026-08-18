#include <WiFi.h>
#include <esp_now.h>
#include "esp_wifi.h"

#define RED1    32
#define BLACK1  33
#define RED2    18
#define BLACK2  19

uint8_t receiverAddress[] = {
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
};

void sendCommand(char command) {
  esp_now_send(receiverAddress, (uint8_t *)&command, 1);

  Serial.print("SENT: ");
  Serial.println(command);
}

void setup() {

  Serial.begin(115200);

  pinMode(RED1, INPUT_PULLUP);
  pinMode(BLACK1, INPUT_PULLUP);
  pinMode(RED2, INPUT_PULLUP);
  pinMode(BLACK2, INPUT_PULLUP);

  // Clear previous saved Wi-Fi state just in case it's confused
  WiFi.disconnect(true);
  delay(100);

  // Connect to the SAME Wi-Fi hotspot so the ESP32 radio synchronizes
  // to the EXACT same Wi-Fi channel as the train ESP32.
  // Without this, ESP-NOW will fail because they are on different channels!
  WiFi.mode(WIFI_STA);
  WiFi.begin("Somil's A35", "somil@12");
  
  Serial.print("Connecting to Wi-Fi to sync channel...");
  unsigned long startAttempt = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startAttempt < 20000) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Channel Synced: ");
  Serial.println(WiFi.channel());

  if (esp_now_init() != ESP_OK) {
    Serial.println("ESP-NOW ERROR");
    return;
  }

  esp_now_peer_info_t peer = {};
  memcpy(peer.peer_addr, receiverAddress, 6);
  peer.channel = 0; // 0 means use the current Wi-Fi channel
  peer.encrypt = false;

  esp_now_add_peer(&peer);

  Serial.println("CONTROLLER READY");
}

void loop() {

  if (digitalRead(RED1) == LOW) {
    sendCommand('A');
  }
  else if (digitalRead(BLACK1) == LOW) {
    sendCommand('B');
  }
  else if (digitalRead(RED2) == LOW) {
    sendCommand('C');
  }
  else if (digitalRead(BLACK2) == LOW) {
    sendCommand('D');
  }
  else {
    sendCommand('S');
  }

  delay(100);
}